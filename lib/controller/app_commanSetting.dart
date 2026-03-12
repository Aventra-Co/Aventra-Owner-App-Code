import 'package:flutter/material.dart';

import 'app_color.dart';

import 'app_font.dart';

class SettingRow extends StatelessWidget {
  final String title;
  final String leadingIcon;
  final String rightLeadingIcon;
  final Function onPress;

  const SettingRow({
    Key? key,
    required this.title,
    required this.leadingIcon,
    required this.rightLeadingIcon,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPress(),
      child: Container(
        width: MediaQuery.of(context).size.width * 85 / 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 5 / 100,
              height: MediaQuery.of(context).size.width * 5 / 100,
              alignment: Alignment.center,
              child: Image.asset(
                leadingIcon,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 68 / 100,
              child: Text(
                title,
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontFamily: AppFont.fontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 4 / 100,
              height: MediaQuery.of(context).size.width * 4 / 100,
              alignment: Alignment.center,
              child: Image.asset(
                rightLeadingIcon,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
