import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controller/app_footer.dart';
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_header.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';
import '../../controller/app_loader.dart';
import '../../controller/app_snack_bar_toast_message.dart';
import '../other_screen/selectDate.dart';
import 'dart:ui' as ui;

class BookingDates extends StatefulWidget {
  static String routeName = './BookingDates';
  const BookingDates({super.key});

  @override
  State<BookingDates> createState() => _CalenderScreenScreenState();
}

class _CalenderScreenScreenState extends State<BookingDates> {
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
  }

  int status = 0;

  // @override
  // Widget build(BuildContext context) {
  //   return ProgressHUD(
  //       inAsyncCall: isApiCalling,
  //       opacity: 0.5,
  //       child: _buildUIScreen(context));
  // }

  Widget build(BuildContext context) {
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
                AppHeaderOrange(
                    text: AppLanguage.bookingDates[language],
                    onPress: () {
                      Navigator.pop(context);
                    }),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          //!========== View Booking Dates Button ==========

                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),

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
                                        border: Border.all(
                                            color: AppColor.themeColor),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical:
                                              screenWidth > 600 ? 15 : 8.0),
                                      child: Text(
                                        AppLanguage.seaText[language],
                                        style: TextStyle(
                                            fontSize:
                                                screenWidth > 600 ? 20 : 14,
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
                                    width: MediaQuery.of(context).size.width *
                                        42 /
                                        100,
                                    decoration: BoxDecoration(
                                        color: status == 2
                                            ? AppColor.themeColor
                                            : AppColor.secondaryColor,
                                        border: Border.all(
                                            color: AppColor.themeColor),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical:
                                              screenWidth > 600 ? 15 : 8.0),
                                      child: Text(
                                        AppLanguage.propertyText[language],
                                        style: TextStyle(
                                            fontSize:
                                                screenWidth > 600 ? 20 : 14,
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
                                    // getUnavailabilityApi(
                                    //     userId,
                                    //     DateFormat('yyyy-MM-dd')
                                    //         .format(selectedDay));
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
