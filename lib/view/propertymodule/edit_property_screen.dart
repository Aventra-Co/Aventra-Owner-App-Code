import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/app_config_provider.dart';
import '../../controller/app_header.dart';
import '../../controller/app_loader.dart';

import '../../controller/app_button.dart';
import '../../controller/app_snack_bar_toast_message.dart';
import '../../controller/textinput.dart';
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';
import 'dart:ui' as ui;

import '../authentication/login_screen.dart';

class EditPropertyScreen extends StatefulWidget {
  static String routeName = './EditPropertyScreen';
  const EditPropertyScreen({super.key, required this.propertyDetails});

  final dynamic propertyDetails;

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  TextEditingController searchTextController = TextEditingController();
  TextEditingController propertyNameTextEditingController =
      TextEditingController();
  TextEditingController propertytypeTextEditingController =
      TextEditingController();
  TextEditingController propertyaddressTextEditingController =
      TextEditingController();
  TextEditingController roomsTextEditingController = TextEditingController();
  TextEditingController hallsTextEditingController = TextEditingController();
  TextEditingController outdoorSeatingTextEditingController =
      TextEditingController();
  TextEditingController washroomsTextEditingController =
      TextEditingController();
  TextEditingController poolTextEditingController = TextEditingController();
  TextEditingController searchPropertyTypeTextEditingController =
      TextEditingController();
  DateTime? selectedDate;
  var sendDate = "";
  bool isApiCalling = false;
  List propertyTypeList = <dynamic>[];
  List propertyTypeSearchList = <dynamic>[];
  int selectedPropertyType = 0;
  int userId = 0;
  dynamic userDetails;

  @override
  void initState() {
    super.initState();
    getPropertyTypeApi();
    getUserDetails();
  }

