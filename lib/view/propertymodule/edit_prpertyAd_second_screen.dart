import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_boat_ownerside/controller/app_snack_bar_toast_message.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_loader.dart';
import '../authentication/login_screen.dart';
import '../../controller/app_footer.dart';
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class EditPropertyAdSecondScreen extends StatefulWidget {
  static String routeName = './EditPropertyAdSecondScreen';
  final dynamic adDetails;
  final XFile? coverImage;
  final List<XFile> serverImageList;
  final List<dynamic> propertyImageList;
  final String deleteIds;
  final String guardNameEnglish;
  final String guardNameArabic;
  final String number;
  final String genderId;
  final String nationalityId;
  final String destinationId;
  final String propertyId;
  final String location;
  final String lat;
  final String long;
  final String cityId;
  final String adultCount;
  final String childCount;
  final String descEng;
  final String descArab;
  final String isPrivate;
  final String couponCode;
  final String startDate;
  final String endDate;
  final String couponDiscount;
  final String discount;

  const EditPropertyAdSecondScreen({
    super.key,
    this.coverImage,
    required this.serverImageList,
    required this.propertyImageList,
    required this.deleteIds,
    required this.guardNameEnglish,
    required this.guardNameArabic,
    required this.number,
    required this.genderId,
    required this.nationalityId,
    required this.destinationId,
    required this.propertyId,
    required this.location,
    required this.lat,
    required this.long,
    required this.cityId,
    required this.adultCount,
    required this.childCount,
    required this.descEng,
    required this.descArab,
    required this.isPrivate,
    required this.couponCode,
    required this.startDate,
    required this.endDate,
    required this.couponDiscount,
    required this.discount,
    required this.adDetails,
  });

  @override
  State<EditPropertyAdSecondScreen> createState() =>
      _EditPropertyAdSecondScreenState();
}

