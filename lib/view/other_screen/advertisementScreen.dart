import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_loader.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../authentication/login_screen.dart';
import '/utilities/app_header.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import 'dart:ui' as ui;

class AdvertisementScreen extends StatefulWidget {
  static String routeName = './AdvertisementScreen';
  final String tripId;
  const AdvertisementScreen({super.key, required this.tripId});

  @override
  State<AdvertisementScreen> createState() => _AdvertisementScreenState();
}

class _AdvertisementScreenState extends State<AdvertisementScreen> {
  List images = [
    AppImage.boatImage,
    AppImage.boatWaterIcon,
    AppImage.yatchImage,
    AppImage.yatch2Image,
    AppImage.carBgImage,
  ];
  bool isApiCalling = false;
  int selectedImageInd = 0;
  String allActivity = "";
  String showFormattedDates = '';
  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  int userId = 0;
  dynamic userDetails;
  dynamic adDetails = {};
  List<dynamic> tripImages = [];

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
    getAdDetailsApi(userId);
    setState(() {});
  }

  //=============================GET Advertisement DETAILS===================================//
  Future<void> getAdDetailsApi(userId) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}get_trip_details?user_id=$userId&trip_id=${widget.tripId}");
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
          var item = res['trip_arr'];
          adDetails = (item != "NA") ? item : [];
          String coverImage = adDetails['trip_image'];
          tripImages.add({"trip_image_id": 0, "image": coverImage});
          if (adDetails['tripImages'] != "NA") {
            tripImages.addAll(adDetails['tripImages']);
          }
          List<dynamic> activity =
              (adDetails['activity'] != "NA") ? adDetails['activity'] : [];
          changeDateFormat();
          concatActivities(activity);
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

  void concatActivities(List<dynamic> activities) {
    String activity = activities.map((activity) {
      return language == 0
          ? activity['name_english']!
          : activity['name_arabic']!;
    }).join(", ");
    allActivity = activity;
    setState(() {});
  }

  changeDateFormat() {
    if (adDetails['trip_date_type'] == 1) {
      List<String> tempArr = adDetails['trip_date'].split(", ");
      List<String> formattedDates = [];
      for (var i = 0; i < tempArr.length; i++) {
        formattedDates.add(
          DateFormat("dd-MM-yyyy").format(DateTime.parse(tempArr[i])),
        );
      }
      showFormattedDates = formattedDates.join(', ');
    } else {
      showFormattedDates = adDetails['trip_date'];
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
              AppHeaderOrange(
                  text: AppLanguage.advertisementText[language],
                  onPress: () {
                    Navigator.pop(context);
                  }),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100),

                      //==================IMAGE CODE=====================//
                      if (tripImages.isNotEmpty)
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          height: screenWidth > 600
                              ? MediaQuery.of(context).size.height * 30 / 100
                              : MediaQuery.of(context).size.height * 20 / 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              '${AppConfigProvider.imageURL}${tripImages[selectedImageInd]['image']}',
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      color: Colors.grey.shade300,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100),

                      //list
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 100 / 100,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: screenWidth > 600 ? 38 : 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children:
                                  List.generate(tripImages.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedImageInd = index;
                                          });
                                        },
                                        child: SizedBox(
                                          width: screenWidth > 600
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  15 /
                                                  100
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  15 /
                                                  100,
                                          height: screenWidth > 600
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  15 /
                                                  100
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  15 /
                                                  100,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.network(
                                              '${AppConfigProvider.imageURL}${tripImages[index]['image']}',
                                              fit: BoxFit.cover,
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent?
                                                          loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                } else {
                                                  return Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey.shade300,
                                                    highlightColor:
                                                        Colors.grey.shade100,
                                                    child: Container(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100),

                      if (adDetails.isNotEmpty)
                        Column(
                          children: [
                            textTile(
                                AppLanguage.advertisementTypeText[language],
                                adDetails['advertisement_type'] == 0
                                    ? AppLanguage.privateText[language]
                                    : AppLanguage.publicText[language]),
                 
                            textTile(AppLanguage.tripDateText[language],
                                showFormattedDates),
                            textTile(AppLanguage.tripTimeText[language],
                                adDetails["trip_time"]),
                            textTile(AppLanguage.numberOfGuestsText[language],
                                adDetails['max_people'].toString()),
                            // textTile(AppLanguage.tripHoursText[language], "4 hr"),
                            textTile(AppLanguage.slotPriceText[language],
                                "${adDetails['price_per_hour']} KWD"),
                            textTile(AppLanguage.captainNameText[language],
                                "${adDetails['captain_name_english'][language]}"),

                            //loop addons
                            if (adDetails['addons'] != "NA")
                              Wrap(
                                children: List.generate(
                                  adDetails['addons'].length,
                                  (index) {
                                    return textTile(
                                        adDetails['addons'][index]['addonName'],
                                        adDetails['addons'][index]['subCat']);
                                  },
                                ),
                              ),

                            if (allActivity.isNotEmpty)
                              textTile(AppLanguage.activityText[language],
                                  allActivity),

                            textTile(AppLanguage.tripDestinationText[language],
                                adDetails['destinaton'][language]),
                            // textTile(AppLanguage.tripTypeText[language], "Parasailing"),
                            textTile(AppLanguage.couponCodeText[language],
                                adDetails['coupon_code'] ?? ""),
                            if (adDetails['coupon_code'] != null &&
                                adDetails['coupon_code'] != "NA")
                              Column(
                                children: [
                                  textTile(AppLanguage.startDateText[language],
                                      adDetails['coupon_start_date'] ?? ""),
                                  textTile(AppLanguage.endDateText[language],
                                      adDetails['coupon_end_date'] ?? ""),
                                ],
                              ),

                            textTile(AppLanguage.couponDiscountText[language],
                                "${adDetails['coupon_discount'].toString()}%"),
                            textTile(AppLanguage.discountText[language],
                                "${adDetails['discount'].toString()}%"),
                            textTile(
                                AppLanguage.selectedItemPriceText[language],
                                "KDW ${adDetails['totalAddonPrice']}"),
                        
                            textTile(AppLanguage.cancellationTimeText[language],
                                "${adDetails['cancle_day']} Days"),
                          ],
                        )
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

  textTile(leftText, rightText) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 90 / 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 47 / 100,
                child: Text(
                  "$leftText:",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColor.primaryColor,
                    fontFamily: AppFont.fontFamily,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 41 / 100,
                child: Text(
                  rightText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColor.primaryColor,
                    fontFamily: AppFont.fontFamily,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),
      ],
    );
  }
}