  //--------------------GET USER DETAILS-----------------------//
  Future<dynamic> getUserDetails() async {
    dynamic details = widget.propertyDetails;
    propertyNameTextEditingController.text =
        details['property_name_english'] ?? "";
    selectedPropertyType = details['property_type'] ?? 0;
    propertytypeTextEditingController.text =
        details['property_type']?.toString() ?? '';
    propertyaddressTextEditingController.text =
        details['property_address'] ?? "";
    roomsTextEditingController.text = details['no_of_rooms']?.toString() ?? '';
    hallsTextEditingController.text = details['no_of_halls']?.toString() ?? '';
    outdoorSeatingTextEditingController.text = details['outdoor_seating'] ?? "";
    washroomsTextEditingController.text =
        details['no_of_washroom']?.toString() ?? '';
    poolTextEditingController.text = details['pool'] ?? "";
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

  validation() {
    if (propertyNameTextEditingController.text.trim().isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.enterPropertyNameMsg[language]);
    } else if (propertytypeTextEditingController.text.trim().isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.selectPropertyTypeMsg[language]);
    } else if (propertyaddressTextEditingController.text.trim().isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.enterPropertyAddressMSg[language]);
    } else if (roomsTextEditingController.text.trim().isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.enterRoomsMsg[language]);
    } else if (hallsTextEditingController.text.trim().isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.enterHallsMsg[language]);
    } else if (outdoorSeatingTextEditingController.text.trim().isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.enterOutdoorSeatingMsg[language]);
    } else if (washroomsTextEditingController.text.trim().isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.enterWashroomsMsg[language]);
    } else if (poolTextEditingController.text.trim().isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.enterPoolMsg[language]);
    } else {
      editPropertyApiCall();
    }
  }

  //------------------------edit property API CALL--------------------------------//
  editPropertyApiCall() async {
    setState(() {
      isApiCalling = true;
    });

    Uri url = Uri.parse("${AppConfigProvider.apiUrl}edit_property");

    print("Url===> $url");

    try {
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.fields['user_id'] = userId.toString();
      formData.fields['property_id'] =
          widget.propertyDetails['property_id'].toString();
      formData.fields['property_name_english'] =
          propertyNameTextEditingController.text.trim();
      formData.fields['property_type'] = selectedPropertyType.toString();
      formData.fields['no_of_rooms'] = roomsTextEditingController.text.trim();
      formData.fields['no_of_halls'] = hallsTextEditingController.toString();
      formData.fields['no_of_washroom'] =
          washroomsTextEditingController.text.trim();
      formData.fields['property_address'] =
          propertyaddressTextEditingController.text.trim();
      formData.fields['outdoor_seating'] =
          outdoorSeatingTextEditingController.text.trim();
      formData.fields['pool'] = poolTextEditingController.text.trim();

      log("response--==> ${formData.fields}");
      // print("response--==> ${formData.files}");
      http.StreamedResponse response = await formData.send();
      print("response--==> $response");
      var responseString = await response.stream.toBytes();
      var res = jsonDecode(utf8.decode(responseString));

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          Navigator.pop(context);
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

  //!=============================GET Property type===================================//
  Future<void> getPropertyTypeApi() async {
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}get_property_type");
    print("url $url");

    String token = AppConstant.token;

    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token', // Use 'Bearer' if required
    };

    setState(() {
      isApiCalling = true;
    });

    print("headers $headers");

    try {
      final response = await http.get(url, headers: headers);
      print("response $response");

      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);
        print("res $res");

        if (res['success'] == true) {
          var item = res['data'];
          propertyTypeList = (item != "NA") ? item : [];
          propertyTypeSearchList = (item != "NA") ? item : [];

          setState(() {
            isApiCalling = false;
          });
        } else {
          if (res['active_status'] == 0) {
            SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          }
          setState(() {
            isApiCalling = false;
          });
        }
      } else {
        print("Error: ${response.statusCode}");
        setState(() {
          isApiCalling = false;
        });
      }
    } catch (e) {
      print("Exception: $e");
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
    double screenWidth = MediaQuery.of(context).size.width;

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
                              AppLanguage.editpropertyText[language],
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
                        controller: propertyNameTextEditingController,
                        hintText: AppLanguage.enterPropertyNameText[language],
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
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        height: MediaQuery.of(context).size.height * 5.5 / 100,
                        child: TextFormField(
                          readOnly: true,
                          style: const TextStyle(
                              height: 1.1,
                              color: AppColor.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                          textAlignVertical: TextAlignVertical.center,
                          controller: propertytypeTextEditingController,
                          onTap: () {
                            dropDownModelForPropertyType(context, screenWidth);
                          },
                          decoration: InputDecoration(
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
                                  const EdgeInsets.symmetric(vertical: 10),
                              fillColor: Colors.transparent,
                              filled: true,
                              counterText: '',
                              hintText:
                                  "${AppLanguage.guardNationalityText[language]}*",
                              hintStyle: const TextStyle(
                                  color: AppColor.textColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16),
                              suffixIcon: IconButton(
                                icon: Container(
                                  alignment: language == 0
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  width: MediaQuery.of(context).size.width *
                                      20 /
                                      100,
                                  height: MediaQuery.of(context).size.width *
                                      5 /
                                      100,
                                  child: Image.asset(
                                    AppImage.dropDownIcon,
                                  ),
                                ),
                                onPressed: () {
                                  dropDownModelForPropertyType(
                                      context, screenWidth);
                                },
                              )),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),

                      //!=== Enter Boat Brand ===
                      CustomTextFormFieldBlackWidth(
                        controller: propertyaddressTextEditingController,
                        hintText:
                            AppLanguage.enterPropertyAddressText[language],
                        keyboardtype: TextInputType.text,
                        maxLength: 50,
                        fillColorStatus: 0,
                        readOnly: false,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                      ),

                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),

                      //!=== Enter Boat Size ==
                      CustomTextFormFieldBlackWidth(
                        controller: roomsTextEditingController,
                        hintText: AppLanguage.enterRoomsText[language],
                        keyboardtype: TextInputType.name,
                        maxLength: 50,
                        fillColorStatus: 0,
                        readOnly: false,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),

                      //!=== Enter Boat Capacity ===
                      CustomTextFormFieldBlackWidth(
                        controller: hallsTextEditingController,
                        hintText: AppLanguage.enterHallsText[language],
                        keyboardtype: TextInputType.name,
                        maxLength: 50,
                        fillColorStatus: 0,
                        readOnly: false,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),

                      CustomTextFormFieldBlackWidth(
                        controller: outdoorSeatingTextEditingController,
                        hintText: AppLanguage.enterOutdoorSeatingText[language],
                        keyboardtype: TextInputType.name,
                        maxLength: 50,
                        fillColorStatus: 0,
                        readOnly: false,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),

                      //!=== Enter Toilet ===
                      CustomTextFormFieldBlackWidth(
                        controller: washroomsTextEditingController,
                        hintText: AppLanguage.enterWashroomsText[language],
                        keyboardtype: TextInputType.name,
                        maxLength: 50,
                        fillColorStatus: 0,
                        readOnly: false,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),

                      //!=== Enter Toilet ===
                      CustomTextFormFieldBlackWidth(
                        controller: poolTextEditingController,
                        hintText: AppLanguage.enterPoolText[language],
                        keyboardtype: TextInputType.name,
                        maxLength: 50,
                        fillColorStatus: 0,
                        readOnly: false,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 6 / 100),

                      //!=== Add Boat Image Text ===

                      AppButton(
                          text: AppLanguage.submitText[language],
                          onPress: () {
                            validation();
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

  //---------------------SEARCH FUNCTION COUNTRY--------------------///
  searchResultCountry(String query) {
    print(query);

    var results1 = propertyTypeSearchList
        .where((value) => value['property_type_name'][language]
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    print("results1 $results1");

    propertyTypeList = [];

    propertyTypeList = results1;

    setState(() {});
  }

  void dropDownModelForPropertyType(BuildContext context, screenWidth) {
    showModalBottomSheet<void>(
      constraints: BoxConstraints.expand(width: screenWidth),
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      backgroundColor: AppColor.secondaryColor,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection:
                  language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              child: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: AppColor.secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        // SizedBox(
                        //   height: MediaQuery.of(context).size.height * 4 / 100,
                        // ),

                        AppHeaderOrange(
                            text: AppLanguage.propertyType[language],
                            onPress: () {
                              Navigator.pop(context);
                            }),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 4 / 100,
                        ),

                        // Search field
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          height:
                              MediaQuery.of(context).size.height * 6.5 / 100,
                          child: TextFormField(
                            style: const TextStyle(
                              height: 1.1,
                              color: AppColor.primaryColor,
                              fontFamily: AppFont.fontFamily,
                            ),
                            textAlignVertical: TextAlignVertical.center,
                            readOnly: false,
                            keyboardType: TextInputType.text,
                            controller: searchPropertyTypeTextEditingController,
                            maxLength: 50,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColor.boaderColor),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColor.boaderColor),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColor.themeColor),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                              ),
                              contentPadding:
                                  const EdgeInsets.only(right: 10, left: 10),
                              fillColor: Colors.white,
                              filled: true,
                              counterText: '',
                              hintText: AppLanguage.searchText[language],
                              hintStyle: AppConstant.textFilledStyle,
                            ),
                            onChanged: (input) {
                              setState(() {
                                if (input.isNotEmpty) {
                                  searchResultCountry(input);
                                } else {
                                  propertyTypeList = propertyTypeSearchList;
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        // List
                        Flexible(
                          child: ListView.builder(
                            itemCount: propertyTypeList.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        2 /
                                        100,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedPropertyType =
                                            propertyTypeList[index]
                                                ["property_type_id"];
                                        propertytypeTextEditingController.text =
                                            propertyTypeList[index]
                                                    ['property_type_name']
                                                [language];
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          90 /
                                          100,
                                      color: AppColor.secondaryColor,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            propertyTypeList[index]
                                                    ['property_type_name']
                                                [language],
                                            style: const TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 17,
                                              color: AppColor.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                5 /
                                                100,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                5 /
                                                100,
                                            child: selectedPropertyType ==
                                                    propertyTypeList[index]
                                                        ["property_type_id"]
                                                ? Image.asset(
                                                    AppImage.tickOrangeIcon,
                                                    fit: BoxFit.fill,
                                                  )
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        2 /
                                        100,
                                  ),
                                  if (index < propertyTypeList.length)
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          90 /
                                          100,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .2 /
                                              100,
                                      color: AppColor.textColor,
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
