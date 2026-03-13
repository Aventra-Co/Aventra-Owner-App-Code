import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_boat_ownerside/controller/app_snack_bar_toast_message.dart';
import 'package:the_boat_ownerside/view/other_screen/manage_staff_screen.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_loader.dart';
import '../authentication/login_screen.dart';
import '../../controller/app_button.dart';
import '../../controller/app_header.dart';
import '../../controller/textinput.dart';
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';
import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';

class AddStaffScreen extends StatefulWidget {
  static String routeName = './AddStaffScreen';
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddBoatScreenState();
}

class _AddBoatScreenState extends State<AddStaffScreen> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController roleTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController searchCountryTextEditingController =
      TextEditingController();
  DateTime? selectedDate;
  var sendDate = "";
  int isSelectedRole = 0;
  List<int> status = [];
  bool isPasswordVisible = false;
  List<dynamic> roleList = <dynamic>[];
  List<dynamic> roleSearchList = <dynamic>[];
  int isViewHome = 0;
  int isManageHome = 0;
  int isViewMyAd = 0;
  int isManageMyAd = 0;
  int isChat = 0;
  int isViewUnavailability = 0;
  int isManageUnavailability = 0;
  int isViewBoat = 0;
  int isManageBoat = 0;
  int isViewProperty = 0;
  int isManageProperty = 0;
  int isViewMyWallet = 0;
  int isViewHistory = 0;
  bool isApiCalling = false;
  XFile? _imageSelect;
  var fileName = 'NA';

  @override
  void initState() {
    super.initState();
    getUserDetails();
    getRolesApi();
  }

  int userId = 0;
  dynamic userDetails;

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
      print("up $data");
      userId = data['user_id'];
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

  //---------------------SEARCH FUNCTION COUNTRY--------------------///
  searchResultCountry(String query) {
    print(query);

    var results1 = roleSearchList
        .where((value) => value['role'][language]
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    print("results1 $results1");

    roleList = [];

    roleList = results1;

    setState(() {});
  }

  //=============================Fetch Roles DETAILS===================================//
  Future<void> getRolesApi() async {
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}fetch_role");
    print("url $url");

    String token = AppConstant.token;

    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token', // Use 'Bearer' if required
    };

    setState(() {
      isApiCalling = true;
    });

    print("headers $headers");

    try {
      final response = await http.get(url, headers: headers);
      print("response $response");

      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);
        print("res $res");

        if (res['success'] == true) {
          var item = res['role_arr'];
          roleList = (item != "NA") ? item : [];
          roleSearchList = (item != "NA") ? item : [];

          setState(() {
            isApiCalling = false;
          });
        } else {
          if (res['active_status'] == 0) {
            SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          }
          setState(() {
            isApiCalling = false;
          });
        }
      } else {
        print("Error: ${response.statusCode}");
        setState(() {
          isApiCalling = false;
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        isApiCalling = false;
      });
    }
  }

  //=============add staff validation===================
  addStaffValidation(
    String username,
    String fullname,
    String role,
    String email,
    String password,
    String image,
  ) {
    if (username.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.usernameMsg[language]);
      return;
    } else if (fullname.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.fullNameMessage[language]);
      return;
    } else if (role.isEmpty) {
      SnackBarToastMessage.showSnackBar(context, AppLanguage.roleMsg[language]);
      return;
    } else if (email.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.emailMessage[language]);
      return;
    } else if (!AppConstant.emailValidatorRegExp.hasMatch(email)) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.emailValidMessage[language]);
      return;
    } else if (password.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.passwordMessage[language]);
    } else if (password.length < 6) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.passwordMinMessage[language]);
    } else if (image.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.uploadIdMsg[language]);
      return;
    } else {
      addStaffApiCall();
    }
  }

