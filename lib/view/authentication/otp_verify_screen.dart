import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_footer.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_language.dart';

class OTP extends StatefulWidget {
  static String routeName = "./OTP";
  const OTP({super.key});

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  TextEditingController mobileTextEditingController = TextEditingController();

  bool resendText = true;

  TextEditingController pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: MediaQuery.of(context).size.width * 20 / 100,
      height: MediaQuery.of(context).size.width * 12 / 100,
      margin: const EdgeInsets.only(right: 5),
      textStyle: const TextStyle(
        fontSize: 23,
        fontFamily: AppFont.fontFamily,
        fontWeight: FontWeight.w600,
        color: AppColor.primaryColor,
      ),
      decoration: BoxDecoration(
        // border: Border.all(color: AppColor.greyLightColor),
        color: AppColor.textLightColor,
        borderRadius: BorderRadius.circular(8),
      ),
    );
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.secondaryColor,
        body: Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            color: AppColor.secondaryColor,
            child: Column(
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height * 1 / 100),
                AppHeader(
                    text: "",
                    onPress: () {
                      Navigator.pop(context);
                    }),
                SizedBox(
                    height: MediaQuery.of(context).size.height * 6 / 100),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 3 / 100,
                      ),
                      Container(
                          alignment: Alignment.center,
                          child: Text(
                            AppLanguage.otpVerficationText[language],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColor.themeColor,
                                fontSize: 30,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w800),
                          )),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          alignment: Alignment.center,
                          child: Text(
                            AppLanguage.sentOtpText[language],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w400),
                          )),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  5 /
                                  100,
                            ),
                            Pinput(
                              controller: pinController,
                              defaultPinTheme: defaultPinTheme,
                              autofocus: true,
                              length: 6,
                              hapticFeedbackType:
                                  HapticFeedbackType.lightImpact,
                              onCompleted: (pin) {},
                              onChanged: (value) {},
                              cursor: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 13),
                                    width: 15,
                                    height: 2,
                                    color: AppColor.textColor,
                                  ),
                                ],
                              ),
                              submittedPinTheme: defaultPinTheme.copyWith(
                                decoration: defaultPinTheme.decoration!
                                    .copyWith(
                                        borderRadius:
                                            BorderRadius.circular(5),
                                        border: Border.all(
                                          color: AppColor.textColor,
                                        )),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  4 /
                                  100,
                            ),
                          ],
                        ),
                      ),
                      AppButton(
                          text: AppLanguage.verifyButtonText[language],
                          onPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyFooterPage(
                                        indexOfPage: 0,
                                      )),
                            );
                          }),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 3.5 / 100,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLanguage.didnotReciveOtpText[language],
                              style: const TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  color: AppColor.textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                AppLanguage.resendText[language],
                                style: const TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    color: AppColor.redcolor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          AppLanguage.changeEmailText[language],
                          style: const TextStyle(
                              fontFamily: AppFont.fontFamily,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColor.textColor,
                              color: AppColor.textColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12),
                        ),
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 26.5 / 100,
                      ),
                    ]),
                  ),
                ),
            const NoInternetBanner(),
              ],
            )),
      ),
    );
  }
}
