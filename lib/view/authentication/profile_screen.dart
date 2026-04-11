import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:the_boat_ownerside/view/propertymodule/manage_property_screen.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_snack_bar_toast_message.dart';
import '../other_screen/manageBoatScreen.dart';
import '/view/other_screen/historyScreen.dart';
import '/view/other_screen/ratingScreen.dart';
import '/view/other_screen/walletScreen.dart';
import '/view/other_screen/manage_staff_screen.dart';
import '../../controller/app_footer.dart';
import '/view/authentication/setting_screen.dart';
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';
import 'login_screen.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  static String routeName = './ProfileScreen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenScreenState();
}

class _ProfileScreenScreenState extends State<ProfileScreen> {
  bool isApiCalling = false;
  int userId = 0;
  String fullName = "";
  String email = "";
  dynamic userDetails;
  dynamic userDataArr;
  String profileImage = "";
  String businessName = '';
  String merchantId = '';
  String username = '';
  var fileName = 'NA';
  double rating = 0;
  int viewWallet = 0;
  int viewHistory = 0;
  int viewBoat = 0;
  int manageBoat = 0;
  int viewProperty = 0;
  int manageProperty = 0;
  int userType = 0;
  dynamic permissions = {};
  String balance = "";

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  //----------------------------GET USER DETAILS--------------------------------//
  Future<dynamic> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    userDetails = prefs.getString("userDetails");

