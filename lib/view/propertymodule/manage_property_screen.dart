import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_boat_ownerside/view/propertymodule/add_property_screen.dart';
import 'package:the_boat_ownerside/view/propertymodule/edit_property_screen.dart';
import '../../controller/app_color.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_footer.dart';
import '../../controller/app_header.dart';
import '../../controller/app_language.dart';
import '../../controller/app_loader.dart';
import '../../controller/app_shimmers.dart';
import '../../controller/app_snack_bar_toast_message.dart';
import '../../controller/route_observer.dart';
import 'package:http/http.dart' as http;

import '../authentication/login_screen.dart';

class ManagePropertyScreen extends StatefulWidget {
  const ManagePropertyScreen({super.key});

  @override
  State<ManagePropertyScreen> createState() => _ManagePropertyScreenState();
}

class _ManagePropertyScreenState extends State<ManagePropertyScreen>
    with RouteAware {
  List optionsList = [
    {"id": 1, "title": AppLanguage.editText[language]},
    {"id": 2, "title": AppLanguage.deleteText[language]},
    {"id": 3, "title": AppLanguage.backText[language]}
  ];
  bool isApiCalling = true;
  bool isLoading = true;
  List<dynamic> propertyList = [];

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  int userId = 0;
  dynamic userDetails;
  int userType = 0;
  dynamic permissions = {};
  int manageProperty = 0;

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
    getPropertiesApi(userId, true);
    profileApiCall(userId);
    setState(() {});
  }

  //=============================GET Boat DETAILS===================================//
  Future<void> getPropertiesApi(userId, bool isLoad) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}get_all_owner_properties?user_id=$userId&type=$userType");
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
      isLoading = isLoad;
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
          propertyList = (item != "NA") ? item : [];

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
          manageProperty = permissions['manage_boat'] ?? 0;
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
  deletePropertyApiCall(propertyId) async {
    setState(() {
      isApiCalling = true;
    });

    Uri url = Uri.parse("${AppConfigProvider.apiUrl}delete_property");

    print("Url===> $url");

    try {
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.fields['property_id'] = propertyId.toString();

      log("response--==> ${formData.fields}");
      // print("response--==> ${formData.files}");
      http.StreamedResponse response = await formData.send();
      print("response--==> $response");
      var responseString = await response.stream.toBytes();
      var res = jsonDecode(utf8.decode(responseString));

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          getPropertiesApi(userId, true);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void didPopNext() {
    getPropertiesApi(userId, false);
  }

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  //--------------------REFRESH FUNCION-----------------------//
  Future<Null> _refreshPage() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(const Duration(seconds: 1));
    // getTopStories(0);
    getUserDetails();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
        inAsyncCall: isApiCalling,
        opacity: 0.5,
        child: _buildUIScreen(context));
  }

  Widget _buildUIScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        color: AppColor.themeColor,
        child: Column(
          children: [
            AppHeaderOrange(
                text: AppLanguage.managePropertyText[language],
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

            SizedBox(height: size.height * 0.03),

            /// ADD BUTTON
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddPropertyScreen())),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.themeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: size.width * 0.01),
                        Text(
                          AppLanguage.addText[language],
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.02),

            /// PROPERTY LIST
            isLoading
                ? boatsShimmerEffect(context)
                : Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                      ),
                      children: [
                        /// FIRST PROPERTY
                        ///
                        Wrap(
                          children: List.generate(
                            propertyList.length,
                            (index) {
                              return Container(
                                margin: EdgeInsets.only(
                                  bottom: size.height * 0.02,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04,
                                  vertical: size.height * 0.02,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            propertyList[index]
                                                    ['property_name_english'] ??
                                                "",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.primaryColor,
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.005),
                                          Text(
                                            propertyList[index]
                                                    ['property_type_name'] ??
                                                "",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => optionsBottomSheet(
                                          context,
                                          screenWidth,
                                          propertyList[index]['property_id'],
                                          propertyList[index]),
                                      child: const Icon(
                                        Icons.more_vert,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  //======================Delete Account Bottomsheet=============
  void _deleteAlertBottomSheet(
      BuildContext context, screenWidth, int propertyId) {
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
                            )),

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
                                AppLanguage.deletePropertyText[language],
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
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 75 / 100,
                              child: Text(
                                AppLanguage.areYousureyouwantText[language],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: AppFont.fontFamily,
                                    color: AppColor.primaryColor),
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
                                        AppLanguage.backButtonText[language],
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
                                      Navigator.pop(context);
                                      deletePropertyApiCall(propertyId);
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
                                          // Border property
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

  void optionsBottomSheet(
    BuildContext context,
    double screenWidth,
    int propertyId,
    dynamic propertyDetails,
  ) {
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
            double itemHeight = 50;
            double maxHeight = MediaQuery.of(context).size.height * 0.5;
            double calculatedHeight = (optionsList.length * itemHeight) + 40;
            double bottomSheetHeight =
                calculatedHeight < maxHeight ? calculatedHeight : maxHeight;
            return GestureDetector(
              onTap: () => Navigator.pop(context), // ✅ background tap se close
              child: Container(
                width: screenWidth,
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: GestureDetector(
                    onTap:
                        () {}, // ✅ inner container tap propagation rokne ke liye
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              itemCount: optionsList.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                color: AppColor.boaderColor,
                                thickness: 1,
                                height: 10,
                              ),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    if (optionsList[index]['id'] == 3) {
                                      Navigator.pop(context);
                                    } else if (optionsList[index]['id'] == 2) {
                                      Navigator.pop(context);
                                      _deleteAlertBottomSheet(
                                          context, screenWidth, propertyId);
                                    } else if (optionsList[index]['id'] == 1) {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditPropertyScreen(
                                            propertyDetails: propertyDetails,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    width: screenWidth * 0.85,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
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
              ),
            );
          },
        );
      },
    );
  }
}
