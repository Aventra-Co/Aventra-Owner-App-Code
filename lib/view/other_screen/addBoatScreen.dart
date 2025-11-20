import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_boat_ownerside/view/other_screen/chooseBoatScreen.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_loader.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../authentication/login_screen.dart';
import '/utilities/app_button.dart';
import '/utilities/textinput.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';

class AddBoatScreen extends StatefulWidget {
  static String routeName = './AddBoatScreen';
  const AddBoatScreen({super.key});

  @override
  State<AddBoatScreen> createState() => _AddBoatScreenState();
}

class _AddBoatScreenState extends State<AddBoatScreen> {
  TextEditingController searchTextController = TextEditingController();
  TextEditingController boatNameTextEditingController = TextEditingController();
  TextEditingController boatRegistrationNumberTextEditingController =
      TextEditingController();
  TextEditingController boatCapacityTextEditingController =
      TextEditingController();
  TextEditingController boatSizeTextEditingController = TextEditingController();
  TextEditingController cabinsTextEditingController = TextEditingController();
  TextEditingController toiletTextEditingController = TextEditingController();
  TextEditingController boatBrandTextEditingController =
      TextEditingController();
  TextEditingController boatYearTextEditingController = TextEditingController();
  DateTime? selectedDate;
  var sendDate = "";
  bool isApiCalling = false;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  int userId = 0;
  dynamic userDetails;

//--------------------GET USER DETAILS-----------------------//
  Future<dynamic> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    userDetails = prefs.getString("userDetails");
    setState(() {
      isApiCalling = true;
    });

    // print("userDetails $userDetails");
    if (userDetails != null) {
      dynamic data = json.decode(userDetails);
      print("up $data");
      userId = data['user_id'];
    }
    setState(() {
      isApiCalling = false;
    });
    setState(() {});
  }

  //==========================DATE FUNCTION=======================//
  Future<void> _selectYearOnly(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime firstDate = DateTime(1900);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            // Limit the height
            height: 300,
            width: 300,
            child: YearPicker(
              firstDate: firstDate,
              lastDate: currentDate,
              initialDate: selectedDate ?? currentDate,
              selectedDate: selectedDate ?? currentDate,
              onChanged: (DateTime dateTime) {
                String selectedYear = DateFormat('yyyy').format(dateTime);
                boatYearTextEditingController.text = selectedYear;
                setState(() {
                  selectedDate = dateTime;
                  sendDate = selectedYear;
                });
                Navigator.pop(context); // Close dialog after selection
              },
            ),
          ),
        );
      },
    );
  }

//-------------------------------add boat VALIDATION---------------------------------//
  void addBoatValidation(
    String boatName,
    String registration,
    String boatBrand,
    String year,
    String size,
    String capacity,
    String cabins,
    String toilet,
  ) {
    if (boatName.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.boatNameMsg[language]);
      return;
    } else if (registration.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.registrationMsg[language]);
      return;
    } else if (boatBrand.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.boatBrandMsg[language]);
      return;
    } else if (year.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.boatYearMsg[language]);
      return;
    } else if (size.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.boatSizeMsg[language]);
      return;
    } else if (capacity.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.boatCapacityMsg[language]);
      return;
    } else if (cabins.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.cabinsMsg[language]);
      return;
    } else if (toilet.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.toiletMsg[language]);
      return;
    } else {
      // If validation passes, call the API
      addBoatApiCall();
    }
  }

