import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_boat_ownerside/controller/app_footer.dart';
import 'package:the_boat_ownerside/controller/app_shimmers.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_snack_bar_toast_message.dart';
import '../authentication/login_screen.dart';
import '/view/other_screen/staffDetailsScreen.dart';
import '/view/other_screen/add_staff_screen.dart';
import '../../controller/app_image.dart';
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_header.dart';
import '../../controller/app_language.dart';
import '../../controller/app_loader.dart';
import 'dart:ui' as ui;

class ManageStaffScreen extends StatefulWidget {
  static String routeName = "./ManageStaffScreen";
  const ManageStaffScreen({super.key});

  @override
  State<ManageStaffScreen> createState() => _ContactAdminState();
}

class _ContactAdminState extends State<ManageStaffScreen> {
  TextEditingController searchCountryTextEditingController =
      TextEditingController();
  dynamic userDetails;
  dynamic userDataArr;
  int userId = 0;
  bool isApiCalling = false;
  bool isLoading = true;
  List<dynamic> staffList = <dynamic>[];
  List<dynamic> searchStaffList = <dynamic>[];

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

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
    getAllStaffApi(userId);
    setState(() {});
  }

  //=============================GET All Staff DETAILS===================================//
  Future<void> getAllStaffApi(userId) async {
    Uri url =
        Uri.parse("${AppConfigProvider.apiUrl}get_all_staff?owner_id=$userId");
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
          var item = res['staff_arr'];
          staffList = (item != "NA") ? item : [];
          searchStaffList = (item != "NA") ? item : [];

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

  //---------------------SEARCH FUNCTION COUNTRY--------------------//
  searchResultCountry(String query) {
    print(query);

    var results1 = searchStaffList
        .where((value) => value['fullname']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    print("results1 $results1");

    staffList = [];

    staffList = results1;

    setState(() {});
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
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
            body: Directionality(
          textDirection:
              language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Container(
              width: MediaQuery.of(context).size.width * 100 / 100,
              height: MediaQuery.of(context).size.height * 100 / 100,
              color: AppColor.secondaryColor,
              child: Column(children: [
                AppHeaderOrange(
                    text: AppLanguage.manageStaffText[language],
                    onPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyFooterPage(
                            indexOfPage: 4,
                          ),
                        ),
                      );
                    }),
                SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),

                //add bottom
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddStaffScreen(),
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
                              color: Color(0xffBEC3C7), // Shadow color
                              blurRadius: 2.0, // Blur intensity
                              offset: Offset(0, 5), // Moves shadow 5px down
                            ),
                          ],
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
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

                // Search field
                SizedBox(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  height: MediaQuery.of(context).size.height * 6 / 100,
                  child: TextFormField(
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.1,
                      color: AppColor.primaryColor,
                      fontFamily: AppFont.fontFamily,
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    readOnly: false,
                    keyboardType: TextInputType.text,
                    controller: searchCountryTextEditingController,
                    maxLength: 50,
                    decoration: InputDecoration(
                      prefixIcon: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: Image.asset(
                              AppImage.searchIcon,
                              width: screenWidth > 600
                                  ? MediaQuery.of(context).size.width * 3 / 100
                                  : MediaQuery.of(context).size.width * 5 / 100,
                              height: screenWidth > 600
                                  ? MediaQuery.of(context).size.width * 3 / 100
                                  : MediaQuery.of(context).size.width * 5 / 100,
                            ),
                          ),
                        ],
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColor.boaderColor),
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColor.boaderColor),
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColor.themeColor),
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      contentPadding:
                          const EdgeInsets.only(right: 10, left: 10),
                      fillColor: Colors.white,
                      filled: true,
                      counterText: '',
                      hintText: AppLanguage.searchText[language],
                      hintStyle: const TextStyle(
                          color: AppColor.boaderColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 16),
                    ),
                    onChanged: (input) {
                      setState(() {
                        if (input.isNotEmpty) {
                          searchResultCountry(input);
                        } else {
                          staffList = searchStaffList;
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),

                isLoading
                    ? staffShimmerEffect(context)
                    : Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              if (staffList.isNotEmpty)
                                Wrap(
                                  children: [
                                    ...List.generate(staffList.length, (index) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          //coupon card
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    3 /
                                                    100,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              StaffDetailsScreen(
                                                                userId: staffList[
                                                                            index]
                                                                        [
                                                                        'user_id']
                                                                    .toString(),
                                                              )));
                                                },
                                                child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            90 /
                                                            100,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 10,
                                                    ),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 1,
                                                          color: AppColor
                                                              .boaderColor),
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
                                                      color: AppColor
                                                          .secondaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              80 /
                                                              100,
                                                      child: Row(
                                                        children: [
                                                          //image
                                                          SizedBox(
                                                            width: screenWidth >
                                                                    600
                                                                ? MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    6 /
                                                                    100
                                                                : MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    10 /
                                                                    100,
                                                            height: screenWidth >
                                                                    600
                                                                ? MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    6 /
                                                                    100
                                                                : MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    10 /
                                                                    100,
                                                            child: Image.asset(
                                                              AppImage
                                                                  .avatarIcon,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                3 /
                                                                100,
                                                          ),

                                                          //left side
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                40 /
                                                                100,
                                                            child: Text(
                                                              staffList[index]
                                                                  ['fullname'],
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      screenWidth >
                                                                              600
                                                                          ? 20
                                                                          : 13,
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
                                                        ],
                                                      ),
                                                    )),
                                              ),
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
                                                2 /
                                                100,
                                          )
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              if (staffList.isEmpty)
                                Column(
                                  children: [
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                20 /
                                                100),
                                    //!text msg
                                    SizedBox(
                                      width: screenWidth * 80 / 100,
                                      child: Text(
                                        AppLanguage.staffNodataMsg[language],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColor.primaryColor),
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      5 /
                                      100),
                            ],
                          ),
                        ),
                      ),
                const NoInternetBanner(),
              ])),
        )),
      ),
    );
  }
}
