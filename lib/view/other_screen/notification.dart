import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:the_boat_ownerside/utilities/app_footer.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_loader.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../authentication/login_screen.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import 'broadcastScreen.dart';
import 'history_details.dart';
import 'upcoming_details.dart';
import 'dart:ui' as ui;

class Notifications extends StatefulWidget {
  static String routeName = './Notifications';

  const Notifications({super.key});

  @override
  State<Notifications> createState() => _Notifications();
}

class _Notifications extends State<Notifications> {
  int userId = 0;
  bool isApiCalling = true;
  List<dynamic> notificationarraylist = <dynamic>[];

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  //!----------------------User Details-----------------------!//
  Future<dynamic> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    dynamic userDetails = prefs.getString("userDetails");

    print("user_details===++ $userDetails");

    if (userDetails != null) {
      dynamic data = json.decode(userDetails);

      setState(() {
        userId = data['user_id'];
      });
      notificationApi();
    }
  }

  //! ============================ Notification API Calling ================================= !//
  notificationApi() async {
    setState(() {
      isApiCalling = true;
    });
    // ignore: unused_local_variable
    final prefs = await SharedPreferences.getInstance();

    String apiUrl =
        '${AppConfigProvider.apiUrl}get_all_notifications?user_id=$userId';

    print("Line 72===++ $apiUrl");
    String token = AppConstant.token;

    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token', // Use 'Bearer' if required
    };

    try {
      // Send the HTTP GET request with headers
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      // Parse the response
      dynamic res = jsonDecode(response.body);

      print("Response102:===++ ${res}");
      // Check the status code
      if (response.statusCode == 200) {
        if (res['success'] == true) {
          setState(() {
            isApiCalling = false;
          });
          if (res['notification_arr'] != "NA") {
            setState(() {
              notificationarraylist = res['notification_arr'];
            });
            log("notificationarraylist$notificationarraylist");
          } else {
            setState(() {
              notificationarraylist = [];
            });
          }
        } else {
          if (res['active_status'] == 0) {
            final prefs = await SharedPreferences.getInstance();
            print("prefs =================>$prefs");
            prefs.remove('user_details');
            AppConstant.token = "";
            Future.delayed(const Duration(milliseconds: 300), () async {
              // ignore: use_build_context_synchronously
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
              // ignore: use_build_context_synchronously
              SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
            });
          }
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          setState(() {
            isApiCalling = false;
          });
        }
      } else {
        setState(() {
          isApiCalling = false;
        });
        // Handle other status codes if needed
        print("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isApiCalling = false;
      });
      // Handle exceptions
      print("Error: $e");
    }
  }

//================= delete_single_notification =============
  deleteSingleNotificationApi(notificationId) async {
    setState(() {
      isApiCalling = true;
    });
    Uri url =
        Uri.parse("${AppConfigProvider.apiUrl}delete_single_notifications");
    print("Url $url");
    String token = AppConstant.token;
    try {
      var headers = {
        'Authorization': 'Bearer $token',
      };
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.headers.addAll(headers);
      formData.fields['user_id'] = userId.toString();
      formData.fields['notification_message_id'] = notificationId.toString();

      print("response--> ${formData.fields}");

      http.StreamedResponse response = await formData.send();
      print("response--> $response");
      var responseString = await response.stream.toBytes();
      var res = jsonDecode(utf8.decode(responseString));

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          notificationApi();
          setState(() {
            isApiCalling = false;
          });
        } else {
          setState(() {
            isApiCalling = false;
          });
          // ignore: use_build_context_synchronously
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
        }
      } else {
        setState(() {
          isApiCalling = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isApiCalling = false;
      });
    }
  }