//------------------------add boat API CALL--------------------------------//
  addBoatApiCall() async {
    setState(() {
      isApiCalling = true;
    });

    Uri url = Uri.parse("${AppConfigProvider.apiUrl}add_boat");

    print("Url===> $url");

    try {
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.fields['owner_id'] = userId.toString();
      formData.fields['boat_name_english'] = boatNameTextEditingController.text;
      formData.fields['boat_brand'] = boatBrandTextEditingController.text;
      formData.fields['boat_registration_number'] =
          boatRegistrationNumberTextEditingController.text;
      formData.fields['boat_year'] = sendDate.toString();
      formData.fields['boat_size'] = boatSizeTextEditingController.text;
      formData.fields['boat_capacity'] = boatCapacityTextEditingController.text;
      formData.fields['cabins'] = cabinsTextEditingController.text;
      formData.fields['toilet'] = toiletTextEditingController.text;

      // if (_imageSelect != null) {
      //   XFile image1 = _imageSelect!;
      //   List<int> imageBytes = await image1.readAsBytes();
      //   http.MultipartFile imageFile = http.MultipartFile.fromBytes(
      //       'image', imageBytes,
      //       filename: 'image.jpg', contentType: MediaType('image', 'jpg'));

      //   formData.files.add(imageFile);
      // } else {
      //   formData.fields['image'] = "";
      // }

      log("response--==> ${formData.fields}");
      // print("response--==> ${formData.files}");
      http.StreamedResponse response = await formData.send();
      print("response--==> $response");
      var responseString = await response.stream.toBytes();
      var res = jsonDecode(utf8.decode(responseString));

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChooseBoatScreen(),
            ),
          );
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          setState(() {
            isApiCalling = false;
          });
        } else {
          setState(() {
            isApiCalling = false;
          });
          // ignore: use_build_context_synchronously
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          if (res['active_status'] == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Login()));
          }
        }
      } else {
        setState(() {
          isApiCalling = false;
        });
      }
    } catch (e) {
      setState(() {
        isApiCalling = false;
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
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColor.secondaryColor,
        body: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 100 / 100,
                height: MediaQuery.of(context).size.height * 20 / 100,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(AppImage.headerBgImage),
                        fit: BoxFit.cover),
                    color: AppColor.themeColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50))),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100,
                    ),

                    //manage text
                    Container(
                      width: MediaQuery.of(context).size.width * 100 / 100,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width:
                                  MediaQuery.of(context).size.width * 15 / 100,
                              height:
                                  MediaQuery.of(context).size.width * 8 / 100,
                              child: Image.asset(
                                AppImage.leftArrowIcon,
                                color: AppColor.secondaryColor,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              AppLanguage.addBoatText[language],
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
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),
                      //!===Enter Boat Name====
                      CustomTextFormFieldBlackWidth(
                        controller: boatNameTextEditingController,
                        hintText: AppLanguage.enterBoatNameText[language],
                        keyboardtype: TextInputType.name,
                        maxLength: 50,
                        fillColorStatus: 0,
                        readOnly: false,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),

                      //!=== Enter Boat Registration Number ===
                      CustomTextFormFieldBlackWidth(
                        controller: boatRegistrationNumberTextEditingController,
                        hintText: AppLanguage
                            .enterBoatRegistrationNumberText[language],
                        keyboardtype: TextInputType.text,
                        maxLength: 50,
                        fillColorStatus: 0,
                        readOnly: false,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),

                      //!=== Enter Boat Brand ===
                      CustomTextFormFieldBlackWidth(
                        controller: boatBrandTextEditingController,
                        hintText: AppLanguage.enterBoatBrandText[language],
                        keyboardtype: TextInputType.text,
                        maxLength: 50,
                        fillColorStatus: 0,
                        readOnly: false,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),

                      //!-----------boat year field---------------
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        height: MediaQuery.of(context).size.height * 6 / 100,
                        child: TextFormField(
                          style: const TextStyle(
                              height: 1.1,
                              color: AppColor.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                          textAlignVertical: TextAlignVertical.center,
                          controller: boatYearTextEditingController,
                          decoration: InputDecoration(
                              hintText: AppLanguage.boatYearText[language],
                              border: const UnderlineInputBorder(
                                // Use UnderlineInputBorder
                                borderSide:
                                    BorderSide(color: AppColor.boaderColor),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColor.boaderColor),
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
                              hintStyle: AppConstant.textFilledStyle,
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
                                onPressed: () {
                                  _selectYearOnly(context);
                                },
                              )),
                          readOnly: true,
                          onTap: () => _selectYearOnly(context),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),

                      //!=== Enter Boat Size ==
                      CustomTextFormFieldBlackWidth(
                        controller: boatSizeTextEditingController,
                        hintText: AppLanguage.enterBoatSizeText[language],
                        keyboardtype: TextInputType.number,
                        maxLength: 50,
                        fillColorStatus: 0,
                        readOnly: false,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),

                      //!=== Enter Boat Capacity ===
                      CustomTextFormFieldBlackWidth(
                        controller: boatCapacityTextEditingController,
                        hintText: AppLanguage.enterBoatCapacityText[language],
                        keyboardtype: TextInputType.number,
                        maxLength: 50,
                        fillColorStatus: 0,
                        readOnly: false,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),

                      //!=== Enter Cabins ===
                      CustomTextFormFieldBlackWidth(
                        controller: cabinsTextEditingController,
                        hintText: AppLanguage.enterCabinsText[language],
                        keyboardtype: TextInputType.number,
                        maxLength: 50,
                        fillColorStatus: 0,
                        readOnly: false,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),

                      //!=== Enter Toilet ===
                      CustomTextFormFieldBlackWidth(
                        controller: toiletTextEditingController,
                        hintText: AppLanguage.enterToiletText[language],
                        keyboardtype: TextInputType.number,
                        maxLength: 50,
                        fillColorStatus: 0,
                        readOnly: false,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 6 / 100),

                      //!=== Add Boat Image Text ===
                      // Container(
                      //   width: MediaQuery.of(context).size.width * 90 / 100,
                      //   child: Text(
                      //     AppLanguage.addBoatImageText[language],
                      //     style: const TextStyle(
                      //         color: AppColor.textColor,
                      //         fontFamily: AppFont.fontFamily,
                      //         fontWeight: FontWeight.w400,
                      //         fontSize: 20),
                      //   ),
                      // ),
                      // SizedBox(
                      //     height: MediaQuery.of(context).size.height * 1 / 100),
                      // Container(
                      //   width: MediaQuery.of(context).size.width * 90 / 100,
                      //   height: MediaQuery.of(context).size.height * 15 / 100,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(10),
                      //     border: Border.all(
                      //       color: AppColor.boaderColor,
                      //     ),
                      //   ),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       Image.asset(
                      //         AppImage.uploadImageIcon,
                      //         scale: 4,
                      //       ),
                      //       SizedBox(
                      //           height:
                      //               MediaQuery.of(context).size.height * 1 / 100),
                      //       Text(
                      //         AppLanguage.chooseFileToUploadText[language],
                      //         style: const TextStyle(
                      //             color: AppColor.textColor,
                      //             fontFamily: AppFont.fontFamily,
                      //             fontWeight: FontWeight.w600,
                      //             fontSize: 14),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(
                      //     height: MediaQuery.of(context).size.height * 5 / 100),

                      //!=== Button Submit ===
                      AppButton(
                          text: AppLanguage.submitText[language],
                          onPress: () {
                            addBoatValidation(
                                boatNameTextEditingController.text,
                                boatRegistrationNumberTextEditingController
                                    .text,
                                boatBrandTextEditingController.text,
                                boatYearTextEditingController.text,
                                boatSizeTextEditingController.text,
                                boatCapacityTextEditingController.text,
                                cabinsTextEditingController.text,
                                toiletTextEditingController.text);
                          }),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 3 / 100),
                    ],
                  ),
                ),
              ),
              const NoInternetBanner(),
            ],
          ),
        ),
      ),
    );
  }
}
