import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_boat_ownerside/utilities/app_footer.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_loader.dart';
import '../../utilities/app_shimmers.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../authentication/login_screen.dart';
import '/utilities/app_header.dart';
import 'edit_boat_details_screen.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import 'addBoatScreen.dart';

class ChooseBoatScreen extends StatefulWidget {
  static String routeName = './WalletScreen';
  const ChooseBoatScreen({super.key});

  @override
  State<ChooseBoatScreen> createState() => _ChooseBoatScreenState();
}

class _ChooseBoatScreenState extends State<ChooseBoatScreen> {
  bool isApiCalling = false;
  bool isLoading = true;
  List<dynamic> boatList = [];
  List optionsList = [
    {"id": 1, "title": AppLanguage.editText[language]},
    {"id": 2, "title": AppLanguage.deleteText[language]},
    {"id": 3, "title": AppLanguage.backText[language]}
  ];

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  int userId = 0;
  dynamic userDetails;
  int manageBoat = 0;
  int userType = 0;
  dynamic permissions = {};

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
      userType = data["user_type"] ?? 0;
    }
    setState(() {
      isApiCalling = false;
    });
    getBoatsApi(userId);
    profileApiCall(userId);
    setState(() {});
  }

  //=============================GET Boat DETAILS===================================//
  Future<void> getBoatsApi(userId) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}fetch_all_boats?owner_id=$userId&type=$userType");
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
      isLoading = true;
    });

    print("headers $headers");

    try {
      final response = await http.get(url, headers: headers);
      print("response $response");

      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);
        print("res $res");

        if (res['success'] == true) {
          var item = res['boat_arr'];
          boatList = (item != "NA") ? item : [];

          setState(() {
            isLoading = false;
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
            isLoading = false;
          });
        }
      } else {
        print("Error: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  //------------------------View Profile API CALL--------------------------------//
  Future<void> profileApiCall(userId) async {
    Uri url =
        Uri.parse("${AppConfigProvider.apiUrl}view_profile?user_id=$userId");
    print("url $url");

    String token = AppConstant.token;

    if (token.isEmpty) {
      print("Token is missing!");
      // return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token', // Use 'Bearer' if required
    };

    print("headers $headers");

    try {
      final response = await http.get(url, headers: headers);
      print("response $response");

      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);
        print("res $res");

        if (res['success'] == true) {
          var item = res['user_arr'];
          permissions = (item != "NA") ? item : {};
          manageBoat = permissions['manage_boat'] ?? 0;
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

  //=============================Delete Boat DETAILS===================================//
  deleteBoatApiCall(boatId) async {
    setState(() {
      isApiCalling = true;
    });

    Uri url = Uri.parse("${AppConfigProvider.apiUrl}delete_boat");

    print("Url===> $url");

    try {
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.fields['boat_id'] = boatId.toString();

      log("response--==> ${formData.fields}");
      // print("response--==> ${formData.files}");
      http.StreamedResponse response = await formData.send();
      print("response--==> $response");
      var responseString = await response.stream.toBytes();
      var res = jsonDecode(utf8.decode(responseString));

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          getBoatsApi(userId);
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
    double screenWidth = MediaQuery.of(context).size.width;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return WillPopScope(
      onWillPop: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MyFooterPage(
              indexOfPage: 4,
            ),
          ),
        );
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: AppColor.secondaryColor,
        body: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          child: Column(
            children: [
              AppHeaderOrange(
                  text: AppLanguage.chooseBoatText[language],
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyFooterPage(
                          indexOfPage: 4,
                        ),
                      ),
                    );
                    return Future.value(false);
                  }),
              SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),

              //add bottom
              if (userType == 3 || (userType == 2 && manageBoat == 1))
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddBoatScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 90 / 100,
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 20 / 100,
                      decoration: BoxDecoration(
                          color: AppColor.themeColor,
                          boxShadow: const [
                            BoxShadow(
                              color: AppColor.textLightColor, // Shadow color
                              blurRadius: 3.0, // Blur intensity
                              offset: Offset(0, 5), // Moves shadow 5px down
                            ),
                          ],
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: screenWidth > 600
                                  ? MediaQuery.of(context).size.width * 4 / 100
                                  : MediaQuery.of(context).size.width * 5 / 100,
                              height: screenWidth > 600
                                  ? MediaQuery.of(context).size.width * 4 / 100
                                  : MediaQuery.of(context).size.width * 5 / 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.asset(
                                  AppImage.addIcon,
                                  color: AppColor.secondaryColor,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 1 / 100,
                            ),
                            Text(
                              AppLanguage.addText[language],
                              style: const TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.secondaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 3 / 100,
              ),

              isLoading
                  ? boatsShimmerEffect(context)
                  : Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (boatList.isNotEmpty)
                              Wrap(
                                children: [
                                  ...List.generate(boatList.length, (index) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        //coupon card
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  3 /
                                                  100,
                                            ),
                                            Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    90 /
                                                    100,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 1,
                                                      color:
                                                          AppColor.boaderColor),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: AppColor
                                                          .textLightColor, // Shadow color
                                                      blurRadius:
                                                          2.0, // Blur intensity
                                                      offset: Offset(0,
                                                          5), // Moves shadow 5px down
                                                    ),
                                                  ], //BoxShadow
                                                  color:
                                                      AppColor.secondaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 6.0),
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            80 /
                                                            100,
                                                    child: Row(
                                                      children: [
                                                        //left side
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              45 /
                                                              100,
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    45 /
                                                                    100,
                                                                child: Text(
                                                                  "${AppLanguage.yearText[language]}-${boatList[index]['boat_year'].toString()}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: AppColor
                                                                          .primaryColor,
                                                                      fontFamily:
                                                                          AppFont
                                                                              .fontFamily),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    45 /
                                                                    100,
                                                                child: Text(
                                                                  "${AppLanguage.capacityText[language]}-${boatList[index]['boat_capacity']}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: AppColor
                                                                          .primaryColor,
                                                                      fontFamily:
                                                                          AppFont
                                                                              .fontFamily),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        //right side
                                                        Container(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              35 /
                                                              100,
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    26 /
                                                                    100,
                                                                // color: Colors.black,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              2.0),
                                                                  child: Text(
                                                                    boatList[index]
                                                                            [
                                                                            'boat_name_english'] ??
                                                                        "",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: AppColor
                                                                            .primaryColor,
                                                                        fontFamily:
                                                                            AppFont.fontFamily),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    4 /
                                                                    100,
                                                              ),
                                                              if (userType ==
                                                                      3 ||
                                                                  (userType ==
                                                                          2 &&
                                                                      manageBoat ==
                                                                          1))
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    optionsBottomSheet(
                                                                        context,
                                                                        screenWidth,
                                                                        index);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        5 /
                                                                        100,
                                                                    child: Image
                                                                        .asset(
                                                                      AppImage
                                                                          .threeDotIcon,
                                                                      color: AppColor
                                                                          .primaryColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  3 /
                                                  100,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              3 /
                                              100,
                                        )
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            if (boatList.isEmpty)
                              Column(
                                children: [
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              20 /
                                              100),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        20 /
                                        100,
                                    height: MediaQuery.of(context).size.width *
                                        20 /
                                        100,
                                    child: Image.asset(
                                      AppImage.noDataIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
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
    );
  }

//=====================options bottomsheet===============
  void optionsBottomSheet(
      BuildContext context, double screenWidth, int boatIndex) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      constraints: BoxConstraints.expand(width: screenWidth),
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double itemHeight = 50; // Approximate height of each item
            double maxHeight = MediaQuery.of(context).size.height * 0.5;
            double calculatedHeight = (optionsList.length * itemHeight) + 40;
            double bottomSheetHeight =
                calculatedHeight < maxHeight ? calculatedHeight : maxHeight;

            return GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: screenWidth,
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    width: screenWidth * 0.85,
                    constraints: BoxConstraints(
                      maxHeight: bottomSheetHeight,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColor.secondaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      // Ensures no overflow
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Prevent overflow
                        children: [
                          ListView.separated(
                            shrinkWrap:
                                true, // Prevents unnecessary space usage
                            physics:
                                const NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: optionsList.length,
                            separatorBuilder: (context, index) => Divider(
                              color: AppColor.boaderColor,
                              thickness: 1,
                              height: 10,
                            ),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  if (optionsList[index]['id'] == 1) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditBoatDetailsScreen(
                                          boatId: boatList[boatIndex]['boat_id']
                                              .toString(),
                                          boatName: boatList[boatIndex]
                                              ['boat_name_english'],
                                          registration: boatList[boatIndex]
                                              ['boat_registration_number'],
                                          year: boatList[boatIndex]['boat_year']
                                              .toString(),
                                          size: boatList[boatIndex]['boat_size']
                                              .toString(),
                                          capacity: boatList[boatIndex]
                                                  ['boat_capacity']
                                              .toString(),
                                          cabin: boatList[boatIndex]['cabins']
                                              .toString(),
                                          toilet: boatList[boatIndex]['toilet']
                                              .toString(),
                                          boatBrand: boatList[boatIndex]
                                                  ['boat_brand'] ??
                                              "",
                                        ),
                                      ),
                                    );
                                  } else if (optionsList[index]['id'] == 2) {
                                    deleteBoatBottomSheet(
                                        context,
                                        screenWidth,
                                        boatList[boatIndex]['boat_id']
                                            .toString());
                                  }
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  width: screenWidth * 0.85,
                                  alignment: Alignment.center,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    optionsList[index]['title'],
                                    style: const TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 17,
                                      color: AppColor.textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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

//=====================delete bottomsheet===============
  void deleteBoatBottomSheet(BuildContext context, screenWidth, boatId) {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        constraints: BoxConstraints.expand(width: screenWidth),
        enableDrag: false,
        isDismissible: false,
        backgroundColor: AppColor.primaryColor.withOpacity(0.1),
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: ((context, setState) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 100 / 100,
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  color: AppColor.primaryColor.withOpacity(0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        // height: MediaQuery.of(context).size.height * 31 / 100,
                        width: MediaQuery.of(context).size.width * 85 / 100,
                        // color: Colors.red,
                        decoration: const BoxDecoration(
                          color: AppColor.secondaryColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.width * 10 / 100,
                            ),
                          
                            Container(
                              //color: Colors.amber,
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 55 / 100,
                              child: Text(
                                AppLanguage.deleteText[language],
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppFont.fontFamily),
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100),
                            Container(
                              //color: Colors.amber,
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 75 / 100,
                              child: Text(
                                AppLanguage.deleteBoatMsg[language],
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppFont.fontFamily),
                              ),
                            ),

                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 4 / 100,
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 65 / 100,
                              height:
                                  MediaQuery.of(context).size.width * 13 / 100,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width *
                                          30 /
                                          100,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              5 /
                                              100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        //color: Colors.red,
                                        border: Border.all(
                                          color: AppColor.primaryColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        AppLanguage.cancelText[language],
                                        style: const TextStyle(
                                            color: AppColor.primaryColor,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      deleteBoatApiCall(boatId);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width *
                                          30 /
                                          100,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              5 /
                                              100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: AppColor.themeColor,
                                        border: Border.all(
                                          color: AppColor.themeColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        AppLanguage.yesText[language],
                                        style: const TextStyle(
                                            color: AppColor.secondaryColor,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 6 / 100,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }
}
