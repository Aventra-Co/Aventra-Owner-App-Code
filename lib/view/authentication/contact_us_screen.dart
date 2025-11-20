import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_loader.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../../utilities/textinput.dart';
import 'login_screen.dart';
import 'dart:ui' as ui;

class ContactUs extends StatefulWidget {
  static String routeName = "./ContactUs";
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactAdminState();
}

class _ContactAdminState extends State<ContactUs> {
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
    getDetails();
  }

//------------------------------GET DETAILS-------------------------------//
  Future<dynamic> getDetails() async {
    final prefs = await SharedPreferences.getInstance();
    userDetails = prefs.getString("userDetails");

    if (userDetails != null) {
      dynamic data = json.decode(userDetails);
      print("up ${data}");
      userId = data['user_id']; //Retrieve userId from local storage
      print('74$userId');

      nameTextEditingController.text = data["fullname"] ?? "";
      emailTextEditingController.text = data["email"] ?? '';
    } else {
      nameTextEditingController.text = "";
      emailTextEditingController.text = "";
    }
    setState(() {});
  }

  //------------------------------CONTACT US VALIDATION-------------------------------//
  contactUsValidation(String name, String email, String msg) {
    if (name.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.fullNameMessage[language]);
      return;
    } else if (email.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.emailMessage[language]);
      return;
    } else if (!AppConstant.emailValidatorRegExp.hasMatch(email)) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.emailValidMessage[language]);
      return;
    } else if (msg.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.descriptionMsg[language]);
      return;
    } else {
      contactUsAPICall(name, email, msg);
    }
  }

//-----------------------------------CONTACT US API CALL-------------------------------------//
  contactUsAPICall(name, email, msg) async {
    print("86");
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}contact_us");

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
        'name': name,
        'email': email,
        'message': msg,
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
        print("res : $res");
        if (res['success'] == true) {
          setState(() {
            isApiCalling = false;
          });
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          Navigator.pop(context);
        } else {
          // ignore: use_build_context_synchronously
          setState(() {
            isApiCalling = false;
          });
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
                  text: AppLanguage.contactUsText[language],
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
                                  color: AppColor.textColor,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColor.textColor,
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
                            contactUsValidation(
                                nameTextEditingController.text,
                                emailTextEditingController.text,
                                messageTextEditingController.text);
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
