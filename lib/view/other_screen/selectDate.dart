import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:the_boat_ownerside/controller/app_footer.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_loader.dart';
import '../../controller/app_snack_bar_toast_message.dart';
import '../authentication/login_screen.dart';
import '../../controller/app_font.dart';
import '../../controller/app_header.dart';
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

class SelectDateScreen extends StatefulWidget {
  static String routeName = './SelectDateScreen';
  const SelectDateScreen({super.key});

  @override
  State<SelectDateScreen> createState() => _SelectDateScreenState();
}

class _SelectDateScreenState extends State<SelectDateScreen> {
  TextEditingController timeTextEditingController = TextEditingController();
  DateTime today = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  String? startTimeFormatted;
  String? endTimeFormatted;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  String sendStartTime = "";
  String sendEndTime = "";
  int tripTime = 0;
  TextEditingController _timeController = TextEditingController();
  bool isApiCalling = true;
  List<dynamic> boatList = <dynamic>[];
  // List<int> selectedBoats = [];
  int selectedBoatId = 0;
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int userId = 0;
  int userType = 0;
  dynamic userDetails;
  Set<DateTime> dotDateSet = {};
  List<dynamic> dateList = <dynamic>[];

  String _formatTimeOfDayTo24(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes:00';
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

//--------------------GET USER DETAILS-----------------------//
  Future<dynamic> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    userDetails = prefs.getString("userDetails");

    // print("userDetails $userDetails");
    if (userDetails != null) {
      dynamic data = json.decode(userDetails);
      print("up $data");
      userId = data['user_id'];
      userType = data['user_type'];
    }
    getCalendarDatesApi(userId);
    getBoatsApi(userId, userType);
    setState(() {});
  }

