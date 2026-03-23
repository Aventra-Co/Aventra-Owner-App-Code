import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../chat/chat_screen.dart';
import '../../controller/app_button.dart';
import '../../controller/app_color.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';
import '../../controller/app_loader.dart';
import '../../controller/app_snack_bar_toast_message.dart';
import '../../model/chat_user.dart';
import '../authentication/login_screen.dart';
import 'property_ongoing_detail_screen.dart';
import 'view_property_details_screen.dart';
import 'dart:ui' as ui;

class TripStartDetailsScreen extends StatefulWidget {
  final int propertyBookingId;
  const TripStartDetailsScreen({super.key, required this.propertyBookingId});

  @override
  State<TripStartDetailsScreen> createState() => _TripStartDetailsScreenState();
}

class _TripStartDetailsScreenState extends State<TripStartDetailsScreen> {
  dynamic bookingDetails = {};
  String allActivity = "";
  bool isApiCalling = true;
  int selectedImageInd = 0;
  String showFormattedDates = '';
  List<dynamic> tripImages = [];
  List<dynamic> offerings = [];
  dynamic userDetails;
  String addCalendarDate = '';
  int userId = 0;

  //map
  double longitudex = 77.4126;

  double latitudex = 23.2599;

  GoogleMapController? mapController;

