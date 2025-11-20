import 'package:flutter/material.dart';
import '../utilities/app_color.dart';
import 'app_font.dart';

class AppButton extends StatelessWidget {
  final String text;
  final Function onPress;

  const AppButton({
    super.key,
    required this.text,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPress();
      },
      child: Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height * 6.5 / 100,
        width: MediaQuery.of(context).size.width * 90 / 100,
        decoration: BoxDecoration(
          color: AppColor.themeColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: AppColor.secondaryColor,
            fontFamily: AppFont.fontFamily,
            fontWeight: FontWeight.w700
          ),
        ),
      ),
    );
  }
}

class CardButton extends StatelessWidget {
  final String text;
  final Function onPress;

  const CardButton({
    super.key,
    required this.text,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height * 5 / 100,
      width: MediaQuery.of(context).size.width * 65 / 100,
      decoration: BoxDecoration(
        color: AppColor.themeColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColor.secondaryColor,
          fontFamily: AppFont.fontFamily,
          fontWeight: FontWeight.w600
        ),
      ),
    );
  }
}
