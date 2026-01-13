import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helper/apis.dart';
import '../../model/chat_user.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_firebase.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '/utilities/app_footer.dart';
import '/view/authentication/forgot_password_screen.dart';
import '/view/authentication/contact_admin.dart';
import '/utilities/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_loader.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class Login extends StatefulWidget {
  static String routeName = "./Login";
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usernameTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isPasswordVisible = true;
  bool isApiCalling = false;
  List<dynamic> languageList = [
    {"id": 0, "name": "English"},
    {"id": 1, "name": "Arabic"},
  ];
  List<dynamic> languageShortList = [
    {"id": 0, "name": "Eng"},
    {"id": 1, "name": "Ar"},
  ];
  String languageName = "Eng";
  int languageId = 0;
  var id = 1;

  @override
  void initState() {
    super.initState();
    setLanguage();
  }

  setLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    dynamic langId = prefs.getString("language_id");
    log("dfd$langId");
    if (langId != null) {
      languageId = int.parse(langId);
      if (languageId == 0) {
        language = 0;
        languageName = "Eng";
      } else {
        language = 1;
        languageName = "Ar";
      }
    } else {
      languageId = 0;
      languageName = "Eng";
    }
    setState(() {});
    log("finalLang$languageId");
  }

//-----------------------------SIGN IN VALIDATION--------------------------------//
  signInValidation(String username, String password) {
    if (username.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.usernameMsg[language]);
      return;
    } else if (password.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.passwordMessage[language]);
      return;
    } else if (password.length < 6) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.passwordMinMessage[language]);
      return;
    } else {
      loginapicallingStart(username, password);
    }
  }

