import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controller/route_observer.dart';
import '../../controller/app_footer.dart';
import '/view/authentication/contact_us_screen.dart';
import '../content_screen/content_screen.dart';
import '/view/authentication/change_password_screen.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_header.dart';
import '../../controller/app_language.dart';
import '/view/authentication/edit_profile_screen.dart';
import '../../controller/app_color.dart';
import '../../controller/app_image.dart';
import 'change_language_screen.dart';
import 'delete_account_screen.dart';
import 'login_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_snack_bar_toast_message.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class SettingScreen extends StatefulWidget {
  static String routeName = './SettingScreen';
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => SettingScreenScreenState();
}

class SettingScreenScreenState extends State<SettingScreen> with RouteAware {
  List accountOptionsList = [
    {
      "id": 1,
      "title": AppLanguage.editProfileText[language],
    },
    {
      "id": 2,
      "title": AppLanguage.changePasswordText[language],
    },
    {
      "id": 3,
      "title": AppLanguage.changeLanguageText[language],
    },
  ];

  List supportOptionsList = [
    {
      "id": 4,
      "title": AppLanguage.termsConditionText[language],
    },
    {
      "id": 5,
      "title": AppLanguage.privacyPolicyText[language],
    },
    {
      "id": 6,
      "title": AppLanguage.aboutUsText[language],
    },
    {
      "id": 7,
      "title": AppLanguage.contactUsText[language],
    },
    {
      "id": 8,
      "title": AppLanguage.shareAppText[language],
    },
    {
      "id": 9,
      "title": AppLanguage.rateAppText[language],
    },
    {
      "id": 10,
      "title": AppLanguage.deleteAccountText[language],
    },
    {
      "id": 11,
      "title": AppLanguage.logoutText[language],
    },
  ];

  bool isApiCalling = false;
  int userId = 0;
  String fullName = "";
  String email = "";
  dynamic userDetails;
  dynamic userDataArr;
  String shareWith = "";
  String termsandconditionstype = "";
  String privacypolicytype = "";
  String aboutustype = "";
  String rateappurl = "";
  String profileImage = "";
  String vendorId = '';
  var fileName = 'NA';

  @override
  void initState() {
    super.initState();
    getUserDetails();
    getAllContent();
  }

  //----------------------------GET USER DETAILS--------------------------------//
  Future<dynamic> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    userDetails = prefs.getString("userDetails");

    // print("userDetails $userDetails");
    if (userDetails == null) {
      // print("worked");
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.notRegisteredMsg[language]);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Login()));
    } else {
      userDataArr = jsonDecode(userDetails);
      userId = userDataArr['user_id'] ?? 0;
      fullName = userDataArr['name'] ?? "";
      profileImage = userDataArr["image"] ?? "NA";
      vendorId = userDataArr["id"] ?? "NA";
    }

    // print("userDataArr $userDataArr");
    isApiCalling = false;
    setState(() {});
  }

//-----------------Sign Out-----------------------
  localstorageclearbutton() async {
    final prefs = await SharedPreferences.getInstance();
    print("prefs =================>$prefs");
    prefs.remove('userDetails');
    prefs.remove('password');

    log("Worked");

    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

//-----------------GET CONTENT API CALL-----------------//
  Future<void> getAllContent() async {
    Uri url = Uri.parse(
        '${AppConfigProvider.apiUrl}/get_all_content?language_id=$language');
    print("url $url");

    try {
      final response = await http.get(
        url,
      );

      dynamic res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // print("res $res");
        if (res['success'] == true) {
          setState(() {
            isApiCalling = false;
          });
          List data = res['content_arr'];
          for (var i = 0; i < data.length; i++) {
            if (data[i]['content_type'] == 5) {
              setState(() {
                shareWith = data[i]['content_english'];
              });
              print("share app ${data[i]['content']}");
            }
            if (data[i]['content_type'] == 2) {
              var url1 = data[i]['content_url'];

              setState(() {
                termsandconditionstype = url1;
              });
              print('289 term $termsandconditionstype');
            }

            if (data[i]['content_type'] == 1) {
              var url1 = data[i]['content_url'];

              setState(() {
                privacypolicytype = url1;
              });
              print('289 privacy $privacypolicytype');
            }
            if (data[i]['content_type'] == 0) {
              var url1 = data[i]['content_url'];

              setState(() {
                aboutustype = url1;
              });
              print('289 about $aboutustype');
            }

            if (AppConstant.deviceType == 'android') {
              if (data[i]['content_type'] == 4) {
                var androidurl = data[i]['content_english'];

                setState(() {
                  rateappurl = androidurl;
                });
                print('rateappurl $rateappurl');
              }
            }

            if (AppConstant.deviceType == 'ios') {
              if (data[i]['content_type'] == 3) {
                var iosurl = data[i]['content_english'];

                setState(() {
                  rateappurl = iosurl;
                });
              }
            }
          }
        }
      } else {
        setState(() {
          isApiCalling = false;
        });
        if (res['active_status'] == 0) {
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Login()));
        }
      }
    } catch (e) {}
  }

