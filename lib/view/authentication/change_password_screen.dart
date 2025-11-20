import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_loader.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import 'login_screen.dart';
import 'dart:ui' as ui;

class ChangePassword extends StatefulWidget {
  static String routeName = "./ChangePassword";
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();
  dynamic userDetails;
  dynamic userDataArr;
  int userId = 0;
  bool isApiCalling = false;
  bool isCurrentPassHidden = false;
  bool isNewPassHidden = false;
  bool isConfirmPassHidden = false;

  @override
  void initState() {
    super.initState();
    getDetails();
  }

//============================GET DETAILS=======================
  Future<dynamic> getDetails() async {
    final prefs = await SharedPreferences.getInstance();
    userDetails = prefs.getString("userDetails");

    // print("userDetails $userDetails");
    if (userDetails != null) {
      dynamic data = json.decode(userDetails);
      print("up ${data}");
      userId = data['user_id'];
    } else {}
    setState(() {});
  }

//================================CHANGE PASSWORD VALIDATION=================
  passwordValidation(
      String currPassword, String newPassword, String confirmNewPassword) {
    if (currPassword.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.currPasswordMsg[language]);
      return false;
    } else if (currPassword.length < 6) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.passwordMinMessage[language]);
      return false;
    } else if (newPassword.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.newPasswordMsg[language]);
      return false;
    } else if (newPassword.length < 6) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.passwordMinMessage[language]);
      return false;
    } else if (confirmNewPassword.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.confirmNewPasswordMsg[language]);
      return false;
    } else if (confirmNewPassword.length < 6) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.passwordMinMessage[language]);
      return false;
    } else if (confirmNewPassword != newPassword) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.newPasswordandConfirmpassMessage[language]);
      return false;
    } else {
      changePasswordApiCall(newPassword);
    }
  }

//-------------------------------CHANGE PASS API CALL----------------------------------//
  changePasswordApiCall(String password) async {
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}change_password");
    print("Url $url");
    setState(() {
      isApiCalling = true;
    });
    String token = AppConstant.token;
    try {
      var headers = {
        'Authorization': 'Bearer $token',
      };

      var body = {
        'user_id': userId.toString(),
        'current_password': currentPasswordController.text,
        'new_password': password,
      };

      print("body $body");

      http.Response response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      print("response--> $response");
      var res = jsonDecode(response.body);

      print("res333 : $res");
      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        setState(() {
          isApiCalling = false;
        });
        if (res['success'] == true) {
          print('Password Changed');
          final prefs = await SharedPreferences.getInstance();
          prefs.setString("password", password);
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          Navigator.pop(context);
        } else {
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

        throw Exception('Album loading failed!');
      }
    } catch (e) {
      setState(() {
        isApiCalling = false;
      });

      print("Call Update Api");
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: Directionality(
          textDirection:
              language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 100 / 100,
            color: AppColor.secondaryColor,
            child: Stack(
              children: [
                Column(
                  children: [
                    AppHeaderOrange(
                        text: AppLanguage.changePasswordText[language],
                        onPress: () {
                          Navigator.pop(context);
                        }),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 2 / 100,
                    ),
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100),

                            //old password
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              height:
                                  MediaQuery.of(context).size.height * 6 / 100,
                              child: TextFormField(
                                readOnly: false,
                                style: const TextStyle(
                                    height: 1.1,
                                    color: AppColor.textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.visiblePassword,
                                controller: currentPasswordController,
                                maxLength: AppConstant.passwordLength,
                                obscureText: isCurrentPassHidden,
                                decoration: InputDecoration(
                                    border: const UnderlineInputBorder(
                                      // Use UnderlineInputBorder
                                      borderSide: BorderSide(
                                          color: AppColor.primaryColor),
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColor.primaryColor),
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
                                    hintText: AppLanguage
                                        .currentPasswordText[language],
                                    hintStyle: AppConstant.textFilledStyle,
                                    suffixIcon: IconButton(
                                      icon: Container(
                                        alignment: Alignment.centerRight,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                10 /
                                                100,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                8 /
                                                100,
                                        child: Image.asset(
                                            isCurrentPassHidden
                                                ? AppImage.showEyeIcon
                                                : AppImage.hideEyeIcon,
                                            color: AppColor.textColor),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isCurrentPassHidden =
                                              !isCurrentPassHidden;
                                        });
                                      },
                                    )),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100,
                            ),

                            //password field
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              height:
                                  MediaQuery.of(context).size.height * 6 / 100,
                              child: TextFormField(
                                readOnly: false,
                                style: const TextStyle(
                                    height: 1.1,
                                    color: AppColor.textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.visiblePassword,
                                controller: newPasswordController,
                                maxLength: AppConstant.passwordLength,
                                obscureText: isNewPassHidden,
                                decoration: InputDecoration(
                                    border: const UnderlineInputBorder(
                                      // Use UnderlineInputBorder
                                      borderSide: BorderSide(
                                          color: AppColor.primaryColor),
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColor.primaryColor),
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
                                    hintText:
                                        AppLanguage.newPasswordText[language],
                                    hintStyle: AppConstant.textFilledStyle,
                                    suffixIcon: IconButton(
                                      icon: Container(
                                        alignment: Alignment.centerRight,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                10 /
                                                100,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                8 /
                                                100,
                                        child: Image.asset(
                                            isNewPassHidden
                                                ? AppImage.showEyeIcon
                                                : AppImage.hideEyeIcon,
                                            color: AppColor.textColor),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isNewPassHidden = !isNewPassHidden;
                                        });
                                      },
                                    )),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100,
                            ),

                            //confirm new password field
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              height:
                                  MediaQuery.of(context).size.height * 6 / 100,
                              child: TextFormField(
                                readOnly: false,
                                style: const TextStyle(
                                    height: 1.1,
                                    color: AppColor.textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.visiblePassword,
                                controller: confirmNewPasswordController,
                                maxLength: AppConstant.passwordLength,
                                obscureText: isConfirmPassHidden,
                                decoration: InputDecoration(
                                    border: const UnderlineInputBorder(
                                      // Use UnderlineInputBorder
                                      borderSide: BorderSide(
                                          color: AppColor.primaryColor),
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColor.primaryColor),
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
                                    hintText: AppLanguage
                                        .confirmNewPasswordText[language],
                                    hintStyle: AppConstant.textFilledStyle,
                                    suffixIcon: IconButton(
                                      icon: Container(
                                        alignment: Alignment.centerRight,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                10 /
                                                100,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                8 /
                                                100,
                                        child: Image.asset(
                                            isConfirmPassHidden
                                                ? AppImage.showEyeIcon
                                                : AppImage.hideEyeIcon,
                                            color: AppColor.textColor),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isConfirmPassHidden =
                                              !isConfirmPassHidden;
                                        });
                                      },
                                    )),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 45 / 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const NoInternetBanner(),
                  ],
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 6 / 100,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 100 / 100,
                        child: AppButton(
                            text: AppLanguage.submitText[language],
                            onPress: () {
                              passwordValidation(
                                  currentPasswordController.text,
                                  newPasswordController.text,
                                  confirmNewPasswordController.text);
                            }),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