//================= delete_all_notification =============//
  deleteAllNotificationApi(userId) async {
    setState(() {
      isApiCalling = true;
    });
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}delete_all_notifications");
    print("Url $url");
    String token = AppConstant.token;
    try {
      var headers = {
        'Authorization': 'Bearer $token',
      };
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.headers.addAll(headers);
      formData.fields['user_id'] = userId.toString();

      print("response--> ${formData.fields}");

      http.StreamedResponse response = await formData.send();
      print("response--> $response");
      var responseString = await response.stream.toBytes();
      var res = jsonDecode(utf8.decode(responseString));

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);

          notificationApi();

          setState(() {
            isApiCalling = false;
          });
        } else {
          setState(() {
            isApiCalling = false;
          });
          // ignore: use_build_context_synchronously
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
        }
      } else {
        setState(() {
          isApiCalling = false;
        });
      }
    } catch (e) {
      print(e);
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
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyFooterPage(
              indexOfPage: 0,
            ),
          ),
        );
        return Future.value(false);
      },
      child: Scaffold(
        // backgroundColor: Colors.white,s
        body: Directionality(
          textDirection:
              language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 100 / 100,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  height: MediaQuery.of(context).size.height * 13 / 100,
                  decoration: const BoxDecoration(
                      color: AppColor.themeColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyFooterPage(
                                indexOfPage: 0,
                              ),
                            ),
                          );
                        },
                        child: Transform.rotate(
                          angle: language == 1 ? 3.1416 : 0,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 16 / 100,
                            height: MediaQuery.of(context).size.width * 8 / 100,
                            child: Image.asset(
                              AppImage.leftArrowIcon,
                              color: AppColor.secondaryColor,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        AppLanguage.notificationText[language],
                        style: const TextStyle(
                            color: AppColor.secondaryColor,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 20),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (notificationarraylist.isNotEmpty) {
                            deleteAllNotificationApi(userId);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            alignment: language == 1
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            width: MediaQuery.of(context).size.width * 16 / 100,
                            height: MediaQuery.of(context).size.width * 6 / 100,
                            child: Text(AppLanguage.clearallText[language],
                                style: const TextStyle(
                                    color: AppColor.secondaryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //! Notification list
                if (notificationarraylist.isNotEmpty && isApiCalling == false)
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 0),
                      width: MediaQuery.of(context).size.width * 95 / 100,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: notificationarraylist.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (notificationarraylist[index]['action'] ==
                                      "trip_booking") {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UpcomingDetailsScreen(
                                                  tripId: notificationarraylist[
                                                          index]['action_id']
                                                      .toString(),
                                                )));
                                  } else if (notificationarraylist[index]
                                          ['action'] ==
                                      "trip_cancellation") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HistoryDetails(
                                          isCancelled: 3,
                                          tripId: notificationarraylist[index]
                                                  ['action_id']
                                              .toString(),
                                        ),
                                      ),
                                    );
                                  } else if (notificationarraylist[index]
                                          ['action'] ==
                                      "Broadcast") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BroadcastScreen(
                                          broadCastDetails:
                                              notificationarraylist[index],
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  color: AppColor.secondaryColor,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                2 /
                                                100,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                10 /
                                                100,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                10 /
                                                100,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: (notificationarraylist[index]
                                                          ['user_image'] !=
                                                      null &&
                                                  notificationarraylist[index]
                                                          ['user_image'] !=
                                                      "NA")
                                              ? Image.network(
                                                  '${AppConfigProvider.imageURL}${notificationarraylist[index]['user_image']}',
                                                  fit: BoxFit.cover,
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget child,
                                                          ImageChunkEvent?
                                                              loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    } else {
                                                      return Shimmer.fromColors(
                                                        baseColor: Colors
                                                            .grey.shade300,
                                                        highlightColor: Colors
                                                            .grey.shade100,
                                                        child: Container(
                                                          color: Colors
                                                              .grey.shade300,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                )
                                              : Image.asset(
                                                  AppImage
                                                      .profilePlaceholderImage,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                3 /
                                                100,
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                78 /
                                                100,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                (notificationarraylist[index]
                                                            ['action'] ==
                                                        "trip_booking")
                                                    ? SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            55 /
                                                            100,
                                                        child: Text(
                                                          '${AppLanguage.bookingIdText[language]}: #${notificationarraylist[index]['booking_id']}',
                                                          textAlign:
                                                              TextAlign.start,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                              color: AppColor
                                                                  .themeColor,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            55 /
                                                            100,
                                                        child: Text(
                                                          '${notificationarraylist[index]['title'][language]}',
                                                          textAlign:
                                                              TextAlign.start,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                              color: AppColor
                                                                  .themeColor,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                Text(
                                                  notificationarraylist[index]
                                                          ['date_time'] ??
                                                      "",
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        AppColor.primaryColor,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                78 /
                                                100,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      70 /
                                                      100,
                                                  child: Text(
                                                    '${notificationarraylist[index]['message'][language]}',
                                                    textAlign: TextAlign.start,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: AppColor
                                                            .primaryColor,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    deleteSingleNotificationApi(
                                                        notificationarraylist[
                                                                index][
                                                            'notification_message_id']);
                                                  },
                                                  child: Container(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            4 /
                                                            100,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            4 /
                                                            100,
                                                    child: Image.asset(
                                                      AppImage.crossIcon,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              //! ==== Boader ===
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    90 /
                                    100,
                                child: const Divider(
                                  thickness: 1,
                                  color: AppColor.boaderColor,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ), //: Container(),

                if (notificationarraylist.isEmpty && isApiCalling == false)
                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                      ),
                      SizedBox(
                        width: screenWidth * 0.7,
                        child: Text(
                          AppLanguage.notificationNoDataMsg[language],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                const NoInternetBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
