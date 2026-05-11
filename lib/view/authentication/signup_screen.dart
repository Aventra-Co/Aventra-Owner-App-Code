import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '/view/authentication/otp_verify_screen.dart';
import '../content_screen/content_screen.dart';
import '../../controller/app_button.dart';
// import '/utilities/app_header.dart';
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';
import '../../controller/app_loader.dart';
import '../../controller/textinput.dart';
import 'login_screen.dart';

class Signup extends StatefulWidget {
  static String routeName = "./Signup";
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController boatStaffTextEditingController =
      TextEditingController();
  TextEditingController firstNameTextEditingController =
      TextEditingController();
  TextEditingController mobileTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController roleTextEditingController = TextEditingController();
  TextEditingController countryTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController =
      TextEditingController();
  TextEditingController searchCountryTextEditingController =
      TextEditingController();
  bool isPasswordVisible = true;
  bool isConfirmPasswordVisible = true;
  bool isCheckBoxValue = false;
  bool isApiCalling = false;
  DateTime? selectedDate;
  var sendDate = "";
  int selectedGender = 0;
  int isSelectedCountry = 0;

  @override
  void initState() {
    super.initState();
    // getAllContent();
  }

  //==========================DATE FUNCTION=======================//
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      var sendDate1 = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        selectedDate = picked;
        sendDate = sendDate1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
        inAsyncCall: isApiCalling,
        opacity: 0.5,
        child: _buildUIScreen(context));
  }

  Widget _buildUIScreen(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: AppColor.secondaryColor,
          body: Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 100 / 100,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: AppColor.themeColor,
                image: DecorationImage(
                    image: AssetImage(AppImage.loginPageImage),
                    fit: BoxFit.cover)),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 8 / 100,
                        ),

                        //logo
                        Container(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          alignment: Alignment.center,
                          child: const Text(
                            "Logo",
                            style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontSize: 40,
                                fontWeight: FontWeight.w600,
                                color: AppColor.themeColor),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100,
                        ),

                        //my boat text
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            AppLanguage.aventraText[language],
                            style: const TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColor.secondaryColor),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //boat staff
                        CustomTextFormFieldLightText(
                          controller: boatStaffTextEditingController,
                          hintText: AppLanguage.boatStaffText[language],
                          maxLength: AppConstant.fullnameLength,
                          keyboardtype: TextInputType.text,
                          fillColorStatus: 0,
                          readOnly: false,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //firstNameText
                        CustomTextFormFieldLightText(
                          controller: firstNameTextEditingController,
                          hintText: AppLanguage.firstNameText[language],
                          maxLength: AppConstant.fullnameLength,
                          keyboardtype: TextInputType.text,
                          fillColorStatus: 0,
                          readOnly: false,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //emailText
                        CustomTextFormFieldLightText(
                          controller: emailTextEditingController,
                          hintText: AppLanguage.emailText[language],
                          maxLength: AppConstant.emailMaxLength,
                          keyboardtype: TextInputType.emailAddress,
                          fillColorStatus: 0,
                          readOnly: false,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //mobileText
                        CustomTextFormFieldLightText(
                          controller: mobileTextEditingController,
                          hintText: AppLanguage.mobileText[language],
                          maxLength: AppConstant.mobileLength,
                          keyboardtype: TextInputType.number,
                          fillColorStatus: 0,
                          readOnly: false,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //roleText
                        CustomTextFormFieldLightText(
                          controller: roleTextEditingController,
                          hintText: AppLanguage.roleText[language],
                          maxLength: AppConstant.fullnameLength,
                          keyboardtype: TextInputType.text,
                          fillColorStatus: 0,
                          readOnly: false,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //countryText
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          height: MediaQuery.of(context).size.height * 6 / 100,
                          child: TextFormField(
                            readOnly: true,
                            style: const TextStyle(
                                height: 1.1,
                                color: AppColor.textLightColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                            textAlignVertical: TextAlignVertical.center,
                            controller: countryTextEditingController,
                            onTap: () {
                              // dropDownModelForCountry(context);
                            },
                            decoration: InputDecoration(
                                border: const UnderlineInputBorder(
                                  // Use UnderlineInputBorder
                                  borderSide: BorderSide(
                                      color: AppColor.secondaryColor),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColor.secondaryColor),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColor.themeColor, width: 1),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 9),
                                fillColor: Colors.transparent,
                                filled: true,
                                counterText: '',
                                hintText:
                                    AppLanguage.selectCountryText[language],
                                hintStyle: const TextStyle(
                                    color: Color(0xffBEC3C7),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                                suffixIcon: IconButton(
                                  icon: Container(
                                    alignment: Alignment.centerRight,
                                    width: MediaQuery.of(context).size.width *
                                        20 /
                                        100,
                                    height: MediaQuery.of(context).size.width *
                                        6 /
                                        100,
                                    child: Image.asset(
                                      AppImage.nextArrowWhiteIcon,
                                    ),
                                  ),
                                  onPressed: () {},
                                )),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //-----------DOB field---------------
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          height: MediaQuery.of(context).size.height * 6 / 100,
                          child: TextFormField(
                            style: const TextStyle(
                                height: 1.1,
                                color: AppColor.textLightColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                                hintText: selectedDate != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(selectedDate!)
                                    : 'Date Of Birth',
                                border: const UnderlineInputBorder(
                                  // Use UnderlineInputBorder
                                  borderSide: BorderSide(
                                      color: AppColor.secondaryColor),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColor.secondaryColor),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColor.themeColor, width: 1),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 9),
                                fillColor: Colors.transparent,
                                filled: true,
                                counterText: '',
                                hintStyle: const TextStyle(
                                    color: Color(0xffBEC3C7),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                                suffixIcon: IconButton(
                                  icon: Container(
                                    alignment: Alignment.centerRight,
                                    width: MediaQuery.of(context).size.width *
                                        20 /
                                        100,
                                    height: MediaQuery.of(context).size.width *
                                        6 /
                                        100,
                                    child: Image.asset(
                                      AppImage.calenderImage,
                                    ),
                                  ),
                                  onPressed: () {},
                                )),
                            readOnly: true,
                            onTap: () => _selectDate(context),
                          ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100),

                        //gender text
                        Container(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            AppLanguage.genderText[language],
                            style: const TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColor.textLightColor),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //gender selection
                        Container(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            children: [
                              //male
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedGender = 1;
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      30 /
                                      100,
                                  child: Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                6 /
                                                100,
                                        child: Image.asset(selectedGender == 1
                                            ? AppImage.tickMarkIcon
                                            : AppImage.boxIcon),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                4 /
                                                100,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                20 /
                                                100,
                                        child: Text(
                                          AppLanguage.maleText[language],
                                          style: const TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.textLightColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              //female
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedGender = 2;
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      30 /
                                      100,
                                  child: Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                6 /
                                                100,
                                        child: Image.asset(selectedGender == 2
                                            ? AppImage.tickMarkIcon
                                            : AppImage.boxIcon),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                4 /
                                                100,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                20 /
                                                100,
                                        child: Text(
                                          AppLanguage.femaleText[language],
                                          style: const TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.textLightColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              //company
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedGender = 3;
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      30 /
                                      100,
                                  child: Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                6 /
                                                100,
                                        child: Image.asset(selectedGender == 3
                                            ? AppImage.tickMarkIcon
                                            : AppImage.boxIcon),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                4 /
                                                100,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                20 /
                                                100,
                                        child: Text(
                                          AppLanguage.otherText[language],
                                          style: const TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.textLightColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //password field
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          height: MediaQuery.of(context).size.height * 6 / 100,
                          child: TextFormField(
                            readOnly: false,
                            style: const TextStyle(
                                height: 1.1,
                                color: AppColor.textLightColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.visiblePassword,
                            controller: passwordTextEditingController,
                            maxLength: AppConstant.passwordLength,
                            obscureText: isPasswordVisible,
                            decoration: InputDecoration(
                              border: const UnderlineInputBorder(
                                // Use UnderlineInputBorder
                                borderSide:
                                    BorderSide(color: AppColor.secondaryColor),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColor.secondaryColor),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColor.secondaryColor, width: 1),
                              ),
                              suffixIcon: IconButton(
                                icon: Container(
                                  alignment: Alignment.centerRight,
                                  width: MediaQuery.of(context).size.width *
                                      20 /
                                      100,
                                  height: MediaQuery.of(context).size.width *
                                      6 /
                                      100,
                                  child: Image.asset(
                                      isPasswordVisible
                                          ? AppImage.showEyeIcon
                                          : AppImage.hideEyeIcon,
                                      color: AppColor.textLightColor),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 9),
                              fillColor: Colors.transparent,
                              filled: true,
                              counterText: '',
                              hintText: AppLanguage.passwordText[language],
                              hintStyle: const TextStyle(
                                  color: Color(0xffBEC3C7),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //confirm password field
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          height: MediaQuery.of(context).size.height * 6 / 100,
                          child: TextFormField(
                            readOnly: false,
                            style: const TextStyle(
                                height: 1.1,
                                color: AppColor.textLightColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.visiblePassword,
                            controller: confirmPasswordTextEditingController,
                            maxLength: AppConstant.passwordLength,
                            obscureText: isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              border: const UnderlineInputBorder(
                                // Use UnderlineInputBorder
                                borderSide:
                                    BorderSide(color: AppColor.secondaryColor),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColor.secondaryColor),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColor.secondaryColor, width: 1),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 9),
                              fillColor: Colors.transparent,
                              filled: true,
                              counterText: '',
                              hintText:
                                  AppLanguage.confirmPasswordText[language],
                              hintStyle: const TextStyle(
                                  color: Color(0xffBEC3C7),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16),
                              suffixIcon: IconButton(
                                icon: Container(
                                  alignment: Alignment.centerRight,
                                  width: MediaQuery.of(context).size.width *
                                      20 /
                                      100,
                                  height: MediaQuery.of(context).size.width *
                                      6 /
                                      100,
                                  child: Image.asset(
                                      isConfirmPasswordVisible
                                          ? AppImage.showEyeIcon
                                          : AppImage.hideEyeIcon,
                                      color: AppColor.textLightColor),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isConfirmPasswordVisible =
                                        !isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //check box
                        Container(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isCheckBoxValue = !isCheckBoxValue;
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      6 /
                                      100,
                                  child: Image.asset(isCheckBoxValue
                                      ? AppImage.tickMarkIcon
                                      : AppImage.boxIcon),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width *
                                    80 /
                                    100,
                                alignment: Alignment.center,
                                child: Text.rich(
                                  textAlign: TextAlign.center,
                                  TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              AppLanguage.acceptText[language],
                                          style: const TextStyle(
                                              color: AppColor.secondaryColor,
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              setState(() {
                                                isCheckBoxValue =
                                                    !isCheckBoxValue;
                                              });
                                            }),
                                      TextSpan(
                                          text: AppLanguage
                                              .termsConditionText[language],
                                          //    textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: AppColor.themeColor,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  AppColor.themeColor,
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.pushNamed(
                                                  context, Content.routeName,
                                                  arguments: ContentClass(
                                                      header: AppLanguage
                                                              .termsConditionText[
                                                          language],
                                                      contentType: ""));
                                            }),
                                      TextSpan(
                                          text: AppLanguage.andText[language],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: AppFont.fontFamily,
                                              color: AppColor.secondaryColor,
                                              fontWeight: FontWeight.w400)),
                                      TextSpan(
                                          text: AppLanguage
                                              .privacyPolicyText[language],
                                          style: const TextStyle(
                                              decorationColor:
                                                  AppColor.themeColor,
                                              decoration:
                                                  TextDecoration.underline,
                                              color: AppColor.themeColor,
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.pushNamed(
                                                  context, Content.routeName,
                                                  arguments: ContentClass(
                                                      header: AppLanguage
                                                              .privacyPolicyText[
                                                          language],
                                                      contentType: ""));
                                            }),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //sign up button
                        AppButton(
                            text: AppLanguage.signUpText[language],
                            onPress: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const OTP()));
                            }),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //dont have text
                        Container(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLanguage.alreadyHaveAccText[language],
                                style: const TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.secondaryColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Login()));
                                },
                                child: Text(
                                  AppLanguage.loginText[language],
                                  style: const TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColor.secondaryColor,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColor.secondaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),
                      ],
                    ),
                  ),
                ),
                const NoInternetBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
}
