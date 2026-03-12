import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:the_boat_ownerside/view/propertymodule/upcoming_detail_screen.dart';

import '../../controller/app_button.dart';
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_header.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';
import 'view_property_details_screen.dart';

class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.02),
            CustomAppHeader(
              text: AppLanguage.detailsText[language],
              suffixText: "ID: #4567687687",
              onPress: () {
                Navigator.pop(context);
              },
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // child: Image.asset(
              //   AppImage.propertyImage,
              //   height: size.height * 0.18,
              //   width: double.infinity,
              //   fit: BoxFit.cover,
              // ),
            ),

            SizedBox(height: size.height * 0.02),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => TripStartDetailsScreen())));
              },
              child: Container(
                width: size.width * 100 / 100,
                height: size.height * 15 / 100,
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  color: AppColor.lightColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Ongoing
                          Row(
                            children: [
                              Text(
                                AppLanguage.ongoingText[language],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.pendingColor,
                                ),
                              ),
                              SizedBox(width: size.width * 0.04),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context,
                                  MaterialPageRoute(builder: (context)=> ViewPropertyDetailsScreen()));
                                },
                                child: Text(
                                  AppLanguage.viewDetailsText[language],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColor.blueColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.blueColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: size.height * 0.01),

                          // Title
                          Text(
                            AppLanguage.greenleafInnText[language],
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),

                          SizedBox(height: size.height * 0.005),

                          // Location
                          Text(
                            AppLanguage.propertyLocationText[language],
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        AppImage.house1Icon,
                        width: size.width * 0.22,
                        height: size.width * 0.20,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.025),

            Text(
              AppLanguage.customerDetailsText[language],
              style: TextStyle(
                fontSize: 14,
                fontFamily: AppFont.fontFamily,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            SizedBox(height: size.height * 0.008),

            Text(
              AppLanguage.customerNameText[language],
              style: const TextStyle(
                fontSize: 16,
                fontFamily: AppFont.fontFamily,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),

            SizedBox(height: size.height * 0.025),

            //  Booking Details Heading
            Text(
              AppLanguage.bookingDetailsText[language],
              style: const TextStyle(
                fontSize: 14,
                fontFamily: AppFont.fontFamily,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            SizedBox(height: size.height * 0.015),

            //  Booking Date
            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                  color: Colors.grey.shade700,
                ),
                SizedBox(width: size.width * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Jan 06,2025",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      AppLanguage.bookingDates[language],
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),

            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                  color: Colors.grey.shade700,
                ),
                SizedBox(width: size.width * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "1 Day",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      AppLanguage.bookingTimeText[language],
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: size.height * 0.02),

            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 20,
                  color: Colors.grey.shade700,
                ),
                SizedBox(width: size.width * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLanguage.guestCountText[language],
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      AppLanguage.guestsText[language],
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: size.height * 0.03),

            Text(
              AppLanguage.descriptionText[language],
              style: const TextStyle(
                fontSize: 21,
                fontFamily: AppFont.fontFamily,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            SizedBox(height: size.height * 0.01),

            Text(
              AppLanguage.blueNaturedescriptionText[language],
              style: TextStyle(
                fontSize: 16,
                fontFamily: AppFont.fontFamily,
                fontWeight: FontWeight.w400,
                color: AppColor.grey5959Color,
                height: 1.5,
              ),
            ),

            SizedBox(height: size.height * 0.03 ),

            Text(
              AppLanguage.whatThisPlaceOffersText[language],
              style: const TextStyle(
                fontSize: 21,
                fontFamily: AppFont.fontFamily,
                fontWeight: FontWeight.w500,
                color: AppColor.black2A2AColor,
              ),
            ),

            SizedBox(height: size.height * 0.015),
            GridView.count(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 5,
              mainAxisSpacing: size.height * 0.005,
              crossAxisSpacing: size.width * 0.04,
              children: [
                FeatureItem(
                  title: AppLanguage.tvText[language],
                  icon: AppImage.tv,
                ),
                FeatureItem(
                  title: AppLanguage.beddingText[language],
                  icon: AppImage.bedding,
                ),
                FeatureItem(
                  title: AppLanguage.wifiText[language],
                  icon: AppImage.wifi,
                ),
                FeatureItem(
                  title: AppLanguage.microwaveText[language],
                  icon: AppImage.microwave,
                ),
                FeatureItem(
                  title: AppLanguage.acText[language],
                  icon: AppImage.acIcon,
                ),
                FeatureItem(
                  title: AppLanguage.kettleText[language],
                  icon: AppImage.kettle,
                ),
                FeatureItem(
                  title: AppLanguage.fridgeText[language],
                  icon: AppImage.fridge,
                ),
                FeatureItem(
                  title: AppLanguage.coffeeMachineText[language],
                  icon: AppImage.coffeeMachine,
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),
            Row(
              children: [
                Image.asset(
                  AppImage.cancellationPolicyIcon,
                  width: size.width * 0.06,
                  // height: size.width * 0.06,
                ),
                SizedBox(width: size.width * 0.02),
                Text(
                  AppLanguage.cancellationPolicyText[language],
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: AppFont.fontFamily,
                    fontWeight: FontWeight.w500,
                    color: AppColor.themeColor,
                  ),
                ),
              ],
            ),

            SizedBox(height: size.height * 0.025),

            Container(
              width: size.width * 100 / 100,
              height: size.height * 21 / 100,
              padding: EdgeInsets.all(size.width * 0.04),
              decoration: BoxDecoration(
                color: AppColor.lightorangeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLanguage.billingDetailsText[language],
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  _billRow("1 Day", "200 KWD"),
                  SizedBox(height: size.height * 0.03),
                  Divider(
                    height: size.height * 0.01,
                    color: AppColor.divider1Color,
                  ),
                  _billRow("Grand Total", "200 KWD", isBold: true),
                  Divider(
                    height: size.height * 0.02,
                    color: AppColor.divider1Color,
                  ),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.05),

            AppButton(text: AppLanguage.chatText[language], onPress: () {}),
            SizedBox(height: size.height * 0.08),
          ],
        ),
      ),
    );
  }

  Widget _billRow(String left, String right, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          left,
          style: TextStyle(
            fontSize: 16,
            fontFamily: AppFont.fontFamily,
            fontWeight: isBold ? FontWeight.w500 : FontWeight.w400,
            color: Colors.black,
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontSize: 16,
            fontFamily: AppFont.fontFamily,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class FeatureItem extends StatelessWidget {
  final String title;
  final String icon;
  final Color? iconColor;
  final Color? textColor;

  const FeatureItem({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      children: [
        Image.asset(
          icon,
          height: size.width * 0.035,
          color: iconColor ?? Colors.grey.shade700,
        ),
        SizedBox(width: size.width * 0.02),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppFont.fontFamily,
              fontWeight: FontWeight.w500,
              color: textColor ?? Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}
