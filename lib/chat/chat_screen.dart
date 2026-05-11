import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_boat_ownerside/controller/app_footer.dart';
import '../helper/apis.dart';
import '../helper/my_date_util.dart';
import '../model/chat_user.dart';
import '../model/message.dart';
import '../controller/app_color.dart';
import '../controller/app_config_provider.dart';
import '../controller/app_constant.dart';
import '../controller/app_image.dart';
import '../controller/app_language.dart';
import '../controller/app_snack_bar_toast_message.dart';
import '../view/authentication/login_screen.dart';
import 'message_card.dart';
import 'profile_image.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = []; // for storing all messages
  XFile? _imageSelect;
  String _selectedImagePath = '';
  String _fileName = 'NA';
  bool _isApiCalling = false;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _latestMessagesSubscription;
  DocumentSnapshot<Map<String, dynamic>>? _lastFetchedDoc;
  bool _hasMoreMessages = true;
  bool _isFetchingMore = false;
  bool _isInitialLoadingMessages = true;
  String? _conversationId;
  final int _messagesPageSize = 30;
  final TextEditingController _textController = TextEditingController();
  bool _showEmoji = false; // showEmoji -- for storing value of showing or hiding emoji
  bool _isUploading = false; // isUploading -- for checking if image is uploading or not?
  int _userId = 0;
  dynamic _data;
  dynamic _userDataArr;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    _initMessagesPagination();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initMessagesPagination() async {
    _conversationId = await APIs.resolveConversationId(widget.user.id);
    await _loadInitialMessages();
    final String? conversationId = _conversationId;
    if (conversationId == null || conversationId.isEmpty) return;
    _latestMessagesSubscription = APIs
        .getLatestMessagesByConversationId(conversationId, limit: _messagesPageSize)
        .listen((snapshot) => _mergeMessageDocs(snapshot.docs));
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadInitialMessages() async {
    try {
      final String? conversationId = _conversationId;
      if (conversationId == null || conversationId.isEmpty) {
        _hasMoreMessages = false;
        return;
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot =
      await APIs.getMessagesPageByConversationId(
        conversationId,
        limit: _messagesPageSize,
        startAfter: null,
      );
      if (snapshot.docs.isNotEmpty) {
        _lastFetchedDoc = snapshot.docs.last;
      }
      _hasMoreMessages = snapshot.docs.length == _messagesPageSize;
      _mergeMessageDocs(snapshot.docs);
    }
    finally {
      if (mounted) {
        setState(() => _isInitialLoadingMessages = false);
      }
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isFetchingMore || !_hasMoreMessages) return;
    if (_lastFetchedDoc == null) return;

    setState(() => _isFetchingMore = true);
    try {
      final String? conversationId = _conversationId;
      if (conversationId == null || conversationId.isEmpty) {
        _hasMoreMessages = false;
        return;
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot =
      await APIs.getMessagesPageByConversationId(
        conversationId,
        limit: _messagesPageSize,
        startAfter: _lastFetchedDoc,
      );
      if (snapshot.docs.isNotEmpty) {
        _lastFetchedDoc = snapshot.docs.last;
      }
      if (snapshot.docs.length < _messagesPageSize) {
        _hasMoreMessages = false;
      }
      _mergeMessageDocs(snapshot.docs);
    }
    finally {
      if (mounted) {
        setState(() => _isFetchingMore = false);
      }
    }
  }

  void _mergeMessageDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    if (!mounted) return;

    final Map<String, Message> merged = {
      for (final Message m in _list) m.sent: m,
    };

    for (final QueryDocumentSnapshot<Map<String, dynamic>> d in docs) {
      final Message m = Message.fromJson(d.data());
      merged[m.sent] = m;
    }

    final List<Message> updated = merged.values.toList()
      ..sort((a, b) {
        final int ai = int.tryParse(a.sent) ?? 0;
        final int bi = int.tryParse(b.sent) ?? 0;
        return bi.compareTo(ai);
      });

    setState(() => _list = updated);
  }

  @override
  void dispose() {
    _latestMessagesSubscription?.cancel();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<dynamic> _getUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _data = prefs.getString("userDetails");

    // print("userDetails $userDetails");
    if (_data == null) {
      // print("worked");
      SnackBarToastMessage.showSnackBar(context, AppLanguage.notRegisteredMsg[language]);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
    }
    else {
      _userDataArr = jsonDecode(_data);
      _userId = _userDataArr['user_id'] ?? 0;
    }

    // print("userDataArr $userDataArr");;
    _isApiCalling = false;
    _setActiveStatus();
    _getActiveStatus();
    setState(() {});
  }

  Future<void> _setActiveStatus() async {
    setState(() => _isApiCalling = true);
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}user_chat_status");
    String token = AppConstant.token;
    print("Url===> $url");

    try {
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      Map<String, String> body = {
        'user_id': _userId.toString(),
        'other_user_id': widget.user.id.toString(),
      };

      print("body $body");

      http.Response response = await http.post(url, headers: headers, body: body);
      print("response--> $response");
      var res = jsonDecode(response.body);

      print("res333 : $res");

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          // log("Status True");
          setState(() => _isApiCalling = false);
        }
        else {
          // ignore: use_build_context_synchronously
          setState(() => _isApiCalling = false);
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          if (res['active_status'] == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
          }
        }
      }
      else {
        setState(() => _isApiCalling = false);
      }
    }
    catch (e) {
      setState(() => _isApiCalling = false);
    }
  }

  Future<void> _getActiveStatus() async {
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}get_active_status?user_id=$_userId&other_user_id=${widget.user.id}");
    print("urlrttt $url");

    String token = AppConstant.token;

    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token', // Use 'Bearer' if required
    };

    setState(() => _isApiCalling = true);

    print("headers $headers");

    try {
      final http.Response response = await http.get(url, headers: headers);
      print("response $response");

      if (response.statusCode == 200) {
        // log("APiStatus200 $isActive");
        dynamic res = jsonDecode(response.body);
        print("res $res");

        if (res['success'] == true) {
          _isActive = res['status'];
          log("APiStatus $_isActive");
          setState(() => _isApiCalling = false);
        }
        else {
          setState(() => _isApiCalling = false);
          // ignore: use_build_context_synchronously
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          if (res['active_status'] == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
          }
        }
      }
      else {
        setState(() => _isApiCalling = false);
      }
    }
    catch (e) {
      setState(() => _isApiCalling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    return WillPopScope(
      onWillPop: () {
        if (_showEmoji) {
          setState(() => _showEmoji = false);
          return Future.value(false);
        }
        else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyFooterPage(indexOfPage: 2)));
          return Future.value(true);
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus;
          setState(() => _showEmoji = false);
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              StreamBuilder(
                stream: APIs.getUserInfo(widget.user),
                builder: (context, snapshot) {
                  final List<QueryDocumentSnapshot<Map<String, dynamic>>>? data = snapshot.data?.docs;
                  final List<ChatUser> list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                  return Container(
                    width: MediaQuery.of(context).size.width * 100 / 100,
                    height: MediaQuery.of(context).size.height * 14 / 100,
                    decoration: const BoxDecoration(
                      color: AppColor.themeColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height:
                          MediaQuery.of(context).size.height * 6 / 100,
                        ),
                        Row(
                          children: [
                            //back button
                            IconButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const MyFooterPage(indexOfPage: 2),
                                ),
                              ),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),

                            //user profile picture
                            ProfileImage(
                              size: MediaQuery.of(context).size.height * .05,
                              url: list.isNotEmpty ? list[0].image : widget.user.image,
                            ),

                            //for adding some space
                            const SizedBox(width: 10),

                            //user name & last seen time
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //user name
                                Text(
                                  list.isNotEmpty ? list[0].name : widget.user.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                //for adding some space
                                const SizedBox(height: 2),

                                //last seen time of user
                                Text(
                                  list.isNotEmpty ? list[0].isOnline ? 'Online' : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive:
                                    list[0].lastActive,
                                  ) : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive:
                                    widget.user.lastActive,
                                  ),
                                  style: const TextStyle(fontSize: 13, color: Colors.white),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 2 / 100,
              ),
              Expanded(
                child: _isInitialLoadingMessages ? const SizedBox() : _list.isEmpty ? const Center(
                  child: Text('Say Hii! 👋', style: TextStyle(fontSize: 20)),
                ) : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: _list.length + 1,
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .01),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (index == _list.length) {
                      if (_isFetchingMore) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return const SizedBox(height: 12);
                    }
                    return MessageCard(message: _list[index]);
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .01,
              ),

              //progress indicator for showing uploading
              if (_isUploading) const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),

              //chat input filed
              _chatInput(screenWidth),
              SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),

              //show emojis on keyboard emoji button click & vice versa
              if (_showEmoji)SizedBox(
                height: MediaQuery.of(context).size.height * .35,
                child: EmojiPicker(
                  textEditingController: _textController,
                  config: const Config(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return SafeArea(
      child: InkWell(
        onTap: () {},
        child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final List<QueryDocumentSnapshot<Map<String, dynamic>>>? data = snapshot.data?.docs;
            final List<ChatUser> list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Container(
              width: MediaQuery.of(context).size.width * 100 / 100,
              height: MediaQuery.of(context).size.height * 7 / 100,
              //color: Colors.amberAccent,
              decoration: BoxDecoration(
                color: Colors.white, // Background color of the container
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Shadow color
                    blurRadius: 4, // Blur radius of the shadow
                    offset: Offset(0, 1), // Offset for bottom shadow
                  ),
                ],
              ),
              child: Row(
                children: [
                  //back button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),

                  //user profile picture
                  ProfileImage(
                    size: MediaQuery.of(context).size.height * .05,
                    url: list.isNotEmpty ? list[0].image : widget.user.image,
                  ),

                  //for adding some space
                  const SizedBox(width: 10),

                  //user name & last seen time
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //user name
                      Text(
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: const TextStyle(
                          fontSize: 16, color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      //for adding some space
                      const SizedBox(height: 2),

                      //last seen time of user
                      Text(
                        list.isNotEmpty ? list[0].isOnline ? 'Online' : MyDateUtil.getLastActiveTime(
                          context: context,
                          lastActive: list[0].lastActive,
                        ) : MyDateUtil.getLastActiveTime(
                          context: context,
                          lastActive: widget.user.lastActive,
                        ),
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _chatInput(screenWidth) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.secondaryColor,
        boxShadow: [
          BoxShadow(
            color: AppColor.textLightColor, // Shadow color
            blurRadius: 5.0, // Blur intensity
            offset: Offset(0, -4), // Moves shadow 5px down
          ),
        ],
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 10 / 100,
      alignment: Alignment.center,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 90 / 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 80 / 100,
              height: MediaQuery.of(context).size.height * 6.5 / 100,
              child: TextFormField(
                readOnly: false,
                style: const TextStyle(
                  height: 1.1,
                  color: AppColor.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.text,
                controller: _textController,
                maxLength: AppConstant.describeLength,
                onTap: () => setState(() => _showEmoji = false),
                decoration: InputDecoration(
                  prefixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          setState(() => _showEmoji = true);
                        },
                        child: SizedBox(
                          child: Image.asset(
                            AppImage.smileIcon,
                            width: screenWidth > 600 ? MediaQuery.of(context).size.width * 4 / 100 : MediaQuery.of(context).size.width * 5 / 100,
                            height: screenWidth > 600 ? MediaQuery.of(context).size.width * 4 / 100 : MediaQuery.of(context).size.width * 5 / 100,
                          ),
                        ),
                      ),
                    ],
                  ),
                  suffixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() => _showEmoji = false);
                          FocusScope.of(context).unfocus();
                          _imagePickerBottomSheet();
                        },
                        child: SizedBox(
                          child: Image.asset(
                            AppImage.clipImage,
                            width: screenWidth > 600 ? MediaQuery.of(context).size.width * 4 / 100 : MediaQuery.of(context).size.width * 5 / 100,
                            height: screenWidth > 600 ? MediaQuery.of(context).size.width * 4 / 100 : MediaQuery.of(context).size.width * 5 / 100,
                          ),
                        ),
                      ),
                    ],
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.boaderColor),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.boaderColor),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.themeColor),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  fillColor: AppColor.secondaryColor,
                  filled: true,
                  counterText: '',
                  hintText: AppLanguage.messageText[language],
                  hintStyle: const TextStyle(
                    color: AppColor.textColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_textController.text.isNotEmpty) {
                  if (_list.isEmpty) {
                    //on first message (add user to my_user collection of chat user)
                    APIs.sendFirstMessage(widget.user, _textController.text, TypeEnum.text, _isActive);
                  }
                  else {
                    //simply send message
                    APIs.sendMessage(widget.user, _textController.text, TypeEnum.text, _isActive);
                  }
                  _textController.text = '';
                }
              },
              child: SizedBox(
                width: screenWidth > 600 ? MediaQuery.of(context).size.width * 4 / 100 : MediaQuery.of(context).size.width * 6 / 100,
                height: screenWidth > 600 ? MediaQuery.of(context).size.width * 4 / 100 : MediaQuery.of(context).size.width * 6 / 100,
                child: Image.asset(
                  AppImage.sendImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _imagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text(AppLanguage.photoGalleryText[language]),
                onTap: () {
                  _imgFromGallery();
                  setState(() {});
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text(AppLanguage.cameraText[language]),
                onTap: () {
                  _imgFromCamera();
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _imgFromCamera() async {
    dynamic image = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50);
    if (image != null) {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _imageSelect = image;
          _fileName = image.path;
          //  var _btnActive = true;
        });
        sendImageApiCall();
      });
    } else {
      setState(() {
        //  var _btnActive = false;
      });
    }

    Navigator.of(context).pop();
  }

  Future<void> _imgFromGallery() async {
    dynamic image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (image != null) {
      print("image$image");
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _imageSelect = image;
          _fileName = image.path;
        });
        sendImageApiCall();
      });
    } else {
      setState(() {
        //    var _btnActive = false;
      });
    }

    Navigator.of(context).pop();
  }

  Future<void> sendImageApiCall() async {
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}file_upload_owner");
    print("Url $url");

    setState(() {
      _isApiCalling = true; // Set API call to true while the process starts
    });

    String token = AppConstant.token;
    print(token);

    try {
      var headers = {
        'authorization': 'Bearer $token',
      };

      // Prepare the multipart request
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.headers.addAll(headers);

      // Add the image file
      if (_imageSelect != null) {
        XFile image1 = _imageSelect!;
        List<int> imageBytes = await image1.readAsBytes();
        http.MultipartFile imageFile = http.MultipartFile.fromBytes(
            'image', imageBytes,
            filename: 'image.jpg', contentType: MediaType('image', 'jpg'));

        formData.files.add(imageFile);
      } else {
        formData.fields['images'] = "";
      }

      // Send the request
      var response = await formData.send();
      var responseBody = await http.Response.fromStream(response);

      print("response--> ${responseBody.body}");
      var res = jsonDecode(responseBody.body);

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          setState(() {
            _selectedImagePath = res['image_path'];
            log("selectedImagePath $_selectedImagePath");
            _isApiCalling = false;
          });
          if (_list.isEmpty) {
            //on first message (add user to my_user collection of chat user)
            APIs.sendFirstMessage(
                widget.user, _selectedImagePath, TypeEnum.image, _isActive);
          } else {
            //simply send message
            APIs.sendMessage(
                widget.user, _selectedImagePath, TypeEnum.image, _isActive);
          }
          // sendImage(selectedImagePath);
        } else {
          setState(() {
            _isApiCalling = false;
          });
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          if (res['active_status'] == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Login()));
          }
        }
      } else {
        setState(() {
          _isApiCalling = false;
        });
      }
    } catch (e) {
      setState(() {
        _isApiCalling = false;
      });
      print("Error: $e");
    }
  }
}
