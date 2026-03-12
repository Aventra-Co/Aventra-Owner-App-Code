import 'package:flutter/material.dart';
import '/view/authentication/calender_screen.dart';
import '/view/authentication/inbox_screen.dart';
import '/view/authentication/my_ads_screen.dart';
import '/view/authentication/profile_screen.dart';
import '/view/authentication/trips_screen.dart';
import 'app_color.dart';
import 'app_constant.dart';
import 'app_font.dart';
import 'app_image.dart';
import 'app_language.dart';
import 'dart:ui' as ui;

class MyFooterPage extends StatefulWidget {
  const MyFooterPage({required this.indexOfPage, super.key});
  final int indexOfPage;

  @override
  State<MyFooterPage> createState() => _MyFooterPageState();
}

class _MyFooterPageState extends State<MyFooterPage> {
  int _selectedIndex = 0;
  PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();

    // _pageController = PageController(initialPage: AppConstant.selectFooterIndex);
    _pageController = PageController(initialPage: widget.indexOfPage);
    setState(() {
      _selectedIndex = widget.indexOfPage;
      // _selectedIndex = AppConstant.selectFooterIndex;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const <Widget>[
          TripsScreen(),
          MyAdsScreen(),
          InboxScreen(),
          CalenderScreen(),
          ProfileScreen()
        ],
      ),
      bottomNavigationBar: Directionality(
        textDirection:
            language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: BottomNavigationBar(
          backgroundColor: AppColor.secondaryColor,
          items: <BottomNavigationBarItem>[
            //trips
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 1 / 100,
                  ),
                  Container(
                    height: screenWidth > 600
                        ? MediaQuery.of(context).size.width * 5 / 100
                        : MediaQuery.of(context).size.width * 7 / 100,
                    width: screenWidth > 600
                        ? MediaQuery.of(context).size.width * 5 / 100
                        : MediaQuery.of(context).size.width * 7 / 100,
                    //  color: Colors.amber,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(_selectedIndex == 0
                                ? AppImage.tripsActiveIcon
                                : AppImage.tripsDeactiveIcon))),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5 / 100,
                  ),
                  Text(
                    AppLanguage.tripText[language],
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: screenWidth > 600 ? 16 : 11,
                      fontWeight: FontWeight.w500,
                      color: _selectedIndex == 0
                          ? AppColor.themeColor
                          : AppColor.textColor,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 2 / 100,
                  ),
                ],
              ),
              label: "",
              backgroundColor: AppColor.secondaryColor,
            ),

            //my ads
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 1 / 100,
                  ),
                  Container(
                    height: screenWidth > 600
                        ? MediaQuery.of(context).size.width * 5 / 100
                        : MediaQuery.of(context).size.width * 7 / 100,
                    width: screenWidth > 600
                        ? MediaQuery.of(context).size.width * 5 / 100
                        : MediaQuery.of(context).size.width * 7 / 100,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(_selectedIndex == 1
                                ? AppImage.myAdsActiveIcon
                                : AppImage.myAdsDeactiveIcon))),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5 / 100,
                  ),
                  Text(
                    AppLanguage.myAdsText[language],
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: screenWidth > 600 ? 16 : 11,
                      fontWeight: FontWeight.w500,
                      color: _selectedIndex == 1
                          ? AppColor.themeColor
                          : AppColor.textColor,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 2 / 100,
                  ),
                ],
              ),
              label: "",
              backgroundColor: AppColor.secondaryColor,
            ),

            //inbox
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 1 / 100,
                  ),
                  Container(
                    height: screenWidth > 600
                        ? MediaQuery.of(context).size.width * 5 / 100
                        : MediaQuery.of(context).size.width * 7 / 100,
                    width: screenWidth > 600
                        ? MediaQuery.of(context).size.width * 5 / 100
                        : MediaQuery.of(context).size.width * 7 / 100,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(_selectedIndex == 2
                                ? AppImage.inboxActiveIcon
                                : AppImage.inboxDeactiveIcon))),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5 / 100,
                  ),
                  Text(
                    AppLanguage.inboxText[language],
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: screenWidth > 600 ? 16 : 11,
                      fontWeight: FontWeight.w500,
                      color: _selectedIndex == 2
                          ? AppColor.themeColor
                          : AppColor.textColor,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 2 / 100,
                  ),
                ],
              ),
              label: "",
              backgroundColor: AppColor.secondaryColor,
            ),

            //calender
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 1 / 100,
                  ),
                  Container(
                    height: screenWidth > 600
                        ? MediaQuery.of(context).size.width * 5 / 100
                        : MediaQuery.of(context).size.width * 7 / 100,
                    width: screenWidth > 600
                        ? MediaQuery.of(context).size.width * 5 / 100
                        : MediaQuery.of(context).size.width * 7 / 100,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(_selectedIndex == 3
                                ? AppImage.calenderActiveIcon
                                : AppImage.calenderDeactiveIcon))),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5 / 100,
                  ),
                  Text(
                    AppLanguage.calenderText[language],
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: screenWidth > 600 ? 16 : 11,
                      fontWeight: FontWeight.w500,
                      color: _selectedIndex == 3
                          ? AppColor.themeColor
                          : AppColor.textColor,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 2 / 100,
                  ),
                ],
              ),
              label: "",
              backgroundColor: AppColor.secondaryColor,
            ),

            //profile
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 1 / 100,
                  ),
                  Container(
                    height: screenWidth > 600
                        ? MediaQuery.of(context).size.width * 5 / 100
                        : MediaQuery.of(context).size.width * 7 / 100,
                    width: screenWidth > 600
                        ? MediaQuery.of(context).size.width * 5 / 100
                        : MediaQuery.of(context).size.width * 7 / 100,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(_selectedIndex == 4
                                ? AppImage.profileActiveIcon
                                : AppImage.profileDeactiveIcon))),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5 / 100,
                  ),
                  Text(
                    AppLanguage.profileText[language],
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: screenWidth > 600 ? 16 : 11,
                      fontWeight: FontWeight.w500,
                      color: _selectedIndex == 4
                          ? AppColor.themeColor
                          : AppColor.textColor,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 2 / 100,
                  ),
                ],
              ),
              label: "",
              backgroundColor: AppColor.secondaryColor,
            ),
          ],
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          iconSize: 25,
          onTap: _onItemTapped,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          elevation: 5,
        ),
      ),
    );
  }
}
