import 'package:flutter/material.dart';
import 'app_color.dart';
import 'app_constant.dart'; // Update with your actual path

// ignore: must_be_immutable
class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final int fillColorStatus;
  final bool readOnly;
  // ignore: prefer_typing_uninitialized_variables
  var keyboardtype;

  CustomTextFormField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.keyboardtype,
      required this.maxLength,
      required this.fillColorStatus,
      required this.readOnly});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 90 / 100,
        height: MediaQuery.of(context).size.height * 6 / 100,
        child: TextFormField(
          readOnly: readOnly,
          style: const TextStyle(
              height: 1.1,
              color: AppColor.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w400),
          textAlignVertical: TextAlignVertical.center,
          keyboardType: keyboardtype,
          controller: controller,
          maxLength: maxLength,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(
              // Use UnderlineInputBorder
              borderSide: BorderSide(color: AppColor.secondaryColor),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.secondaryColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.themeColor, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 9),
            fillColor: Colors.transparent,
            filled: true,
            counterText: '',
            hintText: hintText,
            hintStyle: AppConstant.textFilledStyle,
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomTextFormFieldLightText extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final int fillColorStatus;
  final bool readOnly;
  // ignore: prefer_typing_uninitialized_variables
  var keyboardtype;

  CustomTextFormFieldLightText(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.keyboardtype,
      required this.maxLength,
      required this.fillColorStatus,
      required this.readOnly});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 90 / 100,
        height: MediaQuery.of(context).size.height * 6 / 100,
        child: TextFormField(
          readOnly: readOnly,
          style: const TextStyle(
              height: 1.1,
              color: AppColor.textLightColor,
              fontSize: 16,
              fontWeight: FontWeight.w400),
          textAlignVertical: TextAlignVertical.center,
          keyboardType: keyboardtype,
          controller: controller,
          maxLength: maxLength,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(
              // Use UnderlineInputBorder
              borderSide: BorderSide(color: AppColor.secondaryColor),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.secondaryColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.themeColor, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 9),
            fillColor: Colors.transparent,
            filled: true,
            counterText: '',
            hintText: hintText,
            hintStyle: const TextStyle(
                color: Color(0xffBEC3C7),
                fontWeight: FontWeight.w400,
                fontSize: 16),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomTextFormFieldBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final int fillColorStatus;
  final bool readOnly;
  // ignore: prefer_typing_uninitialized_variables
  var keyboardtype;

  CustomTextFormFieldBox(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.keyboardtype,
      required this.maxLength,
      required this.fillColorStatus,
      required this.readOnly});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 90 / 100,
        height: MediaQuery.of(context).size.height * 7 / 100,
        child: TextFormField(
          readOnly: readOnly,
          style: const TextStyle(
              height: 1.1,
              color: AppColor.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w400),
          textAlignVertical: TextAlignVertical.center,
          keyboardType: keyboardtype,
          controller: controller,
          maxLength: maxLength,
          decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.boaderColor),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.boaderColor),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.themeColor),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              fillColor: fillColorStatus == 0
                  ? AppColor.secondaryColor
                  : AppColor.secondaryColor,
              filled: true,
              counterText: '',
              hintText: hintText,
              hintStyle: const TextStyle(
                  color: AppColor.textColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 16)),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomTextFormFieldBlackWidth extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final int fillColorStatus;
  final bool readOnly;
  final double width;
  // ignore: prefer_typing_uninitialized_variables
  var keyboardtype;

  CustomTextFormFieldBlackWidth(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.keyboardtype,
      required this.maxLength,
      required this.fillColorStatus,
      required this.width,
      required this.readOnly});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        height: MediaQuery.of(context).size.height * 5.5 / 100,
        child: TextFormField(
          readOnly: readOnly,
          style: const TextStyle(
              height: 1.1,
              color: AppColor.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w400),
          textAlignVertical: TextAlignVertical.center,
          keyboardType: keyboardtype,
          controller: controller,
          maxLength: maxLength,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(
              // Use UnderlineInputBorder
              borderSide: BorderSide(color: AppColor.boaderColor),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.boaderColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.themeColor, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            fillColor: Colors.transparent,
            filled: true,
            counterText: '',
            hintText: hintText,
            hintStyle: AppConstant.textFilledStyle,
          ),
        ),
      ),
    );
  }
}
