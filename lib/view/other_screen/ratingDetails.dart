import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import 'dart:ui' as ui;
import '../../utilities/app_loader.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../authentication/login_screen.dart';

class RatingDetailsScreen extends StatefulWidget {
  static String routeName = './RatingDetailsScreen';
  final String ratingId;
  const RatingDetailsScreen({super.key, required this.ratingId});

  @override
  State<RatingDetailsScreen> createState() => _RatingDetailsScreenState();
}

class _RatingDetailsScreenState extends State<RatingDetailsScreen> {
  TextEditingController searchTextController = TextEditingController();

  bool isApiCalling = false;
  dynamic ratingDetails = {};

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  int userId = 0;
  dynamic userDetails;
  List<dynamic> addOnsRating = <dynamic>[];

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
        "${AppConfigProvider.apiUrl}view_rating?rating_review_id=${widget.ratingId}");
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
      isApiCalling = true;
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
          ratingDetails = (item != "NA") ? item : {};
          addOnsRating = (ratingDetails['addon_rating'] != "NA")
              ? ratingDetails['addon_rating']
              : [];

          setState(() {
            isApiCalling = false;
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
            isApiCalling = false;
          });
        }
      } else {
        print("Error: ${response.statusCode}");
        setState(() {
          isApiCalling = false;
        });
      }
    } catch (e) {
      print("Exception: $e");
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
                            AppLanguage.detailsText[language],
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
                  ],
                ),
              ),
              if (ratingDetails.isNotEmpty)
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Row(
                          children: [
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 12 / 100,
                              height:
                                  MediaQuery.of(context).size.width * 12 / 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: ratingDetails['image'] != null
                                      ? Image.network(
                                          '${AppConfigProvider.imageURL}${ratingDetails['image']}',
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            } else {
                                              return Shimmer.fromColors(
                                                baseColor: Colors.grey.shade300,
                                                highlightColor:
                                                    Colors.grey.shade100,
                                                child: Container(
                                                  color: Colors.grey.shade300,
                                                ),
                                              );
                                            }
                                          },
                                        )
                                      : Image.asset(
                                          AppImage.boatImage,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    2 /
                                    100),
                            Text(
                              ratingDetails['name'] ?? "",
                              style: const TextStyle(
                                  color: AppColor.primaryColor,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Row(
                          children: [
                            Text(
                              AppLanguage.totalRatingsText[language],
                              style: const TextStyle(
                                  color: AppColor.primaryColor,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14),
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    2 /
                                    100),
                            RatingBarIndicator(
                              rating: ratingDetails['total_rating']
                                  .toDouble(), // Use your desired rating value here
                              itemCount: 5,
                              itemSize: 20, // Specify the size of each star
                              unratedColor: AppColor.textColor,
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.yellow,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.1 / 100,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        color: AppColor.primaryColor,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Text(
                          "${AppLanguage.ratingText[language]}:",
                          style: const TextStyle(
                              color: AppColor.primaryColor,
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w600,
                              fontSize: 18),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 85 / 100,
                        child: Column(
                          children: [
                            //! Time Rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${AppLanguage.timeText[language]}:",
                                  style: const TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.primaryColor),
                                ),
                                RatingBarIndicator(
                                  rating: ratingDetails['time']
                                      .toDouble(), // Use your desired rating value here
                                  itemCount: 5,
                                  itemSize: 20, // Specify the size of each star
                                  unratedColor: AppColor.textColor,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  ),
                                ),
                              ],
                            ),

                            //! Clean Rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${AppLanguage.cleanText[language]}:",
                                  style: const TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.primaryColor),
                                ),
                                RatingBarIndicator(
                                  rating: ratingDetails['clean']
                                      .toDouble(), // Use your desired rating value here
                                  itemCount: 5,
                                  itemSize: 20, // Specify the size of each star
                                  unratedColor: AppColor.textColor,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  ),
                                ),
                              ],
                            ),

                            //! Captain Rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${AppLanguage.captainText[language]}:",
                                  style: const TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.primaryColor),
                                ),
                                RatingBarIndicator(
                                  rating: ratingDetails['captain']
                                      .toDouble(), // Use your desired rating value here
                                  itemCount: 5,
                                  itemSize: 20, // Specify the size of each star
                                  unratedColor: AppColor.textColor,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  ),
                                ),
                              ],
                            ),

                            //! Hospitality Rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${AppLanguage.hospitalityText[language]}:",
                                  style: const TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.primaryColor),
                                ),
                                RatingBarIndicator(
                                  rating: ratingDetails['hospitality']
                                      .toDouble(), // Use your desired rating value here
                                  itemCount: 5,
                                  itemSize: 20, // Specify the size of each star
                                  unratedColor: AppColor.textColor,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (addOnsRating.isNotEmpty)
                        Wrap(
                          children: List.generate(
                            addOnsRating.length,
                            (index) {
                              return Column(
                                children: [
                                  //! Addons
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        1 /
                                        100,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        80 /
                                        100,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          addOnsRating[index]['addon_name'],
                                          style: const TextStyle(
                                              color: AppColor.primaryColor,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14),
                                        ),
                                        Row(
                                          children: [
                                            RatingBarIndicator(
                                              rating: addOnsRating[index]
                                                      ['rating']
                                                  .toDouble(), // Use your desired rating value here
                                              itemCount: 5,
                                              itemSize:
                                                  20, // Specify the size of each star
                                              unratedColor: AppColor.textColor,
                                              itemBuilder: (context, _) =>
                                                  const Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.1 / 100,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        color: AppColor.primaryColor,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),
                      if (ratingDetails['review'] != null &&
                          ratingDetails['review'] != "NA" &&
                          ratingDetails['review'].isNotEmpty) ...[
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            "${AppLanguage.commentsText[language]}:",
                            style: const TextStyle(
                                color: AppColor.primaryColor,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 18),
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            ratingDetails['review'] ?? "",
                            style: const TextStyle(
                                color: AppColor.primaryColor,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 6 / 100),
                      ],
                    ],
                  ),
                )),
              if (ratingDetails.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 6.5 / 100,
                    width: MediaQuery.of(context).size.width * 90 / 100,
                    decoration: BoxDecoration(
                      color: AppColor.secondaryColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xffBEC3C7), // Shadow color
                          blurRadius: 9.0, // Blur intensity
                          offset: Offset(0, 5), // Moves shadow 5px down
                        ),
                      ],
                    ),
                    child: Text(
                      AppLanguage.goBackText[language],
                      style: const TextStyle(
                          fontSize: 16,
                          color: AppColor.themeColor,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              SizedBox(height: MediaQuery.of(context).size.height * 5 / 100),
              const NoInternetBanner(),
            ],
          ),
        ),
      ),
    );
  }
}
