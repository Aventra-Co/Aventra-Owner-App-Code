import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_loader.dart';
import '../../utilities/app_shimmers.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '/view/other_screen/advertisementScreen.dart';
import '/view/other_screen/edit_advertisement.dart';
import '/view/other_screen/add_advertisement_screen.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_footer.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import 'dart:ui' as ui;
import 'login_screen.dart';

class MyAdsScreen extends StatefulWidget {
  static String routeName = './MyAdsScreen';
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenScreenState();
}

class _MyAdsScreenScreenState extends State<MyAdsScreen> {
  TextEditingController searchTextController = TextEditingController();
  List optionsList = [
    {"id": 1, "title": AppLanguage.editText[language]},
    {"id": 2, "title": AppLanguage.deleteText[language]},
    {"id": 3, "title": AppLanguage.backText[language]}
  ];
  bool isApiCalling = false;
  bool isLoading = true;
  List<dynamic> tripList = [];
  List<dynamic> searchTripList = [];
  int viewMyAdd = 0;
  int manageMyAd = 0;
  int userType = 0;
  dynamic permissions = {};

// "chat":1,"view_unavailability":0,"manage_unavailability":1,

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

    // print("userDetails $userDetails");
    if (userDetails != null) {
      dynamic data = json.decode(userDetails);
      print("up $data");
      userId = data['user_id'];
      userType = data['user_type'] ?? 0;
    }
    profileApiCall(userId);
    setState(() {});
  }

  //------------------------View Profile API CALL--------------------------------//
  Future<void> profileApiCall(userId) async {
    setState(() {
      isLoading = true;
    });
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

          viewMyAdd = permissions['view_my_add'] ?? 0;
          manageMyAd = permissions['manage_my_add'] ?? 0;

          if (userType == 3 ||
              (userType == 2 && manageMyAd == 1) ||
              (userType == 2 && viewMyAdd == 1)) {
            getAllTripsApi(userId);
          } else {
            setState(() {
              isApiCalling = false;
              isLoading = false;
            });
          }
        } else {
          setState(() {
            isApiCalling = false;
            isLoading = false;
          });
          // ignore: use_build_context_synchronously
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          if (res['active_status'] == 0) {
            localstorageclearbutton();
          }
        }
      } else {
        setState(() {
          isApiCalling = false;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isApiCalling = false;
        isLoading = false;
      });
    }
  }

  //-----------------Sign Out-----------------------
  localstorageclearbutton() async {
    final prefs = await SharedPreferences.getInstance();
    print("prefs =================>$prefs");
    prefs.remove('userDetails');
    prefs.remove('password');

    log("Worked");

    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  //=============================GET Boat DETAILS===================================//
  Future<void> getAllTripsApi(userId) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}get_all_trips?user_id=$userId&user_type=$userType");
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
          var item = res['trip_arr'];
          tripList = (item != "NA") ? item : [];
          searchTripList = (item != "NA") ? item : [];

          setState(() {
            isApiCalling = false;
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
            isApiCalling = false;
            isLoading = false;
          });
        }
      } else {
        print("Error: ${response.statusCode}");
        setState(() {
          isApiCalling = false;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        isApiCalling = false;
        isLoading = false;
      });
    }
  }

  //=============================Delete Boat DETAILS===================================//
  deleteAdApiCall(tripId) async {
    setState(() {
      isApiCalling = true;
    });

    Uri url = Uri.parse("${AppConfigProvider.apiUrl}delete_trip");

    print("Url===> $url");

    try {
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.fields['trip_id'] = tripId.toString();

      log("response--==> ${formData.fields}");
      // print("response--==> ${formData.files}");
      http.StreamedResponse response = await formData.send();
      print("response--==> $response");
      var responseString = await response.stream.toBytes();
      var res = jsonDecode(utf8.decode(responseString));

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          getAllTripsApi(userId);
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

  //---------------------SEARCH FUNCTION Trips--------------------///
  searchResultCountry(String query) {
    print(query);

    var results1 = searchTripList
        .where((value) => value['boat_name_english']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    print("results1 $results1");

    tripList = [];

    tripList = results1;

    setState(() {});
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
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: AppColor.secondaryColor,
          body: Directionality(
            textDirection:
                language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            child: RefreshIndicator(
              onRefresh: _refreshPage,
              color: AppColor.themeColor,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 100 / 100,
                height: MediaQuery.of(context).size.height * 100 / 100,
                child: Column(
                  children: [
                    //image header
                    Container(
                      width: MediaQuery.of(context).size.width * 100 / 100,
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
                                : MediaQuery.of(context).size.height * 4 / 100,
                          ),

                          //manage text
                          Container(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            alignment: Alignment.center,
                            child: Text(
                              AppLanguage.manageAdvText[language],
                              style: const TextStyle(
                                  color: AppColor.secondaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFont.fontFamily),
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 3 / 100,
                          ),

                          //search field
                          if (userType == 3 ||
                              (userType == 2 && viewMyAdd == 1))
                            Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    90 /
                                    100,
                                height: MediaQuery.of(context).size.height *
                                    7 /
                                    100,
                                child: TextFormField(
                                  readOnly: false,
                                  style: const TextStyle(
                                      height: 1.1,
                                      color: AppColor.textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.text,
                                  controller: searchTextController,
                                  maxLength: AppConstant.searchLength,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value.isNotEmpty) {
                                        searchResultCountry(value);
                                      } else {
                                        tripList = searchTripList;
                                      }
                                    });
                                  },
                                  decoration: InputDecoration(
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColor.boaderColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColor.boaderColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColor.themeColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 15),
                                      fillColor: AppColor.secondaryColor,
                                      filled: true,
                                      counterText: '',
                                      hintText:
                                          AppLanguage.searchHereText[language],
                                      hintStyle: const TextStyle(
                                          color: AppColor.textColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16)),
                                ),
                              ),
                            ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100,
                          ),

                          //add adv
                          if (userType == 3 ||
                              (userType == 2 && manageMyAd == 1))
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AddAdvertisementScreen()));
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width *
                                    60 /
                                    100,
                                decoration: BoxDecoration(
                                    color: AppColor.themeColor,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenWidth > 600 ? 15 : 8.0),
                                  child: Text(
                                    AppLanguage.addAdvText[language],
                                    style: TextStyle(
                                        fontSize: screenWidth > 600 ? 20 : 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColor.secondaryColor,
                                        fontFamily: AppFont.fontFamily),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 3 / 100,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100),

                    isLoading
                        ? myAdsShimmerEffect(context)
                        : Expanded(
                            child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                if (tripList.isNotEmpty)
                                  Wrap(
                                    children: [
                                      ...List.generate(tripList.length,
                                          (index) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            //coupon card
                                            Stack(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AdvertisementScreen(
                                                          tripId: tripList[
                                                                      index]
                                                                  ['trip_id']
                                                              .toString(),
                                                        ),
                                                      ),
                                                    );
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
                                                      vertical: 5,
                                                    ),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      image: DecorationImage(
                                                        image: tripList[index][
                                                                    'trip_image'] !=
                                                                null
                                                            ? NetworkImage(
                                                                "${AppConfigProvider.imageURL}${tripList[index]['trip_image']}")
                                                            : const AssetImage(
                                                                    AppImage
                                                                        .imageFrame)
                                                                as ImageProvider,
                                                        fit: BoxFit.cover,
                                                        colorFilter:
                                                            ColorFilter.mode(
                                                          Colors.black.withOpacity(
                                                              0.3), // Adjust the opacity
                                                          BlendMode
                                                              .darken, // You can change the BlendMode if needed
                                                        ),
                                                      ),
                                                    ),

                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              1 /
                                                              100,
                                                        ),

                                                        //3 options
                                                        (userType == 3 ||
                                                                (userType ==
                                                                        2 &&
                                                                    manageMyAd ==
                                                                        1))
                                                            ? SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    80 /
                                                                    100,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        optionsBottomSheet(
                                                                            context,
                                                                            screenWidth,
                                                                            tripList[index]['trip_id']);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width: screenWidth >
                                                                                600
                                                                            ? MediaQuery.of(context).size.width *
                                                                                5 /
                                                                                100
                                                                            : MediaQuery.of(context).size.width *
                                                                                6 /
                                                                                100,
                                                                        height: screenWidth >
                                                                                600
                                                                            ? MediaQuery.of(context).size.width *
                                                                                5 /
                                                                                100
                                                                            : MediaQuery.of(context).size.width *
                                                                                6 /
                                                                                100,
                                                                        decoration: const BoxDecoration(
                                                                            color:
                                                                                AppColor.secondaryColor,
                                                                            shape: BoxShape.circle),
                                                                        child: Image
                                                                            .asset(
                                                                          AppImage
                                                                              .menuCircle,
                                                                          color:
                                                                              AppColor.themeColor,
                                                                          fit: BoxFit
                                                                              .contain,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            : SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    80 /
                                                                    100,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    3 /
                                                                    100,
                                                              ),
                                                        SizedBox(
                                                          height: screenWidth >
                                                                  600
                                                              ? MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  9 /
                                                                  100
                                                              : MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  2 /
                                                                  100,
                                                        ),

                                                        //text
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              80 /
                                                              100,
                                                          child: Text(
                                                            tripList[index][
                                                                'boat_name_english'],
                                                            style: const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: AppColor
                                                                    .secondaryColor,
                                                                fontFamily: AppFont
                                                                    .fontFamily),
                                                          ),
                                                        ),

                                                        //text3
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              80 /
                                                              100,
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                AppLanguage
                                                                        .pickUpText[
                                                                    language],
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: AppColor
                                                                        .secondaryColor,
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontFamily),
                                                              ),
                                                              const Text(
                                                                " \u2022 ",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: AppColor
                                                                        .secondaryColor,
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontFamily),
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    63 /
                                                                    100,
                                                                child: Text(
                                                                  "${tripList[index]['city_name'][language] ?? ""}",
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: AppColor
                                                                          .secondaryColor,
                                                                      fontFamily:
                                                                          AppFont
                                                                              .fontFamily),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        //text3
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              80 /
                                                              100,
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                AppLanguage
                                                                        .advTypeText[
                                                                    language],
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: AppColor
                                                                        .secondaryColor,
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontFamily),
                                                              ),
                                                              const Text(
                                                                " \u2022 ",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: AppColor
                                                                        .secondaryColor,
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontFamily),
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    63 /
                                                                    100,
                                                                child: Text(
                                                                  tripList[index]
                                                                              [
                                                                              'advertisement_type'] ==
                                                                          0
                                                                      ? AppLanguage
                                                                              .privateText[
                                                                          language]
                                                                      : AppLanguage
                                                                              .publicText[
                                                                          language],
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: AppColor
                                                                          .secondaryColor,
                                                                      fontFamily:
                                                                          AppFont
                                                                              .fontFamily),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        //rating member button
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              80 /
                                                              100,
                                                          child: Row(
                                                            children: [
                                                              //ratings
                                                              if (tripList[index]
                                                                          [
                                                                          'rating']
                                                                      .toString() !=
                                                                  "0.00")
                                                                Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  decoration: BoxDecoration(
                                                                      color: AppColor
                                                                          .secondaryColor
                                                                          .withOpacity(
                                                                              .4),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20)),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            8.0,
                                                                        vertical:
                                                                            2),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        SizedBox(
                                                                          width: screenWidth > 600
                                                                              ? MediaQuery.of(context).size.width * 2 / 100
                                                                              : MediaQuery.of(context).size.width * 3 / 100,
                                                                          height: screenWidth > 600
                                                                              ? MediaQuery.of(context).size.width * 2 / 100
                                                                              : MediaQuery.of(context).size.width * 3 / 100,
                                                                          child:
                                                                              Image.asset(AppImage.starIcon),
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              1 /
                                                                              100,
                                                                        ),
                                                                        Text(
                                                                          tripList[index]['rating']
                                                                              .toString(),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: AppColor.secondaryColor,
                                                                              fontFamily: AppFont.fontFamily),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    2 /
                                                                    100,
                                                              ),

                                                              //members
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    23 /
                                                                    100,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: BoxDecoration(
                                                                    color: AppColor
                                                                        .secondaryColor
                                                                        .withOpacity(
                                                                            .4),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20)),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8.0,
                                                                      vertical:
                                                                          2),
                                                                  child: Text(
                                                                    "${tripList[index]['max_people']}  ${AppLanguage.membersText[language]}",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: AppColor
                                                                            .secondaryColor,
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
                                                                    2 /
                                                                    100,
                                                              ),

                                                              const Spacer(),

                                                              //speed
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                    color: AppColor
                                                                        .themeColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5)),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8.0,
                                                                      vertical:
                                                                          4),
                                                                  child: Text(
                                                                    "${tripList[index]['price_per_hour']} KWD",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: AppColor
                                                                            .secondaryColor,
                                                                        fontFamily:
                                                                            AppFont.fontFamily),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              2 /
                                                              100,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                if (tripList[index]
                                                            ['discount'] !=
                                                        null &&
                                                    tripList[index]
                                                            ['discount'] >
                                                        0) ...[
                                                  Positioned(
                                                    top: language == 0
                                                        ? -30
                                                        : -30,
                                                    left: language == 0
                                                        ? -22
                                                        : null,
                                                    right: language == 1
                                                        ? -22
                                                        : null,
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              30 /
                                                              100,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              15 /
                                                              100,
                                                      child: Image.asset(
                                                          language == 0
                                                              ? AppImage
                                                                  .discountStrip
                                                              : AppImage
                                                                  .discountStripInverted),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top:
                                                        language == 0 ? 15 : 14,
                                                    left: language == 0
                                                        ? -25
                                                        : null,
                                                    right: language == 1
                                                        ? -25
                                                        : null,
                                                    child: Transform.rotate(
                                                      angle: language == 0
                                                          ? -.65
                                                          : .65,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        // color: Colors.red,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            30 /
                                                            100,
                                                        child: Text(
                                                          "${tripList[index]['discount']}% ${AppLanguage.offText[language]}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: const TextStyle(
                                                              fontFamily: AppFont
                                                                  .fontFamily,
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color: AppColor
                                                                  .secondaryColor),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ]
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
                                if (tripList.isEmpty)
                                  Column(
                                    children: [
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              20 /
                                              100),
                                      //!text msg
                                      SizedBox(
                                        width: screenWidth * 70 / 100,
                                        child: Text(
                                          AppLanguage.advNodataMsg[language],
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
                              ],
                            ),
                          )),
                    const NoInternetBanner(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

//=====================options bottomsheet===============
  void optionsBottomSheet(
      BuildContext context, double screenWidth, int tripId) {
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
                            separatorBuilder: (context, index) => const Divider(
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
                                            EditAdvertisementScreen(
                                          tripId: tripId.toString(),
                                        ),
                                      ),
                                    );
                                  } else if (optionsList[index]['id'] == 2) {
                                    deleteBottomSheet(context, screenWidth,
                                        tripId.toString());
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

//=====================Delete bottomsheet===============
  void deleteBottomSheet(BuildContext context, screenWidth, tripId) {
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
                                AppLanguage.deleteMsg[language],
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
                                      deleteAdApiCall(tripId);
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