//------------------------SHARE  APP FUNCTION------------------//
  shareApp(BuildContext context) async {
    print("share187 $shareWith");
    var shareUrl = shareWith;

    final RenderBox box = context.findRenderObject() as RenderBox;
    await Share.share(shareUrl,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

//---------------------------OPEN RATE URL-----------------------//
  Future openUrl({
    required String url,
    bool inApp = false,
  }) async {
    print(url);
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      // If not, prepend https:// to the URL
      url = 'https://$url';
    }

    if (await canLaunch(url)) {
      await launch(url,
          forceSafariVC: inApp, forceWebView: inApp, enableJavaScript: true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void didPopNext() {
    getAllContent();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    navigation(int id) {
      if (id == 1) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const EditProfileScreen()));
      } else if (id == 2) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ChangePassword()));
      } else if (id == 3) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ChangeLanguage()));
      } else if (id == 4) {
        Navigator.pushNamed(context, Content.routeName,
            arguments: ContentClass(
                header: AppLanguage.termsConditionText[language],
                contenttype: termsandconditionstype));
      } else if (id == 5) {
        Navigator.pushNamed(context, Content.routeName,
            arguments: ContentClass(
                header: AppLanguage.privacyPolicyText[language],
                contenttype: privacypolicytype));
      } else if (id == 6) {
        Navigator.pushNamed(context, Content.routeName,
            arguments: ContentClass(
                header: AppLanguage.aboutUsText[language],
                contenttype: aboutustype));
      } else if (id == 7) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ContactUs()));
      } else if (id == 9) {
        openUrl(url: rateappurl);
      } else if (id == 8) {
        shareApp(
          context,
        );
      } else if (id == 10) {
        _deleteAccountBottomSheet(context, screenWidth);
      } else if (id == 11) {
        _logoutBottomSheet(context, screenWidth);
      }
    }

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MyFooterPage(
              indexOfPage: 4,
            ),
          ),
        );
        return true;
      },
      child: Scaffold(
        body: Directionality(
          textDirection:
              language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 100 / 100,
            child: Column(
              children: [
                AppHeaderOrange(
                    text: AppLanguage.settingText[language],
                    onPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyFooterPage(
                            indexOfPage: 4,
                          ),
                        ),
                      );
                    }),
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100),

                      //ACCOUNT TEXT
                      Container(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Text(
                          AppLanguage.accountText[language],
                          style: const TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColor.themeColor),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),

                      //account options
                      Wrap(
                        children: [
                          ...List.generate(accountOptionsList.length, (index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    navigation(accountOptionsList[index]['id']);
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        90 /
                                        100,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            width: 1,
                                            color: AppColor.boaderColor)),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          80 /
                                          100,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  3 /
                                                  100,
                                            ),

                                            //text
                                            Text(
                                              accountOptionsList[index]
                                                  ['title'],
                                              style: const TextStyle(
                                                  color: AppColor.primaryColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily:
                                                      AppFont.fontFamily),
                                            ),
                                            const Spacer(),

                                            //next
                                            Container(
                                              alignment: language == 1
                                                  ? Alignment.centerLeft
                                                  : Alignment.centerRight,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  10 /
                                                  100,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  5 /
                                                  100,
                                              child: Image.asset(
                                                  AppImage.semiCircleArrowIcon),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  3 /
                                                  100,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      2 /
                                      100,
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100),

                      //SUPPORT TEXT
                      Container(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Text(
                          AppLanguage.supportText[language],
                          style: const TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColor.themeColor),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),
                      //Support options
                      Wrap(
                        children: [
                          ...List.generate(supportOptionsList.length, (index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    navigation(supportOptionsList[index]['id']);
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        90 /
                                        100,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            width: 1,
                                            color: AppColor.boaderColor)),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          80 /
                                          100,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  3 /
                                                  100,
                                            ),

                                            //text
                                            Text(
                                              supportOptionsList[index]
                                                  ['title'],
                                              style: const TextStyle(
                                                  color: AppColor.primaryColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily:
                                                      AppFont.fontFamily),
                                            ),
                                            const Spacer(),

                                            //next
                                            Container(
                                              alignment: language == 1
                                                  ? Alignment.centerLeft
                                                  : Alignment.centerRight,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  10 /
                                                  100,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  5 /
                                                  100,
                                              child: Image.asset(
                                                  AppImage.semiCircleArrowIcon),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  3 /
                                                  100,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      2 /
                                      100,
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),
                    ],
                  ),
                )),
                const NoInternetBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //======================Delete Account Bottomsheet=============
  void _deleteAccountBottomSheet(BuildContext context, screenWidth) {
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
                            )),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.width * 10 / 100,
                            ),
                            Container(
                              //color: Colors.amber,
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 55 / 100,
                              child: Text(
                                AppLanguage.deleteAccountText[language],
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
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 75 / 100,
                              child: Text(
                                AppLanguage.deleteAccountConfirmation[language],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: AppFont.fontFamily,
                                    color: AppColor.primaryColor),
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
                                        AppLanguage.backButtonText[language],
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
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const DeleteAccount(),
                                        ),
                                      );
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
                                          // Border property
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

//=====================Logout bottomsheet===============
  void _logoutBottomSheet(BuildContext context, screenWidth) {
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
                            Container(
                              //color: Colors.amber,
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 55 / 100,
                              child: Text(
                                AppLanguage.logoutText[language],
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
                                AppLanguage.exitLogout[language],
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
                                        AppLanguage.backButtonText[language],
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
                                      localstorageclearbutton();
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
}
