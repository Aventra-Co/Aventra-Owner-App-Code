import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'app_color.dart';
import 'app_constant.dart';
import 'app_font.dart';
import 'app_image.dart';

class AppHeader extends StatelessWidget {
  final String text;
  final Function onPress;
  const AppHeader({
    super.key,
    required this.text,
    required this.onPress, required String suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 100 / 100,
      height: MediaQuery.of(context).size.height * 8 / 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              onPress();
            },
            child: Transform.rotate(
              angle: language == 1 ? 3.1416 : 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 15 / 100,
                height: MediaQuery.of(context).size.width * 6 / 100,
                child: Image.asset(
                  AppImage.leftArrowIcon,
                  color: AppColor.primaryColor,
                ),
              ),
            ),
          ),
          Container(
            child: Text(
              text,
              style: const TextStyle(
                  color: AppColor.primaryColor,
                  fontFamily: AppFont.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 20),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 15 / 100,
            height: MediaQuery.of(context).size.width * 6 / 100,
          ),
        ],
      ),
    );
  }
}

class AppHeaderOrange extends StatelessWidget {
  final String text;
  final Function onPress;
  const AppHeaderOrange({super.key, required this.text, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 100 / 100,
      height: MediaQuery.of(context).size.height * 16 / 100,
      decoration: const BoxDecoration(
          color: AppColor.themeColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              onPress();
            },
            child: Transform.rotate(
              angle: language == 1 ? 3.1416 : 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 15 / 100,
                height: MediaQuery.of(context).size.width * 8 / 100,
                child: Image.asset(
                  AppImage.leftArrowIcon,
                  color: AppColor.secondaryColor,
                ),
              ),
            ),
          ),
          Container(
            child: Text(
              text,
              style: const TextStyle(
                  color: AppColor.secondaryColor,
                  fontFamily: AppFont.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 20),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 15 / 100,
            height: MediaQuery.of(context).size.width * 6 / 100,
          ),
        ],
      ),
    );
  }
}


class CustomAppHeader extends StatelessWidget {
  final String text;
  final String? suffixText; // ✅ Added suffix
  final Function onPress;

  const CustomAppHeader({
    super.key,
    required this.text,
    required this.onPress,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width * 100 / 100,
      height: size.height * 8 / 100,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
      child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [

    Row(
      children: [

        GestureDetector(
          onTap: () {
            onPress();
          },
          child: Transform.rotate(
            angle: language == 1 ? 3.1416 : 0,
            child: Image.asset(
              AppImage.leftArrowIcon,
              width: size.width * 6 / 100,
              height: size.width * 6 / 100,
              color: AppColor.primaryColor,
            ),
          ),
        ),

        SizedBox(width: size.width * 3 / 100), // 👈 spacing between arrow & text

        Text(
          text,
          style: const TextStyle(
            color: AppColor.primaryColor,
            fontFamily: AppFont.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ],
    ),

    /// 🔹 Right Side ID
    Text(
      suffixText ?? "",
      textAlign: TextAlign.end,
      style: const TextStyle(
        color: AppColor.textColor,
        fontFamily: AppFont.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
    ),
  ],
),
    );
  }


}