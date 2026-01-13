import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../helper/apis.dart';
import '../../model/chat_user.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_firebase.dart';
import '../../utilities/app_footer.dart';
import '../../utilities/app_loader.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '/utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/textinput.dart';
import 'login_screen.dart';
import 'dart:ui' as ui;

class EditProfileScreen extends StatefulWidget {
  static String routeName = './EditProfileScreen';
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenScreenState();
}

class _EditProfileScreenScreenState extends State<EditProfileScreen> {
  TextEditingController businessNameTextEditingController =
      TextEditingController();
  TextEditingController usernameTextController = TextEditingController();
  TextEditingController fullNameTextController = TextEditingController();
  TextEditingController mobileTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController genderTextEditingController = TextEditingController();
  TextEditingController roleTextEditingController = TextEditingController();
  TextEditingController merchantIdTextEditingController =
      TextEditingController();
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  DateTime? selectedDate;
  var sendDate = "";
  List genderList = [
    AppLanguage.maleText[language],
    AppLanguage.femaleText[language],
    AppLanguage.companyText[language]
  ];
  String isSelectedGender = "";
  int genderId = 0;

  //==========================DATE FUNCTION=======================//
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      var sendDate1 = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        selectedDate = picked;
        sendDate = sendDate1;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  String profileImage = "NA";
  int userId = 0;
  dynamic userDetails;
  var fileName = 'NA';
  // late File _image;
  bool isApiCalling = false;
  XFile? _imageSelect;
  String date = '';
  String dobDate = '';

//--------------------GET USER DETAILS-----------------------//
  Future<dynamic> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    userDetails = prefs.getString("userDetails");
    setState(() {
      isApiCalling = true;
    });

    // print("userDetails $userDetails");
    if (userDetails != null) {
      dynamic data = json.decode(userDetails);
      print("up ${data}");
      userId = data['user_id'];
      profileImage = data["image"] ?? "NA";
      print('74$userId');
      fullNameTextController.text = data['fullname'] ?? "";
      usernameTextController.text = data['username'] ?? "";
      businessNameTextEditingController.text = data['company_name'] ?? "";
      merchantIdTextEditingController.text = data['merchant_id'] ?? "";
      genderTextEditingController.text = genderList[data["gender"]];
      if (data['dob_formated'] != null &&
          data['dob_formated'] != "Invalid date") {
        date = data["dob_formated"] ?? '';
        selectedDate = DateFormat("dd/MM/yyyy").parse(date);
        DateTime dateTime = DateFormat("dd/MM/yyyy").parse(date);
        sendDate = DateFormat("yyyy-MM-dd").format(dateTime);
        print(date);
        print('783  $sendDate');
      } else {
        date = "";
      }
      emailTextEditingController.text = data["email"] ?? "";
      if (data["mobile"] == null) {
        // mobileTextEditingController.text = "";
      } else {
        mobileTextEditingController.text = data["mobile"].toString();
      }
      log(sendDate);
    } else {
      usernameTextController.text = "";
      fullNameTextController.text = "";
      mobileTextEditingController.text = "";
      emailTextEditingController.text = "";
      genderTextEditingController.text = "";
      roleTextEditingController.text = "";
      emailTextEditingController.text = "";
      mobileTextEditingController.text = "";
    }
    setState(() {
      isApiCalling = false;
    });
    setState(() {});
  }

//--------------------------------FROM CAMERA-----------------------//
  Future<void> _imgFromCamera() async {
    dynamic image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        // maxHeight: 450.0,
        // maxWidth: 450.0,
        imageQuality: 50);

    if (image != null) {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _imageSelect = image;
          fileName = image.path;
          //  var _btnActive = true;
        });
      });
    } else {
      setState(() {
        //  var _btnActive = false;
      });
    }

    Navigator.of(context).pop();
  }

