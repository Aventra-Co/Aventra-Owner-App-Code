import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_boat_ownerside/view/authentication/setting_screen.dart';
import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_loader.dart';
import 'dart:ui' as ui;

class ChangeLanguage extends StatefulWidget {
  static String routeName = "./ChangeLanguage";
  const ChangeLanguage({super.key});

  @override
  State<ChangeLanguage> createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangeLanguage> {
  dynamic userDetails;
  dynamic userDataArr;
  int userId = 0;
  bool isApiCalling = false;
  int selectedLanguage = 0;
  List languageList = [
    {
      "id": 0,
      "title": "English",
    },
    {
      "id": 1,
      "title": "Arabic",
    },
    // {
    //   "id": 3,
    //   "title": AppLanguage.frenchText[language],
    // },
    // {
    //   "id": 4,
    //   "title": AppLanguage.italianText[language],
    // },
    // {
    //   "id": 5,
    //   "title": AppLanguage.koreanText[language],
    // },
  ];
  dynamic languageId;
  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  Future<dynamic> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    dynamic userDetails = prefs.getString("userDetails");
    languageId = prefs.getString("language_id");
    log(languageId);
    if (languageId != null) {
      selectedLanguage = int.parse(languageId);
    }

    print("userDetails $userDetails");
    print(languageId.runtimeType);

    // ----------- userid and phone number --------------
    if (userDetails != null) {
      // dynamic data = json.decode(userDetails);
      setState(() {});
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
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            //image header
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 100 / 100,
                              height:
                                  MediaQuery.of(context).size.height * 20 / 100,
                              decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(AppImage.headerBgImage),
                                      fit: BoxFit.cover),
                                  // color: AppColor.themeColor,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(50),
                                      bottomRight: Radius.circular(50))),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: AppConstant.deviceType == "ios"
                                        ? MediaQuery.of(context).size.height *
                                            6 /
                                            100
                                        : MediaQuery.of(context).size.height *
                                            4 /
                                            100,
                                  ),

                                  //change lang
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        100 /
                                        100,
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        //edit
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Transform.rotate(
                                            angle: language == 1 ? 3.1416 : 0,
                                            child: Container(
                                              color: Colors.transparent,
                                              alignment: Alignment.center,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  15 /
                                                  100,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  7 /
                                                  100,
                                              child:
                                                  Image.asset(AppImage.backIcon),
                                            ),
                                          ),
                                        ),

                                        //profile
                                        Container(
                                          alignment: Alignment.center,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              70 /
                                              100,
                                          child: Text(
                                            AppLanguage
                                                .changeLanguageText[language],
                                            style: const TextStyle(
                                                color: AppColor.secondaryColor,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: AppFont.fontFamily),
                                          ),
                                        ),

                                        Container(
                                          alignment: Alignment.centerRight,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              15 /
                                              100,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              7 /
                                              100,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        10 /
                                        100,
                                  ),
                                ],
                              ),
                            ),
                         
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100,
                            ),

                            //language list
                            Wrap(
                              children: [
                                ...List.generate(languageList.length, (index) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedLanguage =
                                                languageList[index]['id'];
                                          });

                                          // -----Local Storage End------------
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              90 /
                                              100,
                                          decoration: BoxDecoration(
                                              color: selectedLanguage ==
                                                      languageList[index]['id']
                                                  ? AppColor.themeColor
                                                  : AppColor.secondaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 1,
                                                  color: AppColor.boaderColor)),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                80 /
                                                100,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 18),
                                              child: Text(
                                                languageList[index]['title'],
                                                style: TextStyle(
                                                    color: selectedLanguage ==
                                                            languageList[index]
                                                                ['id']
                                                        ? AppColor
                                                            .secondaryColor
                                                        : AppColor.primaryColor,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        AppFont.fontFamily),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                2 /
                                                100,
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ,   const NoInternetBanner(),
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
                            text: AppLanguage.doneText[language],
                            onPress: () async {
                              language = selectedLanguage;

                              // -----Local Storage ------------
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setString(
                                  "language_id", jsonEncode(selectedLanguage));

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingScreen()));
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