  //=============================GET Boat DETAILS===================================//
  Future<void> getBoatsApi(userId, userType) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}get_boats_by_availability?user_id=$userId&user_type=$userType");
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
          var item = res['boat_array'];
          boatList = (item != "NA") ? item : [];

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

  validation() {
    if (selectedBoatId == 0) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.selectBoatMsg[language]);
      return;
    } else if (selectedDate.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.selectDateMsg[language]);
      return;
    } else if (tripTime == 1 &&
        (sendStartTime.isEmpty || sendEndTime.isEmpty)) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.selectStartEndMsg[language]);
      return;
    } else {
      addUnavailabilityApiCall();
    }
  }

  //------------------------add unavailability API CALL--------------------------------//
  addUnavailabilityApiCall() async {
    setState(() {
      isApiCalling = true;
    });

    Uri url = Uri.parse("${AppConfigProvider.apiUrl}add_unavailabilty");

    print("Url===> $url");

    try {
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.fields['user_id'] = userId.toString();
      formData.fields['date'] = selectedDate;
      formData.fields['boat_ids'] = selectedBoatId.toString();
      formData.fields['type'] = tripTime.toString();
      formData.fields['from_time'] = sendStartTime;
      formData.fields['to_time'] = sendEndTime;
      formData.fields['select_all'] = "0";
      // (boatList.length == selectedBoats.length) ? "0" : "0";

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
                indexOfPage: 3,
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

  //=============================GET Calendar Dates DETAILS===================================//
  Future<void> getCalendarDatesApi(userId) async {
    setState(() {
      isApiCalling = true;
    });
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}get_calender_date?user_id=$userId");
    print("url $url");

    String token = AppConstant.token;

    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token', // Use 'Bearer' if required
    };

    print("headers $headers");

    try {
      final response = await http.get(url, headers: headers);
      print("response $response");

      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);
        print("res $res");

        if (res['success'] == true) {
          var item = res['dateArray'];
          dateList = (item != "NA") ? item : [];
          dotDateSet = dateList
              .map((dateStr) => DateTime.parse(dateStr['date'].trim()))
              .toSet();
          log("markedDates$dotDateSet");
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

  int status = 1;
  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
        inAsyncCall: isApiCalling,
        opacity: 0.5,
        child: _buildUIScreen(context));
  }

  Widget _buildUIScreen(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final isAtCurrentMonth = DateTime(today.year, today.month) == currentMonth;

    double screenWidth = MediaQuery.of(context).size.width;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
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
                //!============== AppHeader ==============
                AppHeaderOrange(
                    text: AppLanguage.selectDateText[language],
                    onPress: () {
                      Navigator.pop(context);
                    }),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

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
                                  width: MediaQuery.of(context).size.width *
                                      42 /
                                      100,
                                  decoration: BoxDecoration(
                                      color: status == 1
                                          ? AppColor.themeColor
                                          : AppColor.secondaryColor,
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
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: ((context) => MyFooterPage(
                                  //               indexOfPage: 1,
                                  //             ))));
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width *
                                      42 /
                                      100,
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

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                           
                              Text(   status==1 ?
                               AppLanguage.selectBoatText[language]
                               :  AppLanguage.selectPropertyText[language],
                                style: const TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.primaryColor,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100,
                        ),

                        //!pickup list
                        Container(
                          alignment: Alignment.centerLeft,
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 15,
                            runSpacing: 10,
                            children: List.generate(boatList.length, (index) {
                              return (GestureDetector(
                                onTap: () {
                                  if (selectedBoatId ==
                                      boatList[index]["boat_id"]) {
                                    setState(() {
                                      selectedBoatId = 0;
                                    });
                                    log("$selectedBoatId");
                                  } else {
                                    setState(() {
                                      selectedBoatId =
                                          boatList[index]["boat_id"];
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                      color: selectedBoatId ==
                                              boatList[index]["boat_id"]
                                          ? AppColor.themeColor
                                          : AppColor.secondaryColor,
                                      border: Border.all(
                                          width: 1,
                                          color: selectedBoatId ==
                                                  boatList[index]["boat_id"]
                                              ? AppColor.themeColor
                                              : AppColor.boaderColor),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 12.0),
                                    child: Text(
                                      status==1 ?
                                      boatList[index]['boat_name_english'] ??
                                          "" :AppLanguage.PalmResortText[language],
                                      textAlign: TextAlign.center,
                                      style: TextStyle( 
                                          color: selectedBoatId ==
                                                  boatList[index]["boat_id"]
                                              ? AppColor.secondaryColor
                                              : AppColor.themeColor,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                              ));
                            }),
                          ),
                        ),

                        if (boatList.isEmpty && isApiCalling == false)
                          Column(
                            children: [
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      2 /
                                      100),
                              //!text msg
                              SizedBox(
                                width: screenWidth * 70 / 100,
                                child: Text(
                                  AppLanguage.boatNodataMsg[language],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.primaryColor),
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      2 /
                                      100),
                            ],
                          ),

                        //!===== Boader =================================
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: const Divider(
                            thickness: 1,
                            color: AppColor.boaderColor,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //!======= Custom Header ==========
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColor.lightblue,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left Arrow Button
                              GestureDetector(
                                onTap:
                                    isAtCurrentMonth ? null : _onLeftArrowTap,
                                child: Icon(
                                  Icons.arrow_back,
                                  color: isAtCurrentMonth
                                      ? Colors.grey
                                      : AppColor.themeColor,
                                  size: 30,
                                ),
                              ),
                              // Month & Year
                              Text(
                                DateFormat.yMMMM().format(today),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              // Right Arrow Button
                              GestureDetector(
                                onTap: _onRightArrowTap,
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: AppColor.themeColor,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),

                        //!============== Calendar ===============
                        TableCalendar(
                          focusedDay: today,
                          firstDay: DateTime(now.year, now.month, 1),
                          lastDay: DateTime.utc(2100, 12, 31),
                          headerVisible: false,
                          availableGestures: AvailableGestures.none,
                          enabledDayPredicate: (day) {
                            final today = DateTime.now();
                            return !day.isBefore(
                                DateTime(today.year, today.month, today.day));
                          },
                          calendarStyle: const CalendarStyle(
                            selectedDecoration: BoxDecoration(
                              color: AppColor.themeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          selectedDayPredicate: (day) => isSameDay(today, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              selectedDate =
                                  DateFormat('yyyy-MM-dd').format(selectedDay);
                              today = focusedDay;
                            });
                          },
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              bool isSelected = isSameDay(day, _selectedDay);
                              bool showDot = dotDateSet.any((markedDay) =>
                                  markedDay.year == day.year &&
                                  markedDay.month == day.month &&
                                  markedDay.day == day.day);

                              return _buildDayCell(day, isSelected, showDot);
                            },
                            selectedBuilder: (context, day, focusedDay) {
                              bool isSelected = isSameDay(day, _selectedDay);
                              bool showDot = dotDateSet.any((markedDay) =>
                                  markedDay.year == day.year &&
                                  markedDay.month == day.month &&
                                  markedDay.day == day.day);

                              return _buildDayCell(day, isSelected, showDot);
                            },
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),

                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, bottom: 30),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    //!=== Choose time Text ====
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          90 /
                                          100,
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              2 /
                                              100,
                                    ),

                                    //! Open Time Text and Image
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          90 /
                                          100,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                tripTime = 1;
                                                _timeController.clear();
                                                sendStartTime = "";
                                                sendEndTime = "";
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  alignment: Alignment.topLeft,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      4 /
                                                      100,
                                                  child: Image.asset(
                                                    tripTime == 1
                                                        ? AppImage
                                                            .markedCircleIcon
                                                        : AppImage.circleIcon,
                                                    scale: 4,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      1 /
                                                      100,
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      5 /
                                                      100,
                                                  child: Text(
                                                    AppLanguage
                                                        .timingText[language],
                                                    style: const TextStyle(
                                                        color: AppColor
                                                            .primaryColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            AppFont.fontFamily),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (tripTime == 1)
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  5 /
                                                  100,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: AppColor.textColor),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5),
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      55 /
                                                      100,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      4 /
                                                      100,
                                                  child: TextFormField(
                                                    style: const TextStyle(
                                                      color:
                                                          AppColor.primaryColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                    ),
                                                    readOnly: true,
                                                    controller:
                                                        _timeController, // <-- Your TextEditingController
                                                    onTap: () async {
                                                      // Pick start time
                                                      final TimeOfDay?
                                                          pickedStart =
                                                          await showTimePicker(
                                                        context: context,
                                                        initialTime:
                                                            TimeOfDay.now(),
                                                      );

                                                      if (pickedStart != null) {
                                                        // 👇 Force minutes to 0
                                                        final fixedStart =
                                                            pickedStart
                                                                .replacing(
                                                                    minute: 0);

                                                        // Pick end time
                                                        final TimeOfDay?
                                                            pickedEnd =
                                                            await showTimePicker(
                                                          context: context,
                                                          initialTime: fixedStart
                                                              .replacing(
                                                                  hour: fixedStart
                                                                          .hour +
                                                                      1),
                                                        );

                                                        if (pickedEnd != null) {
                                                          // 👇 Force minutes to 0
                                                          final fixedEnd =
                                                              pickedEnd
                                                                  .replacing(
                                                                      minute:
                                                                          0);

                                                          final startMinutes =
                                                              fixedStart.hour *
                                                                  60;
                                                          final endMinutes =
                                                              fixedEnd.hour *
                                                                  60;

                                                          log("endMinutes: $endMinutes");

                                                          if (endMinutes >=
                                                              startMinutes) {
                                                            final String
                                                                startFormatted =
                                                                fixedStart
                                                                    .format(
                                                                        context);
                                                            final String
                                                                endFormatted =
                                                                fixedEnd.format(
                                                                    context);

                                                            log("Formatted end time: $endFormatted");

                                                            final String
                                                                start24Hour =
                                                                _formatTimeOfDayTo24(
                                                                    fixedStart);
                                                            final String
                                                                end24Hour =
                                                                _formatTimeOfDayTo24(
                                                                    fixedEnd);

                                                            setState(() {
                                                              _timeController
                                                                      .text =
                                                                  "$startFormatted - $endFormatted";
                                                              sendStartTime =
                                                                  start24Hour;
                                                              sendEndTime =
                                                                  end24Hour;
                                                              selectedStartTime =
                                                                  fixedStart;
                                                              selectedEndTime =
                                                                  fixedEnd;
                                                              startTimeFormatted =
                                                                  start24Hour;
                                                              endTimeFormatted =
                                                                  end24Hour;
                                                            });
                                                          } else {
                                                            // Show a warning if end time is earlier
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
                                                          "Select Start to End Time",
                                                      hintStyle:
                                                          const TextStyle(
                                                        color: AppColor
                                                            .primaryColor,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                      ),
                                                      enabledBorder:
                                                          const OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                      focusedBorder:
                                                          const OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets.only(
                                                              right: 20),
                                                      border: InputBorder.none,
                                                      suffixIcon: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              1 /
                                                              100,
                                                          width: MediaQuery.of(
                                                                      context)
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
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1 /
                                              100,
                                    ),

                                    //! Fixed Time Text and Image
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          90 /
                                          100,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                tripTime = 0;
                                                _timeController.clear();
                                                sendStartTime = "";
                                              });
                                            },
                                            child: Container(
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    tripTime == 0
                                                        ? AppImage
                                                            .markedCircleIcon
                                                        : AppImage.circleIcon,
                                                    scale: 4,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            1 /
                                                            100,
                                                  ),
                                                  Text(
                                                    AppLanguage
                                                        .fullDay[language],
                                                    style: const TextStyle(
                                                        color: AppColor
                                                            .primaryColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            AppFont.fontFamily),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                5 /
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
                                    ),

                                    //!========== Add Unavailability Button ==========
                                    SizedBox(
                                      width: screenWidth * 0.9,
                                      height: screenWidth > 600
                                          ? MediaQuery.of(context).size.height *
                                              0.065
                                          : null,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          validation();
                                        },
                                        icon: Image.asset(AppImage.addIcon,
                                            scale: 4),
                                        label: Text(
                                          AppLanguage
                                              .addAvailabilityText[language],
                                          style: const TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColor.secondaryColor,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColor.themeColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const NoInternetBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showTimerBhottomSheet() {
    showModalBottomSheet(
      backgroundColor: AppColor.secondaryColor,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 30),
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 43 / 100,
                    height: MediaQuery.of(context).size.height * 8 / 100,
                    child: TextFormField(
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (pickedTime != null) {
                          final String formattedTime =
                              pickedTime.format(context);
                          setState(() {
                            timeTextEditingController.text = formattedTime;
                          });
                          // print(formattedDate);
                        }
                      },
                      style: const TextStyle(
                          color: AppColor.primaryColor,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                      textAlignVertical: TextAlignVertical.center,
                      controller: timeTextEditingController,
                      readOnly: true,
                      decoration: InputDecoration(
                        suffixIcon: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: Image.asset(
                                AppImage.dropDownIcon,
                                height:
                                    MediaQuery.of(context).size.width * 4 / 100,
                                width:
                                    MediaQuery.of(context).size.width * 4 / 100,
                              ),
                            ),
                          ],
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColor.boaderColor),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColor.boaderColor),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColor.themeColor),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        hintText: AppLanguage.timeText[language],
                        hintStyle: AppConstant.textFilledStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _onLeftArrowTap() {
    final previousMonth = DateTime(today.year, today.month - 1);
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    if (!previousMonth.isBefore(currentMonth)) {
      setState(() {
        today = previousMonth;
      });
    }
  }

  void _onRightArrowTap() {
    setState(() {
      today = DateTime(today.year, today.month + 1);
    });
  }

  Widget _buildDayCell(DateTime day, bool isSelected, bool showDot) {
    return Container(
      margin: const EdgeInsets.all(6),
      width: 50,
      height: 50,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColor.themeColor : AppColor.secondaryColor,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  spreadRadius: 1,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Text(
              day.day.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? AppColor.secondaryColor
                    : AppColor.primaryColor,
              ),
            ),
          ),
          if (showDot)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