// ------------------------------FROM GALLERY------------------------//
  Future<void> _imgFromGallery() async {
    print("run");
    dynamic image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        // maxHeight: 450.0,
        // maxWidth: 450.0,
        imageQuality: 50);

    if (image != null) {
      print("image 243 $image");
      Future.delayed(const Duration(seconds: 0), () {
        setState(() {
          _imageSelect = image;
          fileName = image.path;
          //  var _btnActive = true;
        });
      });
    } else {
      setState(() {
        //    var _btnActive = false;
      });
    }

    Navigator.of(context).pop();
  }

  //-------------------------------IMAGE PICKER BOTTOM SHEET--------------------------//
  void imagePickerBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: Text(AppLanguage.photoGalleryText[language]),
                      onTap: () {
                        _imgFromGallery();
                        setState(() {});
                        // Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: Text(AppLanguage.cameraText[language]),
                    onTap: () {
                      _imgFromCamera();
                      setState(() {});
                      // Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

//-------------------------------EDIT PROFILE VALIDATION---------------------------------//
  void editProfileValidation(
    String businessName,
    String email,
    String mobile,
    String merchantId,
    String fullName,
    String dob,
    String gender,
  ) {
    if (businessName.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.businessNameMsg[language]);
      return;
    } else if (email.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.emailMessage[language]);
      return;
    } else if (!AppConstant.emailValidatorRegExp.hasMatch(email)) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.emailValidMessage[language]);
      return;
    } else if (mobile.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.mobileNumberMessage[language]);
      return;
    } else if (mobile.length < 7) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.mobilevalidMessage[language]);
      return;
    } else if (merchantId.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.merchantIdMsg[language]);
      return;
    } else if (fullName.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.fullNameMessage[language]);
      return;
    } else if (sendDate.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.dobMessage[language]);
      return;
    } else if (gender.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.genderMsg[language]);
      return;
    } else {
      // If validation passes, call the API
      editProfileUsertApiCall();
    }
  }

