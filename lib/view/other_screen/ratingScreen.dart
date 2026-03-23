import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/app_color.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';
import '../../controller/app_loader.dart';
import '../../controller/app_shimmers.dart';
import '../../controller/app_snack_bar_toast_message.dart';
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

  // ================= PROPERTY STATIC RATING LIST =================

  List<Map<String, dynamic>> propertyRatingList = [
    {
      "rating_review_id": "101",
      "name": "Ahmed Ali",
      "review": "Amazing property experience",
      "total_rating_average": 4.5,
      "createtime": "12 Feb 2026",
      "image": AppImage.profilePlaceholderImage,
    },
    {
      "rating_review_id": "102",
      "name": "Sara Khan",
      "review": "Very clean",
      "total_rating_average": 5.0,
      "createtime": "15 Feb 2026",
      "image": AppImage.profilePlaceholderImage,
    },
    {
      "rating_review_id": "103",
      "name": "John Smith",
      "review": "Good Experience Hopefully will have again",
      "total_rating_average": 3.5,
      "createtime": "18 Feb 2026",
      "image": AppImage.profilePlaceholderImage,
    },
  ];

  int status = 1;
  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
        inAsyncCall: isApiCalling,
        opacity: 0.5,
        child: _buildUIScreen(context));
  }

  Widget _buildUIScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double screenWidth = MediaQuery.of(context).size.width;
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
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 3 / 100,
                    ),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),

              //!toggle buttons
              SizedBox(
                width: MediaQuery.of(context).size.width * 90 / 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          status = 1;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 42 / 100,
                        decoration: BoxDecoration(
                            color: status == 1
                                ? AppColor.themeColor
                                : AppColor.secondaryColor,
                            border: Border.all(color: AppColor.themeColor),
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenWidth > 600 ? 15 : 8.0),
                          child: Text(
                            AppLanguage.seaText[language],
                            style: TextStyle(
                                fontSize: screenWidth > 600 ? 20 : 14,
                                fontWeight: FontWeight.w700,
                                color: status == 1
                                    ? AppColor.secondaryColor
                                    : AppColor.primaryColor,
                                fontFamily: AppFont.fontFamily),
                          ),
                        ),
                      ),
                    ),

                    //!upcoming
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          status = 2;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 42 / 100,
                        decoration: BoxDecoration(
                            color: status == 2
                                ? AppColor.themeColor
                                : AppColor.secondaryColor,
                            border: Border.all(color: AppColor.themeColor),
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenWidth > 600 ? 15 : 8.0),
                          child: Text(
                            AppLanguage.propertyText[language],
                            style: TextStyle(
                                fontSize: screenWidth > 600 ? 20 : 14,
                                fontWeight: FontWeight.w700,
                                color: status == 2
                                    ? AppColor.secondaryColor
                                    : AppColor.primaryColor,
                                fontFamily: AppFont.fontFamily),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              if (status == 2 && propertyRatingList.isNotEmpty) ...[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),
                Wrap(
                  children: [
                    ...List.generate(propertyRatingList.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RatingDetailsScreen(
                                ratingId: ratingList[index]['rating_review_id']
                                    .toString(),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: size.height * 0.01,
                              horizontal: size.width * 2 / 100),
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 7.0),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColor.textLightColor,
                                blurRadius: 9.0,
                                offset: Offset(1, 0),
                              ),
                            ],
                            color: AppColor.secondaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(
                                  propertyRatingList[index]['image']),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      propertyRatingList[index]['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontFamily: AppFont.fontFamily,
                                          fontSize: 12,
                                          color: AppColor.primaryColor),
                                    ),
                                    Text(
                                      propertyRatingList[index]['createtime'],
                                      style: const TextStyle(
                                          color: AppColor.primaryColor,
                                          fontSize: 12,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                                RatingBarIndicator(
                                  rating: propertyRatingList[index]
                                          ['total_rating_average']
                                      .toDouble(),
                                  itemCount: 5,
                                  itemSize: 20,
                                  unratedColor: AppColor.textLightColor,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              propertyRatingList[index]['review'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 8,
                                  color: AppColor.primaryColor),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
              isLoading
                  ? ratingShimmerEffect(context)
                  : Expanded(
                      child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          if (ratingList.isNotEmpty && status != 2)
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