    print("userDetails $userDetails");
    if (userDetails == null) {
      // print("worked");
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.notRegisteredMsg[language]);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Login()));
    } else {
      userDataArr = jsonDecode(userDetails);
      userId = userDataArr['user_id'] ?? 0;
      fullName = userDataArr['fullname'] ?? "";
      username = userDataArr['username'] ?? "";
      profileImage = userDataArr["image"] ?? "NA";
      businessName = userDataArr["company_name"] ?? "";
      merchantId = userDataArr["merchant_id"] ?? "";
      rating = userDataArr["total_rating"].toDouble();
      log("rating80${rating.toStringAsFixed(0)}");
      userType = userDataArr["user_type"] ?? 0;
    }

    getWalletApi(userId);
    isApiCalling = false;
    profileApiCall(userId);
    setState(() {});
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

          log("permissions $permissions");

          viewWallet = permissions['view_my_wallet'] ?? 0;
          viewHistory = permissions['view_history'] ?? 0;
          viewBoat = permissions['view_boat'] ?? 0;
          manageBoat = permissions['manage_boat'] ?? 0;
          viewProperty = permissions['view_property'] ?? 0;
          manageProperty = permissions['manage_property'] ?? 0;
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

  //=============================GET Ratings DETAILS===================================//
  Future<void> getWalletApi(userId) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}get_wallet_details?user_id=$userId");
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
          balance = res['grandTotalAmount'].toString();
          setState(() {});
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
    double screenWidth = MediaQuery.of(context).size.width;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) => const MyFooterPage(indexOfPage: 0)),
          ),
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Directionality(
          textDirection:
              language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 100 / 100,
            child: Column(
              children: [
                //image header
                SizedBox(
                  // color: Colors.red,
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  height: screenWidth > 600
                      ? MediaQuery.of(context).size.height * 28 / 100
                      : MediaQuery.of(context).size.height * 30 / 100,
                  child: Stack(
                    children: [
                      //cover image
                      Container(
                        width: MediaQuery.of(context).size.width * 100 / 100,
                        height: screenWidth > 600
                            ? MediaQuery.of(context).size.height * 20 / 100
                            : MediaQuery.of(context).size.height * 20 / 100,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(AppImage.headerBgImage),
                                fit: BoxFit.cover),
                            // color: AppColor.themeColor,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(50),
                                bottomRight: Radius.circular(50))),
                        child: Column(
                          children: [
                            SizedBox(
                              height: AppConstant.deviceType == "ios"
                                  ? MediaQuery.of(context).size.height * 6 / 100
                                  : MediaQuery.of(context).size.height *
                                      4 /
                                      100,
                            ),

                            //profile edit setting
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  //edit
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      width: MediaQuery.of(context).size.width *
                                          10 /
                                          100,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              7 /
                                              100,
                                      // child: Image.asset(AppImage.editIcon),
                                    ),
                                  ),

                                  //profile
                                  Container(
                                    alignment: Alignment.center,
                                    width: MediaQuery.of(context).size.width *
                                        70 /
                                        100,
                                    child: Text(
                                      AppLanguage.profileText[language],
                                      style: const TextStyle(
                                          color: AppColor.secondaryColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: AppFont.fontFamily),
                                    ),
                                  ),

                                  //setting
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SettingScreen()));
                                    },
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      width: MediaQuery.of(context).size.width *
                                          10 /
                                          100,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              7 /
                                              100,
                                      child: Image.asset(AppImage.settingIcon),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 10 / 100,
                            ),
                          ],
                        ),
                      ),

                      //profile image
                      Positioned(
                        bottom: MediaQuery.of(context).size.height * 0.5 / 100,
                        left: MediaQuery.of(context).size.width * 35 / 100,
                        child: //profile image
                            Container(
                          width: MediaQuery.of(context).size.width * 30 / 100,
                          height: MediaQuery.of(context).size.width * 30 / 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width:
                                  MediaQuery.of(context).size.width * 30 / 100,
                              height:
                                  MediaQuery.of(context).size.width * 30 / 100,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: profileImage != 'NA'
                                  ? Image.network(
                                      "${AppConfigProvider.imageURL}$profileImage",
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          // Image has loaded
                                          return child;
                                        } else {
                                          // Image is still loading, show shimmer
                                          return Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor:
                                                Colors.grey.shade100,
                                            child: Container(
                                              color: Colors.grey.shade300,
                                            ),
                                          );
                                        }
                                      },
                                    )
                                  : Image.asset(
                                      AppImage.profilePlaceholderImage2,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        //name
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            businessName,
                            style: const TextStyle(
                                color: AppColor.primaryColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppFont.fontFamily),
                          ),
                        ),

                        //name
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            fullName,
                            style: const TextStyle(
                                color: AppColor.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppFont.fontFamily),
                          ),
                        ),

                        //name
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            username,
                            style: const TextStyle(
                                color: AppColor.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppFont.fontFamily),
                          ),
                        ),

                        //number
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            "#$merchantId",
                            style: const TextStyle(
                                color: AppColor.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFont.fontFamily),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //MY WALLET REVIEW
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //wallet button
                              GestureDetector(
                                onTap: () {
                                  if (userType == 3 ||
                                      (userType == 2 && viewWallet == 1)) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const WalletScreen(),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width *
                                      42 /
                                      100,
                                  decoration: BoxDecoration(
                                      color: AppColor.themeColor,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          (userType == 3 ||
                                                  (userType == 2 &&
                                                      viewWallet == 1))
                                              ? "KWD $balance"
                                              : "KWD 0",
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.secondaryColor,
                                              fontFamily: AppFont.fontFamily),
                                        ),
                                        Text(
                                          AppLanguage.myWalletText[language],
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.secondaryColor,
                                              fontFamily: AppFont.fontFamily),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              //review button
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RatingScreen()));
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width *
                                      42 /
                                      100,
                                  decoration: BoxDecoration(
                                      color: AppColor.themeColor,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "[${rating.toStringAsFixed(0)}]",
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      AppColor.secondaryColor,
                                                  fontFamily:
                                                      AppFont.fontFamily),
                                            ),
                                            RatingBarIndicator(
                                              rating: rating
                                                  .toDouble(), // Use your desired rating value here
                                              itemCount: 5,
                                              itemSize:
                                                  20, // Specify the size of each star
                                              unratedColor: AppColor.textColor,
                                              itemBuilder: (context, _) =>
                                                  const Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          AppLanguage.reviewText[language],
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.secondaryColor,
                                              fontFamily: AppFont.fontFamily),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        //manage boat
                        if (userType == 3 ||
                            (userType == 2 && viewBoat == 1) ||
                            (userType == 2 && manageBoat == 1))
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ManageBoatScreen()));
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 1,
                                          color: AppColor.boaderColor)),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        80 /
                                        100,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: Row(
                                        children: [
                                          //boat icon
                                          GestureDetector(
                                            child: Container(
                                              alignment: language == 1
                                                  ? Alignment.centerLeft
                                                  : Alignment.centerRight,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  10 /
                                                  100,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  7 /
                                                  100,
                                              child: Image.asset(
                                                  AppImage.floatingBoatIcon),
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                3 /
                                                100,
                                          ),

                                          //text
                                          Text(
                                            AppLanguage
                                                .manageBoatText[language],
                                            style: const TextStyle(
                                                color: AppColor.primaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: AppFont.fontFamily),
                                          ),
                                          const Spacer(),

                                          //next
                                          Container(
                                            alignment: language == 1
                                                ? Alignment.centerLeft
                                                : Alignment.centerRight,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                10 /
                                                100,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                5 /
                                                100,
                                            child: Image.asset(
                                                AppImage.semiCircleArrowIcon),
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
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),
                            ],
                          ),

                        if (userType == 3 ||
                            (userType == 2 && viewProperty == 1) ||
                            (userType == 2 && manageProperty == 1))
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ManagePropertyScreen()));
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 1,
                                          color: AppColor.boaderColor)),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        80 /
                                        100,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13.0),
                                      child: Row(
                                        children: [
                                          //setting icon
                                          GestureDetector(
                                            child: Container(
                                              alignment: language == 1
                                                  ? Alignment.centerLeft
                                                  : Alignment.centerRight,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  10 /
                                                  100,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  5 /
                                                  100,
                                              child: Image.asset(
                                                  AppImage.homeIcons),
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                3 /
                                                100,
                                          ),

                                          //text
                                          Text(
                                            AppLanguage
                                                .managePropertyText[language],
                                            style: const TextStyle(
                                                color: AppColor.primaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: AppFont.fontFamily),
                                          ),
                                          const Spacer(),

                                          //next
                                          Container(
                                            alignment: language == 1
                                                ? Alignment.centerLeft
                                                : Alignment.centerRight,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                10 /
                                                100,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                5 /
                                                100,
                                            child: Image.asset(
                                                AppImage.semiCircleArrowIcon),
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
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),
                            ],
                          ),

                        //manage staff
                        if (userType == 3)
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ManageStaffScreen()));
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 1,
                                          color: AppColor.boaderColor)),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        80 /
                                        100,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13.0),
                                      child: Row(
                                        children: [
                                          //setting icon
                                          GestureDetector(
                                            child: Container(
                                              alignment: language == 1
                                                  ? Alignment.centerLeft
                                                  : Alignment.centerRight,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  10 /
                                                  100,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  5 /
                                                  100,
                                              child: Image.asset(
                                                  AppImage.profileSettingIcon),
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                3 /
                                                100,
                                          ),

                                          //text
                                          Text(
                                            AppLanguage
                                                .manageYourStaffText[language],
                                            style: const TextStyle(
                                                color: AppColor.primaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: AppFont.fontFamily),
                                          ),
                                          const Spacer(),

                                          //next
                                          Container(
                                            alignment: language == 1
                                                ? Alignment.centerLeft
                                                : Alignment.centerRight,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                10 /
                                                100,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                5 /
                                                100,
                                            child: Image.asset(
                                                AppImage.semiCircleArrowIcon),
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
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),
                            ],
                          ),

                        //history
                        if (userType == 3 ||
                            (userType == 2 && viewHistory == 1))
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HistoryScreen()));
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 1,
                                          color: AppColor.boaderColor)),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        80 /
                                        100,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13.0),
                                      child: Row(
                                        children: [
                                          //history icon
                                          Container(
                                            alignment: language == 1
                                                ? Alignment.centerLeft
                                                : Alignment.centerRight,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                10 /
                                                100,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                4.5 /
                                                100,
                                            child:
                                                Image.asset(AppImage.resetIcon),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                3 /
                                                100,
                                          ),

                                          //text
                                          Text(
                                            AppLanguage.historyText[language],
                                            style: const TextStyle(
                                                color: AppColor.primaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: AppFont.fontFamily),
                                          ),
                                          const Spacer(),

                                          //next
                                          Container(
                                            alignment: language == 1
                                                ? Alignment.centerLeft
                                                : Alignment.centerRight,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                10 /
                                                100,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                5 /
                                                100,
                                            child: Image.asset(
                                                AppImage.semiCircleArrowIcon),
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
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
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
      ),
    );
  }
}
