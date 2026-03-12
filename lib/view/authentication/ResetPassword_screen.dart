import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../controller/app_button.dart';
import '../../controller/app_color.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_header.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';
import '../../controller/app_loader.dart';
import '../../controller/app_snack_bar_toast_message.dart';
import 'login_screen.dart';

class ResetPasswordHeader extends StatelessWidget {
  static const routeName = './ResetPasswordHeader';
  const ResetPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    ResetPasswordIdClass? object;
    object = ModalRoute.of(context)!.settings.arguments as ResetPasswordIdClass;

    // print("Data Retrieved ${object.userId}");
    return ResetPassword(
      userId: object.userId,
    );
  }
}

class ResetPassword extends StatefulWidget {
  final String userId;
  const ResetPassword({super.key, required this.userId});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmpasswordTextEditingController =
      TextEditingController();
  bool isPasswordVisible = true;
  bool isConfirmPasswordVisible = true;
  bool isApiCalling = false;

//--------------------------------------CREATE PASSWORD VALIDATION---------------------------//
  createPasswordValidation(
      BuildContext context, String password, String confirmpass) {
    if (password.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.passwordMessage[language]);
    } else if (password.length < 6) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.passwordMinMessage[language]);
    } else if (confirmpass.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.confirmNewPasswordMsg[language]);
    } else if (confirmpass.length < 6) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.passwordMinMessage[language]);
    } else if (password != confirmpass) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.passwordandConfrimpassMessage[language]);
    } else {
      print(" line 66 ${widget.userId}");
      createNewPasswordRequest(widget.userId, password);
    }
  }

  // ---------------------CREATE NEW PASSWORD API CALL-------------------//
  createNewPasswordRequest(userId, password) async {
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}forgot_change_password");

    print("Url $url");

    setState(() {
      isApiCalling = true;
    });

    try {
      http.MultipartRequest formData = http.MultipartRequest('POST', url);

      formData.fields['user_id'] = userId.toString();
      formData.fields['new_password'] = password.toString();
      http.StreamedResponse response = await formData.send();
      print("response--> $response");
      var responseString = await response.stream.toBytes();
      var res = jsonDecode(utf8.decode(responseString));

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          setState(() {
            isApiCalling = false;
          });
          // ignore: use_build_context_synchronously
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          //FirebaseProvider.firebaseCreateUser(true);
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        } else {
          // ignore: use_build_context_synchronously
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          setState(() {
            isApiCalling = false;
          });
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark));

    return WillPopScope(
      onWillPop: () {
        sureGoBackBottomSheet(context);
        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            body: Container(
                height: MediaQuery.of(context).size.height * 100 / 100,
                width: MediaQuery.of(context).size.width * 100 / 100,
                color: AppColor.secondaryColor,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100,
                    ),
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            CustomAppHeader(
                                text: AppLanguage.resetPasswordText[language],
                                onPress: () {
                                  sureGoBackBottomSheet(context);
                                }),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100,
                            ),
                            Column(
                              children: [
                                //password
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      6 /
                                      100,
                                  child: TextFormField(
                                      readOnly: false,
                                      style: const TextStyle(
                                          height: 1.1,
                                          color: AppColor.textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      controller: passwordTextEditingController,
                                      maxLength: AppConstant.passwordLength,
                                      obscureText: isPasswordVisible,
                                      decoration: InputDecoration(
                                          border: const UnderlineInputBorder(
                                            // Use UnderlineInputBorder
                                            borderSide: BorderSide(
                                                color: AppColor.boaderColor),
                                          ),
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColor.boaderColor),
                                          ),
                                          focusedBorder:
                                              const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColor.themeColor,
                                                width: 1),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 0),
                                          fillColor: Colors.transparent,
                                          filled: true,
                                          counterText: '',
                                          hintText: AppLanguage
                                              .passwordText[language],
                                          hintStyle: const TextStyle(
                                              color: AppColor.textColor,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16),
                                          suffixIcon: IconButton(
                                            icon: Container(
                                              alignment: Alignment.bottomCenter,
                                              margin: const EdgeInsets.only(
                                                  right: 4),
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
                                                  color:
                                                      AppColor.textLightColor),
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
                                  height: MediaQuery.of(context).size.height *
                                      2 /
                                      100,
                                ),

                                //confirm password
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      6 /
                                      100,
                                  child: TextFormField(
                                      readOnly: false,
                                      style: const TextStyle(
                                          height: 1.1,
                                          color: AppColor.textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      controller:
                                          confirmpasswordTextEditingController,
                                      maxLength: AppConstant.passwordLength,
                                      obscureText: isConfirmPasswordVisible,
                                      decoration: InputDecoration(
                                          border: const UnderlineInputBorder(
                                            // Use UnderlineInputBorder
                                            borderSide: BorderSide(
                                                color: AppColor.boaderColor),
                                          ),
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColor.boaderColor),
                                          ),
                                          focusedBorder:
                                              const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColor.themeColor,
                                                width: 1),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 0),
                                          fillColor: Colors.transparent,
                                          filled: true,
                                          counterText: '',
                                          hintText: AppLanguage
                                              .confirmNewPasswordText[language],
                                          hintStyle: const TextStyle(
                                              color: AppColor.textColor,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16),
                                          suffixIcon: IconButton(
                                            icon: Container(
                                              alignment: Alignment.bottomCenter,
                                              margin: const EdgeInsets.only(
                                                  right: 4),
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
                                                  isConfirmPasswordVisible
                                                      ? AppImage.showEyeIcon
                                                      : AppImage.hideEyeIcon,
                                                  color:
                                                      AppColor.textLightColor),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                isConfirmPasswordVisible =
                                                    !isConfirmPasswordVisible;
                                              });
                                            },
                                          ))),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      2 /
                                      100,
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      6 /
                                      100,
                                ),

                                AppButton(
                                  text: AppLanguage.updateButtonText[language],
                                  onPress: () {
                                    createPasswordValidation(
                                        context,
                                        passwordTextEditingController.text,
                                        confirmpasswordTextEditingController
                                            .text);
                                  },
                                )
                              ],
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 50 / 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                 const NoInternetBanner(),
                  ],
                ))),
      ),
    );
  }

  void sureGoBackBottomSheet(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(
        AppLanguage.noText[language],
        style: TextStyle(
            fontFamily: AppFont.fontFamily,
            color: AppColor.redcolor,
            fontSize: 14,
            fontWeight: FontWeight.w600),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        AppLanguage.yesText[language],
        style: TextStyle(
            fontFamily: AppFont.fontFamily,
            color: AppColor.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w600),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
        );
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        AppLanguage.backText[language],
        style: TextStyle(
            fontFamily: AppFont.fontFamily,
            color: AppColor.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w500),
      ),
      content: Text(
        AppLanguage.sureGoBackText[language],
        style: TextStyle(
            fontFamily: AppFont.fontFamily,
            color: AppColor.primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w400),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
