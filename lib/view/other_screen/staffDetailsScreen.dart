import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_loader.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../authentication/login_screen.dart';
import '/utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import 'dart:ui' as ui;
import 'manage_staff_screen.dart';

class StaffDetailsScreen extends StatefulWidget {
  static String routeName = './StaffDetailsScreen';
  final String userId;
  const StaffDetailsScreen({super.key, required this.userId});

  @override
  State<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController roleTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController searchCountryTextEditingController =
      TextEditingController();
  bool isApiCalling = false;
  int isSelectedRole = 0;
  List<dynamic> roleList = <dynamic>[];
  List<dynamic> roleSearchList = <dynamic>[];
  XFile? coverImage;
  String showCoverImage = "";
  int isViewHome = 0;
  int isManageHome = 0;
  int isViewMyAd = 0;
  int isManageMyAd = 0;
  int isChat = 0;
  int isViewUnavailability = 0;
  int isManageUnavailability = 0;
  int isViewBoat = 0;
  int isManageBoat = 0;
  int isViewMyWallet = 0;
  int isViewHistory = 0;

  @override
  void initState() {
    super.initState();
    getStaffDetailsApi();
    getRolesApi();
  }

  int userId = 0;
  dynamic userDetails;

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

  //=============================GET Boat DETAILS===================================//
  Future<void> getStaffDetailsApi() async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}view_profile?user_id=${widget.userId}");
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
          var item = res['user_arr'];
          userDetails = (item != "NA") ? item : [];

          fillDetails();

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

  //=============================Delete Staff DETAILS===================================//
  deleteStaffApiCall() async {
    setState(() {
      isApiCalling = true;
    });

    Uri url = Uri.parse("${AppConfigProvider.apiUrl}delete_staff");

    print("Url===> $url");

    try {
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.fields['staff_id'] = widget.userId;

      log("response--==> ${formData.fields}");
      // print("response--==> ${formData.files}");
      http.StreamedResponse response = await formData.send();
      print("response--==> $response");
      var responseString = await response.stream.toBytes();
      var res = jsonDecode(utf8.decode(responseString));

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          // getBoatsApi(userId);
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

  //--------------------------------FROM CAMERA-----------------------//
  Future<void> _coverImgFromCamera() async {
    dynamic image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        // maxHeight: 450.0,
        // maxWidth: 450.0,
        imageQuality: 50);

    if (image != null) {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          coverImage = image;
          showCoverImage = coverImage!.path;
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
  Future<void> _coverImgFromGallery() async {
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
          coverImage = image;
          showCoverImage = coverImage!.path;
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
  void coverImagePickerBottomSheet() {
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
                        _coverImgFromGallery();
                        setState(() {});
                        // Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: Text(AppLanguage.cameraText[language]),
                    onTap: () {
                      _coverImgFromCamera();
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

  fillDetails() {
    nameTextEditingController.text = userDetails['l_name'] ?? "";
    roleTextEditingController.text = userDetails['role_name'][language] ?? "";
    emailTextEditingController.text = userDetails['email'] ?? "";
    showCoverImage = userDetails["image"] ?? "";
    isSelectedRole = userDetails["role"] ?? "";
    isViewHome = userDetails["view_home"];
    isManageHome = userDetails["manage_home"];
    isViewMyAd = userDetails["view_my_add"];
    isManageMyAd = userDetails["manage_my_add"];
    isChat = userDetails["chat"];
    isViewUnavailability = userDetails["view_unavailability"];
    isManageUnavailability = userDetails["manage_unavailability"];
    isViewBoat = userDetails["view_boat"];
    isManageBoat = userDetails["manage_boat"];
    isViewMyWallet = userDetails["view_my_wallet"];
    isViewHistory = userDetails["view_history"];
    setState(() {});
  }

  //=============Edit staff validation===================
  editStaffValidation(
    String fullname,
    String role,
    String email,
    String image,
  ) {
    if (fullname.isEmpty) {
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
    } else if (image.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.uploadIdMsg[language]);
      return;
    } else {
      editStaffApiCall();
    }
  }

//------------------------add boat API CALL--------------------------------//
  editStaffApiCall() async {
    setState(() {
      isApiCalling = true;
    });
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}edit_staff_details");
    print("Url===> $url");
    try {
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.fields['staff_id'] = widget.userId.toString();
      formData.fields['username'] = userDetails['f_name'] ?? "";
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
      formData.fields['view_my_wallet'] = isViewMyWallet.toString();
      formData.fields['view_history'] = isViewHistory.toString();

      if (coverImage != null) {
        XFile image1 = coverImage!;
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
          child: Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 100 / 100,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  height: MediaQuery.of(context).size.height * 12 / 100,
                  decoration: const BoxDecoration(
                      color: AppColor.themeColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 15 / 100,
                          height: MediaQuery.of(context).size.width * 8 / 100,
                          child: Image.asset(
                            AppImage.leftArrowIcon,
                            color: AppColor.secondaryColor,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          AppLanguage.staffDetailsText[language],
                          style: const TextStyle(
                              color: AppColor.secondaryColor,
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 20),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          deleteBoatBottomSheet(context, screenWidth);
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 15 / 100,
                          height: MediaQuery.of(context).size.width * 6 / 100,
                          child: Image.asset(
                            AppImage.deleteDeactiveIcon,
                            color: AppColor.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100),

                        Container(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                                width:
                                    MediaQuery.of(context).size.width * 4 / 100,
                                child: Image.asset(
                                  AppImage.userprofileIcon,
                                ),
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      2 /
                                      100),
                              Text(
                                AppLanguage.nameText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),

                        //!=== Name ====
                        TextField(
                          controller: nameTextEditingController,
                          hintText: AppLanguage.enterNameText[language],
                          keyboardtype: TextInputType.name,
                          maxLength: 50,
                          fillColorStatus: 0,
                          readOnly: false,
                          width: MediaQuery.of(context).size.width * 90 / 100,
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),

                        Container(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                                width:
                                    MediaQuery.of(context).size.width * 4 / 100,
                                child: Image.asset(
                                  AppImage.userRoleIcon,
                                ),
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      2 /
                                      100),
                              Text(
                                AppLanguage.roleText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),

                        //!=== Role ====
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
                                contentPadding: const EdgeInsets.only(
                                    top: 10, bottom: 10, left: 22),
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
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),

                        Container(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                                width:
                                    MediaQuery.of(context).size.width * 4 / 100,
                                child: Image.asset(
                                  AppImage.emailIcon,
                                ),
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      2 /
                                      100),
                              Text(
                                AppLanguage.emailText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),

                        //!=== Email ====
                        TextField(
                          controller: emailTextEditingController,
                          hintText: AppLanguage.emailText[language],
                          keyboardtype: TextInputType.name,
                          maxLength: 50,
                          fillColorStatus: 0,
                          readOnly: true,
                          width: MediaQuery.of(context).size.width * 90 / 100,
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 3 / 100),

                        // Container(
                        //   width: MediaQuery.of(context).size.width * 90 / 100,
                        //   child: Row(
                        //     children: [
                        //       Container(
                        //         height:
                        //             MediaQuery.of(context).size.height * 2 / 100,
                        //         width: MediaQuery.of(context).size.width * 4 / 100,
                        //         child: Image.asset(
                        //           AppImage.phoneIcon,
                        //         ),
                        //       ),
                        //       SizedBox(
                        //           width:
                        //               MediaQuery.of(context).size.width * 2 / 100),
                        //       Text(
                        //         AppLanguage.mobileText[language],
                        //         style: const TextStyle(
                        //             color: AppColor.primaryColor,
                        //             fontFamily: AppFont.fontFamily,
                        //             fontWeight: FontWeight.w600,
                        //             fontSize: 14),
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        // //!=== mobile ====
                        // TextField(
                        //   controller: mobileTextEditingController,
                        //   hintText: AppLanguage.mobileText[language],
                        //   keyboardtype: TextInputType.name,
                        //   maxLength: 50,
                        //   fillColorStatus: 0,
                        //   readOnly: false,
                        //   width: MediaQuery.of(context).size.width * 90 / 100,
                        // ),
                        // SizedBox(
                        //     height: MediaQuery.of(context).size.height * 2 / 100),

                        Container(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                                width:
                                    MediaQuery.of(context).size.width * 4 / 100,
                                child: Image.asset(
                                  AppImage.addCertificateIcon,
                                ),
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      2 /
                                      100),
                              Text(
                                AppLanguage.certificateText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100),

                        //! Certificate Image
                        buildCoverImage(screenWidth),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100),
                        // Container(
                        //   height: MediaQuery.of(context).size.height * 30 / 100,
                        //   width: MediaQuery.of(context).size.width * 80 / 100,
                        //   child: Image.asset(
                        //     AppImage.certificateImage,
                        //     fit: BoxFit.fill,
                        //   ),
                        // ),

                        //!=== Permission Text ===
                        Container(
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
                        Container(
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
                                child: Container(
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
                        Container(
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
                                child: Container(
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
                        Container(
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
                                child: Container(
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
                        Container(
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
                                child: Container(
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
                        Container(
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
                                child: Container(
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
                        Container(
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
                                child: Container(
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
                        Container(
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
                                child: Container(
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
                        Container(
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
                                child: Container(
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
                        Container(
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
                                child: Container(
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

                        //=============view wallet===============
                        Container(
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
                                child: Container(
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
                        Container(
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
                                child: Container(
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

                        AppButton(
                            text: AppLanguage.updateButtonText[language],
                            onPress: () {
                              editStaffValidation(
                                  nameTextEditingController.text,
                                  roleTextEditingController.text,
                                  emailTextEditingController.text,
                                  showCoverImage);
                            }),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 4 / 100),
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

  Widget buildCoverImage(screenWidth) {
    if (coverImage == null && showCoverImage == "") {
      // Case 1: No image selected or shown yet
      return GestureDetector(
        onTap: () {
          coverImagePickerBottomSheet();
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 90 / 100,
          height: MediaQuery.of(context).size.height * 20 / 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColor.boaderColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppImage.uploadIcon,
                color: AppColor.boaderColor,
                scale: 15,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 1 / 100),
              Text(
                AppLanguage.chooseFileToUploadText[language],
                style: const TextStyle(
                    color: AppColor.textColor,
                    fontFamily: AppFont.fontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ],
          ),
        ),
      );
    } else if (coverImage == null && showCoverImage != "") {
      // Case 2: Show image from URL
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.18,
              child: Image.network(
                "${AppConfigProvider.imageURL}$showCoverImage",
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(color: Colors.grey.shade300),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: MediaQuery.of(context).size.width * 0.01,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showCoverImage = "";
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.06,
                child: Image.asset(AppImage.crossIcon),
              ),
            ),
          ),
        ],
      );
    } else {
      // Case 3: Local image picked
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.18,
              child: Image.file(
                File(coverImage!.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: MediaQuery.of(context).size.width * 0.01,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  coverImage = null;
                  showCoverImage = "";
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.06,
                child: Image.asset(AppImage.crossIcon),
              ),
            ),
          ),
        ],
      );
    }
  }

  //=====================delete bottomsheet===============
  void deleteBoatBottomSheet(
    BuildContext context,
    screenWidth,
  ) {
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
                        // height: MediaQuery.of(context).size.height * 31 / 100,
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.width * 10 / 100,
                            ),
                            // Container(
                            //   margin: EdgeInsets.only(top: 10),
                            //   alignment: Alignment.center,
                            //   width:
                            //       MediaQuery.of(context).size.width * 15 / 100,
                            //   height:
                            //       MediaQuery.of(context).size.width * 15 / 100,
                            //   child: Image.asset(
                            //     AppImage.deleteIcon,
                            //     fit: BoxFit.cover,
                            //   ),
                            // ),
                            Container(
                              //color: Colors.amber,
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 55 / 100,
                              child: Text(
                                AppLanguage.deleteText[language],
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppFont.fontFamily),
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100),
                            Container(
                              //color: Colors.amber,
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 75 / 100,
                              child: Text(
                                AppLanguage.deleteBoatMsg[language],
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppFont.fontFamily),
                              ),
                            ),

                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 4 / 100,
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 65 / 100,
                              height:
                                  MediaQuery.of(context).size.width * 13 / 100,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width *
                                          30 /
                                          100,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              5 /
                                              100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        //color: Colors.red,
                                        border: Border.all(
                                          color: AppColor.primaryColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        AppLanguage.cancelText[language],
                                        style: const TextStyle(
                                            color: AppColor.primaryColor,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      deleteStaffApiCall();
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width *
                                          30 /
                                          100,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              5 /
                                              100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: AppColor.themeColor,
                                        border: Border.all(
                                          color: AppColor.themeColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        AppLanguage.yesText[language],
                                        style: const TextStyle(
                                            color: AppColor.secondaryColor,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 6 / 100,
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

                      AppHeader(
                          text: "",
                          onPress: () {
                            Navigator.pop(context);
                          }),

                      // Search field
                      Container(
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

// ignore: must_be_immutable
class TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final int fillColorStatus;
  final bool readOnly;
  final double width;
  // ignore: prefer_typing_uninitialized_variables
  var keyboardtype;

  TextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.keyboardtype,
      required this.maxLength,
      required this.fillColorStatus,
      required this.width,
      required this.readOnly});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        height: MediaQuery.of(context).size.height * 5.5 / 100,
        child: TextFormField(
          readOnly: readOnly,
          style: const TextStyle(
              height: 1.1,
              color: AppColor.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w400),
          textAlignVertical: TextAlignVertical.center,
          keyboardType: keyboardtype,
          controller: controller,
          maxLength: maxLength,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(
              // Use UnderlineInputBorder
              borderSide: BorderSide(color: AppColor.boaderColor),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.boaderColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.themeColor, width: 1),
            ),
            contentPadding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 22),
            fillColor: Colors.transparent,
            filled: true,
            counterText: '',
            hintText: hintText,
            hintStyle: AppConstant.textFilledStyle,
          ),
        ),
      ),
    );
  }
}
