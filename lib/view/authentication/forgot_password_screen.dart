import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '/utilities/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_loader.dart';
import '../../utilities/textinput.dart';
import 'forget_otp_verification.dart';
import 'login_screen.dart';
import 'dart:ui' as ui;

class ForgotPasswordScreen extends StatefulWidget {
  static String routeName = "./ForgotPasswordScreen";
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  bool isApiCalling = false;

  //---------------------------------FORGOT PASS EMAIL VALIDATION--------------------------
  forgotPasswordEmailValidation(String email) {
    if (email.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.emailMessage[language]);
      return;
    } else if (!AppConstant.emailValidatorRegExp.hasMatch(email)) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.emailValidMessage[language]);
      return;
    } else {
      forgetPasswordRequestApiCall(email);
    }
  }

  //-----------------------forgot passward---------------
  forgetPasswordRequestApiCall(email) async {
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}forgot_password");

    print("Url $url");

    setState(() {
      isApiCalling = true;
    });

    try {
      String playeID = AppConstant.playerID.toString();
      print("playeID line number 101 $playeID");
      http.MultipartRequest formData = http.MultipartRequest('POST', url);

      formData.fields['email'] = email.toString();

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
          if (res["userDataArray"] != null) {
            var userData = res["userDataArray"];
            int userId = userData["user_id"];
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setInt('user_id', userId);
            Navigator.pushNamed(context, ForgetOTPVerificationHeader.routeName,
                arguments: ForgotOtpResendEmailClass(
                    userId: userId.toString(), email: ''));
            SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          } else {
            SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          }
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
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
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
                        image: AssetImage(AppImage.loginPageImage),
                        fit: BoxFit.cover)),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100,
                    ),
                    Container(
                      alignment: language == 1
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width * 100 / 100,
                      height: MediaQuery.of(context).size.height * 8 / 100,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          // color: Colors.red,
                          width: MediaQuery.of(context).size.width * 15 / 100,
                          height: MediaQuery.of(context).size.width * 8 / 100,
                          child: Image.asset(
                            AppImage.leftArrowIcon,
                            color: AppColor.secondaryColor,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        // physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 4 / 100,
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
                                  MediaQuery.of(context).size.height * 2 / 100,
                            ),

                            //my boat text
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              alignment: Alignment.center,
                              child: Text(
                                AppLanguage.aventraOwnerText[language],
                                style: const TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.themeColor),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 10 / 100,
                            ),

                            //email
                            CustomTextFormFieldBox(
                              controller: emailTextEditingController,
                              hintText: AppLanguage.emailText[language],
                              maxLength: AppConstant.fullnameLength,
                              keyboardtype: TextInputType.text,
                              fillColorStatus: 0,
                              readOnly: false,
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 3 / 100,
                            ),

                            //submit button
                            AppButton(
                                text: AppLanguage.submitText[language],
                                onPress: () {
                                  forgotPasswordEmailValidation(
                                      emailTextEditingController.text);
                                }),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100,
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
}
