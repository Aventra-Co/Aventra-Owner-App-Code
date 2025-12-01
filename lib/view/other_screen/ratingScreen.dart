import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_loader.dart';
import '../../utilities/app_shimmers.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../authentication/login_screen.dart';
import 'ratingDetails.dart';
import 'dart:ui' as ui;

class RatingScreen extends StatefulWidget {
  static String routeName = './RatingScreen';
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  TextEditingController searchTextController = TextEditingController();
  bool isApiCalling = false;
  bool isLoading = true;
  List<dynamic> ratingList = [];
  double totalRating = 0;

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
    setState(() {
      isApiCalling = true;
    });

    // print("userDetails $userDetails");
    if (userDetails != null) {
      dynamic data = json.decode(userDetails);
      print("up $data");
      userId = data['user_id'];
    }
    setState(() {
      isApiCalling = false;
    });
    getRatingsApi(userId);
    setState(() {});
  }

  //=============================GET Ratings DETAILS===================================//
  Future<void> getRatingsApi(userId) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}get_all_ratings?owner_id=$userId");
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
          var item = res['rating_arr'];
          ratingList = (item != "NA") ? item : [];
          totalRating = res['total_rating'].toDouble();

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
              Container(
                width: MediaQuery.of(context).size.width * 100 / 100,
                // height: MediaQuery.of(context).size.height * 29 / 100,
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
                              child: Transform.rotate(
                                angle: language == 1 ? 3.1416 : 0,
                                child: Image.asset(
                                  AppImage.leftArrowIcon,
                                  color: AppColor.secondaryColor,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              AppLanguage.ratingText[language],
                              style: const TextStyle(
                                  color: AppColor.secondaryColor,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 15 / 100,
                            height: MediaQuery.of(context).size.width * 6 / 100,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 2 / 100,
                    ),

                    SizedBox(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 30 / 100,
                            child: Column(
                              children: [
                                Text(
                                  totalRating.toStringAsFixed(2),
                                  style: const TextStyle(
                                      color: AppColor.secondaryColor,
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20),
                                ),
                                Row(
                                  children: [
                                    RatingBarIndicator(
                                      rating:
                                          totalRating, // Use your desired rating value here
                                      itemCount: 5,
                                      itemSize:
                                          18, // Specify the size of each star
                                      unratedColor: AppColor.secondaryColor,
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                      ),
                                    ),
                                    Text(
                                      "(${ratingList.length})",
                                      style: const TextStyle(
                                          color: AppColor.secondaryColor,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 2 / 100,
                          ),
                          // SizedBox(
                          //   width: MediaQuery.of(context).size.width * 58 / 100,
                          //   child: Column(
                          //     children: [
                          //       //! Time
                          //       SizedBox(
                          //         height: MediaQuery.of(context).size.height *
                          //             2 /
                          //             100,
                          //       ),
                          //       SizedBox(
                          //         width: MediaQuery.of(context).size.width *
                          //             58 /
                          //             100,
                          //         child: Row(
                          //           mainAxisAlignment:
                          //               MainAxisAlignment.spaceBetween,
                          //           children: [
                          //             SizedBox(
                          //               width:
                          //                   MediaQuery.of(context).size.width *
                          //                       25 /
                          //                       100,
                          //               child: Text(
                          //                 AppLanguage.timeText[language],
                          //                 style: const TextStyle(
                          //                     color: AppColor.secondaryColor,
                          //                     fontFamily: AppFont.fontFamily,
                          //                     fontWeight: FontWeight.w400,
                          //                     fontSize: 14),
                          //               ),
                          //             ),
                          //             SizedBox(
                          //               width:
                          //                   MediaQuery.of(context).size.width *
                          //                       33 /
                          //                       100,
                          //               child: Row(
                          //                 children: [
                          //                   RatingBarIndicator(
                          //                     rating:
                          //                         2, // Use your desired rating value here
                          //                     itemCount: 5,
                          //                     itemSize:
                          //                         20, // Specify the size of each star
                          //                     unratedColor:
                          //                         AppColor.secondaryColor,
                          //                     itemBuilder: (context, _) =>
                          //                         const Icon(
                          //                       Icons.star,
                          //                       color: Colors.yellow,
                          //                     ),
                          //                   ),
                          //                   const Text(
                          //                     "(2)",
                          //                     style: TextStyle(
                          //                         color:
                          //                             AppColor.secondaryColor,
                          //                         fontFamily:
                          //                             AppFont.fontFamily,
                          //                         fontWeight: FontWeight.w400,
                          //                         fontSize: 14),
                          //                   ),
                          //                 ],
                          //               ),
                          //             )
                          //           ],
                          //         ),
                          //       ),

                          //       //! Clean
                          //       SizedBox(
                          //         width: MediaQuery.of(context).size.width *
                          //             0.5 /
                          //             100,
                          //       ),
                          //       SizedBox(
                          //         width: MediaQuery.of(context).size.width *
                          //             58 /
                          //             100,
                          //         child: Column(
                          //           children: [
                          //             SizedBox(
                          //               width:
                          //                   MediaQuery.of(context).size.width *
                          //                       58 /
                          //                       100,
                          //               child: Row(
                          //                 mainAxisAlignment:
                          //                     MainAxisAlignment.spaceBetween,
                          //                 children: [
                          //                   SizedBox(
                          //                     width: MediaQuery.of(context)
                          //                             .size
                          //                             .width *
                          //                         25 /
                          //                         100,
                          //                     child: Text(
                          //                       AppLanguage.cleanText[language],
                          //                       style: const TextStyle(
                          //                           color:
                          //                               AppColor.secondaryColor,
                          //                           fontFamily:
                          //                               AppFont.fontFamily,
                          //                           fontWeight: FontWeight.w400,
                          //                           fontSize: 14),
                          //                     ),
                          //                   ),
                          //                   SizedBox(
                          //                     width: MediaQuery.of(context)
                          //                             .size
                          //                             .width *
                          //                         33 /
                          //                         100,
                          //                     child: Row(
                          //                       children: [
                          //                         RatingBarIndicator(
                          //                           rating:
                          //                               3, // Use your desired rating value here
                          //                           itemCount: 5,
                          //                           itemSize:
                          //                               20, // Specify the size of each star
                          //                           unratedColor:
                          //                               AppColor.secondaryColor,
                          //                           itemBuilder: (context, _) =>
                          //                               const Icon(
                          //                             Icons.star,
                          //                             color: Colors.yellow,
                          //                           ),
                          //                         ),
                          //                         const Text(
                          //                           "(3)",
                          //                           style: TextStyle(
                          //                               color: AppColor
                          //                                   .secondaryColor,
                          //                               fontFamily:
                          //                                   AppFont.fontFamily,
                          //                               fontWeight:
                          //                                   FontWeight.w400,
                          //                               fontSize: 14),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                   )
                          //                 ],
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),

                          //       //! Captain
                          //       SizedBox(
                          //         width: MediaQuery.of(context).size.width *
                          //             0.5 /
                          //             100,
                          //       ),
                          //       SizedBox(
                          //         width: MediaQuery.of(context).size.width *
                          //             58 /
                          //             100,
                          //         child: Column(
                          //           children: [
                          //             SizedBox(
                          //               width:
                          //                   MediaQuery.of(context).size.width *
                          //                       58 /
                          //                       100,
                          //               child: Row(
                          //                 mainAxisAlignment:
                          //                     MainAxisAlignment.spaceBetween,
                          //                 children: [
                          //                   SizedBox(
                          //                     width: MediaQuery.of(context)
                          //                             .size
                          //                             .width *
                          //                         25 /
                          //                         100,
                          //                     child: Text(
                          //                       AppLanguage
                          //                           .captainText[language],
                          //                       style: const TextStyle(
                          //                           color:
                          //                               AppColor.secondaryColor,
                          //                           fontFamily:
                          //                               AppFont.fontFamily,
                          //                           fontWeight: FontWeight.w400,
                          //                           fontSize: 14),
                          //                     ),
                          //                   ),
                          //                   SizedBox(
                          //                     width: MediaQuery.of(context)
                          //                             .size
                          //                             .width *
                          //                         33 /
                          //                         100,
                          //                     child: Row(
                          //                       children: [
                          //                         RatingBarIndicator(
                          //                           rating:
                          //                               5, // Use your desired rating value here
                          //                           itemCount: 5,
                          //                           itemSize:
                          //                               20, // Specify the size of each star
                          //                           unratedColor:
                          //                               AppColor.secondaryColor,
                          //                           itemBuilder: (context, _) =>
                          //                               const Icon(
                          //                             Icons.star,
                          //                             color: Colors.yellow,
                          //                           ),
                          //                         ),
                          //                         const Text(
                          //                           "(5)",
                          //                           style: TextStyle(
                          //                               color: AppColor
                          //                                   .secondaryColor,
                          //                               fontFamily:
                          //                                   AppFont.fontFamily,
                          //                               fontWeight:
                          //                                   FontWeight.w400,
                          //                               fontSize: 14),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                   )
                          //                 ],
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),

                          //       //! Hospitality
                          //       SizedBox(
                          //         width: MediaQuery.of(context).size.width *
                          //             0.5 /
                          //             100,
                          //       ),
                          //       SizedBox(
                          //         width: MediaQuery.of(context).size.width *
                          //             58 /
                          //             100,
                          //         child: Column(
                          //           children: [
                          //             SizedBox(
                          //               width:
                          //                   MediaQuery.of(context).size.width *
                          //                       58 /
                          //                       100,
                          //               child: Row(
                          //                 mainAxisAlignment:
                          //                     MainAxisAlignment.spaceBetween,
                          //                 children: [
                          //                   SizedBox(
                          //                     width: MediaQuery.of(context)
                          //                             .size
                          //                             .width *
                          //                         25 /
                          //                         100,
                          //                     child: Text(
                          //                       AppLanguage
                          //                           .hospitalityText[language],
                          //                       style: const TextStyle(
                          //                           color:
                          //                               AppColor.secondaryColor,
                          //                           fontFamily:
                          //                               AppFont.fontFamily,
                          //                           fontWeight: FontWeight.w400,
                          //                           fontSize: 14),
                          //                     ),
                          //                   ),
                          //                   SizedBox(
                          //                     width: MediaQuery.of(context)
                          //                             .size
                          //                             .width *
                          //                         33 /
                          //                         100,
                          //                     child: Row(
                          //                       children: [
                          //                         RatingBarIndicator(
                          //                           rating:
                          //                               4, // Use your desired rating value here
                          //                           itemCount: 5,
                          //                           itemSize:
                          //                               20, // Specify the size of each star
                          //                           unratedColor:
                          //                               AppColor.secondaryColor,
                          //                           itemBuilder: (context, _) =>
                          //                               const Icon(
                          //                             Icons.star,
                          //                             color: Colors.yellow,
                          //                           ),
                          //                         ),
                          //                         const Text(
                          //                           "(4)",
                          //                           style: TextStyle(
                          //                               color: AppColor
                          //                                   .secondaryColor,
                          //                               fontFamily:
                          //                                   AppFont.fontFamily,
                          //                               fontWeight:
                          //                                   FontWeight.w400,
                          //                               fontSize: 14),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                   )
                          //                 ],
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),

                          //       //! Food
                          //       SizedBox(
                          //         width: MediaQuery.of(context).size.width *
                          //             0.5 /
                          //             100,
                          //       ),
                          //       SizedBox(
                          //         width: MediaQuery.of(context).size.width *
                          //             58 /
                          //             100,
                          //         child: Column(
                          //           children: [
                          //             SizedBox(
                          //               width:
                          //                   MediaQuery.of(context).size.width *
                          //                       58 /
                          //                       100,
                          //               child: Row(
                          //                 mainAxisAlignment:
                          //                     MainAxisAlignment.spaceBetween,
                          //                 children: [
                          //                   SizedBox(
                          //                     width: MediaQuery.of(context)
                          //                             .size
                          //                             .width *
                          //                         25 /
                          //                         100,
                          //                     child: Text(
                          //                       AppLanguage.foodText[language],
                          //                       style: const TextStyle(
                          //                           color:
                          //                               AppColor.secondaryColor,
                          //                           fontFamily:
                          //                               AppFont.fontFamily,
                          //                           fontWeight: FontWeight.w400,
                          //                           fontSize: 14),
                          //                     ),
                          //                   ),
                          //                   SizedBox(
                          //                     width: MediaQuery.of(context)
                          //                             .size
                          //                             .width *
                          //                         33 /
                          //                         100,
                          //                     child: Row(
                          //                       children: [
                          //                         RatingBarIndicator(
                          //                           rating:
                          //                               3, // Use your desired rating value here
                          //                           itemCount: 5,
                          //                           itemSize:
                          //                               20, // Specify the size of each star
                          //                           unratedColor:
                          //                               AppColor.secondaryColor,
                          //                           itemBuilder: (context, _) =>
                          //                               const Icon(
                          //                             Icons.star,
                          //                             color: Colors.yellow,
                          //                           ),
                          //                         ),
                          //                         const Text(
                          //                           "(3)",
                          //                           style: TextStyle(
                          //                               color: AppColor
                          //                                   .secondaryColor,
                          //                               fontFamily:
                          //                                   AppFont.fontFamily,
                          //                               fontWeight:
                          //                                   FontWeight.w400,
                          //                               fontSize: 14),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                   )
                          //                 ],
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),

                          //       //! Equipment
                          //       SizedBox(
                          //         width: MediaQuery.of(context).size.width *
                          //             0.5 /
                          //             100,
                          //       ),
                          //       SizedBox(
                          //         width: MediaQuery.of(context).size.width *
                          //             58 /
                          //             100,
                          //         child: Column(
                          //           children: [
                          //             SizedBox(
                          //               width:
                          //                   MediaQuery.of(context).size.width *
                          //                       58 /
                          //                       100,
                          //               child: Row(
                          //                 mainAxisAlignment:
                          //                     MainAxisAlignment.spaceBetween,
                          //                 children: [
                          //                   SizedBox(
                          //                     width: MediaQuery.of(context)
                          //                             .size
                          //                             .width *
                          //                         25 /
                          //                         100,
                          //                     child: Text(
                          //                       AppLanguage
                          //                           .equipmentText[language],
                          //                       style: const TextStyle(
                          //                           color:
                          //                               AppColor.secondaryColor,
                          //                           fontFamily:
                          //                               AppFont.fontFamily,
                          //                           fontWeight: FontWeight.w400,
                          //                           fontSize: 14),
                          //                     ),
                          //                   ),
                          //                   SizedBox(
                          //                     width: MediaQuery.of(context)
                          //                             .size
                          //                             .width *
                          //                         33 /
                          //                         100,
                          //                     child: Row(
                          //                       children: [
                          //                         RatingBarIndicator(
                          //                           rating:
                          //                               3, // Use your desired rating value here
                          //                           itemCount: 5,
                          //                           itemSize:
                          //                               20, // Specify the size of each star
                          //                           unratedColor:
                          //                               AppColor.secondaryColor,
                          //                           itemBuilder: (context, _) =>
                          //                               const Icon(
                          //                             Icons.star,
                          //                             color: Colors.yellow,
                          //                           ),
                          //                         ),
                          //                         const Text(
                          //                           "(3)",
                          //                           style: TextStyle(
                          //                               color: AppColor
                          //                                   .secondaryColor,
                          //                               fontFamily:
                          //                                   AppFont.fontFamily,
                          //                               fontWeight:
                          //                                   FontWeight.w400,
                          //                               fontSize: 14),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                   )
                          //                 ],
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),

                          //       //! Entertainment
                          //       SizedBox(
                          //         width: MediaQuery.of(context).size.width *
                          //             0.5 /
                          //             100,
                          //       ),
                          //       SizedBox(
                          //         width: MediaQuery.of(context).size.width *
                          //             58 /
                          //             100,
                          //         child: Column(
                          //           children: [
                          //             SizedBox(
                          //               width:
                          //                   MediaQuery.of(context).size.width *
                          //                       58 /
                          //                       100,
                          //               child: Row(
                          //                 mainAxisAlignment:
                          //                     MainAxisAlignment.spaceBetween,
                          //                 children: [
                          //                   SizedBox(
                          //                     width: MediaQuery.of(context)
                          //                             .size
                          //                             .width *
                          //                         25 /
                          //                         100,
                          //                     child: Text(
                          //                       AppLanguage.entertainmentText[
                          //                           language],
                          //                       style: const TextStyle(
                          //                           color:
                          //                               AppColor.secondaryColor,
                          //                           fontFamily:
                          //                               AppFont.fontFamily,
                          //                           fontWeight: FontWeight.w400,
                          //                           fontSize: 14),
                          //                     ),
                          //                   ),
                          //                   SizedBox(
                          //                     width: MediaQuery.of(context)
                          //                             .size
                          //                             .width *
                          //                         33 /
                          //                         100,
                          //                     child: Row(
                          //                       children: [
                          //                         RatingBarIndicator(
                          //                           rating:
                          //                               3, // Use your desired rating value here
                          //                           itemCount: 5,
                          //                           itemSize:
                          //                               20, // Specify the size of each star
                          //                           unratedColor:
                          //                               AppColor.secondaryColor,
                          //                           itemBuilder: (context, _) =>
                          //                               const Icon(
                          //                             Icons.star,
                          //                             color: Colors.yellow,
                          //                           ),
                          //                         ),
                          //                         const Text(
                          //                           "(3)",
                          //                           style: TextStyle(
                          //                               color: AppColor
                          //                                   .secondaryColor,
                          //                               fontFamily:
                          //                                   AppFont.fontFamily,
                          //                               fontWeight:
                          //                                   FontWeight.w400,
                          //                               fontSize: 14),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                   )
                          //                 ],
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),

                          //       SizedBox(
                          //         height: MediaQuery.of(context).size.height *
                          //             2 /
                          //             100,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 3 / 100,
                    ),
                  ],
                ),
              ),
              isLoading
                  ? ratingShimmerEffect(context)
                  : Expanded(
                      child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          if (ratingList.isNotEmpty)
                            Wrap(
                              children: [
                                ...List.generate(ratingList.length, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RatingDetailsScreen(
                                              ratingId: ratingList[index]
                                                      ['rating_review_id']
                                                  .toString(),
                                            ),
                                          ));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 10),
                                      width: MediaQuery.of(context).size.width *
                                          90 /
                                          100,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.white,
                                            width: 7.0,
                                            style: BorderStyle.solid),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: AppColor.textLightColor,
                                            blurRadius: 9.0,
                                            offset: Offset(1, 0),
                                          ),
                                        ], //BoxShadow
                                        color: AppColor.secondaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: ratingList[index]
                                                      ['image'] !=
                                                  null
                                              ? NetworkImage(
                                                  '${AppConfigProvider.imageURL}${ratingList[index]['image']}')
                                              : const AssetImage(AppImage
                                                      .profilePlaceholderImage)
                                                  as ImageProvider,
                                        ),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ratingList[index]['name'] ?? "",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontSize: 14,
                                                  color: AppColor.primaryColor),
                                            ),
                                            RatingBarIndicator(
                                              rating: ratingList[index]
                                                      ['total_rating_average']
                                                  .toDouble(), // Use your desired rating value here
                                              itemCount: 5,
                                              itemSize:
                                                  20, // Specify the size of each star
                                              unratedColor:
                                                  AppColor.textLightColor,
                                              itemBuilder: (context, _) =>
                                                  const Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Text(
                                          ratingList[index]['review'] ?? "",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 12,
                                              color: AppColor.primaryColor),
                                        ),
                                        trailing: Container(
                                          child: Text(
                                            ratingList[index]['createtime'] ??
                                                "",
                                            style: const TextStyle(
                                                color: AppColor.primaryColor,
                                                fontSize: 10,
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          if (ratingList.isEmpty)
                            Column(
                              children: [
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        20 /
                                        100),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      20 /
                                      100,
                                  height: MediaQuery.of(context).size.width *
                                      20 /
                                      100,
                                  child: Image.asset(
                                    AppImage.noDataIcon,
                                    fit: BoxFit.cover,
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
