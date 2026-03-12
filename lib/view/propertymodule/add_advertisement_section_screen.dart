import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_boat_ownerside/view/other_screen/add_advertisement_screen.dart';
import 'package:the_boat_ownerside/view/propertymodule/add_advertisement_property_screen.dart';
import 'dart:ui' as ui;
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';

class AddAdvertisementSectionScreen extends StatefulWidget {
  static String routeName = './AddAdvertisementSectionScreen';
  const AddAdvertisementSectionScreen({super.key});

  @override
  State<AddAdvertisementSectionScreen> createState() =>
      _AddAdvertisementSectionScreenState();
}

class _AddAdvertisementSectionScreenState
    extends State<AddAdvertisementSectionScreen> {
  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Directionality(
        textDirection:
            language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Column(
          children: [
            // ── HEADER WITH BG IMAGE ──────────────────────────────────────
            Container(
              width: sw,
              height: sw > 600 ? sh * 0.25 : sh * 0.22,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImage.headerBgImage),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    SizedBox(
                      height: AppConstant.deviceType == "ios"
                          ? sh * 0.01
                          : sh * 0.015,
                    ),
                    // Back + Title row
                    SizedBox(
                      width: sw,
                      child: Row(
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Transform.rotate(
                              angle: language == 1 ? 3.1416 : 0,
                              child: Container(
                                alignment: Alignment.center,
                                color: Colors.transparent,
                                width: sw * 15 / 100,
                                height: sw * 7 / 100,
                                child: Image.asset(AppImage.backIcon),
                              ),
                            ),
                          ),

                          // Title
                          SizedBox(
                            width: sw * 70 / 100,
                            child: Text(
                              AppLanguage.addAdvText[language],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColor.secondaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFont.fontFamily,
                              ),
                            ),
                          ),

                          // Spacer right
                          SizedBox(width: sw * 15 / 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── BODY - TWO CARDS ──────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.05,
                  vertical: sh * 0.04,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── SEA ADVERTISEMENT CARD ───────────────────────────
                    Expanded(
                      child: _adCard(
                        context: context,
                        image: AppImage.seaAdImage,
                        title: AppLanguage.seaAdvertisementText[language],
                        subtitle:
                            AppLanguage.seaAdvertisementSubtitleText[language],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddAdvertisementScreen(),
                            ),
                          );
                        },
                        sw: sw,
                        sh: sh,
                      ),
                    ),

                    SizedBox(width: sw * 0.03),

                    Expanded(
                      child: _adCard(
                        context: context,
                        image: AppImage.propertyAdImage,
                        title: AppLanguage.propertyAdvertisementText[language],
                        subtitle: AppLanguage
                            .propertyAdvertisementSubtitleText[language],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AddAdvertisementPropertyScreen(),
                            ),
                          );
                        },
                        sw: sw,
                        sh: sh,
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
    );
  }

  // ── CARD WIDGET ────────────────────────────────────────────────────────────
  Widget _adCard({
    required BuildContext context,
    required String image,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required double sw,
    required double sh,
  }) {
    return GestureDetector(
            onTap:onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── TOP IMAGE ──────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.asset(
                image,
                width: double.infinity,
                height: sh * 0.14,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: sh * 0.14,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image, color: Colors.grey, size: 40),
                ),
              ),
            ),
      
            // ── CONTENT ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(sw * 0.02),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 11.8,
                        fontWeight: FontWeight.w500,
                        color: AppColor.primaryColor,
                        fontFamily: AppFont.fontFamily,
                      ),
                    ),
                    SizedBox(height: sh * 0.005),
      
                    // Subtitle
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        textAlign: TextAlign.center,
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                          fontFamily: AppFont.fontFamily,
                        ),
                      ),
                    ),
                    SizedBox(height: sh * 0.015),
      
                    // Orange arrow button
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        width: sw * 0.09,
                        height: sw * 0.09,
                        decoration: const BoxDecoration(
                          color: AppColor.themeColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_outward,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
