import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import 'dart:ui' as ui;
import '../../utilities/app_loader.dart';
import '../../utilities/app_shimmers.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../authentication/login_screen.dart';

class WalletScreen extends StatefulWidget {
  static String routeName = './WalletScreen';
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  TextEditingController searchTextController = TextEditingController();
  List<dynamic> walletList = [];
  bool isApiCalling = false;
  bool isLoading = true;
  String balance = "";

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  int userId = 0;
  dynamic userDetails;

//--------------------GET USER DETAILS-----------------------//
  Future<dynamic> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    userDetails = prefs.getString("userDetails");

    // print("userDetails $userDetails");
    if (userDetails != null) {
      dynamic data = json.decode(userDetails);
      print("up $data");
      userId = data['user_id'];
    }
    getWalletApi(userId);
    setState(() {});
  }

  //=============================GET Ratings DETAILS===================================//
  Future<void> getWalletApi(userId) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}get_wallet_details?user_id=$userId");
    print("url $url");

    String token = AppConstant.token;

    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token', // Use 'Bearer' if required
    };

    setState(() {
      isLoading = true;
    });

    print("headers $headers");

    try {
      final response = await http.get(url, headers: headers);
      print("response $response");

      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);
        print("res $res");

        if (res['success'] == true) {
          var item = res['wallet_arr'];
          walletList = (item != "NA") ? item : [];
          balance = res['grandTotalAmount'].toString();
          setState(() {
            isLoading = false;
          });
        } else {
          if (res['active_status'] == 0) {
            SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          }
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("Error: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        isLoading = false;
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
    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      body: Directionality(
        textDirection:
            language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          child: Column(
            children: [
              //header
              Container(
                width: MediaQuery.of(context).size.width * 100 / 100,
                height: MediaQuery.of(context).size.height * 25 / 100,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(AppImage.headerBgImage),
                        fit: BoxFit.cover),
                    color: AppColor.themeColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50))),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100,
                    ),

                    //manage text
                    Container(
                      width: MediaQuery.of(context).size.width * 100 / 100,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 15 / 100,
                              height:
                                  MediaQuery.of(context).size.width * 8 / 100,
                              child: Image.asset(
                                AppImage.leftArrowIcon,
                                color: AppColor.secondaryColor,
                              ),
                            ),
                          ),
                          Text(
                            AppLanguage.myWalletText[language],
                            style: const TextStyle(
                                color: AppColor.secondaryColor,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w700,
                                fontSize: 20),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 15 / 100,
                            height: MediaQuery.of(context).size.width * 6 / 100,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 7 / 100,
                    ),

                    Text(
                      "KWD $balance",
                      style: const TextStyle(
                          color: AppColor.secondaryColor,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 20),
                    ),
                    Text(
                      AppLanguage.totalAmountText[language],
                      style: const TextStyle(
                          color: AppColor.secondaryColor,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w400,
                          fontSize: 20),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),

              //heading
              Container(
                width: MediaQuery.of(context).size.width * 90 / 100,
                alignment: language == 1
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  AppLanguage.transactionsDetailsText[language],
                  style: const TextStyle(
                      color: AppColor.primaryColor,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),

              isLoading
                  ? ratingShimmerEffect(context)
                  : Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Wrap(
                              children: [
                                ...List.generate(
                                  walletList.length,
                                  (index) {
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 10),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                90 /
                                                100,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 7.0,
                                                  style: BorderStyle.solid),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color:
                                                      AppColor.textLightColor,
                                                  blurRadius: 9.0,
                                                  offset: Offset(1, 0),
                                                ),
                                              ], //BoxShadow
                                              color: AppColor.secondaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundImage: walletList[
                                                                index]
                                                            ['user_image'] !=
                                                        null
                                                    ? NetworkImage(
                                                        '${AppConfigProvider.imageURL}${walletList[index]['user_image']}')
                                                    : const AssetImage(AppImage
                                                            .profilePlaceholderImage)
                                                        as ImageProvider,
                                              ),
                                              title: Text(
                                                walletList[index]
                                                        ['boat_name_english'] ??
                                                    "",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontSize: 14,
                                                    color:
                                                        AppColor.primaryColor),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    walletList[index][
                                                            'destination_english'] ??
                                                        "",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontSize: 12,
                                                        color: AppColor
                                                            .primaryColor),
                                                  ),
                                                  Text(
                                                    "${walletList[index]['booking_time']}     ${walletList[index]['booking_date']}",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontSize: 12,
                                                        color: AppColor
                                                            .primaryColor),
                                                  ),
                                                ],
                                              ),
                                              trailing: Text(
                                                "\$${walletList[index]['total_amount']}",
                                                style: const TextStyle(
                                                    color:
                                                        AppColor.primaryColor,
                                                    fontSize: 16,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (index == walletList.length - 1)
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  4 /
                                                  100),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
              const NoInternetBanner(),
            ],
          ),
        ),
      ),
    );
  }
}