  LatLng initialPosition = const LatLng(23.2599, 77.4126);

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
        "${AppConfigProvider.apiUrl}view_property_booking_by_bookingid?user_id=$userId&property_booking_id=${widget.propertyBookingId}");
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
          bookingDetails = (item != "NA") ? item : [];
          offerings = bookingDetails['amenities'] ?? [];
          log("bookingDetails['discount_percentage']  ${bookingDetails['discount_percentage']}");
          latitudex = double.parse(bookingDetails['latitude']);
          longitudex = double.parse(bookingDetails['longitude']);
          addCalendarDate =
              convertDateToFormatted(bookingDetails['checkin_date']);
          initialPosition = LatLng(latitudex, longitudex);
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

  //!!Date formatter
  String convertDateToFormatted(String inputDate) {
    log("not caaleedd");
    final DateTime parsedDate = DateFormat('MMM dd, yyyy').parse(inputDate);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  //!!---------------------------------Add to Calendar API CALL---------------------------//!
  addCalendarApiCall() async {
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}add_to_calender");
    print("Url $url");
    setState(() {
      isApiCalling = true;
    });
    String token = AppConstant.token;
    try {
      var headers = {
        'Authorization': 'Bearer $token',
      };

      var body = {
        'user_id': userId.toString(),
        'trip_booking_id': widget.propertyBookingId.toString(),
        'date': addCalendarDate,
        'entity_type': "1",
      };

      print("body $body");

      http.Response response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      print("response--> $response");
      var res = jsonDecode(response.body);

      print("res333 : $res");

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        setState(() {
          isApiCalling = false;
        });
        if (res['success'] == true) {
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          setState(() {
            bookingDetails['add_status'] = 1;
          });
        } else {
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          if (res['active_status'] == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Login()));
          }
        }
      } else {
        setState(() {
          isApiCalling = false;
        });

        throw Exception('Album loading failed!');
      }
    } catch (e) {
      setState(() {
        isApiCalling = false;
      });

      print("Call Update Api");
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
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
    return Directionality(
      textDirection:
          language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 100 / 100,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 7 / 100,
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Transform.rotate(
                          angle: language == 1 ? 3.1416 : 0,
                          child: SizedBox(
                            height: MediaQuery.of(context).size.width * 5 / 100,
                            width: MediaQuery.of(context).size.width * 5 / 100,
                            child: Image.asset(
                              AppImage.backIcon,
                              color: Colors.black,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 4 / 100,
                        width: MediaQuery.of(context).size.width * 4 / 100,
                      ),
                      Text(AppLanguage.detailsText[language],
                          style: const TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFont.fontFamily)),
                      const Spacer(),
                      Text("ID: #${bookingDetails['booking_random_id'] ?? ""}",
                          style: const TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontFamily: AppFont.fontFamily)),
                    ],
                  ),
                ),
                if (bookingDetails.isNotEmpty)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: size.height * 0.01),
                          if (bookingDetails['add_status'] == 0)
                          Container(
                            alignment: Alignment.centerRight,
                            width: MediaQuery.of(context).size.width * 95 / 100,
                            child: GestureDetector(
                              onTap: () {
                                addCalendarApiCall();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width *
                                    25 /
                                    100,
                                decoration: BoxDecoration(
                                    color: AppColor.themeColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    AppLanguage.addToCalenderText[language],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: AppColor.secondaryColor,
                                        fontFamily: AppFont.fontFamily),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: size.width * 0.05),
                            decoration: const BoxDecoration(
                              color: AppColor.peachColor,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            AppLanguage.upcomingText[language],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: AppFont.fontFamily,
                                              color: AppColor.pendingColor,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViewPropertyDetailsScreen(
                                                          adDetails:
                                                              bookingDetails),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              AppLanguage
                                                  .viewDetailsText[language],
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  color: Color(0xFF17A2B8),
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      AppColor.completedColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bookingDetails[
                                                    'property_name_english'] ??
                                                "",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: AppFont.fontFamily,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            bookingDetails['property_type_name']
                                                    [language] ??
                                                "",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppFont.fontFamily,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${AppLanguage.guardText[language]} \u2022 ${language == 0 ? (((bookingDetails['guard_name_english'] ?? "").toString().trim().isEmpty) ? "NA" : bookingDetails['guard_name_english'] ?? "") : (((bookingDetails['guard_name_arabic'] ?? "").toString().trim().isEmpty) ? "N/A" : bookingDetails['guard_name_arabic'] ?? "")}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppFont.fontFamily,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    "${AppConfigProvider.imageURL}${bookingDetails['cover_image']}",
                                    width: size.width * 0.18,
                                    height: size.width * 0.18,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: size.height * 0.02),

                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.05),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Location Address
                                Text(
                                  AppLanguage.locationAddressText[language],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppFont.fontFamily,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  child: Text(
                                    bookingDetails['address'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontFamily,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.02),

                                //!Map
                                Stack(children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              18 /
                                              100,
                                      width: MediaQuery.of(context).size.width *
                                          90 /
                                          100,
                                      child: GoogleMap(
                                        mapToolbarEnabled: false,
                                        zoomGesturesEnabled: false,
                                        rotateGesturesEnabled: true,
                                        myLocationEnabled: false,
                                        myLocationButtonEnabled: false,
                                        compassEnabled: true,
                                        initialCameraPosition: CameraPosition(
                                          target: initialPosition,
                                          zoom: 10.0,
                                        ),
                                        onMapCreated: (controller) {
                                          //method called when map is created
                                          setState(() {
                                            mapController = controller;
                                          });
                                        },
                                        markers: {
                                          Marker(
                                            markerId: const MarkerId(''),
                                            position:
                                                LatLng(latitudex, longitudex),
                                            draggable: true,
                                            onDragEnd: (value) {
                                              // value is the new position
                                            },
                                          ),
                                        },
                                      ),
                                    ),
                                  ),
                                ]),

                                SizedBox(height: size.height * 0.03),

                                // Booking Details
                                Text(
                                  AppLanguage.bookingDetailsText[language],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppFont.fontFamily,
                                    // color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.02),

                                _detailRow(
                                    context,
                                    AppImage.timeIcon,
                                    bookingDetails['booking_date'] ?? '',
                                    AppLanguage.checkInDateText[language],
                                    AppLanguage.changeText[language],
                                    0, () {
                                  Navigator.pop(context);
                                }),
                                SizedBox(height: size.height * 0.02),

                                _detailRow(
                                    context,
                                    AppImage.timeIcon,
                                    bookingDetails['booking_time_label'] ?? "",
                                    // '$totalDates ${AppLanguage.daysText[language]}',
                                    AppLanguage.bookingDays[language],
                                    AppLanguage.changeText[language],
                                    0, () {
                                  Navigator.pop(context);
                                }),
                                SizedBox(height: size.height * 0.02),

                                _detailRow(
                                    context,
                                    AppImage.memberIcon,
                                    '${bookingDetails['max_adult'] ?? "0"} ${AppLanguage.adultText[language]} \u2022 ${bookingDetails['max_child'] ?? "0"} ${AppLanguage.childrenText[language]}',
                                    AppLanguage.guestsText[language],
                                    AppLanguage.changeText[language],
                                    0, () {
                                  Navigator.pop(context);
                                }),
                                SizedBox(height: size.height * 0.03),

                                // Description
                                Text(
                                  AppLanguage.descriptionText[language],
                                  style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppFont.fontFamily,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.015),
                                Text(
                                  (bookingDetails['description_english']
                                                  [language]
                                              ?.toString()
                                              .trim()
                                              .isNotEmpty ??
                                          false)
                                      ? bookingDetails['description_english']
                                          [language]
                                      : "NA",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: AppFont.fontFamily,
                                    color: Colors.grey.shade700,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: size.height * 3 / 100),

                                Text(
                                  AppLanguage.whatThisplaceOfferText[language],
                                  style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppFont.fontFamily,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01),
                                _amenitiesGrid(context),

                                SizedBox(height: size.height * 0.03),

                                // GestureDetector(
                                //   onTap: () =>
                                //       _showCancellationPolicyDialog(context),
                                //   child: Row(
                                //     mainAxisAlignment: MainAxisAlignment.start,
                                //     children: [
                                //       Image.asset(
                                //         AppImage.cancelIcon,
                                //         width: size.width * 0.045,
                                //       ),
                                //       SizedBox(width: size.width * 0.02),
                                //       Text(
                                //         AppLanguage
                                //             .cancellationPolicyText[language],
                                //         style: const TextStyle(
                                //           fontSize: 14,
                                //           fontWeight: FontWeight.w500,
                                //           fontFamily: AppFont.fontFamily,
                                //           color: AppColor.themeColor,
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.03),

                          // Billing Details
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.02,
                                horizontal: size.width * 0.04),
                            color: AppColor.peachColor,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.height * 0.018),
                                  Text(
                                    AppLanguage.billingDetailsText[language],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: AppFont.fontFamily,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 2 / 100),
                                  _billingRow(
                                      size,
                                      bookingDetails['booking_time_label'] ??
                                          "",
                                      '${bookingDetails['total_amount'] ?? "0"} KWD',
                                      ''),
                                  Divider(height: size.height * 2 / 100),
                                  _billingRow(
                                      size,
                                      AppLanguage.grandTotalText[language],
                                      '${bookingDetails['total_amount'] ?? "0"} KWD',
                                      '',
                                      isBold: true),
                                  if (bookingDetails['discount_percentage'] !=
                                          null &&
                                      bookingDetails['discount_percentage'] !=
                                          0 &&
                                      bookingDetails['discount_percentage'] !=
                                          "NA")
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "+${AppLanguage.withText[language]} ${bookingDetails['discount_percentage']}% ${AppLanguage.discountText[language]}",
                                          style: const TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.primaryColor),
                                        ),
                                      ],
                                    ),
                                  if (bookingDetails['coupon_code'] != null &&
                                      bookingDetails['coupon_code']
                                          .isNotEmpty &&
                                      bookingDetails['coupon_code'] != "NA")
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "+${AppLanguage.withText[language]} ${bookingDetails['coupon_discount']}% ${AppLanguage.couponDiscountText[language]}",
                                          style: const TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.primaryColor),
                                        ),
                                      ],
                                    ),
                                  Divider(height: size.height * 2 / 100),
                                  SizedBox(height: size.height * 0.02),
                                ]),
                          ),

                          SizedBox(height: size.height * 0.03),

                          //chat button
                          Center(
                            child: AppButton(
                                text: AppLanguage.chatText[language],
                                onPress: () {
                                  navigateToChatScreen(
                                      bookingDetails['user_id'].toString());
                                }),
                          ),

                          // Cancel Booking
                          // InkWell(
                          //   onTap: () {
                          //     // Navigator.push(
                          //     //     context,
                          //     //     MaterialPageRoute(
                          //     //         builder: (context) => CancelBooking(
                          //     //               cancelType: 2,
                          //     //               tripBookingId: "0",
                          //     //               propertyBookingId:
                          //     //                   widget.propertyBookingId,
                          //     //             )));
                          //     // _showCancelBookingModal(context);
                          //   },
                          //   child: Container(
                          //     padding: EdgeInsets.symmetric(
                          //         vertical: size.height * 0.014,
                          //         horizontal: size.width * 0.05),
                          //     decoration: BoxDecoration(
                          //       color: Colors.grey.shade100,
                          //     ),
                          //     child: Row(
                          //       mainAxisAlignment:
                          //           MainAxisAlignment.spaceBetween,
                          //       children: [
                          //         Row(
                          //           children: [
                          //             const Text(
                          //               'Cancel Booking',
                          //               style: TextStyle(
                          //                 fontSize: 14,
                          //                 fontWeight: FontWeight.w500,
                          //                 fontFamily: AppFont.fontFamily,
                          //                 // color: Colors.grey,
                          //               ),
                          //             ),
                          //             SizedBox(width: size.width * 0.015),
                          //             const Icon(Icons.info_outline,
                          //                 size: 16, color: Colors.grey),
                          //           ],
                          //         ),
                          //         const Icon(Icons.chevron_right),
                          //       ],
                          //     ),
                          //   ),
                          // ),

                          SizedBox(height: size.height * 0.05),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================navigationchat==========//
  void navigateToChatScreen(String userId) {
    print(userId);
    // Flag to prevent multiple navigations
    bool isNavigated = false;

    // Listen for changes in the Firestore collection "users"
    FirebaseFirestore.instance
        .collection("users")
        .snapshots()
        .listen((snapshot) {
      // If already navigated, return early to prevent further navigation
      if (isNavigated) return;

      // Find the user with the matching ID
      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data['id'] == userId) {
          // Create the ChatUser object from the matched document data
          ChatUser user = ChatUser.fromJson(data);

          // Navigate to ChatScreen with the user data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(user: user),
            ),
          );

          // Set the flag to true to prevent further navigation
          isNavigated = true;
          break; // Exit loop once the user is found and the screen is navigated
        }
      }
    });
  }

  Widget _amenitiesGrid(context) {
    return Wrap(
      runSpacing: 10,
      spacing: 20,
      children: List.generate(offerings.length, (index) {
        var sub = offerings[index];
        final amenityName = sub['name']?.toString() ?? '';
        final image = sub['amenity_icon']?.toString() ?? '';
        return SizedBox(
            width: MediaQuery.of(context).size.width * 42 / 100,
            child: FeatureItem(title: amenityName, icon: image));
      }),
    );
  }

  Widget _detailRow(BuildContext context, String image, String value,
      String label, String action, int isAction, VoidCallback onTap) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 90 / 100,
      child: Row(
        children: [
          Image.asset(
            image,
            width: MediaQuery.of(context).size.width * 9 / 100,
            height: MediaQuery.of(context).size.width * 9 / 100,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFont.fontFamily,
                    // color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFont.fontFamily,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isAction == 1)
            TextButton(
              onPressed: onTap,
              child: Text(
                action,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFont.fontFamily,
                  color: AppColor.primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _billingRow(Size size, String label, String amount, String subtitle,
      {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                fontFamily: AppFont.fontFamily,
                color: Colors.black,
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: AppFont.fontFamily,
              ),
            ),
          ],
        ),
        if (subtitle.isNotEmpty) ...[
          SizedBox(height: size.height * 0.005),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              fontFamily: AppFont.fontFamily,
              color: AppColor.completedColor,
            ),
          ),
        ],
      ],
    );
  }
}
