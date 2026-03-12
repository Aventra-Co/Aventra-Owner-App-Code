import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui' as ui;
import '../../controller/app_color.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_header.dart';
import '../../controller/app_language.dart';
import '../../controller/app_loader.dart';
import '../../controller/app_snack_bar_toast_message.dart';
import '../authentication/login_screen.dart';

class PropertyAdvertisementScreen extends StatefulWidget {
  const PropertyAdvertisementScreen({super.key, required this.propertyAdId});

  final String propertyAdId;

  @override
  State<PropertyAdvertisementScreen> createState() =>
      _PropertyAdvertisementScreenState();
}

class _PropertyAdvertisementScreenState
    extends State<PropertyAdvertisementScreen> {
  dynamic adDetails = {};
  String allActivity = "";
  bool isApiCalling = true;
  int selectedImageInd = 0;
  String showFormattedDates = '';
  List<dynamic> tripImages = [];
  List<dynamic> offerings = [];
  dynamic userDetails;
  int userId = 0;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

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
        "${AppConfigProvider.apiUrl}view_owner_advertisements?user_id=$userId&property_ad_id=${widget.propertyAdId}");
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
          var item = res['data'];
          adDetails = (item != "NA") ? item : [];
          if (adDetails['images'] != "NA") {
            tripImages.addAll(adDetails['images']);
            offerings = adDetails['amenities'] ?? [];
          }
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

  // ===========================================================================
  Widget _buildUIScreen(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      body: Directionality(
        textDirection:
            language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: SizedBox(
          width: sw,
          height: sh,
          child: Column(
            children: [
              // ── ORANGE HEADER ──────────────────────────────────────────────
              AppHeaderOrange(
                text: AppLanguage.advertisementText[language],
                onPress: () => Navigator.pop(context),
              ),

              // ── SCROLLABLE BODY ────────────────────────────────────────────
              if (adDetails.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: sh * 0.04),
                          //!==================IMAGE CODE=====================//
                          if (tripImages.isNotEmpty)
                            Container(
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 100 / 100,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    90 /
                                    100,
                                height: screenWidth > 600
                                    ? MediaQuery.of(context).size.height *
                                        30 /
                                        100
                                    : MediaQuery.of(context).size.height *
                                        20 /
                                        100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    '${AppConfigProvider.imageURL}${tripImages[selectedImageInd]['image_path']}',
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
                            ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),

                          //!list
                          Container(
                            alignment: Alignment.center,
                            width:
                                MediaQuery.of(context).size.width * 100 / 100,
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
                                      padding:
                                          const EdgeInsets.only(right: 12.0),
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
                                                  '${AppConfigProvider.imageURL}${tripImages[index]['image_path']}',
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
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),

                          SizedBox(height: sh * 0.02),

                          // ── PROPERTY NAME + TYPE + LOCATION ─────────────────
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: sw * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name
                                Text(
                                  adDetails['property_name_english'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Property type
                                Text(
                                  adDetails['property_type_name'][language] ??
                                      "",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // City with red pin
                                Row(
                                  children: [
                                    Image.asset(
                                      './assets/icons/location.png',
                                      height: size.width * 4.5 / 100,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      adDetails['city_name'] ?? "",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColor.primaryColor,
                                        fontFamily: AppFont.fontFamily,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: sh * 0.02),

                          // // ── DETAIL ROWS ──────────────────────────────────────
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: sw * 0.04),
                            child: Column(
                              children: [
                                _detailRow(AppLanguage.guestsText[language],
                                    "${adDetails['max_adult']} ${AppLanguage.adultText[language]} \u2022 ${adDetails['max_child']} ${AppLanguage.childText[language]}"),
                                _detailRow(
                                    "${AppLanguage.roomsText[language]}:",
                                    "${adDetails['no_of_rooms']?.toString() ?? "NA"} ${AppLanguage.roomsText[language]}"),
                                _detailRow(
                                    "${AppLanguage.washroomsText[language]}:",
                                    "${adDetails['no_of_washroom']?.toString() ?? "NA"} ${AppLanguage.washroomsText[language]}"),
                                _detailRow(
                                    "${AppLanguage.hallsText[language]}:",
                                    "${adDetails['no_of_halls']?.toString() ?? "NA"} ${AppLanguage.hallsText[language]}"),
                                _detailRow(
                                    AppLanguage.outdoorSeatingText[language],
                                    adDetails['outdoor_seating'] ?? "NA"),
                                _detailRow(AppLanguage.poolText[language],
                                    adDetails['pool'] ?? "NA"),
                                _detailRow(AppLanguage.guardText[language],
                                    adDetails['guard_name_english']),
                                _detailRow(AppLanguage.oneDayText[language],
                                    "${adDetails['one_day_active'] == 1 ? adDetails['one_day_price']?.toString() : "NA"} ${adDetails['one_day_active'] == 1 ? "KWD" : ""}"),
                                _detailRow(AppLanguage.weekdayText[language],
                                    "${adDetails['weekday_active'] == 1 ? adDetails['weekday_price']?.toString() : "NA"} ${adDetails['weekday_active'] == 1 ? "KWD" : ""}"),
                                _detailRow(AppLanguage.weekendText[language],
                                    "${adDetails['weekend_active'] == 1 ? adDetails['weekend_price']?.toString() : "NA"} ${adDetails['weekend_active'] == 1 ? "KWD" : ""}"),
                                _detailRow(AppLanguage.fullWeekText[language],
                                    "${adDetails['full_week_active'] == 1 ? adDetails['full_week_price']?.toString() : "NA"} ${adDetails['full_week_active'] == 1 ? "KWD" : ""}"),
                                _detailRow(
                                    AppLanguage.couponCodeCOLONText[language],
                                    adDetails['coupon_code'] ?? "NA"),
                                _detailRow(
                                    AppLanguage
                                        .couponDiscountCOLONText[language],
                                    "${(adDetails['coupon_discount'] ?? "0")}%"),
                                _detailRow(
                                    AppLanguage.discountCOLONText[language],
                                    "${(adDetails['discount_percentage'] ?? "0")}%"),
                                _detailRow(
                                    AppLanguage.petFriendlyCOLONText[language],
                                    adDetails['pet_friendly'] == 0
                                        ? AppLanguage.noText[language]
                                        : AppLanguage.yesText[language]),
                                _detailRow(
                                    AppLanguage
                                        .cancellationTimeCOLONText[language],
                                    "${adDetails['free_cancel_days']} ${AppLanguage.daysCOLONText[language]}"),
                              ],
                            ),
                          ),
                          SizedBox(height: sh * 0.02),
                          // // ── DESCRIPTION ──────────────────────────────────────
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: sw * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLanguage.descriptionText[language],
                                  style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.black2A2AColor,
                                    fontFamily: AppFont.fontFamily,
                                  ),
                                ),
                                SizedBox(height: sh * 0.01),
                                Text(
                                  language == 0
                                      ? adDetails['description_english'] ?? "NA"
                                      : adDetails['description_arabic'] ?? "NA",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColor.primaryColor,
                                    fontFamily: AppFont.fontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: sh * 0.02),

                          // Checkboxes
                          if (offerings.isNotEmpty) ...[
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: sw * 0.04),
                              child: Text(
                                AppLanguage.whatThisPlaceOffersText[language],
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.black2A2AColor,
                                ),
                              ),
                            ),
                            SizedBox(height: sh * 0.01),
                            Wrap(
                              runSpacing: 10,
                              spacing: 20,
                              children:
                                  List.generate(offerings.length, (index) {
                                var sub = offerings[index];
                                final amenityName =
                                    sub['name']?.toString() ?? '';
                                final image =
                                    sub['amenity_icon']?.toString() ?? '';
                                return SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        42 /
                                        100,
                                    child: FeatureItem(
                                        title: amenityName, icon: image));
                              }),
                            ),
                          ],

                          SizedBox(height: sh * 0.02),

                          SizedBox(height: sh * 0.12),
                        ],
                      ),
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

  // ── PLAIN TEXT DETAIL ROW ───────────────────────────────────────────────────
  Widget _detailRow(String label, String value) {
    // final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColor.textColor,
                fontFamily: AppFont.fontFamily,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColor.primaryColor,
                fontFamily: AppFont.fontFamily,
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.018),
      ],
    );
  }

  // ── IMAGE PLACEHOLDER ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => ProgressHUD(
      inAsyncCall: isApiCalling, opacity: 0.5, child: _buildUIScreen(context));
}

// ── FEATURE ITEM WIDGET ───────────────────────────────────────────────────────
class FeatureItem extends StatelessWidget {
  const FeatureItem({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.textColor,
  });

  final String icon;
  final Color? iconColor;
  final Color? textColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Row(
        children: [
          Image.network(
            '${AppConfigProvider.imageURL}$icon',
            fit: BoxFit.cover,
            height: 20,
            loadingBuilder: (BuildContext context, Widget child,
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
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontFamily: AppFont.fontFamily,
                fontWeight: FontWeight.w500,
                color: textColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