class _EditPropertyAdSecondScreenState
    extends State<EditPropertyAdSecondScreen> {
  bool isApiCalling = false;
  int userId = 0;
  String userType = '';
  dynamic userDetails;

  final TextEditingController oneDayController = TextEditingController();
  final TextEditingController weekDayController = TextEditingController();
  final TextEditingController weekendController = TextEditingController();
  final TextEditingController fullWeekController = TextEditingController();
  final TextEditingController cancelDaysController = TextEditingController();

  List<Map<String, dynamic>> offerings = [];
  final Set<String> selectedOfferings = <String>{};
  // List<dynamic> selectedOfferings = [];
  bool oneDay = false;
  bool weekend = false;
  bool weekday = false;
  bool fullweek = false;
  int isToggle = 1;

  @override
  void initState() {
    super.initState();
    fillData();
    getOfferingsApi();
    getUserDetails();
  }

  fillData() {
    dynamic data = widget.adDetails;
    oneDay = data['one_day_active'] == 1;
    if (oneDay) {
      oneDayController.text = data['one_day_price']?.toString() ?? '';
    }
    weekend = data['weekend_active'] == 1;
    if (weekend) {
      weekendController.text = data['weekend_price']?.toString() ?? '';
    }
    weekday = data['weekday_active'] == 1;
    if (weekday) {
      weekDayController.text = data['weekday_price']?.toString() ?? '';
    }
    fullweek = data['full_week_active'] == 1;
    if (fullweek) {
      fullWeekController.text = data['full_week_price']?.toString() ?? '';
    }
    List<dynamic> selectedAmenities = data['amenities'] ?? [];
    if (selectedAmenities.isNotEmpty) {
      for (var element in selectedAmenities) {
        selectedOfferings.add(element['id'].toString());
      }
    }
    isToggle = data['pet_friendly'] ?? 0;
    cancelDaysController.text = data["free_cancel_days"].toString();
    setState(() {});
  }

  //!--------------------GET USER DETAILS-----------------------//
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
      userType = data['user_type'];
    }
    setState(() {
      isApiCalling = false;
    });

    setState(() {});
  }

  validation() {
    if (!oneDay && !weekday && !weekend && !fullweek) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.selectOnePriceBoxMsg[language]);
      return;
    } else if (oneDay && oneDayController.text.trim().isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.enterAllThePriceMsg[language]);
      return;
    } else if (weekday && weekDayController.text.trim().isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.enterAllThePriceMsg[language]);
      return;
    } else if (weekend && weekendController.text.trim().isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.enterAllThePriceMsg[language]);
      return;
    } else if (fullweek && fullWeekController.text.trim().isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.enterAllThePriceMsg[language]);
      return;
    }
    if (oneDay && oneDayController.text.trim().isNotEmpty) {
      if (checkPriceValue(oneDayController)) return;
    }
    if (weekday && weekDayController.text.trim().isNotEmpty) {
      if (checkPriceValue(weekDayController)) return;
    }
    if (weekend && weekendController.text.trim().isNotEmpty) {
      if (checkPriceValue(weekendController)) return;
    }
    if (fullweek && fullWeekController.text.trim().isNotEmpty) {
      if (checkPriceValue(fullWeekController)) return;
    }
    if (cancelDaysController.text.trim().isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.cancelDaysMsg[language]);
      return;
    } else {
      editAdvertisementApiCall();
    }
  }

  editAdvertisementApiCall() async {
    setState(() {
      isApiCalling = true;
    });

    Uri url =
        Uri.parse("${AppConfigProvider.apiUrl}edit_advertisement_property");

    print("Url===> $url");

    try {
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.fields['user_id'] = userId.toString();
      formData.fields['property_ad_id'] =
          widget.adDetails['property_ad_id'].toString();
      formData.fields['guard_name_english'] = widget.guardNameEnglish;
      formData.fields['guard_name_arabic'] = widget.guardNameArabic;
      formData.fields['guard_number'] = widget.number;
      formData.fields['gender'] = widget.genderId;
      formData.fields['country_id'] = widget.nationalityId;
      formData.fields['destination_id'] = widget.destinationId;
      formData.fields['property_id'] = widget.propertyId;
      formData.fields['address'] = widget.location;
      formData.fields['latitude'] = widget.lat;
      formData.fields['longitude'] = widget.long;
      formData.fields['city_id'] = widget.cityId;
      formData.fields['max_adult'] = widget.adultCount;
      formData.fields['max_child'] = widget.childCount;
      formData.fields['description_english'] = widget.descEng;
      formData.fields['description_arabic'] = widget.descArab;
      formData.fields['coupon_code'] = widget.couponCode.toUpperCase();
      formData.fields['start_date'] =
          widget.couponCode.isEmpty ? "" : widget.startDate;
      formData.fields['end_date'] =
          widget.couponCode.isEmpty ? "" : widget.endDate;
      formData.fields['coupon_discount'] =
          widget.couponCode.isEmpty ? "" : widget.couponDiscount;
      formData.fields['discount_percentage'] = widget.discount;
      formData.fields['one_day_price'] = oneDayController.text.trim();
      formData.fields['one_day_active'] = oneDay ? "1" : "0";
      formData.fields['weekday_price'] = weekDayController.text.trim();
      formData.fields['weekday_active'] = weekday ? "1" : "0";
      formData.fields['weekend_price'] = weekendController.text.trim();
      formData.fields['weekend_active'] = weekend ? "1" : "0";
      formData.fields['full_week_price'] = fullWeekController.text.trim();
      formData.fields['full_week_active'] = fullweek ? "1" : "0";
      formData.fields['pet_friendly'] = isToggle.toString();
      formData.fields['amenity_arr'] = jsonEncode(selectedOfferings.toList());
      formData.fields['free_cancel_days'] = cancelDaysController.text;
      formData.fields['delete_image_id'] = widget.deleteIds;

      if (widget.coverImage != null) {
        XFile image1 = widget.coverImage!;
        List<int> imageBytes = await image1.readAsBytes();
        http.MultipartFile imageFile = http.MultipartFile.fromBytes(
            'coverImage', imageBytes,
            filename: 'image.jpg', contentType: MediaType('image', 'jpg'));

        formData.files.add(imageFile);
      } else {
        formData.fields['coverImage'] = "";
      }

      List data1 = widget.propertyImageList;
      List<File> imageListdata = [];
      if (widget.propertyImageList.isNotEmpty) {
        for (var i = 0; i < data1.length; i++) {
          print(data1[i]);
          if (data1[i]['property_image_id'] == 0) {
            imageListdata.add(data1[i]['image_path']);
          }
        }

        print("imagedata>>>>$imageListdata");

        if (imageListdata.isNotEmpty) {
          for (var i = 0; i < imageListdata.length; i++) {
            // Convert image to bytes
            List<int> imageBytes = await imageListdata[i].readAsBytes();
            http.MultipartFile imageFile = http.MultipartFile.fromBytes(
                'image', imageBytes,
                filename: 'image.jpg', contentType: MediaType('image', 'jpg'));

            formData.files.add(imageFile);
          }
        } else {
          formData.fields['image'] = "";
        }
      }

      log("Fields Data--==> ${formData.fields}");
      // print("response--==> ${formData.files}");
      http.StreamedResponse response = await formData.send();
      print("response--==> $response");
      var responseString = await response.stream.toBytes();
      var res = jsonDecode(utf8.decode(responseString));

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyFooterPage(
                indexOfPage: 1,
              ),
            ),
          );
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          setState(() {
            isApiCalling = false;
          });
        } else {
          setState(() {
            isApiCalling = false;
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
          isApiCalling = false;
        });
      }
    } catch (e) {
      setState(() {
        isApiCalling = false;
      });
    } finally {
      setState(() {
        isApiCalling = false;
      });
    }
  }

  //!=============================GET OFFERINGS DETAILS===================================//
  Future<void> getOfferingsApi() async {
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}get_all_amenities");
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
          if (item is List) {
            offerings = item
                .whereType<Map>()
                .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                .toList();
          } else {
            offerings = [];
          }
          // activitySearchList = (item != "NA") ? item : [];

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

  bool checkPriceValue(dynamic controller) {
    int price = int.parse(controller.text.trim());
    if (price <= 0) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.priceValidMsg[language]);
      return true;
    }
    return false;
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
        statusBarIconBrightness: Brightness.light));
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
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
                      // color: AppColor.themeColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50))),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 4 / 100,
                      ),

                      //profile edit setting
                      Container(
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            //back
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Transform.rotate(
                                angle: language == 1 ? 3.1416 : 0,
                                child: Container(
                                  alignment: Alignment.center,
                                  color: Colors.transparent,
                                  width: MediaQuery.of(context).size.width *
                                      15 /
                                      100,
                                  height: MediaQuery.of(context).size.width *
                                      7 /
                                      100,
                                  child: Image.asset(AppImage.backIcon),
                                ),
                              ),
                            ),

                            Container(
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 70 / 100,
                              child: Text(
                                AppLanguage.editAdvText[language],
                                style: const TextStyle(
                                    color: AppColor.secondaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppFont.fontFamily),
                              ),
                            ),

                            //setting
                            Container(
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 15 / 100,
                              height:
                                  MediaQuery.of(context).size.width * 7 / 100,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 10 / 100,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.03),

                        // Price heading
                        Text(
                          AppLanguage.priceText[language],
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: size.height * 0.015),

                        _buildPriceRow(
                          label: AppLanguage.oneDayText[language],
                          // subLabel: "",
                          value: oneDay,
                          onChanged: (val) => setState(() => oneDay = val!),
                          controller: oneDayController,
                          readOnly: !oneDay,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.015),

                        _buildPriceRow(
                          label: AppLanguage.weekDaysText[language],
                          value: weekday,
                          onChanged: (val) => setState(() => weekday = val!),
                          controller: weekDayController,
                          readOnly: !weekday,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.015),

                        // Weekend
                        _buildPriceRow(
                          label: AppLanguage.weekendDaysText[language],
                          value: weekend,
                          onChanged: (val) => setState(() => weekend = val!),
                          controller: weekendController,
                          readOnly: !weekend,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.015),

                        // Saturday
                        _buildPriceRow(
                          label: AppLanguage.fullWeekDaysText[language],
                          value: fullweek,
                          onChanged: (val) => setState(() => fullweek = val!),
                          controller: fullWeekController,
                          readOnly: !fullweek,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.03),

                        // What this place offers
                        Text(
                          AppLanguage.whatThisPlaceOffersText[language],
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(height: size.height * 0.015),

                        // Checkboxes
                        Wrap(
                          runSpacing: 10,
                          spacing: 20,
                          children: List.generate(offerings.length, (index) {
                            var sub = offerings[index];
                            final amenityId = sub['amenity_id']?.toString();
                            final amenityName =
                                sub['amenity_name']?.toString() ?? '';
                            return SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 42 / 100,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        28 /
                                        100,
                                    child: Text(
                                      amenityName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Checkbox(
                                    value: amenityId != null &&
                                        selectedOfferings.contains(amenityId),
                                    onChanged: amenityId == null
                                        ? null
                                        : (value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedOfferings
                                                    .add(amenityId);
                                              } else {
                                                selectedOfferings
                                                    .remove(amenityId);
                                              }
                                            });
                                          },
                                    activeColor: AppColor.themeColor,
                                    side: const BorderSide(
                                      color: AppColor.themeColor,
                                      width: 1.5,
                                    ),
                                    checkColor: Colors.white,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Expanded(
                        //       child: Column(
                        //         children: [
                        //           _buildCheckbox(
                        //               AppLanguage.tvText[language], parking,
                        //               (val) {
                        //             setState(() => parking = val!);
                        //           }),
                        //           _buildCheckbox(
                        //               AppLanguage.wifiText[language], wifi,
                        //               (val) {
                        //             setState(() => wifi = val!);
                        //           }),
                        //           _buildCheckbox(
                        //               AppLanguage.acText[language], fridge,
                        //               (val) {
                        //             setState(() => fridge = val!);
                        //           }),
                        //           _buildCheckbox(
                        //               AppLanguage.fridgeText[language], fridge,
                        //               (val) {
                        //             setState(() => fridge = val!);
                        //           }),
                        //         ],
                        //       ),
                        //     ),
                        //     Expanded(
                        //       child: Column(
                        //         children: [
                        //           _buildCheckbox(
                        //               AppLanguage.beddingText[language],
                        //               , (val) {
                        //             setState(() => microwave = val!);
                        //           }),
                        //           _buildCheckbox(
                        //               AppLanguage.microwaveText[language],
                        //               microwave, (val) {
                        //             setState(() => microwave = val!);
                        //           }),
                        //           _buildCheckbox(
                        //               AppLanguage.kettleText[language], kettle,
                        //               (val) {
                        //             setState(() => kettle = val!);
                        //           }),
                        //           _buildCheckbox(
                        //               AppLanguage.coffeeMachineText[language],
                        //               coffeeMachine, (val) {
                        //             setState(() => coffeeMachine = val!);
                        //           }),
                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        SizedBox(height: size.height * 0.03),

                        // Pet Friendly
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              AppLanguage.petFriendlyText[language],
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: size.width * 0.12),
                            Row(
                              children: [
                                /// YES
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isToggle = 1;
                                    });
                                  },
                                  child: Text(
                                    AppLanguage.yesText[language],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),

                                SizedBox(width: size.width * 0.02),

                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isToggle = 1;
                                    });
                                  },
                                  child: SizedBox(
                                    width: size.width * 6 / 100,
                                    height: size.width * 6 / 100,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.asset(
                                        isToggle == 1
                                            ? AppImage.markedCircleIcon
                                            : AppImage.circleIcon,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: size.width * 0.05),

                                /// NO
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isToggle = 0;
                                    });
                                  },
                                  child: Text(
                                    AppLanguage.noText[language],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),

                                SizedBox(width: size.width * 0.02),

                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isToggle = 0;
                                    });
                                  },
                                  child: SizedBox(
                                    width: size.width * 6 / 100,
                                    height: size.width * 6 / 100,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.asset(
                                        isToggle == 0
                                            ? AppImage.markedCircleIcon
                                            : AppImage.circleIcon,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.02),

                        Text(
                          AppLanguage.customerCanceldaysText[language],
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),

                        Row(
                          children: [
                            Text(
                              AppLanguage.freetocancelbeforeText[language],
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            SizedBox(
                              width: size.width * 0.15,
                              height: size.height * 0.05,
                              child: TextFormField(
                                controller: cancelDaysController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 2,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(0)),
                                    borderSide:
                                        BorderSide(color: AppColor.themeColor),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            Text(
                              AppLanguage.daysText[language],
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.03),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: size.height * 0.06,
                          child: ElevatedButton(
                            onPressed: () {
                              validation();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.themeColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              AppLanguage.submitText[language],
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.08),
                      ],
                    ),
                  ),
                ),

                // Container(
                //   width: double.infinity,
                //   child: const NoInternetBanner(),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required TextEditingController controller,
    required Size size,
    required bool readOnly,
  }) {
    const double checkboxSize = 24; // default checkbox visual size

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Checkbox + Label
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.scale(
              scale: 1,
              child: SizedBox(
                width: checkboxSize,
                height: checkboxSize,
                child: Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: value,
                  onChanged: onChanged,
                  activeColor: AppColor.themeColor,
                  side: const BorderSide(
                    color: AppColor.themeColor,
                    width: 1.5,
                  ),
                  checkColor: Colors.white,
                ),
              ),
            ),
            SizedBox(width: size.width * 0.02),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: AppFont.fontFamily,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: size.height * 0.01),

        /// Price Row (EXACT same left alignment as checkbox)
        Padding(
          padding: EdgeInsets.only(right: checkboxSize + size.width * 0.001),
          child: Row(
            children: [
              SizedBox(
                child: Text(
                  AppLanguage.priceText[language],
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: AppFont.fontFamily,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.03),
              SizedBox(
                width: size.width * 0.35,
                height: size.height * 0.05,
                child: TextFormField(
                  controller: controller,
                  readOnly: readOnly,
                  keyboardType: TextInputType.number,
                  inputFormatters: AppConstant.onlyDigitFormatter,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: AppFont.fontFamily,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.03),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        borderSide: BorderSide(color: AppColor.themeColor),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      counterText: ""),
                ),
              ),
              const SizedBox(
                child: Text(
                  " KWD",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: AppFont.fontFamily,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: size.height * 0.02),
      ],
    );
  }
}

class CustomTextFormFieldSmallBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  //final int maxLength;
  // final int fillColorStatus;
  final bool readOnly;
  // ignore: prefer_typing_uninitialized_variables
  //var keyboardtype;

  CustomTextFormFieldSmallBox(
      {super.key,
      required this.controller,
      required this.hintText,
      //  required this.keyboardtype,
      //required this.maxLength,
      //  required this.fillColorStatus,
      required this.readOnly});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 18 / 100,
        height: MediaQuery.of(context).size.height * 5 / 100,
        child: TextFormField(
          readOnly: readOnly,
          style: const TextStyle(
              height: 1.1,
              color: AppColor.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w400),
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.number,
          controller: controller,
          onChanged: (value) {},
          decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.textColor),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.textColor),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.themeColor),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 7),
              fillColor: AppColor.secondaryColor,
              filled: true,
              counterText: '',
              hintText: hintText,
              hintStyle: const TextStyle(
                  color: AppColor.textColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 10)),
        ),
      ),
    );
  }
}
