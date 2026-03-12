import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controller/app_button.dart';
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_header.dart';
import '../../controller/app_language.dart';
import '../../controller/app_loader.dart';
import '../../controller/textinput.dart';
import 'dart:ui' as ui;

class ContactAdmin extends StatefulWidget {
  static String routeName = "./ContactAdmin";
  const ContactAdmin({super.key});

  @override
  State<ContactAdmin> createState() => _ContactAdminState();
}

class _ContactAdminState extends State<ContactAdmin> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController messageTextEditingController = TextEditingController();
  dynamic userDetails;
  dynamic userDataArr;
  int userId = 0;
  bool isApiCalling = false;

  @override
  void initState() {
    super.initState();
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
            child: Column(children: [
              AppHeaderOrange(
                  text: AppLanguage.contactAdminHeadText[language],
                  onPress: () {
                    Navigator.pop(context);
                  }),
              SizedBox(
                height: MediaQuery.of(context).size.height * 2 / 100,
              ),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100),

                      //name text
                      Container(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Text(
                          AppLanguage.nameText[language],
                          style: const TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColor.titleColor),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),

                      // -----------first Number -------------
                      CustomTextFormFieldBox(
                          readOnly: false,
                          fillColorStatus: 0,
                          controller: nameTextEditingController,
                          hintText: AppLanguage.enterNameText[language],
                          keyboardtype: TextInputType.name,
                          maxLength: AppConstant.fullnameLength),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100),

                      //email text
                      Container(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Text(
                          AppLanguage.emailText[language],
                          style: const TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColor.titleColor),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),
                      // ----------- email Input -------------
                      CustomTextFormFieldBox(
                          readOnly: false,
                          fillColorStatus: 0,
                          controller: emailTextEditingController,
                          hintText: AppLanguage.enterEmailText[language],
                          keyboardtype: TextInputType.emailAddress,
                          maxLength: AppConstant.emailMaxLength),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100),

                      //description text
                      Container(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Text(
                          AppLanguage.descriptionText[language],
                          style: const TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColor.titleColor),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),
                      // ----------- Message Input -------------
                      Container(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: TextFormField(
                          style: const TextStyle(
                              height: 1,
                              color: AppColor.textColor,
                              fontSize: 16),
                          keyboardType: TextInputType.multiline,
                          controller: messageTextEditingController,
                          maxLines: 7,
                          maxLength: AppConstant.describeLength,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColor.boaderColor,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColor.boaderColor,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColor.themeColor,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 15),
                              fillColor: AppColor.secondaryColor,
                              filled: true,
                              counterText: '',
                              hintText:
                                  AppLanguage.enterDescriptionText[language],
                              hintStyle: const TextStyle(
                                  color: AppColor.textColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16)),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 8 / 100),

                      AppButton(
                          text: AppLanguage.sendText[language],
                          onPress: () {
                            Navigator.pop(context);
                          }),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 5 / 100),
                    ],
                  ),
                ),
              ),
              const NoInternetBanner(),
            ])),
      )),
    );
  }
}
