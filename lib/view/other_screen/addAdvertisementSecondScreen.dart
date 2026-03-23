import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:the_boat_ownerside/controller/app_snack_bar_toast_message.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_loader.dart';
import '../authentication/login_screen.dart';
import '../../controller/app_button.dart';
import '../../controller/app_footer.dart';
import '../../controller/textinput.dart';
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class AddAdvertisementSecondScreen extends StatefulWidget {
  static String routeName = './AddAdvertisementSecondScreen';
  final XFile? coverImage;
  final List<XFile> serverImageList;
  final String capNameEng;
  final String capNameArab;
  final String number;
  final String genderId;
  final String nationalityId;
  final String destinationId;
  final String activityId;
  final String boatId;
  final String pickup;
  final String lat;
  final String long;
  final String cityId;
  final String members;
  final String descEng;
  final String descArab;
  final String isPrivate;
  final String couponCode;
  final String startDate;
  final String endDate;
  final String couponDiscount;
  final String discount;
  const AddAdvertisementSecondScreen(
      {super.key,
      this.coverImage,
      required this.capNameEng,
      required this.capNameArab,
      required this.number,
      required this.genderId,
      required this.nationalityId,
      required this.activityId,
      required this.boatId,
      required this.pickup,
      required this.cityId,
      required this.members,
      required this.descEng,
      required this.descArab,
      required this.discount,
      required this.serverImageList,
      required this.isPrivate,
      required this.destinationId,
      required this.lat,
      required this.long,
      required this.couponDiscount,
      required this.couponCode,
      required this.startDate,
      required this.endDate});

  @override
  State<AddAdvertisementSecondScreen> createState() =>
      _AddAdvertisementSecondScreenState();
}

