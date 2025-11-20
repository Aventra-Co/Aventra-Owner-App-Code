import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:the_boat_ownerside/utilities/app_constant.dart';
import 'package:the_boat_ownerside/utilities/app_language.dart';
import 'package:the_boat_ownerside/view/other_screen/upcoming_details.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_loader.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../authentication/login_screen.dart';

class BookingDatesScreen extends StatefulWidget {
  static String routeName = './BookingDatesScreen';
  const BookingDatesScreen({super.key});
  @override
  State<BookingDatesScreen> createState() => BookingDatesScreenState();
}

class BookingDatesScreenState extends State<BookingDatesScreen> {
  DateTime today = DateTime.now();
  Set<DateTime> markedDates = {};
  List<dynamic> unavailabilityList = <dynamic>[];
  List<dynamic> dateList = <dynamic>[];
  int userId = 0;
  bool isApiCalling = false;
  dynamic userDetails;
  List<String> unavailableDates = [];

  @override
  void initState() {
    super.initState();
    getDetails();
  }

//-----------------------------Cancel Booking---------------------------//
  Future<dynamic> getDetails() async {
    final prefs = await SharedPreferences.getInstance();
    userDetails = prefs.getString("userDetails");

    print("userDetails $userDetails");
    if (userDetails != null) {
      dynamic data = json.decode(userDetails);
      print("up $data");
      userId = data['user_id']; //Retrieve userId from local storage
      print('userId- $userId');
      getCalendarDatesApi(userId);
      setState(() {});
    }
  }

  //-----------------------------------REASON VALIDATION---------------------------//
  reasonValidation(String reason) {
    if (reason.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.reasonMsg[language]);
      return false;
    } else {}
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
          unavailableDates =
              dateList.map((date) => date['date'].toString().trim()).toList();
          markedDates = dateList
              .map((dateStr) => DateTime.parse(dateStr['date'].trim()))
              .toSet();
          getSelectedTripsApi(
              userId, DateFormat('yyyy-MM-dd').format(DateTime.now()));
          log("markedDates$markedDates");
          log("unavailableDates$unavailableDates");
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

  //=============================GET Calendar Dates DETAILS===================================//
  Future<void> getSelectedTripsApi(userId, date) async {
    setState(() {
      isApiCalling = true;
    });
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}get_selected_trips?user_id=$userId&date=$date");
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
          var item = res['tripArray'];
          unavailabilityList = (item != "NA") ? item : [];
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
    double screenWidth = MediaQuery.of(context).size.width;
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final isAtCurrentMonth = DateTime(today.year, today.month) == currentMonth;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.secondaryColor,
        body: Container(
          height: MediaQuery.of(context).size.height * 100 / 100,
          width: MediaQuery.of(context).size.width * 100 / 100,
          color: AppColor.secondaryColor,
          child: Column(
            children: [
              AppHeaderOrange(
                  text: AppLanguage.bookingDates[language],
                  onPress: () {
                    Navigator.pop(context);
                  }),
              SizedBox(
                height: MediaQuery.of(context).size.height * 2 / 100,
              ),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04),

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
                              today = focusedDay;
                              log(DateFormat('yyyy-MM-dd').format(selectedDay));
                            });
                            if (unavailableDates.contains(
                                DateFormat('yyyy-MM-dd').format(selectedDay))) {
                              getSelectedTripsApi(userId,
                                  DateFormat('yyyy-MM-dd').format(selectedDay));
                            } else {
                              unavailabilityList.clear();
                            }
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
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }

                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),

                        //!========== Selected Date Display ==========
                        if (unavailabilityList.isNotEmpty)
                          Wrap(
                            children: List.generate(
                              unavailabilityList.length,
                              (index) {
                                return Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UpcomingDetailsScreen(
                                              tripId: unavailabilityList[index]
                                                      ['trip_booking_id']
                                                  .toString(),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
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
                                            Container(
                                              // color: Colors.green,
                                              width: screenWidth * 0.35,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            5 /
                                                            100,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            5 /
                                                            100,
                                                    child: Image.asset(
                                                      AppImage.clockIconOrange,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          screenWidth * 0.015),
                                                  Text(
                                                    unavailabilityList[index]
                                                            ['booking_time'] ??
                                                        "",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      color:
                                                          AppColor.primaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Spacer(),
                                            // All Boats + Delete
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  44 /
                                                  100,
                                              alignment: Alignment.centerRight,
                                              // color: Colors.red,
                                              child: Text(
                                                unavailabilityList[index]
                                                        ['boat_name_english'] ??
                                                    "",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  color: AppColor.primaryColor,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  4 /
                                                  100,
                                            ),
                                          ],
                                        ),
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
            ],
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
