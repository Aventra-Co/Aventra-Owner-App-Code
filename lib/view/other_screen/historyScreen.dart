import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_loader.dart';
import '../../utilities/app_shimmers.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../authentication/login_screen.dart';
import '/utilities/app_constant.dart';
import '/utilities/app_language.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import 'dart:ui' as ui;

import 'history_details.dart';

class HistoryScreen extends StatefulWidget {
  static String routeName = './HistoryScreen';
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> ongoingTripsList = <dynamic>[];
  bool isApiCalling = false;
  bool isLoading = true;
  int userId = 0;
  dynamic data;
  dynamic userDataArr;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  //----------------------------GET USER DETAILS--------------------------------//
  Future<dynamic> getUserDetails() async {
    setState(() {
      isApiCalling = true;
    });
    final prefs = await SharedPreferences.getInstance();
    data = prefs.getString("userDetails");

    // print("userDetails $userDetails");
    if (data == null) {
    } else {
      userDataArr = jsonDecode(data);
      userId = userDataArr['user_id'] ?? 0;
    }

    // print("userDataArr $userDataArr");
    getHistoryApiCall(userId);
    isApiCalling = false;
    setState(() {});
  }

  //------------------------Get History API CALL--------------------------------//
  Future<void> getHistoryApiCall(userId) async {
    Uri url =
        Uri.parse("${AppConfigProvider.apiUrl}get_history?user_id=$userId");
    print("url $url");

    String token = AppConstant.token;

    if (token.isEmpty) {
      print("Token is missing!");
      // return;
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
          var item = res['history_trip'];
          ongoingTripsList = (item != "NA") ? item : [];

          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          // ignore: use_build_context_synchronously
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          if (res['active_status'] == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Login()));
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
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
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;s
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      body: Directionality(
        textDirection:
            language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 100 / 100,
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
                    Container(
                      width: MediaQuery.of(context).size.width * 100 / 100,
                      height: MediaQuery.of(context).size.height * 20 / 100,
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
                            height:
                                MediaQuery.of(context).size.height * 4 / 100,
                          ),

                          //history text
                          Container(
                            width:
                                MediaQuery.of(context).size.width * 100 / 100,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        15 /
                                        100,
                                    height: MediaQuery.of(context).size.width *
                                        8 /
                                        100,
                                    child: Image.asset(
                                      AppImage.leftArrowIcon,
                                      color: AppColor.secondaryColor,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    AppLanguage.historyText[language],
                                    style: const TextStyle(
                                        color: AppColor.secondaryColor,
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      15 /
                                      100,
                                  height: MediaQuery.of(context).size.width *
                                      6 /
                                      100,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    //weather notification
                  ],
                ),
              ),
              isLoading
                  ? tripsShimmerEffect(context)
                  : Expanded(
                      child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 3 / 100),
                          if (ongoingTripsList.isNotEmpty)
                            Wrap(
                              children: [
                                ...List.generate(ongoingTripsList.length,
                                    (index) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      //coupon card
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  HistoryDetails(
                                                isCancelled:
                                                    ongoingTripsList[index]
                                                        ['cancle_status'],
                                                tripId: ongoingTripsList[index]
                                                        ['trip_booking_id']
                                                    .toString(),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  3 /
                                                  100,
                                            ),
                                            Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    90 /
                                                    100,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 5,
                                                ),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 7.0,
                                                      style: BorderStyle.solid),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: AppColor
                                                          .textLightColor,
                                                      blurRadius: 9.0,
                                                      offset: Offset(1, 0),
                                                    ),
                                                  ], //BoxShadow
                                                  color:
                                                      AppColor.secondaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      80 /
                                                      100,
                                                  child: Row(
                                                    children: [
                                                      //image
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            15 /
                                                            100,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            15 /
                                                            100,
                                                        decoration:
                                                            BoxDecoration(
                                                                // color: Colors.red,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: ongoingTripsList[
                                                                          index]
                                                                      [
                                                                      'trip_image'] !=
                                                                  null
                                                              ? Image.network(
                                                                  '${AppConfigProvider.imageURL}${ongoingTripsList[index]['trip_image']}',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  loadingBuilder: (BuildContext
                                                                          context,
                                                                      Widget
                                                                          child,
                                                                      ImageChunkEvent?
                                                                          loadingProgress) {
                                                                    if (loadingProgress ==
                                                                        null) {
                                                                      return child;
                                                                    } else {
                                                                      return Shimmer
                                                                          .fromColors(
                                                                        baseColor: Colors
                                                                            .grey
                                                                            .shade300,
                                                                        highlightColor: Colors
                                                                            .grey
                                                                            .shade100,
                                                                        child:
                                                                            Container(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade300,
                                                                        ),
                                                                      );
                                                                    }
                                                                  },
                                                                )
                                                              : Image.asset(
                                                                  AppImage
                                                                      .imageFrame,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            2 /
                                                            100,
                                                      ),

                                                      //left side
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            35 /
                                                            100,
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  35 /
                                                                  100,
                                                              child: Text(
                                                                ongoingTripsList[
                                                                        index][
                                                                    'boat_name_english'],
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: AppColor
                                                                        .primaryColor,
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontFamily),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  35 /
                                                                  100,
                                                              child: const Text(
                                                                "Boat",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: AppColor
                                                                        .textColor,
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontFamily),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  .5 /
                                                                  100,
                                                            ),
                                                            Container(
                                                              // color: Colors.red,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  35 /
                                                                  100,
                                                              child: Text(
                                                                ongoingTripsList[
                                                                            index]
                                                                        [
                                                                        'random_booking_id']
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: AppColor
                                                                        .primaryColor,
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontFamily),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  .5 /
                                                                  100,
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  35 /
                                                                  100,
                                                              child: Text(
                                                                ongoingTripsList[
                                                                        index][
                                                                    'booking_date'],
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: AppColor
                                                                        .textColor,
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontFamily),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const Spacer(),

                                                      //right side
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            23 /
                                                            100,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                           
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  23 /
                                                                  100,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            2.0),
                                                                child: Text(
                                                                  "KWD ${ongoingTripsList[index]['total_amount']}",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: AppColor
                                                                          .cyan,
                                                                      fontFamily:
                                                                          AppFont
                                                                              .fontFamily),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  1 /
                                                                  100,
                                                            ),

                                                            //! Complete Button
                                                            (ongoingTripsList[
                                                                            index]
                                                                        [
                                                                        'cancle_status'] ==
                                                                    0)
                                                                ? Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        23 /
                                                                        100,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: AppColor
                                                                          .themeColor,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              25),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical: screenWidth > 600
                                                                              ? 10
                                                                              : 4.0),
                                                                      child:
                                                                          Text(
                                                                        AppLanguage
                                                                            .completedText[language],
                                                                        style: TextStyle(
                                                                            fontSize: screenWidth > 600
                                                                                ? 14
                                                                                : 10,
                                                                            color:
                                                                                AppColor.secondaryColor,
                                                                            fontFamily: AppFont.fontFamily,
                                                                            fontWeight: FontWeight.w600),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        23 /
                                                                        100,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .red,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              25),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical: screenWidth > 600
                                                                              ? 10
                                                                              : 4.0),
                                                                      child:
                                                                          Text(
                                                                        AppLanguage
                                                                            .cancelledText[language],
                                                                        style: TextStyle(
                                                                            fontSize: screenWidth > 600
                                                                                ? 14
                                                                                : 10,
                                                                            color:
                                                                                AppColor.secondaryColor,
                                                                            fontFamily: AppFont.fontFamily,
                                                                            fontWeight: FontWeight.w600),
                                                                      ),
                                                                    ),
                                                                  )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )),
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
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                3 /
                                                100,
                                      )
                                    ],
                                  );
                                }),
                              ],
                            ),
                          if (ongoingTripsList.isEmpty)
                            Column(
                              children: [
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        20 /
                                        100),
                                //!text msg
                                Container(
                                  width: screenWidth * 70 / 100,
                                  child: Text(
                                    AppLanguage.hidtoryNodataMsg[language],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    )),
              const NoInternetBanner(),
            ],
          ),
        ),
      ),
    );
  }
}