class _AddAdvertisementSecondScreenState
    extends State<AddAdvertisementSecondScreen> {
  TextEditingController slotPriceTextEditingController =
      TextEditingController();
  TextEditingController minimumHoursTextEditingController =
      TextEditingController();
  TextEditingController idleHoursTextEditingController =
      TextEditingController();
  TextEditingController reetocancelbeforeTextEditingController =
      TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  String sendStartTime = "";
  String sendEndTime = "";
  int tripTime = 0;
  int tripDate = 0;
  DateTime _focusedDay = DateTime.now();
  final List<String> _selectedDateStrings = [];
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  List<List<dynamic>> fetchedData = [];
  List<dynamic> addOnList = [];
  List<int> toCheckBox = [];
  bool isApiCalling = false;
  Map<int, List<TextEditingController>> controllersMap = {}; // key = addon_id
  List<dynamic> selectedAddOns = <dynamic>[];
  int userId = 0;
  dynamic userDetails;
  String? startTimeFormatted;
  String? endTimeFormatted;

  @override
  void initState() {
    super.initState();
    getAddOnsApi();
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
    setState(() {});
  }

  void initializeControllers() {
    for (var addon in addOnList) {
      int addonId = addon['addon_id'];
      List subcategories = addon['subcategories'];
      controllersMap[addonId] = List.generate(
        subcategories.length,
        (_) => TextEditingController(),
      );
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    controllersMap.forEach((_, controllerList) {
      for (var controller in controllerList) {
        controller.dispose();
      }
    });
    super.dispose();
  }

  //=============================GET Add-ons DETAILS===================================//
  Future<void> getAddOnsApi() async {
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}get_addons");
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
          var item = res['addonCategoryArray'];
          addOnList = (item != "NA") ? item : [];
          // activitySearchList = (item != "NA") ? item : [];
          initializeControllers();

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

  //================add-ons validation==================
  addOnsValidation(
      String slotPrice, String minHours, String idleHours, String cancelDay) {
    if (tripTime == 0 && (sendStartTime.isEmpty || sendEndTime.isEmpty)) {
      log("$tripTime");
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.openTimeMsg[language]);
      return;
    } else if (tripTime == 1 && sendStartTime.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.fixedTimeMsg[language]);
      return;
    } else if (slotPrice.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.slotPriceMsg[language]);
      return;
    } else if (minHours.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.minimumHoursMsg[language]);
      return;
    } else if (int.parse(minHours) > 24) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.lessHourMsg[language]);
      return;
    } else if (idleHours.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.idleHoursMsg[language]);
      return;
    } else if (int.parse(idleHours) > 24) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.lessIdleHourMsg[language]);
      return;
    } else if (tripDate == 1 && _selectedDateStrings.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.tripDateMsg[language]);
      return;
    } else if (toCheckBox.length != selectedAddOns.length) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.markedFieldMsg[language]);
      return;
    } else if (cancelDay.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.cancelDaysMsg[language]);
      return;
    } else {
      addAdvertisementApiCall();
    }
  }

  //------------------------add advertisement API CALL--------------------------------//
  addAdvertisementApiCall() async {
    setState(() {
      isApiCalling = true;
    });

    Uri url = Uri.parse("${AppConfigProvider.apiUrl}add_trip");

    print("Url===> $url");

    try {
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.fields['user_id'] = userId.toString();
      formData.fields['captain_name_english'] = widget.capNameEng;
      formData.fields['captain_name_arabic'] = widget.capNameArab;
      formData.fields['advertisement_type'] = widget.isPrivate;
      formData.fields['contact_number'] = widget.number;
      formData.fields['gender'] = widget.genderId;
      formData.fields['country_id'] = widget.nationalityId;
      formData.fields['destination_id'] = widget.destinationId;
      formData.fields['trip_type_id'] = widget.activityId;
      formData.fields['boat_id'] = widget.boatId;
      formData.fields['pickup_point'] = widget.pickup;
      formData.fields['latitude'] = widget.lat;
      formData.fields['longitude'] = widget.long;
      formData.fields['city_id'] = widget.cityId;
      formData.fields['max_people'] = widget.members;
      formData.fields['description_english'] = widget.descEng;
      formData.fields['description_arabic'] = widget.descArab;
      formData.fields['coupon_code'] = widget.couponCode.toUpperCase();
      formData.fields['start_date'] =
          widget.couponCode.isEmpty ? "" : widget.startDate;
      formData.fields['end_date'] =
          widget.couponCode.isEmpty ? "" : widget.endDate;
      formData.fields['coupon_discount'] =
          widget.couponCode.isEmpty ? "" : widget.couponDiscount;
      formData.fields['discount'] = widget.discount;
      formData.fields['trip_time'] = tripTime.toString();
      formData.fields['trip_open_time'] = sendStartTime;
      formData.fields['fixed_time'] = sendStartTime;
      formData.fields['trip_close_time'] = sendEndTime;
      formData.fields['price_per_hour'] = slotPriceTextEditingController.text;
      formData.fields['minimum_hours'] = minimumHoursTextEditingController.text;
      formData.fields['idle_hours'] = idleHoursTextEditingController.text;
      formData.fields['trip_date_type'] = tripDate.toString();
      formData.fields['trip_date'] = _selectedDateStrings.join(", ");
      formData.fields['entertainment_arr'] = jsonEncode(selectedAddOns);
      formData.fields['free_to_cancel'] =
          reetocancelbeforeTextEditingController.text;

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

      List<XFile> data = widget.serverImageList;

      if (data.isNotEmpty) {
        for (var i = 0; i < data.length; i++) {
          print("length data ${data.length}");
          // Convert image to bytes
          List<int> imageBytes = await data[i].readAsBytes();
          http.MultipartFile imageFile = http.MultipartFile.fromBytes(
              'image', imageBytes,
              filename: 'image.jpg', contentType: MediaType('image', 'jpg'));

          formData.files.add(imageFile);
        }
      }

      log("response--==> ${formData.fields}");
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
    }
  }

  String _formatTimeOfDayTo24(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes:00';
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
                //!image header
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

                            //profile
                            Container(
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 70 / 100,
                              child: Text(
                                AppLanguage.addAdvText[language],
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
                  child: Column(
                    children: [
                      //!=== Trip Time ===
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Text(
                          AppLanguage.tripTimeText[language],
                          style: const TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontFamily: AppFont.fontFamily),
                        ),
                      ),

                      //!=== Choose time Text ====
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Text(
                          AppLanguage.chooseTimeText[language],
                          style: const TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFont.fontFamily),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),

                      //! Open Time Text and Image
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  tripTime = 0;
                                  _timeController.clear();
                                  sendStartTime = "";
                                  sendEndTime = "";
                                });
                              },
                              child: Container(
                                child: Row(
                                  children: [
                                    Image.asset(
                                      tripTime == 0
                                          ? AppImage.markedCircleIcon
                                          : AppImage.circleIcon,
                                      scale: 4,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          1 /
                                          100,
                                    ),
                                    Text(
                                      AppLanguage.openTimeText[language],
                                      style: const TextStyle(
                                          color: AppColor.primaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: AppFont.fontFamily),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            (tripTime == 0)
                                ? Container(
                                    height: MediaQuery.of(context).size.height *
                                        5 /
                                        100,
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: AppColor.textColor),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                55 /
                                                100,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                4 /
                                                100,
                                        child: TextFormField(
                                          style: const TextStyle(
                                            color: AppColor.primaryColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppFont.fontFamily,
                                          ),
                                          readOnly: true,
                                          controller:
                                              _timeController, // <-- Your TextEditingController
                                          onTap: () async {
                                            // Pick start time
                                            final TimeOfDay? pickedStart =
                                                await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            );

                                            if (pickedStart != null) {
                                              // 👇 Force minutes to 0
                                              final fixedStart = pickedStart
                                                  .replacing(minute: 0);

                                              // Pick end time
                                              final TimeOfDay? pickedEnd =
                                                  await showTimePicker(
                                                context: context,
                                                initialTime:
                                                    fixedStart.replacing(
                                                        hour: fixedStart.hour +
                                                            1),
                                              );

                                              if (pickedEnd != null) {
                                                // 👇 Force minutes to 0
                                                final fixedEnd = pickedEnd
                                                    .replacing(minute: 0);

                                                final startMinutes =
                                                    fixedStart.hour * 60;
                                                final endMinutes =
                                                    fixedEnd.hour * 60;

                                                if (endMinutes >=
                                                    startMinutes) {
                                                  final String startFormatted =
                                                      fixedStart
                                                          .format(context);
                                                  final String endFormatted =
                                                      fixedEnd.format(context);

                                                  final String start24Hour =
                                                      _formatTimeOfDayTo24(
                                                          fixedStart);
                                                  final String end24Hour =
                                                      _formatTimeOfDayTo24(
                                                          fixedEnd);

                                                  setState(() {
                                                    _timeController.text =
                                                        "$startFormatted - $endFormatted";
                                                    sendStartTime = start24Hour;
                                                    sendEndTime = end24Hour;
                                                    selectedStartTime =
                                                        fixedStart;
                                                    selectedEndTime = fixedEnd;
                                                    startTimeFormatted =
                                                        start24Hour;
                                                    endTimeFormatted =
                                                        end24Hour;
                                                  });
                                                } else {
                                                  SnackBarToastMessage
                                                      .showSnackBar(
                                                    context,
                                                    "End time should be later than start time.",
                                                  );
                                                }
                                              }
                                            }
                                          },

                                          decoration: InputDecoration(
                                            hintText:
                                                "${AppLanguage.startEndTimeText[language]}*",
                                            hintStyle: const TextStyle(
                                              color: AppColor.primaryColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppFont.fontFamily,
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    right: 20),
                                            border: InputBorder.none,
                                            suffixIcon: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1 /
                                                    100,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1 /
                                                    100,
                                                child: Image.asset(
                                                  AppImage
                                                      .clockIconOrange, // Replace with your time icon
                                                  height: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        5 /
                                        100,
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),

                      //! Fixed Time Text and Image
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  tripTime = 1;
                                  _timeController.clear();
                                  sendStartTime = "";
                                });
                              },
                              child: Container(
                                child: Row(
                                  children: [
                                    Image.asset(
                                      tripTime == 1
                                          ? AppImage.markedCircleIcon
                                          : AppImage.circleIcon,
                                      scale: 4,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          1 /
                                          100,
                                    ),
                                    Text(
                                      AppLanguage.fixesTimeText[language],
                                      style: const TextStyle(
                                          color: AppColor.primaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: AppFont.fontFamily),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            (tripTime == 1)
                                ? Container(
                                    height: MediaQuery.of(context).size.height *
                                        5 /
                                        100,
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: AppColor.textColor),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                55 /
                                                100,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                4 /
                                                100,
                                        child: TextFormField(
                                          style: const TextStyle(
                                            color: AppColor.primaryColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppFont.fontFamily,
                                          ),
                                          readOnly: true,
                                          controller: _timeController,
                                          onTap: () async {
                                            final TimeOfDay? pickedStart =
                                                await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            );

                                            if (pickedStart != null) {
                                              // 👇 Force minutes to 0 (disable minute precision)
                                              final fixedStart = pickedStart
                                                  .replacing(minute: 0);

                                              final String startFormatted =
                                                  fixedStart.format(context);

                                              setState(() {
                                                _timeController.text =
                                                    startFormatted;
                                                sendStartTime = startFormatted;
                                                selectedStartTime =
                                                    fixedStart; // Store the fixed time
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText:
                                                "${AppLanguage.selectTimeText[language]}*",
                                            hintStyle: const TextStyle(
                                              color: AppColor.primaryColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppFont.fontFamily,
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    right: 20),
                                            border: InputBorder.none,
                                            suffixIcon: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1 /
                                                    100,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1 /
                                                    100,
                                                child: Image.asset(
                                                  AppImage.calanderIcon,
                                                  height: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        5 /
                                        100,
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 3 / 100,
                      ),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Text(
                          AppLanguage.priceHoursText[language],
                          style: const TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontFamily: AppFont.fontFamily),
                        ),
                      ),

                      //! Text Field Slot Price
                      CustomTextFormFieldBlackWidth(
                        controller: slotPriceTextEditingController,
                        hintText: "${AppLanguage.slotPriceText[language]}*",
                        keyboardtype: TextInputType.number,
                        maxLength: 50,
                        fillColorStatus: 0,
                        readOnly: false,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                      ),

                      //! Text Field Minimum Hours
                      CustomTextFormFieldBlackWidth(
                        controller: minimumHoursTextEditingController,
                        hintText: "${AppLanguage.minimumHoursText[language]}*",
                        keyboardtype: TextInputType.number,
                        maxLength: 2,
                        fillColorStatus: 0,
                        readOnly: false,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                      ),

                      //! Text Field Idle Hours
                      CustomTextFormFieldBlackWidth(
                        controller: idleHoursTextEditingController,
                        hintText: "${AppLanguage.idleHoursText[language]}*",
                        keyboardtype: TextInputType.number,
                        maxLength: 2,
                        fillColorStatus: 0,
                        readOnly: false,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),

                      //!=== Trip date Text ===
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Text(
                          "${AppLanguage.tripDateText[language]} :",
                          style: const TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontFamily: AppFont.fontFamily),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),

                      //! All days Text and Image
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            tripDate = 0;
                          });
                        },
                        child: Container(
                          color: Colors.transparent,
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            children: [
                              Image.asset(
                                tripDate == 0
                                    ? AppImage.markedCircleIcon
                                    : AppImage.circleIcon,
                                scale: 4,
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 1 / 100,
                              ),
                              Text(
                                AppLanguage.alldaysText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: AppFont.fontFamily),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),

                      //! Choose dates Text and Image
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            tripDate = 1;
                            _selectedDateStrings.clear();
                          });
                          log("_selectedDateStrings$_selectedDateStrings");
                        },
                        child: Container(
                          color: Colors.transparent,
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            children: [
                              Image.asset(
                                tripDate == 1
                                    ? AppImage.markedCircleIcon
                                    : AppImage.circleIcon,
                                scale: 4,
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 1 / 100,
                              ),
                              Text(
                                AppLanguage.choosedatesText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: AppFont.fontFamily),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),

                      if (tripDate == 1)
                        Column(
                          children: [
                            TableCalendar(
                              focusedDay: _focusedDay,
                              firstDay: DateTime
                                  .now(), // <-- Disable past dates by setting firstDay to today
                              lastDay: DateTime.utc(2030, 12, 31),
                              availableGestures: AvailableGestures.none,
                              selectedDayPredicate: (day) {
                                final dateStr = _dateFormat.format(day);
                                return _selectedDateStrings.contains(dateStr);
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _focusedDay = focusedDay;
                                  final dateStr =
                                      _dateFormat.format(selectedDay);

                                  // Toggle logic
                                  if (_selectedDateStrings.contains(dateStr)) {
                                    _selectedDateStrings.remove(dateStr);
                                  } else {
                                    _selectedDateStrings.add(dateStr);
                                  }
                                });
                              },
                              headerStyle: const HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                leftChevronIcon: Icon(Icons.arrow_back),
                                rightChevronIcon: Icon(Icons.arrow_forward),
                              ),
                              calendarStyle: CalendarStyle(
                                selectedDecoration: const BoxDecoration(
                                  color: AppColor.themeColor,
                                  shape: BoxShape.circle,
                                ),
                                todayDecoration: BoxDecoration(
                                  color: AppColor.themeColor.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                defaultDecoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                outsideDecoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                weekendDecoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_selectedDateStrings.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                children: _selectedDateStrings.reversed
                                    .map((dateStr) {
                                  return Chip(
                                    label: Text(dateStr),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedDateStrings.remove(dateStr);
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                          ],
                        ),

                      //! Weekend(Friday-Saturday) Text and Image
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            tripDate = 2;
                          });
                        },
                        child: Container(
                          color: Colors.transparent,
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            children: [
                              Image.asset(
                                tripDate == 2
                                    ? AppImage.markedCircleIcon
                                    : AppImage.circleIcon,
                                scale: 4,
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 1 / 100,
                              ),
                              Text(
                                AppLanguage.weekendFridaySaturdayText[language],
                                style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: AppFont.fontFamily),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),

                      // //!=== Equipments Text ===

                      //add-ons list
                      Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 15,
                          runSpacing: 10,
                          children: List.generate(addOnList.length, (index) {
                            var addon = addOnList[index];
                            var addonId = addon['addon_id'];
                            var subcategories = addon['subcategories'];
                            var controllers = controllersMap[addonId]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  addon['addon_name'][language],
                                  style: const TextStyle(
                                    color: AppColor.primaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: AppFont.fontFamily,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  runSpacing: 10,
                                  children: List.generate(subcategories.length,
                                      (subIndex) {
                                    var sub = subcategories[subIndex];
                                    return Customfild(
                                      sub['sub_category_name'][language],
                                      controllers[subIndex],
                                      sub['addon_subcategory_id'],
                                    );
                                  }),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),

                      //!=== Customer Cancel days ===
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Text(
                          AppLanguage.customerCanceldaysText[language],
                          style: const TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontFamily: AppFont.fontFamily),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Row(
                          children: [
                            Text(
                              AppLanguage.freetocancelbeforeText[language],
                              style: const TextStyle(
                                  color: AppColor.primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: AppFont.fontFamily),
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 1 / 100,
                            ),
                            Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    14 /
                                    100,
                                height: MediaQuery.of(context).size.height *
                                    5 /
                                    100,
                                child: TextFormField(
                                  readOnly: false,
                                  style: const TextStyle(
                                      height: 1.1,
                                      color: AppColor.textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.number,
                                  controller:
                                      reetocancelbeforeTextEditingController,
                                  maxLength: 2,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColor.textColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColor.textColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(0)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColor.themeColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(0)),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 7),
                                      fillColor: AppColor.secondaryColor,
                                      filled: true,
                                      counterText: '',
                                      hintText: "",
                                      hintStyle: TextStyle(
                                          color: AppColor.textColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10)),
                                ),
                              ),
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 1 / 100,
                            ),
                            Text(
                              AppLanguage.daysText[language],
                              style: const TextStyle(
                                  color: AppColor.primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: AppFont.fontFamily),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 3 / 100,
                      ),

                      AppButton(
                          text: AppLanguage.submitButtonText[language],
                          onPress: () {
                            addOnsValidation(
                              slotPriceTextEditingController.text,
                              minimumHoursTextEditingController.text,
                              idleHoursTextEditingController.text,
                              reetocancelbeforeTextEditingController.text,
                            );
                          }),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 3 / 100,
                      ),
                    ],
                  ),
                )),
                const NoInternetBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget Customfild(
      String startingText, TextEditingController controller, int id) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 45 / 100,
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 15 / 100,
            child: Text(
              startingText,
              style: const TextStyle(
                color: AppColor.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: AppFont.fontFamily,
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 2 / 100),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 18 / 100,
              height: MediaQuery.of(context).size.height * 5 / 100,
              child: TextFormField(
                readOnly: !toCheckBox.contains(id),
                style: const TextStyle(
                    height: 1.1,
                    color: AppColor.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.number,
                controller: controller,
                onChanged: (value) {
                  fetchAllPrices();
                },
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
                    hintText: AppLanguage.priceText[language],
                    hintStyle: const TextStyle(
                        color: AppColor.textColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 10)),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // log("$controllersMap");
              setState(() {
                if (toCheckBox.contains(id)) {
                  toCheckBox.remove(id);
                  selectedAddOns.removeWhere((element) =>
                      element['addon_subcategory_id'].toString() ==
                      id.toString());
                  log("Final selectedAddOns: $selectedAddOns");
                } else {
                  toCheckBox.add(id);
                }
              });
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 3 / 100,
              width: MediaQuery.of(context).size.width * 9 / 100,
              child: toCheckBox.contains(id)
                  ? Image.asset(AppImage.tickOrangeIcon)
                  : Image.asset(AppImage.orangeBoxIcon),
            ),
          ),
        ],
      ),
    );
  }

  void fetchAllPrices() {
    for (var entry in controllersMap.entries) {
      final addonId = entry.key;
      final controllerList = entry.value;

      final addon = addOnList.firstWhere((e) => e['addon_id'] == addonId);
      final subcategories = addon['subcategories'];

      for (int i = 0; i < controllerList.length; i++) {
        final priceText = controllerList[i].text.trim();
        final subcategoryId = subcategories[i]['addon_subcategory_id'];

        // Check if entry already exists
        final existingIndex = selectedAddOns.indexWhere((element) =>
            element['addon_id'] == addonId.toString() &&
            element['addon_subcategory_id'] == subcategoryId.toString());

        final newEntry = {
          "addon_id": addonId.toString(),
          "addon_subcategory_id": subcategoryId.toString(),
          "price": priceText,
          "checked": "1",
          "checkStatus": "1",
        };

        if (existingIndex != -1) {
          selectedAddOns[existingIndex] = newEntry; // update existing
        } else {
          selectedAddOns.add(newEntry); // add new
        }

        // Optional debug print
        print(
            'Saved: Addon ID: $addonId | Subcategory ID: $subcategoryId | Price: $priceText');
      }
    }

    selectedAddOns.removeWhere((element) {
      final price = element['price']?.toString().trim();
      return price == null || price.isEmpty;
    });

    log("Final selectedAddOns: $selectedAddOns");
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
