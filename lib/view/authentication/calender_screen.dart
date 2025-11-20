import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:the_boat_ownerside/view/other_screen/booking_dates.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_footer.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_loader.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../other_screen/selectDate.dart';
import 'dart:ui' as ui;
import 'login_screen.dart';

class CalenderScreen extends StatefulWidget {
  static String routeName = './CalenderScreen';
  const CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenScreenState();
}

class _CalenderScreenScreenState extends State<CalenderScreen> {
  DateTime today = DateTime.now();
  bool isApiCalling = true;
  List<dynamic> dateList = <dynamic>[];
  List<dynamic> unavailabilityList = <dynamic>[];
  Set<DateTime> markedDates = {};
  List<String> unavailableDates = [];
  int userId = 0;
  dynamic userDetails;
  dynamic permissions = {};
  int viewUnavailability = 0;
  int manageUnavailability = 0;
  int userType = 0;

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
      userType = data['user_type'] ?? 0;
    }
    getAllDatesApi(userId);
    setState(() {});
  }

  //=============================GET Boat DETAILS===================================//
  Future<void> getAllDatesApi(userId) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}get_unavailabilty_date?user_id=$userId");
    print("url $url");

    String token = AppConstant.token;

    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token', // Use 'Bearer' if required
    };

    // setState(() {
    //   isApiCalling = true;
    // });

    print("headers $headers");

    try {
      final response = await http.get(url, headers: headers);
      print("response $response");

      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);
        print("res $res");

        if (res['success'] == true) {
          var item = res['unavailability_arr'];
          dateList = (item != "NA") ? item : [];
          unavailableDates =
              dateList.map((date) => date['date'].toString().trim()).toList();
          markedDates = dateList
              .map((dateStr) => DateTime.parse(dateStr['date'].trim()))
              .toSet();
          log("markedDates$markedDates");
          log("unavailableDates$unavailableDates");
          profileApiCall(userId);
          // fetchDates();
          // setState(() {
          //   isApiCalling = false;
          // });
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

  //------------------------View Profile API CALL--------------------------------//
  Future<void> profileApiCall(userId) async {
    Uri url =
        Uri.parse("${AppConfigProvider.apiUrl}view_profile?user_id=$userId");
    print("url $url");

    String token = AppConstant.token;

    if (token.isEmpty) {
      print("Token is missing!");
      // return;
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
          var item = res['user_arr'];
          permissions = (item != "NA") ? item : {};

          viewUnavailability = permissions['view_unavailability'] ?? 0;
          manageUnavailability = permissions['manage_unavailability'] ?? 0;

          log("userType291$userType");
          if (userType == 3 ||
              (userType == 2 && manageUnavailability == 1) ||
              (userType == 2 && viewUnavailability == 1)) {
            if (unavailableDates
                .contains(DateFormat('yyyy-MM-dd').format(DateTime.now()))) {
              getUnavailabilityApi(
                  userId, DateFormat('yyyy-MM-dd').format(DateTime.now()));
            } else {
              setState(() {
                isApiCalling = false;
              });
            }
          } else {
            setState(() {
              isApiCalling = false;
            });
          }
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

  //=============================GET Unavailability DETAILS===================================//
  Future<void> getUnavailabilityApi(userId, date) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}get_unavailabilty_by_date?user_id=$userId&date=$date");
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
          var item = res['unavailability_arr'];
          unavailabilityList = (item != "NA") ? item : [];
          setState(() {
            isApiCalling = false;
          });
        } else {
          if (res['active_status'] == 0) {
            localstorageclearbutton();
            SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => const Login()),
            // );
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

  //-----------------Sign Out-----------------------
  localstorageclearbutton() async {
    final prefs = await SharedPreferences.getInstance();
    print("prefs =================>$prefs");
    prefs.remove('userDetails');
    prefs.remove('password');

    log("Worked");

    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  //------------------------Delete unavailability API CALL--------------------------------//
  deleteUnavailabilityApiCall(date, boatType, unavailabilityId) async {
    setState(() {
      isApiCalling = true;
    });

    Uri url = Uri.parse("${AppConfigProvider.apiUrl}delete_unavailabilty");

    print("Url===> $url");

    try {
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.fields['user_id'] = userId.toString();
      formData.fields['date'] = date;
      formData.fields['boat_type'] = boatType.toString();
      formData.fields['unavailability_id'] = unavailabilityId.toString();

      log("response--==> ${formData.fields}");
      // print("response--==> ${formData.files}");
      http.StreamedResponse response = await formData.send();
      print("response--==> $response");
      var responseString = await response.stream.toBytes();
      var res = jsonDecode(utf8.decode(responseString));

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          getAllDatesApi(userId);
          getUnavailabilityApi(userId, date);
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
      statusBarIconBrightness: Brightness.light,
    ));

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) => const MyFooterPage(indexOfPage: 0)),
          ),
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColor.secondaryColor,
        body: Directionality(
          textDirection:
              language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                // Header with Background Image
                Container(
                  width: screenWidth,
                  height: MediaQuery.of(context).size.height * 0.20,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImage.headerBgImage),
                      fit: BoxFit.cover,
                    ),
                    color: AppColor.themeColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.07),
                      Container(
                        width: screenWidth * 0.9,
                        alignment: Alignment.center,
                        child: Text(
                          AppLanguage.manageUnavailabilityText[language],
                          style: const TextStyle(
                            color: AppColor.secondaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFont.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),

                //!========= Calendar Body =================
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          //!========== View Booking Dates Button ==========
                          SizedBox(
                            width: screenWidth * 0.9,
                            height: screenWidth > 600
                                ? MediaQuery.of(context).size.height * 0.065
                                : null,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BookingDatesScreen(),
                                  ),
                                );
                              },
                              icon: Image.asset(
                                AppImage.calenderActiveIcon,
                                scale: 4,
                                color: AppColor.secondaryColor,
                              ),
                              label: Text(
                                AppLanguage.viewBookingDatesText[language],
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
                                  MediaQuery.of(context).size.height * 0.02),

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
                              height:
                                  MediaQuery.of(context).size.height * 0.02),

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
                            selectedDayPredicate: (day) =>
                                isSameDay(today, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                today = focusedDay;
                                log("userType$userType");
                                if (userType == 3 ||
                                    (userType == 2 &&
                                        viewUnavailability == 1)) {
                                  if (unavailableDates.contains(
                                      DateFormat('yyyy-MM-dd')
                                          .format(selectedDay))) {
                                    getUnavailabilityApi(
                                        userId,
                                        DateFormat('yyyy-MM-dd')
                                            .format(selectedDay));
                                  } else {
                                    unavailabilityList.clear();
                                  }
                                }

                                log(DateFormat('yyyy-MM-dd')
                                    .format(selectedDay));
                              });
                            },
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                bool shouldHighlight = false;

                                // Case 1: Use markedDates
                                shouldHighlight = markedDates.any((markedDay) =>
                                    markedDay.year == day.year &&
                                    markedDay.month == day.month &&
                                    markedDay.day == day.day);

                                if (shouldHighlight) {
                                  return Container(
                                    margin: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 253, 170, 114),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 2,
                                          spreadRadius: 1,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${day.day}',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }

                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),

                          //!========== Add Unavailability Button ==========
                          SizedBox(
                            width: screenWidth * 0.9,
                            height: screenWidth > 600
                                ? MediaQuery.of(context).size.height * 0.065
                                : null,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (userType == 3 ||
                                    (userType == 2 &&
                                        manageUnavailability == 1)) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SelectDateScreen(),
                                    ),
                                  );
                                }
                              },
                              icon: Image.asset(AppImage.addIcon, scale: 4),
                              label: Text(
                                AppLanguage.addUnavailabilityText[language],
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
                                  MediaQuery.of(context).size.height * 0.02),

                          //!========== Selected Date Display ==========
                          if (unavailabilityList.isNotEmpty)
                            Wrap(
                              children: List.generate(
                                unavailabilityList.length,
                                (index) {
                                  return Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            // Calendar Icon and Date
                                            SizedBox(
                                              width: screenWidth * 0.4,
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                      AppImage.calanderIcon,
                                                      scale: 3),
                                                  SizedBox(
                                                      width:
                                                          screenWidth * 0.015),
                                                  Column(
                                                    children: [
                                                      SizedBox(
                                                        width: screenWidth *
                                                            32 /
                                                            100,
                                                        child: Text(
                                                          DateFormat(
                                                                  "dd-MM-yyyy")
                                                              .format(DateTime.parse(
                                                                  unavailabilityList[
                                                                          index]
                                                                      [
                                                                      'date'])),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontFamily: AppFont
                                                                .fontFamily,
                                                            color: AppColor
                                                                .primaryColor,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: screenWidth *
                                                            32 /
                                                            100,
                                                        child: Text(
                                                          unavailabilityList[
                                                                  index]
                                                              ['specific_time'],
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: const TextStyle(
                                                              fontFamily: AppFont
                                                                  .fontFamily,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColor
                                                                  .primaryColor),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // All Boats + Delete
                                            SizedBox(
                                              width: screenWidth * 0.43,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: screenWidth * 0.35,
                                                    child: Text(
                                                      unavailabilityList[index]
                                                          ['boat_type_label'],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        color: AppColor
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (userType == 3 ||
                                                          (userType == 2 &&
                                                              manageUnavailability ==
                                                                  1)) {
                                                        deleteUnavailabilityApiCall(
                                                            unavailabilityList[
                                                                        index]
                                                                    ['date']
                                                                .toString(),
                                                            unavailabilityList[
                                                                        index][
                                                                    'boat_type']
                                                                .toString(),
                                                            unavailabilityList[
                                                                        index][
                                                                    'navailability_id']
                                                                .toString());
                                                      }
                                                    },
                                                    child: Image.asset(
                                                        AppImage.deleteIcon,
                                                        scale: 3),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                2 /
                                                100,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
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
      ),
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
}
