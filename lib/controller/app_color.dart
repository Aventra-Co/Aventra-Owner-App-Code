import 'package:flutter/material.dart';

class AppColor {
  static const Color themeColor = Color(0xffF96909);
  static const Color secondaryColor = Colors.white;
  static const Color transpSecondaryColor = Color.fromRGBO(255, 255, 255, 0.75);
  static const Color primaryColor = Colors.black;
  static const Color dividerColor = Color(0xffCBCBCB);
  static const Color boaderColor = Color(0xfffBEBEBC);
  static const Color peachColor = Color(0xfffFEE1CE);
  static const Color yellowColor = Color(0xffF9AA00);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const LinearGradient themeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      AppColor.themeColor,
      AppColor.textinputBorderColor,
    ],
  );
  static const LinearGradient themeGradientLTR = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      AppColor.themeColor,
      AppColor.textinputBorderColor,
    ],
  );

  static const Color transparent = Colors.transparent;
  static const Color textColor = Color(0xff535353);
  static const Color textLightColor = Color(0xffBEC3C7);
  static const Color titleColor = Color(0xff6D6E71);
  static const Color currentLocationColor = Color(0xff103DA7);
  static const Color yourDestinationTextColor = Color(0xff3D3838);
  static const Color licenceNumberInputBG = Color.fromRGBO(122, 122, 122, 0.13);
  static const Color textinputColor = Color(0xffE8E8E8);
  static const Color redcolor = Color(0xffD64252);
  static const Color textFillColor = Color(0xffEEEEEE);
  static const Color textInputBGColor = Color(0xffF4F7FB);
  static const Color textborderColor = Color(0xffE8E8E8);
  static const Color textinputBorderColor = Color(0xff92AD6D);
  static const Color textTransparentInputBorderColor =
      Color.fromRGBO(146, 173, 109, 0.25);
  static const Color backgorundColor = Color(0xfff8f8f8);
  static const Color darkGreyColor = Color(0xff707070);
  static const Color notificationDividerColor =
      Color.fromRGBO(187, 182, 182, 0.6);
  static const Color logoutBorderColor = Color(0xffD9D9D9);
  static const Color green = Color(0xff06AA29);
  static const Color cyan = Color(0xff11998E);

  static const LinearGradient profleThemeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      AppColor.textinputBorderColor,
      AppColor.secondaryColor,
    ],
  );
  static const LinearGradient cardThemeGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: <Color>[
      AppColor.textinputBorderColor,
      AppColor.secondaryColor,
    ],
  );
  static const Color carWashCountColor1 = Color(0xff788E59);
  static const Color carWashCountColor2 = Color(0xffA6C47C);

  static const LinearGradient carWashCountGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      AppColor.carWashCountColor1,
      AppColor.carWashCountColor2,
    ],
  );

  static const LinearGradient myCarsGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      Color.fromARGB(195, 146, 173, 109),
      AppColor.secondaryColor,
    ],
  );
  static const LinearGradient trasparentGradient = LinearGradient(
    colors: <Color>[
      AppColor.secondaryColor,
      AppColor.secondaryColor,
    ],
  );
  static const Color lightblue = Color(0xfff3fdfe);
  static const Color background = Color(0xfff6f4f1);
  static const Color chatBubbaleColor = Color(0xff918F8F);

    //----------------------20/02/2026---------------------
  static const Color completedColor = Color(0xFF1A908E);
  static const Color ongoingColor = Color(0xFF096B9B);
  static const Color pendingColor = Color(0xFFF8C63D);
  static const Color black1313Color = Color(0xFF131313);
  static const Color black2A2AColor = Color(0xFF2A2A2A);

  static const Color grey5959Color = Color(0xFF595959);

  // static const Color buttonColor = Color(0xFFF96909);
  static const Color lightorangeColor = Color(0xFFFEE1CE);
    static const Color lightColor = Color(0xFFE2DED354);
static const Color divider1Color = Color(0xFFE3A3A3A);
  static const Color creamColor = Color(0xffEFEFEF);
  static const Color shadowColor = Color(0xffCCCCCC);  
  static const Color blueColor = Color(0xff188A8B);


}