//------------------------add boat API CALL--------------------------------//
  addStaffApiCall() async {
    setState(() {
      isApiCalling = true;
    });
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}add_staff");
    print("Url===> $url");
    try {
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.fields['user_id'] = userId.toString();
      formData.fields['username'] = userNameTextEditingController.text;
      formData.fields['fullname'] = nameTextEditingController.text;
      formData.fields['role_id'] = isSelectedRole.toString();
      formData.fields['email'] = emailTextEditingController.text;
      formData.fields['view_home'] = isViewHome.toString();
      formData.fields['manage_home'] = isManageHome.toString();
      formData.fields['view_my_add'] = isViewMyAd.toString();
      formData.fields['manage_my_add'] = isManageMyAd.toString();
      formData.fields['chat'] = isChat.toString();
      formData.fields['view_unavailability'] = isViewUnavailability.toString();
      formData.fields['manage_unavailability'] =
          isManageUnavailability.toString();
      formData.fields['view_boat'] = isViewBoat.toString();
      formData.fields['manage_boat'] = isManageBoat.toString();
      formData.fields['view_property'] = isViewProperty.toString();
      formData.fields['manage_property'] = isManageProperty.toString();
      formData.fields['view_my_wallet'] = isViewHome.toString();
      formData.fields['view_history'] = isViewHistory.toString();
      formData.fields['user_type'] = "2";
      formData.fields['password'] = passwordTextEditingController.text;

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
      print("response--==> $response");
      var responseString = await response.stream.toBytes();
      var res = jsonDecode(utf8.decode(responseString));
      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageStaffScreen(),
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
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 100 / 100,
            child: Column(
              children: [
                AppHeaderOrange(
                    text: AppLanguage.addStaffText[language],
                    onPress: () {
                      Navigator.pop(context);
                    }),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100,
                        ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            AppLanguage.detailsText[language],
                            style: const TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColor.primaryColor),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //!=== Add username Text ===
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            AppLanguage.usernameText[language],
                            style: const TextStyle(
                                color: AppColor.primaryColor,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                        ),

                        //!===Enter username====
                        CustomTextFormFieldBlackWidth(
                          controller: userNameTextEditingController,
                          hintText: AppLanguage.enterUserNameText[language],
                          keyboardtype: TextInputType.name,
                          maxLength: 50,
                          fillColorStatus: 0,
                          readOnly: false,
                          width: MediaQuery.of(context).size.width * 90 / 100,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //!=== Add Name Text ===
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            AppLanguage.nameText[language],
                            style: const TextStyle(
                                color: AppColor.primaryColor,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                        ),

                        //!===Enter Name====
                        CustomTextFormFieldBlackWidth(
                          controller: nameTextEditingController,
                          hintText: AppLanguage.enterFullNameText[language],
                          keyboardtype: TextInputType.name,
                          maxLength: 50,
                          fillColorStatus: 0,
                          readOnly: false,
                          width: MediaQuery.of(context).size.width * 90 / 100,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //!=== Role Text ===
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            AppLanguage.roleText[language],
                            style: const TextStyle(
                                color: AppColor.primaryColor,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                        ),

                        //!=== Enter Role===
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          height:
                              MediaQuery.of(context).size.height * 5.5 / 100,
                          child: TextFormField(
                            readOnly: true,
                            style: const TextStyle(
                                height: 1.1,
                                color: AppColor.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                            textAlignVertical: TextAlignVertical.center,
                            controller: roleTextEditingController,
                            onTap: () {
                              dropDownModelForRole(context, screenWidth);
                            },
                            decoration: InputDecoration(
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
                                    const EdgeInsets.symmetric(vertical: 10),
                                fillColor: Colors.transparent,
                                filled: true,
                                counterText: '',
                                hintText: AppLanguage.selectText[language],
                                hintStyle: const TextStyle(
                                    color: AppColor.textColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                                suffixIcon: IconButton(
                                  icon: Container(
                                    alignment: language == 1
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    width: MediaQuery.of(context).size.width *
                                        20 /
                                        100,
                                    height: MediaQuery.of(context).size.width *
                                        5 /
                                        100,
                                    child: Image.asset(
                                      AppImage.dropDownIcon,
                                    ),
                                  ),
                                  onPressed: () {
                                    dropDownModelForRole(context, screenWidth);
                                  },
                                )),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //!=== Email Text ===
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            AppLanguage.emailText[language],
                            style: const TextStyle(
                                color: AppColor.primaryColor,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                        ),

                        //!=== Enter email ==
                        CustomTextFormFieldBlackWidth(
                          controller: emailTextEditingController,
                          hintText: AppLanguage.enterEmailText[language],
                          keyboardtype: TextInputType.emailAddress,
                          maxLength: 50,
                          fillColorStatus: 0,
                          readOnly: false,
                          width: MediaQuery.of(context).size.width * 90 / 100,
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100),

                        //!=== Password Text ===
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            AppLanguage.passwordText[language],
                            style: const TextStyle(
                                color: AppColor.primaryColor,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                        ),

                        //password
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          height: MediaQuery.of(context).size.height * 6 / 100,
                          child: TextFormField(
                              readOnly: false,
                              style: const TextStyle(
                                  height: 1.1,
                                  color: AppColor.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.visiblePassword,
                              controller: passwordTextEditingController,
                              maxLength: AppConstant.passwordLength,
                              obscureText: isPasswordVisible,
                              decoration: InputDecoration(
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
                                      const EdgeInsets.symmetric(vertical: 0),
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  counterText: '',
                                  hintText:
                                      AppLanguage.enterPasswordText[language],
                                  hintStyle: const TextStyle(
                                      color: AppColor.textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                  suffixIcon: IconButton(
                                    icon: Container(
                                      alignment: Alignment.bottomCenter,
                                      margin: const EdgeInsets.only(right: 4),
                                      width: MediaQuery.of(context).size.width *
                                          10 /
                                          100,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              8 /
                                              100,
                                      child: Image.asset(
                                          isPasswordVisible
                                              ? AppImage.showEyeIcon
                                              : AppImage.hideEyeIcon,
                                          color: AppColor.textColor),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                  ))),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //!=== Staff Text ===
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            AppLanguage.staffIdText[language],
                            style: const TextStyle(
                                color: AppColor.primaryColor,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),

                        //!=== Upload staff id  Text ===
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            AppLanguage.uploadStaffIdText[language],
                            style: const TextStyle(
                                color: AppColor.textColor,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100),

                        //=======Upload box==============
                        _imageSelect == null
                            ? GestureDetector(
                                onTap: () {
                                  imagePickerBottomSheet();
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      20 /
                                      100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColor.boaderColor,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        AppImage.uploadIcon,
                                        color: AppColor.boaderColor,
                                        scale: 15,
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              1 /
                                              100),
                                      Text(
                                        AppLanguage
                                            .chooseFileToUploadText[language],
                                        style: const TextStyle(
                                            color: AppColor.textColor,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          90 /
                                          100,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              20 /
                                              100,
                                      child: Image.file(
                                        File(_imageSelect!.path),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  //cross icon
                                  Positioned(
                                    top: 0,
                                    right: MediaQuery.of(context).size.width *
                                        .5 /
                                        100,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _imageSelect = null;
                                        });
                                      },
                                      child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              6 /
                                              100,
                                          child:
                                              Image.asset(AppImage.crossIcon)),
                                    ),
                                  ),
                                ],
                              ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100),

                        //!=== Permission Text ===
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            "${AppLanguage.permissionText[language]}:",
                            style: const TextStyle(
                                color: AppColor.primaryColor,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 20),
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),

                        //=============view home===============
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLanguage.viewHomeText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isViewHome == 1) {
                                      setState(() {
                                        isViewHome = 0;
                                      });
                                    } else {
                                      setState(() {
                                        isViewHome = 1;
                                      });
                                    }
                                  });
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      10 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      5 /
                                      100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      isViewHome == 1
                                          ? AppImage.toggleActiveIcon
                                          : AppImage.toggleDeactiveIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),

                        //=============manage home===============
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLanguage.manageHomeText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isManageHome == 1) {
                                      setState(() {
                                        isManageHome = 0;
                                      });
                                    } else {
                                      setState(() {
                                        isManageHome = 1;
                                      });
                                    }
                                  });
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      10 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      5 /
                                      100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      isManageHome == 1
                                          ? AppImage.toggleActiveIcon
                                          : AppImage.toggleDeactiveIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),

                        //=============view my add===============
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLanguage.viewMyAddText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isViewMyAd == 1) {
                                      setState(() {
                                        isViewMyAd = 0;
                                      });
                                    } else {
                                      setState(() {
                                        isViewMyAd = 1;
                                      });
                                    }
                                  });
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      10 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      5 /
                                      100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      isViewMyAd == 1
                                          ? AppImage.toggleActiveIcon
                                          : AppImage.toggleDeactiveIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),

                        //=============manage my add===============
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLanguage.manageMyAddText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isManageMyAd == 1) {
                                      setState(() {
                                        isManageMyAd = 0;
                                      });
                                    } else {
                                      setState(() {
                                        isManageMyAd = 1;
                                      });
                                    }
                                  });
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      10 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      5 /
                                      100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      isManageMyAd == 1
                                          ? AppImage.toggleActiveIcon
                                          : AppImage.toggleDeactiveIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),

                        //=============chat===============
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLanguage.chatText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isChat == 1) {
                                      setState(() {
                                        isChat = 0;
                                      });
                                    } else {
                                      setState(() {
                                        isChat = 1;
                                      });
                                    }
                                  });
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      10 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      5 /
                                      100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      isChat == 1
                                          ? AppImage.toggleActiveIcon
                                          : AppImage.toggleDeactiveIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),

                        //=============view unavailability===============
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLanguage.viewUnavailabilityText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isViewUnavailability == 1) {
                                      setState(() {
                                        isViewUnavailability = 0;
                                      });
                                    } else {
                                      setState(() {
                                        isViewUnavailability = 1;
                                      });
                                    }
                                  });
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      10 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      5 /
                                      100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      isViewUnavailability == 1
                                          ? AppImage.toggleActiveIcon
                                          : AppImage.toggleDeactiveIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),

                        //=============manage unavailability===============
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLanguage.manageUnavailabilityText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isManageUnavailability == 1) {
                                      setState(() {
                                        isManageUnavailability = 0;
                                      });
                                    } else {
                                      setState(() {
                                        isManageUnavailability = 1;
                                      });
                                    }
                                  });
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      10 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      5 /
                                      100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      isManageUnavailability == 1
                                          ? AppImage.toggleActiveIcon
                                          : AppImage.toggleDeactiveIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),

                        //=============view boat===============
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLanguage.viewBoatText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isViewBoat == 1) {
                                      setState(() {
                                        isViewBoat = 0;
                                      });
                                    } else {
                                      setState(() {
                                        isViewBoat = 1;
                                      });
                                    }
                                  });
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      10 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      5 /
                                      100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      isViewBoat == 1
                                          ? AppImage.toggleActiveIcon
                                          : AppImage.toggleDeactiveIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),

                        //=============manage boat===============
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLanguage.manageBoatText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isManageBoat == 1) {
                                      setState(() {
                                        isManageBoat = 0;
                                      });
                                    } else {
                                      setState(() {
                                        isManageBoat = 1;
                                      });
                                    }
                                  });
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      10 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      5 /
                                      100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      isManageBoat == 1
                                          ? AppImage.toggleActiveIcon
                                          : AppImage.toggleDeactiveIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),

                        //=============view property===============
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLanguage.viewPropertyText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isViewProperty == 1) {
                                      setState(() {
                                        isViewProperty = 0;
                                      });
                                    } else {
                                      setState(() {
                                        isViewProperty = 1;
                                      });
                                    }
                                  });
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      10 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      5 /
                                      100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      isViewProperty == 1
                                          ? AppImage.toggleActiveIcon
                                          : AppImage.toggleDeactiveIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),

                        //=============manage property===============
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLanguage.managePropertyText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isManageProperty == 1) {
                                      setState(() {
                                        isManageProperty = 0;
                                      });
                                    } else {
                                      setState(() {
                                        isManageProperty = 1;
                                      });
                                    }
                                  });
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      10 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      5 /
                                      100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      isManageProperty == 1
                                          ? AppImage.toggleActiveIcon
                                          : AppImage.toggleDeactiveIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),

                        //=============view wallet===============
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLanguage.viewMyWalletText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isViewMyWallet == 1) {
                                      setState(() {
                                        isViewMyWallet = 0;
                                      });
                                    } else {
                                      setState(() {
                                        isViewMyWallet = 1;
                                      });
                                    }
                                  });
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      10 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      5 /
                                      100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      isViewMyWallet == 1
                                          ? AppImage.toggleActiveIcon
                                          : AppImage.toggleDeactiveIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),

                        //=============view history===============
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLanguage.viewHistoryText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isViewHistory == 1) {
                                      setState(() {
                                        isViewHistory = 0;
                                      });
                                    } else {
                                      setState(() {
                                        isViewHistory = 1;
                                      });
                                    }
                                  });
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      10 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      5 /
                                      100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      isViewHistory == 1
                                          ? AppImage.toggleActiveIcon
                                          : AppImage.toggleDeactiveIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100),

                        //!=== Button Submit ===
                        AppButton(
                            text: AppLanguage.submitText[language],
                            onPress: () {
                              // Navigator.pop(context);
                              addStaffValidation(
                                  userNameTextEditingController.text,
                                  nameTextEditingController.text,
                                  roleTextEditingController.text,
                                  emailTextEditingController.text,
                                  passwordTextEditingController.text,
                                  _imageSelect?.path ?? '');
                            }),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 3 / 100),
                      ],
                    ),
                  ),
                ),
                const NoInternetBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void dropDownModelForRole(BuildContext context, screenWidth) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      isDismissible: true,
      constraints: BoxConstraints.expand(width: screenWidth),
      context: context,
      backgroundColor: AppColor.secondaryColor,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 4 / 100,
                      ),

                      CustomAppHeader(
                          text: "",
                          onPress: () {
                            Navigator.pop(context);
                          }),

                      // Search field
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        height: MediaQuery.of(context).size.height * 6.5 / 100,
                        child: TextFormField(
                          style: const TextStyle(
                            height: 1.1,
                            color: AppColor.primaryColor,
                            fontFamily: AppFont.fontFamily,
                          ),
                          textAlignVertical: TextAlignVertical.center,
                          readOnly: false,
                          keyboardType: TextInputType.text,
                          controller: searchCountryTextEditingController,
                          maxLength: 50,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColor.boaderColor),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColor.boaderColor),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColor.themeColor),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                            contentPadding:
                                const EdgeInsets.only(right: 10, left: 10),
                            fillColor: Colors.white,
                            filled: true,
                            counterText: '',
                            hintText: AppLanguage.searchText[language],
                            hintStyle: AppConstant.textFilledStyle,
                          ),
                          onChanged: (input) {
                            setState(() {
                              if (input.isNotEmpty) {
                                searchResultCountry(input);
                              } else {
                                roleList = roleSearchList;
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),

                      // List
                      Flexible(
                        child: ListView.builder(
                          itemCount: roleList.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      2 /
                                      100,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelectedRole =
                                          roleList[index]["role_id"];
                                      roleTextEditingController.text =
                                          roleList[index]['role'][language];
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        90 /
                                        100,
                                    color: AppColor.secondaryColor,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          roleList[index]['role'][language],
                                          style: const TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 17,
                                            color: AppColor.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(
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
                                          child: isSelectedRole ==
                                                  roleList[index]["role_id"]
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
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      2 /
                                      100,
                                ),
                                // if (index < roleList.length - 1)
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      .2 /
                                      100,
                                  color: AppColor.textColor,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
