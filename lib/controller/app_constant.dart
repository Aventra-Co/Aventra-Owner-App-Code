import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app_color.dart';
import 'app_connectivity.dart';
import 'app_font.dart';
import 'app_language.dart';

int language = 0;

class AppConstant {
  static int addressNavigation = 0;
  static int addCarNavigation = 0;
  static const int fullnameLength = 50;
  static const int emailMaxLength = 100;
  static const int mobileLength = 15;
  static const int passwordLength = 16;
  static const int searchLength = 250;
  static const int describeLength = 500;
  static bool isLoggedOut = false;
  static int selectFooterIndex = 0;
  static String playerID = "";
    static String temperature = '28';
  static String unit = '°C';
  static String weatherDesc = AppLanguage.clearSkyText[language];
  static String weatherIcon = '☀️';
  static var deviceType = Platform.isAndroid ? 'android' : 'ios';
  static String token = "";
  static String mapkey = "AIzaSyAqdD0whRmRrC5YtKvRBPDaaq_63dluCII";
    static String weatherKey = "iw1HuqjddUHzaFmb";
  static String oneSignalAppId = "3103e952-a0df-4841-a79a-6f221c8be76a";

  static final RegExp emailValidatorRegExp =
      RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  static final RegExp licenseValidatorRegExp =
      RegExp(r'^([A-Z]{2}[0-9]{2}\s?[A-Z]{3})$');

  static String appId = "1:83903925512:web:05db133012c6cbcc7bb0bd";
  static String apiKey = "AIzaSyB8FxTSDhhEmL8rFwW5qdDYECEyHX_ul_0";
  // static String apiKey = "AIzaSyAlmy6hvQysu1m7UhhevgFpuhzXkHHdhJ0";
  static String messagingSenderId = "83903925512";
  static String projectId = "my-boat-a9c54";


//!===================INPUT FORMATTERS==========================
    static List<TextInputFormatter> onlyDigitFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')) // only digits allowed
  ];
  static List<TextInputFormatter> alphaNumericFormatter = [
    FilteringTextInputFormatter.allow(
        RegExp(r'[a-zA-Z0-9]')) // alphanumeric allowed
  ];
  static List<TextInputFormatter> alphabetFormatter = [
    FilteringTextInputFormatter.allow(
        RegExp(r'[a-zA-Z ]') // alphabet and space allowed
        )
  ];
  static List<TextInputFormatter> allAllowFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'.*')) // alphabet allowed
  ];
  //!===================INPUT FORMATTERS==========================

  static const TextStyle textFilledStyle = TextStyle(
      color: AppColor.textColor, fontWeight: FontWeight.w400, fontSize: 16);

  static const TextStyle textHeadingStyle = TextStyle(
      fontFamily: AppFont.fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 23,
      color: AppColor.textColor);
}

class ContentClass {
  final String header;
  final String contentType;

  ContentClass({required this.header, required this.contentType});
}

class ResetPasswordIdClass {
  final String userId;
  ResetPasswordIdClass({required this.userId});
}

class ForgotOtpResendEmailClass {
  final String userId;
  final String email;
  ForgotOtpResendEmailClass({required this.email, required this.userId});
}

class BrandDataClass {
  final String brandId;
  final String servicePrice;

  BrandDataClass({
    required this.brandId,
    required this.servicePrice,
  });
}

class BrandPriceDataClass {
  final String brandId;
  final String servicePrice;

  BrandPriceDataClass({
    required this.brandId,
    required this.servicePrice,
  });
}

class BrandModelDataClass {
  final String brandId;
  final String modelId;
  final String serviceId;
  final String servicePrice;
  BrandModelDataClass({
    required this.brandId,
    required this.modelId,
    required this.serviceId,
    required this.servicePrice,
  });
}

class BrandModelYearDataClass {
  final String brandId;
  final String modelId;
  final String year;
  final String serviceId;
  final String servicePrice;
  final String size;
  BrandModelYearDataClass(
      {required this.brandId,
      required this.modelId,
      required this.year,
      required this.serviceId,
      required this.servicePrice,
      required this.size});
}

class AddressClass {
  final String address;
  final String serviceId;
  final String servicePrice;
  AddressClass({
    required this.address,
    required this.serviceId,
    required this.servicePrice,
  });
}

class ExerciseClass {
  final dynamic planningList;
  ExerciseClass({
    required this.planningList,
  });
}

class BookingDetailsClass {
  final dynamic addressDetails;
  final dynamic carDetails;
  final String time;
  final String date;
  final String sendDate;
  final String serviceId;
  final String slotId;
  final String servicePrice;
  final int isPackage;
  BookingDetailsClass({
    required this.addressDetails,
    required this.carDetails,
    required this.time,
    required this.sendDate,
    required this.date,
    required this.serviceId,
    required this.slotId,
    required this.servicePrice,
    required this.isPackage,
  });
}

class BrandServiceClass {
  final String brandId;
  final String serviceId;
  final String servicePrice;
  BrandServiceClass({
    required this.brandId,
    required this.serviceId,
    required this.servicePrice,
  });
}

class RatingClass {
  final String userId;
  final String bookingId;
  final String otherUserId;
  final String name;
  final String image;
  final String carBrand;
  final String addresh;
  RatingClass({
    required this.userId,
    required this.bookingId,
    required this.otherUserId,
    required this.name,
    required this.image,
    required this.carBrand,
    required this.addresh,
  });
}

class NoInternetBanner extends StatelessWidget {
  const NoInternetBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var connectionProvider = Provider.of<ConnectionProvider>(context);
    if (connectionProvider.status.name == "WiFi" ||
        connectionProvider.status.name == "Mobile") {
      return const SizedBox(); // No internet issue, return empty container
    }

    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 6 / 100,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          color: Colors.red,
          child: Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Text(
              AppLanguage
                  .noInternetText[language], // Access directly without language
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                fontFamily: AppFont.fontFamily,
                color: AppColor.secondaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum BottomMenus { home, myBookings, wallet, profile }