//-----------------------------LOGIN API CALL-----------------------------------//
  loginapicallingStart(username, password) async {
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}sign_in");

    print("Url $url");

    setState(() {
      isApiCalling = true;
    });

    try {
      String playeID = AppConstant.playerID.toString();
      print("playeID line number 101 $playeID");
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.fields['username'] = username.toString();
      formData.fields['password'] = password.toString();
      formData.fields['player_id'] = playeID.toString();
      formData.fields['device_type'] = AppConstant.deviceType.toString();
      http.StreamedResponse response = await formData.send();
      print("response--> $response");
      var responseString = await response.stream.toBytes();
      var res = jsonDecode(utf8.decode(responseString));

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          if (res['userDataArray'] != "NA") {
            AppConstant.token = res['token'];
            print("AppConstant.token ${AppConstant.token}");

            SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
            final prefs = await SharedPreferences.getInstance();
            print("prefs =================>${res['userDataArray']}");
            prefs.setString("userDetails", jsonEncode(res['userDataArray']));
            prefs.setString("password", password);
            FirebaseProvider.firebaseCreateUser(true);
            APIs.userArry = res['userDataArray'];
            APIs.user_id = res['userDataArray']['user_id'].toString();
            updateUser(res['userDataArray'], res['userDataArray']['user_id'],
                AppConstant.playerID);
            log("135line${AppConstant.playerID}");

            if (await userExists(res['userDataArray']['user_id']) && mounted) {
              log("138line${AppConstant.playerID}");
              updateUser(res['userDataArray'], res['userDataArray']['user_id'],
                  AppConstant.playerID);
              print("mounted $mounted");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyFooterPage(
                            indexOfPage: 0,
                          )));
            } else {
              createUser(res['userDataArray']['user_id'], res['userDataArray']);
              updateUser(res['userDataArray'], res['userDataArray']['user_id'],
                  AppConstant.playerID);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const MyFooterPage(indexOfPage: 0)));
            }

            setState(() {
              isApiCalling = false;
            });
          }
        } else {
          // ignore: use_build_context_synchronously
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          setState(() {
            isApiCalling = false;
          });

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

  static Future<void> updateUser(var usserArrey, userId, playerId) async {
    print("userId$userId");
    print("playerId$playerId");
    try {
      await firestore.collection('users').doc(userId.toString()).update({
        'playerId': playerId.toString(),
        'name': usserArrey['fullname'] != null
            ? usserArrey['fullname'].toString()
            : "",
        'email':
            usserArrey['email'] != null ? usserArrey['email'].toString() : "",
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
    double screenHeight = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return WillPopScope(
      onWillPop: () {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: AppColor.secondaryColor,
          body: Directionality(
            textDirection:
                language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            child: Container(
                height: MediaQuery.of(context).size.height * 100 / 100,
                width: MediaQuery.of(context).size.width * 100 / 100,
                decoration: const BoxDecoration(
                    color: AppColor.primaryColor,
                    image: DecorationImage(
                      image: AssetImage(AppImage.hatImage),
                      fit: BoxFit.cover,
                    )),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        // physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 6 / 100,
                            ),
                            //language dropdown
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () {
                                  languageListBottomSheet(
                                      context, screenWidth, screenHeight);
                                },
                                child: Container(
                                  width: screenWidth > 600
                                      ? MediaQuery.of(context).size.width *
                                          18 /
                                          100
                                      : MediaQuery.of(context).size.width *
                                          26 /
                                          100,

                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 10),
                                  // width: MediaQuery.of(context).size.width * 20 / 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColor.secondaryColor),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                4 /
                                                100,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                4 /
                                                100,
                                        child:
                                            Image.asset(AppImage.languageIcon),
                                      ),
                                      Padding(
                                        padding: language == 1
                                            ? const EdgeInsets.only(right: 4.0)
                                            : const EdgeInsets.only(left: 4.0),
                                        child: Text(
                                          languageName.toString(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: AppColor.secondaryColor,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                2 /
                                                100,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                3.5 /
                                                100,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                3.5 /
                                                100,
                                        child: Image.asset(
                                          AppImage.dropDownIcon,
                                          color: AppColor.secondaryColor,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            //logo
                            Container(
                                width: MediaQuery.of(context).size.width *
                                    20 /
                                    100,
                                height: MediaQuery.of(context).size.width *
                                    20 /
                                    100,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(1000),
                                    child: Image.asset(AppImage.applogoImage))),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 4 / 100,
                            ),

                            //my boat text
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              child: Text(
                                AppLanguage.aventraText[language],
                                style: const TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColor.secondaryColor),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100,
                            ),

                            //welcome
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              child: Text(
                                AppLanguage.welcomeText[language],
                                style: const TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.secondaryColor),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 1 / 100,
                            ),

                            //login text
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              child: Text(
                                AppLanguage.loginText[language],
                                style: const TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.secondaryColor),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100,
                            ),

                            //username
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              height:
                                  MediaQuery.of(context).size.height * 6 / 100,
                              child: TextFormField(
                                readOnly: false,
                                style: const TextStyle(
                                    height: 1.1,
                                    color: Color(0xffBEC3C7),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400),
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.text,
                                controller: usernameTextEditingController,
                                maxLength: AppConstant.fullnameLength,
                                decoration: InputDecoration(
                                  border: const UnderlineInputBorder(
                                    // Use UnderlineInputBorder
                                    borderSide: BorderSide(
                                        color: AppColor.secondaryColor),
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColor.secondaryColor),
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
                                  hintText: AppLanguage.usernameText[language],
                                  hintStyle: const TextStyle(
                                      color: Color(0xffBEC3C7),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100,
                            ),

                            //password
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              height:
                                  MediaQuery.of(context).size.height * 6 / 100,
                              child: TextFormField(
                                  readOnly: false,
                                  style: const TextStyle(
                                      height: 1.1,
                                      color: Color(0xffBEC3C7),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400),
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.visiblePassword,
                                  controller: passwordTextEditingController,
                                  maxLength: AppConstant.passwordLength,
                                  obscureText: isPasswordVisible,
                                  decoration: InputDecoration(
                                      border: const UnderlineInputBorder(
                                        // Use UnderlineInputBorder
                                        borderSide: BorderSide(
                                            color: AppColor.secondaryColor),
                                      ),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColor.secondaryColor),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColor.secondaryColor,
                                            width: 1),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 0),
                                      fillColor: Colors.transparent,
                                      filled: true,
                                      counterText: '',
                                      hintText:
                                          AppLanguage.passwordText[language],
                                      hintStyle: const TextStyle(
                                          color: Color(0xffBEC3C7),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20),
                                      suffixIcon: IconButton(
                                        icon: Container(
                                          alignment: Alignment.bottomCenter,
                                          margin:
                                              const EdgeInsets.only(right: 4),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              10 /
                                              100,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              8 /
                                              100,
                                          child: Image.asset(
                                              isPasswordVisible
                                                  ? AppImage.showEyeIcon
                                                  : AppImage.hideEyeIcon,
                                              color: AppColor.textLightColor),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isPasswordVisible =
                                                !isPasswordVisible;
                                          });
                                        },
                                      ))),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100,
                            ),

                            //forgot password
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPasswordScreen()));
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width *
                                    90 /
                                    100,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  AppLanguage.forgotPasswordText[language],
                                  style: const TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: AppColor.secondaryColor),
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 4 / 100,
                            ),

                            //login button
                            AppButton(
                                text: AppLanguage.loginText[language],
                                onPress: () {
                                  signInValidation(
                                      usernameTextEditingController.text,
                                      passwordTextEditingController.text);
                                }),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 6 / 100,
                            ),

                         

                            //Contact Admin
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) =>
                                            const ContactAdmin())));
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width *
                                    90 /
                                    100,
                                alignment: Alignment.center,
                                child: Text(
                                  AppLanguage.contactAdminText[language],
                                  style: const TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: AppColor.secondaryColor,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColor.secondaryColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const NoInternetBanner(),
                  ],
                )),
          ),
        ),
      ),
    );
  }