//------------------------EDIT PROFILE API CALL--------------------------------//
  editProfileUsertApiCall() async {
    setState(() {
      isApiCalling = true;
    });

    Uri url = Uri.parse("${AppConfigProvider.apiUrl}edit_profile");

    print("Url===> $url");

    String token = AppConstant.token;

    try {
      var headers = {
        'Authorization': 'Bearer $token',
      };

      // Prepare the multipart request
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.headers.addAll(headers);
      formData.fields['user_id'] = userId.toString();
      formData.fields['username'] = usernameTextController.text;
      formData.fields['full_name'] = fullNameTextController.text;
      formData.fields['dob'] = sendDate.toString();
      formData.fields['email'] = emailTextEditingController.text;
      formData.fields['mobile'] = mobileTextEditingController.text;
      formData.fields['gender'] = genderId.toString();
      formData.fields['merchant_id'] = merchantIdTextEditingController.text;
      formData.fields['owner_company_name'] =
          businessNameTextEditingController.text;

      if (_imageSelect != null) {
        XFile image1 = _imageSelect!;
        List<int> imageBytes = await image1.readAsBytes();
        http.MultipartFile imageFile = http.MultipartFile.fromBytes(
            'image', imageBytes,
            filename: 'image.jpg', contentType: MediaType('image', 'jpg'));

        formData.files.add(imageFile);
      } else {
        formData.fields['image'] = "";
      }

      log("response--==> ${formData.fields}");
      // print("response--==> ${formData.files}");
      http.StreamedResponse response = await formData.send();
      print("response2--==> $response");
      var responseString = await response.stream.toBytes();
      var res = jsonDecode(utf8.decode(responseString));

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          updateUser(res['userDataArray'], userId);
          FirebaseProvider.firebaseCreateUser(true);
          APIs.userArry = res['userDataArray'];
          APIs.user_id = res['userDataArray']['user_id'].toString();
          if (await userExists(res['userDataArray']['user_id']) && mounted) {
            print("mounted $mounted");

            AppConstant.selectFooterIndex = 0;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyFooterPage(
                          indexOfPage: 0,
                        )));
          } else {
            createUser(res['userDataArray']['user_id'], res['userDataArray']);
          }

          print('Edited Details Fetched');
          dynamic userArr = res['userDataArray'];
          print("userArr $userArr");

          final prefs = await SharedPreferences.getInstance();
          prefs.setString("userDetails", jsonEncode(userArr));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyFooterPage(
                indexOfPage: 4,
              ),
            ),
          );
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          setState(() {
            isApiCalling = false;
          });
        } else {
          setState(() {
            isApiCalling = false;
          });
          // ignore: use_build_context_synchronously
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          if (res['active_status'] == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Login()));
          }
        }
      } else {
        setState(() {
          isApiCalling = false;
        });
      }
    } catch (e) {
      setState(() {
        isApiCalling = false;
      });
    }
  }

  static Future<void> createUser(userid, usserArry) async {
    print("user$usserArry");
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: userid.toString(),
        name: usserArry['fullname'] != null
            ? usserArry['fullname'].toString()
            : "",
        email: usserArry['email'] != null ? usserArry['email'].toString() : "",
        about: "Hey, I'm using We Chat!",
        image: usserArry['image'] != null ? usserArry['image'].toString() : "",
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '',
        mobile: "",
        playerId: AppConstant.playerID,
        groups: []);

    return await firestore
        .collection('users')
        .doc(userid.toString())
        .set(chatUser.toJson());
  }

  static Future<bool> userExists(userid) async {
    var doc = await firestore.collection('users').doc(userid.toString()).get();
    bool exists = doc.exists;

    // Print the status
    print("User exists: $exists");

    return exists;
  }

  static Future<void> updateUser(var usserArrey, userId) async {
    print("userId$userId");
    try {
      await firestore.collection('users').doc(userId.toString()).update({
        'name': usserArrey['fullname'] != null
            ? usserArrey['fullname'].toString()
            : "",
        'image':
            usserArrey['image'] != null ? usserArrey['image'].toString() : "",
      });
      print("User updated successfully!");
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
        inAsyncCall: isApiCalling,
        opacity: 0.5,
        child: _buildUIScreen(context));
  }

  Widget _buildUIScreen(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.secondaryColor,
        body: Directionality(
          textDirection:
              language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 100 / 100,
            child: Column(
              children: [
                //image header
                Container(
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  height: MediaQuery.of(context).size.height * 20 / 100,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(AppImage.headerBgImage),
                          fit: BoxFit.cover),
                      // color: AppColor.themeColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50))),
                  child: Column(
                    children: [
                      SizedBox(
                        height: AppConstant.deviceType == "ios"
                            ? MediaQuery.of(context).size.height * 6 / 100
                            : MediaQuery.of(context).size.height * 4 / 100,
                      ),

                      //profile edit setting
                      Container(
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            //back
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Transform.rotate(
                                angle: language == 1 ? 3.1416 : 0,
                                child: Container(
                                  alignment: Alignment.center,
                                  color: Colors.transparent,
                                  width: MediaQuery.of(context).size.width *
                                      15 /
                                      100,
                                  height: MediaQuery.of(context).size.width *
                                      7 /
                                      100,
                                  child: Image.asset(AppImage.backIcon),
                                ),
                              ),
                            ),

                            //profile
                            Container(
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 70 / 100,
                              child: Text(
                                AppLanguage.editProfileText[language],
                                style: const TextStyle(
                                    color: AppColor.secondaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppFont.fontFamily),
                              ),
                            ),

                            //setting
                            Container(
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 15 / 100,
                              height:
                                  MediaQuery.of(context).size.width * 7 / 100,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 10 / 100,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),

                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      //profile Image
                      GestureDetector(
                        onTap: () {
                          imagePickerBottomSheet();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 40 / 100,
                          height: MediaQuery.of(context).size.height * 17 / 100,
                          // color: Colors.red,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: MediaQuery.of(context).size.width *
                                      35 /
                                      100,
                                  width: MediaQuery.of(context).size.width *
                                      35 /
                                      100,
                                  child: fileName == 'NA'
                                      ? profileImage != "NA"
                                          ? Image.network(
                                              "${AppConfigProvider.imageURL}$profileImage",
                                              fit: BoxFit.cover,
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent?
                                                          loadingProgress) {
                                                if (loadingProgress == null) {
                                                  // Image has loaded
                                                  return child;
                                                } else {
                                                  // Image is still loading, show shimmer
                                                  return Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey.shade300,
                                                    highlightColor:
                                                        Colors.grey.shade100,
                                                    child: Container(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                  );
                                                }
                                              },
                                            )
                                          : Image.asset(
                                              AppImage.profilePlaceholderImage,
                                              fit: BoxFit.cover,
                                            )
                                      : Image.file(
                                          File(_imageSelect!.path),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    imagePickerBottomSheet();
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        10 /
                                        100,
                                    height: MediaQuery.of(context).size.width *
                                        10 /
                                        100,
                                    child: Image.asset(AppImage.editActiveIcon),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),

                      Container(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //username
                            CustomTextFormFieldBlackWidth(
                              width:
                                  MediaQuery.of(context).size.width * 43 / 100,
                              controller: usernameTextController,
                              hintText: AppLanguage.usernameText[language],
                              maxLength: AppConstant.fullnameLength,
                              keyboardtype: TextInputType.text,
                              fillColorStatus: 0,
                              readOnly: true,
                            ),

                            //business name
                            CustomTextFormFieldBlackWidth(
                              width:
                                  MediaQuery.of(context).size.width * 43 / 100,
                              controller: businessNameTextEditingController,
                              hintText: AppLanguage.businessNameText[language],
                              maxLength: AppConstant.fullnameLength,
                              keyboardtype: TextInputType.text,
                              fillColorStatus: 0,
                              readOnly: false,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),

                      //email
                      CustomTextFormFieldBlackWidth(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        controller: emailTextEditingController,
                        hintText: AppLanguage.emailText[language],
                        maxLength: AppConstant.fullnameLength,
                        keyboardtype: TextInputType.text,
                        fillColorStatus: 0,
                        readOnly: true,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),

                      //mobile
                      CustomTextFormFieldBlackWidth(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        controller: mobileTextEditingController,
                        hintText: AppLanguage.mobileText[language],
                        maxLength: AppConstant.mobileLength,
                        keyboardtype: TextInputType.number,
                        fillColorStatus: 0,
                        readOnly: false,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),

                      //merchant id
                      CustomTextFormFieldBlackWidth(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        controller: merchantIdTextEditingController,
                        hintText: AppLanguage.merchantIdText[language],
                        maxLength: AppConstant.fullnameLength,
                        keyboardtype: TextInputType.text,
                        fillColorStatus: 0,
                        readOnly: false,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),

                      //full name
                      CustomTextFormFieldBlackWidth(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        controller: fullNameTextController,
                        hintText: AppLanguage.fullnameText[language],
                        maxLength: AppConstant.fullnameLength,
                        keyboardtype: TextInputType.text,
                        fillColorStatus: 0,
                        readOnly: false,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),

                      //-----------DOB field---------------
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        height: MediaQuery.of(context).size.height * 5.5 / 100,
                        child: TextFormField(
                          style: const TextStyle(
                              height: .9,
                              color: AppColor.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                              hintText: selectedDate != null
                                  ? DateFormat('dd/MM/yyyy')
                                      .format(selectedDate!)
                                  : 'Date Of Birth',
                              border: const UnderlineInputBorder(
                                // Use UnderlineInputBorder
                                borderSide:
                                    BorderSide(color: AppColor.boaderColor),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColor.boaderColor),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColor.themeColor, width: 1),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 9),
                              fillColor: Colors.transparent,
                              filled: true,
                              counterText: '',
                              hintStyle: TextStyle(
                                  height: 1.1,
                                  color: selectedDate != null
                                      ? AppColor.primaryColor
                                      : AppColor.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                              suffixIcon: IconButton(
                                icon: Container(
                                  alignment: Alignment.centerRight,
                                  width: MediaQuery.of(context).size.width *
                                      20 /
                                      100,
                                  height: MediaQuery.of(context).size.width *
                                      6 /
                                      100,
                                  child: Image.asset(
                                    AppImage.calenderImage,
                                  ),
                                ),
                                onPressed: () {
                                  _selectDate(context);
                                },
                              )),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100),

                      //-----------Gender field---------------
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        height: MediaQuery.of(context).size.height * 5.5 / 100,
                        child: TextFormField(
                          style: const TextStyle(
                              height: .9,
                              color: AppColor.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                          textAlignVertical: TextAlignVertical.center,
                          controller: genderTextEditingController,
                          decoration: InputDecoration(
                              hintText: AppLanguage.genderText[language],
                              border: const UnderlineInputBorder(
                                // Use UnderlineInputBorder
                                borderSide:
                                    BorderSide(color: AppColor.boaderColor),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColor.boaderColor),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColor.themeColor, width: 1),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 9),
                              fillColor: Colors.transparent,
                              filled: true,
                              counterText: '',
                              hintStyle: AppConstant.textFilledStyle,
                              suffixIcon: IconButton(
                                icon: Container(
                                  alignment: Alignment.centerRight,
                                  width: MediaQuery.of(context).size.width *
                                      20 /
                                      100,
                                  height: MediaQuery.of(context).size.width *
                                      6 /
                                      100,
                                  child: Image.asset(
                                    AppImage.dropDownIcon,
                                  ),
                                ),
                                onPressed: () {
                                  dropDownModelForGender(context, screenWidth);
                                },
                              )),
                          readOnly: true,
                          onTap: () =>
                              dropDownModelForGender(context, screenWidth),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 3 / 100),

                      AppButton(
                          text: AppLanguage.submitText[language],
                          onPress: () {
                            editProfileValidation(
                              businessNameTextEditingController.text,
                              emailTextEditingController.text,
                              mobileTextEditingController.text,
                              merchantIdTextEditingController.text,
                              fullNameTextController.text,
                              date,
                              genderTextEditingController.text,
                            );
                          }),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 3 / 100),
                    ],
                  ),
                )),
                const NoInternetBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

//=====================gender bottomsheet===============
  void dropDownModelForGender(BuildContext context, screenWidth) {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        constraints: BoxConstraints.expand(width: screenWidth),
        enableDrag: false,
        isDismissible: false,
        backgroundColor: AppColor.primaryColor.withOpacity(0.1),
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: ((context, setState) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 100 / 100,
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  color: AppColor.primaryColor.withOpacity(0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: screenWidth > 600
                            ? MediaQuery.of(context).size.height * 25 / 100
                            : MediaQuery.of(context).size.height * 20 / 100,
                        width: MediaQuery.of(context).size.width * 85 / 100,
                        // color: Colors.red,
                        decoration: const BoxDecoration(
                          color: AppColor.secondaryColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.width * 3 / 100,
                            ),
                            // List
                            Flexible(
                              child: ListView.builder(
                                itemCount: genderList.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                2 /
                                                100,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            genderTextEditingController.text =
                                                genderList[index];
                                            isSelectedGender =
                                                genderList[index];
                                            genderId = index;
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              70 /
                                              100,
                                          color: AppColor.secondaryColor,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                genderList[index],
                                                style: const TextStyle(
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontSize: 17,
                                                  color: AppColor.primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    5 /
                                                    100,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    5 /
                                                    100,
                                                child: isSelectedGender ==
                                                        genderList[index]
                                                    ? Image.asset(
                                                        AppImage.tickOrangeIcon,
                                                        fit: BoxFit.fill,
                                                      )
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }
}
