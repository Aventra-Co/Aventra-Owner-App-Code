import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_snack_bar_toast_message.dart';
import '/view/authentication/login_screen.dart';
import '../../controller/app_button.dart';
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_header.dart';
import '../../controller/app_language.dart';
import '../../controller/app_loader.dart';
import 'dart:ui' as ui;

class DeleteAccount extends StatefulWidget {
  static String routeName = "./DeleteAccount";
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _ContactAdminState();
}

class _ContactAdminState extends State<DeleteAccount> {
  TextEditingController messageTextEditingController = TextEditingController();
  int userId = 0;
  bool isApiCalling = false;
  dynamic userDetails;

  @override
  void initState() {
    super.initState();
    getDetails();
  }

//-----------------------------GET DETAILS---------------------------//
  Future<dynamic> getDetails() async {
    final prefs = await SharedPreferences.getInstance();
    userDetails = prefs.getString("userDetails");

    print("userDetails $userDetails");
    if (userDetails != null) {
      dynamic data = json.decode(userDetails);
      print("up $data");
      userId = data['user_id']; //Retrieve userId from local storage
      print('userId- $userId');
      setState(() {});
    }
  }

  //-----------------------------------REASON VALIDATION---------------------------//
  reasonValidation(String reason) {
    if (reason.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.reasonMsg[language]);
      return false;
    } else {
      deleteAccountApiCall(reason);
    }
  }

//---------------------------------DELETE ACCOUNT API CALL---------------------------//
  deleteAccountApiCall(String reason) async {
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}delete_account");
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
        'reason': reason,
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
          print('Account Deleted');
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          final prefs = await SharedPreferences.getInstance();
          print("prefs =================>$prefs");

          prefs.remove('userDetails');
          prefs.remove("password");

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
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
            child: Column(children: [
              AppHeaderOrange(
                  text: AppLanguage.deleteAccountText[language],
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

                      //reason text
                      Container(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Text(
                          AppLanguage.deleteAccRequestMsg[language],
                          style: const TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColor.primaryColor),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 3 / 100,
                      ),

                      // ----------- Message Input -------------
                      Container(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: TextFormField(
                          style: const TextStyle(
                              height: 1, color: AppColor.textColor),
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
                              hintText: AppLanguage.reasonText[language],
                              hintStyle: const TextStyle(
                                  color: AppColor.textColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12)),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 8 / 100),
                      AppButton(
                          text: AppLanguage.sendText[language],
                          onPress: () {
                            // Navigator.pop(context);
                            reasonValidation(messageTextEditingController.text);
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
