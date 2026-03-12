import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:the_boat_ownerside/view/other_screen/cancel_booking.dart';

import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_header.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';
import '../other_screen/cancel_booking_screen.dart';
import 'manage_property_screen.dart';
import 'view_property_details_screen.dart';

class TripStartDetailsScreen extends StatelessWidget {
  const TripStartDetailsScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColor.secondaryColor,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.02),

                  CustomAppHeader(
                    text: AppLanguage.detailsText[language],
                    suffixText: "ID: #4567687687",
                    onPress: () => Navigator.pop(context),
                  ),

                  SizedBox(height: size.height * 0.02),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(size.width * 0.04),
                    decoration: BoxDecoration(
                      color: AppColor.themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    AppLanguage.upcomingText[language],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.themeColor,
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.04),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewPropertyDetailsScreen()));
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
                              Text(
                                AppLanguage.propertyLocationText[language],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.black1313Color,
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

                  SizedBox(height: size.height * 0.03),

                  /// Customer
                  Text(
                    AppLanguage.customerDetailsText[language],
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: size.height * 0.01),

                  Text(
                    AppLanguage.customerNameText[language],
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 20,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Jan 06,2025",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  AppLanguage.bookingDateText[language],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),

                            // SizedBox(width: size.width * 0.02),

                            Text(
                              AppLanguage.changeText[language],
                              style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColor.black,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
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
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "1 Day" ,
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
                            Text(
                              AppLanguage.changeText[language],
                              style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColor.black,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
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
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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

                  SizedBox(height: size.height * 0.03),
                  Text(
                    AppLanguage.whatThisPlaceOffersText[language],
                    style: const TextStyle(
                      fontSize: 21,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w500,
                      color: AppColor.black2A2AColor,
                    ),
                  ),

                  /// Features
                  GridView.count(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 5,
                    mainAxisSpacing: size.height * 0.012,
                    crossAxisSpacing: size.width * 0.04,
                    children: [
                      FeatureItem(
                        title: AppLanguage.tvText[language],
                        icon: Icons.tv,
                      ),
                      FeatureItem(
                        title: AppLanguage.beddingText[language],
                        icon: Icons.bed,
                      ),
                      FeatureItem(
                        title: AppLanguage.wifiText[language],
                        icon: Icons.wifi,
                      ),
                      FeatureItem(
                        title: AppLanguage.microwaveText[language],
                        icon: Icons.microwave,
                      ),
                      FeatureItem(
                        title: AppLanguage.acText[language],
                        icon: Icons.ac_unit,
                      ),
                      FeatureItem(
                        title: AppLanguage.kettleText[language],
                        icon: Icons.emoji_food_beverage,
                      ),
                      FeatureItem(
                        title: AppLanguage.fridgeText[language],
                        icon: Icons.kitchen,
                      ),
                      FeatureItem(
                        title: AppLanguage.coffeeMachineText[language],
                        icon: Icons.coffee,
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.02),
                  GestureDetector(
                    onTap: (){
                      _showCancellationPolicyDialog(context);
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          AppImage.cancellationPolicyIcon,
                          width: size.width * 0.06,
                          height: size.width * 0.06,
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
                  ),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.04),

            /// ================= FULL WIDTH BILLING =================
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.02,
              ),
              decoration:  BoxDecoration(
                color: AppColor.lightorangeColor.withOpacity(0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLanguage.billingDetailsText[language],
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  _billRow("1 Day", "200 KWD"),
                  SizedBox(height: size.height * 0.02),
                  Divider(
                    height: size.height * 0.03,
                    color: Colors.grey.shade300,
                  ),
                  _billRow("Grand Total", "200 KWD", isBold: true),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.03),

            GestureDetector(
              onTap: (){
                Navigator.push(context,MaterialPageRoute(builder: (context)=> CancelBookingScreen()));
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  color: AppColor.themeColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppLanguage.cancelBookingText[language],
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: size.width * 0.02),
                        Image.asset(
                          AppImage.identifyIcon,
                          width: size.width * 0.04,
                          height: size.width * 0.04,
                        ),
                      ],
                    ),
                    Image.asset(
                      AppImage.rightArrow,
                      width: size.width * 0.04,
                      height: size.width * 0.04,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: size.height * 0.10),
          ],
        ),
      ),
    );
  }


  void _showCancellationPolicyDialog(context) {
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, //
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLanguage.cancellationPolicyText[language],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFont.fontFamily,
                    color: AppColor.themeColor,
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Text(
                  'Cancellations made more than 5 days before the check-in date will receive a full refund of the total booking amount. Cancellations made between 2 to 5 days before the check-in date will receive a 50% refund. No refunds will be issued for cancellations made within 2 days of the check-in date.',
                  style: TextStyle(
                    fontSize: 13.8,
                    fontWeight: FontWeight.w400,
                    fontFamily: AppFont.fontFamily,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        );
      },
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
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontSize: 16,
            fontFamily: AppFont.fontFamily,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}


class FeatureItem extends StatelessWidget {
  final String title;
  final IconData icon;
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
        Icon(
          icon,
          size: size.width * 0.045,
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