//-----------------language selection bottom sheet------------------
  void languageListBottomSheet(BuildContext context, width, height) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints.expand(width: width),
      useRootNavigator: false,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Container(
                height: height,
                width: width,
                decoration: const BoxDecoration(
                  // color: Colors.white,
                  color: AppColor.secondaryColor,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 6 / 100,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width:
                                  MediaQuery.of(context).size.width * 6 / 100,
                              height:
                                  MediaQuery.of(context).size.width * 6 / 100,
                              child: Image.asset(
                                AppImage.backIcon,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 4 / 100,
                          ),
                          Text(
                            AppLanguage.languageText[language],
                            style: const TextStyle(
                              color: AppColor.primaryColor,
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 3 / 100),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(children: [
                          ...List.generate(
                            languageList.length,
                            (index) => Container(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    selectKey(
                                        index,
                                        languageList[index]["name"],
                                        languageList[index]["id"]);
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 3),
                                    width: width,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  90 /
                                                  100,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  6 /
                                                  100,
                                              decoration: BoxDecoration(
                                                border: Border.all(width: .5),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            40 /
                                                            100,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20),
                                                    child: Text(
                                                      languageList[index]
                                                          ["name"],
                                                      style: const TextStyle(
                                                        color: AppColor
                                                            .primaryColor,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            40 /
                                                            100,
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            5 /
                                                            100,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            5 /
                                                            100,
                                                  
                                                    child: languageList[index]
                                                                ["id"] ==
                                                            languageId
                                                        ? Image.asset(
                                                            AppImage
                                                                .tickOrangeIcon,
                                                            fit: BoxFit.fill,
                                                          )
                                                        : Image.asset(
                                                            AppImage
                                                                .orangeBoxIcon,
                                                            fit: BoxFit.fill,
                                                          ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              1 /
                                              100,
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  selectKey(
    index,
    name,
    languageId,
  ) {
    setState(() async {
      this.languageId = languageId;

      var selectedLanguage = languageShortList.firstWhere(
        (lang) => lang['id'] == languageId,
        orElse: () => null,
      );

      selectedLanguage != null ? selectedLanguage['name'] : 'Unknown';
      languageName = selectedLanguage['name'];
      setState(() {
        selectedLanguage = languageList[index]['id'];
      });
      language = selectedLanguage;

      // -----Local Storage ------------
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("language_id", jsonEncode(selectedLanguage));
      log("Selected ID: $languageId");
      log("Selected Name: $selectedLanguage");
    });
  }
}
