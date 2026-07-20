import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_boat_ownerside/view/propertymodule/add_advertisement_section_screen.dart';
import 'package:the_boat_ownerside/view/propertymodule/edit_advertisement_property_screen.dart';
import 'package:the_boat_ownerside/view/propertymodule/property_advertisement_screen.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_loader.dart';
import '../../controller/app_shimmers.dart';
import '../../controller/app_snack_bar_toast_message.dart';
// import '../propertymodule/property_list_screen.dart';
import '/view/other_screen/advertisementScreen.dart';
import '/view/other_screen/edit_advertisement.dart';
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_footer.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';
import 'dart:ui' as ui;
import 'login_screen.dart';
import '../../widgets/trip_ad_card.dart';

class MyAdsScreen extends StatefulWidget {
  final int status;
  static String routeName = './MyAdsScreen';
  const MyAdsScreen({super.key, this.status = 1});

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
  List<dynamic> propertyList = [];
  List<dynamic> searchPropertyList = [];
  int viewMyAdd = 0;
  int manageMyAd = 0;
  int userType = 0;
  dynamic permissions = {};

// "chat":1,"view_unavailability":0,"manage_unavailability":1,

  @override
  void initState() {
    super.initState();
    getUserDetails();
    status = widget.status;
  }

  int status = 1;
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
            getAllAdvertisementApi(userId);
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
          tripList = (item != "NA")
              ? List<dynamic>.from(
                  (item as List).map((e) => Map<String, dynamic>.from(e as Map)))
              : [];
          // List endpoint often omits title/time fields that exist on view_trip_details
          await _enrichSeaTripsFromDetails(tripList);
          searchTripList = List<dynamic>.from(tripList);

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

  /// get_all_trips / get_trip_details may omit titles; view_trip_details has
  /// trip_name_english / trip_name_arabic (+ from_time / to_time).
  Future<void> _enrichSeaTripsFromDetails(List<dynamic> trips) async {
    if (trips.isEmpty) return;

    await Future.wait(trips.map((raw) async {
      if (raw is! Map) return;
      final trip = raw;

      bool hasText(dynamic v) {
        if (v == null || v == 'NA') return false;
        final text = v.toString().trim();
        return text.isNotEmpty && text != 'null';
      }

      final hasTitle = hasText(trip['title_name_en']) ||
          hasText(trip['title_name_ar']) ||
          hasText(trip['trip_name_english']) ||
          hasText(trip['trip_name_arabic']);
      final hasFromTo =
          hasText(trip['from_time']) || hasText(trip['to_time']);
      final tripTime = trip['trip_time'];
      final hasDisplayTime = tripTime is String &&
          tripTime.trim().isNotEmpty &&
          tripTime.trim() != '0' &&
          tripTime.trim() != '1' &&
          (tripTime.contains('-') ||
              tripTime.toUpperCase().contains('AM') ||
              tripTime.toUpperCase().contains('PM'));

      if (hasTitle && (hasFromTo || hasDisplayTime)) return;

      final tripId = trip['trip_id'];
      if (tripId == null) return;

      try {
        final detailsUrl = Uri.parse(
            "${AppConfigProvider.apiUrl}view_trip_details?trip_id=$tripId");
        final token = AppConstant.token;
        final detailsRes = token.isEmpty
            ? await http.get(detailsUrl)
            : await http.get(detailsUrl,
                headers: {'Authorization': 'Bearer $token'});
        if (detailsRes.statusCode != 200) return;
        final detailsJson = jsonDecode(detailsRes.body);
        if (detailsJson['success'] != true) return;

        // API returns trip_arr as a List with one object (not a Map)
        dynamic details = detailsJson['trip_arr'];
        if (details is List && details.isNotEmpty) {
          details = details.first;
        }
        if (details is! Map) return;
        final detailsMap = Map<String, dynamic>.from(details as Map);

        if (!hasTitle) {
          final en =
              detailsMap['title_name_en'] ?? detailsMap['trip_name_english'];
          final ar =
              detailsMap['title_name_ar'] ?? detailsMap['trip_name_arabic'];
          if (hasText(en)) {
            trip['title_name_en'] = en;
            trip['trip_name_english'] = en;
          }
          if (hasText(ar)) {
            trip['title_name_ar'] = ar;
            trip['trip_name_arabic'] = ar;
          }
        }

        if (!hasFromTo) {
          if (hasText(detailsMap['from_time'])) {
            trip['from_time'] = detailsMap['from_time'];
          }
          if (hasText(detailsMap['to_time'])) {
            trip['to_time'] = detailsMap['to_time'];
          }
          if (detailsMap['fixed_time'] != null) {
            trip['fixed_time'] = detailsMap['fixed_time'];
          }
          // Prefer numeric open/fixed flag from details when list had a string
          if (detailsMap['trip_time'] is int ||
              detailsMap['trip_time']?.toString() == '0' ||
              detailsMap['trip_time']?.toString() == '1') {
            trip['trip_time'] = detailsMap['trip_time'];
          }
        }

        // Open-time cards display the configured duration, not the operating
        // window. The list endpoint omits it, so retain the details value.
        if (!hasText(trip['minimum_hours']) &&
            hasText(detailsMap['minimum_hours'])) {
          trip['minimum_hours'] = detailsMap['minimum_hours'];
        }

        // Activity / type for landscape label
        if (trip['activity'] == null ||
            (trip['activity'] is Map && (trip['activity'] as Map).isEmpty) ||
            (trip['activity'] is List && (trip['activity'] as List).isEmpty)) {
          if (detailsMap['activity'] != null) {
            trip['activity'] = detailsMap['activity'];
          }
        }
        if (!hasText(trip['trip_type_name']) &&
            hasText(detailsMap['trip_type_name'])) {
          trip['trip_type_name'] = detailsMap['trip_type_name'];
        }
      } catch (e) {
        log('enrich trip $tripId failed: $e');
      }
    }));
  }

  //=============================GET Boat DETAILS===================================//
  Future<void> getAllAdvertisementApi(userId) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}get_all_owner_advertisements?user_id=$userId&type=$userType");
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
          var item = res['data'];
          propertyList = (item != "NA") ? item : [];
          searchPropertyList = (item != "NA") ? item : [];

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

  //=============================Delete Boat DETAILS===================================//
  deletePropAdApiCall(propId) async {
    setState(() {
      isApiCalling = true;
    });

    Uri url =
        Uri.parse("${AppConfigProvider.apiUrl}delete_advertisement_property");

    print("Url===> $url");

    try {
      http.MultipartRequest formData = http.MultipartRequest('POST', url);
      formData.fields['property_ad_id'] = propId.toString();
      formData.fields['user_id'] = userId.toString();

      log("response--==> ${formData.fields}");
      // print("response--==> ${formData.files}");
      http.StreamedResponse response = await formData.send();
      print("response--==> $response");
      var responseString = await response.stream.toBytes();
      var res = jsonDecode(utf8.decode(responseString));

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          getAllAdvertisementApi(userId);
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
  searchSeaAds(String query) {
    print(query);

    var results1 = searchTripList
        .where((value) {
          final en = (value['title_name_en'] ?? value['trip_name_english'])
                  ?.toString()
                  .toLowerCase() ??
              '';
          final ar = (value['title_name_ar'] ?? value['trip_name_arabic'])
                  ?.toString()
                  .toLowerCase() ??
              '';
          final boatName =
              value['boat_name_english']?.toString().toLowerCase() ?? '';
          final q = query.toLowerCase();
          return en.contains(q) || ar.contains(q) || boatName.contains(q);
        })
        .toList();

    print("results1 $results1");

    tripList = [];

    tripList = results1;

    setState(() {});
  }

  searchPropertyAds(String query) {
    print(query);

    var results1 = searchPropertyList
        .where((value) => value['property_name_english']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    print("results1 $results1");

    propertyList = [];

    propertyList = results1;

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
    final size = MediaQuery.of(context).size;
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
                                      if (status == 2) {
                                        if (value.isNotEmpty) {
                                          searchPropertyAds(value);
                                        } else {
                                          propertyList = searchPropertyList;
                                        }
                                      } else {
                                        if (value.isNotEmpty) {
                                          searchSeaAds(value);
                                        } else {
                                          tripList = searchTripList;
                                        }
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

                          if (userType == 3 ||
                              (userType == 2 && manageMyAd == 1))
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AddAdvertisementSectionScreen()));
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

                    //!toggle buttons
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                status = 1;
                                searchTextController.clear();
                                tripList = searchTripList;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 42 / 100,
                              decoration: BoxDecoration(
                                  color: status == 1
                                      ? AppColor.themeColor
                                      : AppColor.secondaryColor,
                                  border:
                                      Border.all(color: AppColor.themeColor),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenWidth > 600 ? 15 : 8.0),
                                child: Text(
                                  AppLanguage.seaText[language],
                                  style: TextStyle(
                                      fontSize: screenWidth > 600 ? 20 : 14,
                                      fontWeight: FontWeight.w700,
                                      color: status == 1
                                          ? AppColor.secondaryColor
                                          : AppColor.primaryColor,
                                      fontFamily: AppFont.fontFamily),
                                ),
                              ),
                            ),
                          ),

                          //!upcoming
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                status = 2;
                                searchTextController.clear();
                                propertyList = searchPropertyList;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 42 / 100,
                              decoration: BoxDecoration(
                                  color: status == 2
                                      ? AppColor.themeColor
                                      : AppColor.secondaryColor,
                                  border:
                                      Border.all(color: AppColor.themeColor),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenWidth > 600 ? 15 : 8.0),
                                child: Text(
                                  AppLanguage.propertyText[language],
                                  style: TextStyle(
                                      fontSize: screenWidth > 600 ? 20 : 14,
                                      fontWeight: FontWeight.w700,
                                      color: status == 2
                                          ? AppColor.secondaryColor
                                          : AppColor.primaryColor,
                                      fontFamily: AppFont.fontFamily),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),

                    if (status == 1) ...[
                      //! SEA TAB
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
                                            final trip = tripList[index];
                                            final size =
                                                MediaQuery.of(context).size;
                                            final canManage = userType == 3 ||
                                                (userType == 2 &&
                                                    manageMyAd == 1);
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Stack(
                                                  children: [
                                                    TripAdCard(
                                                      trip: trip,
                                                      layout: TripAdCardLayout
                                                          .landscape,
                                                      width: size.width * 0.9,
                                                      height: size.height * 0.24,
                                                      showFavorite: false,
                                                      showShare: false,
                                                      showImageCount: false,
                                                      topTrailing: canManage
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                optionsBottomSheet(
                                                                    context,
                                                                    screenWidth,
                                                                    trip[
                                                                        'trip_id'],
                                                                    1);
                                                              },
                                                              child: Container(
                                                                width: screenWidth >
                                                                        600
                                                                    ? size.width *
                                                                        5 /
                                                                        100
                                                                    : size.width *
                                                                        6 /
                                                                        100,
                                                                height: screenWidth >
                                                                        600
                                                                    ? size.width *
                                                                        5 /
                                                                        100
                                                                    : size.width *
                                                                        6 /
                                                                        100,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                        color: AppColor
                                                                            .secondaryColor,
                                                                        shape: BoxShape
                                                                            .circle),
                                                                child:
                                                                    Image.asset(
                                                                  AppImage
                                                                      .menuCircle,
                                                                  color: AppColor
                                                                      .themeColor,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              ),
                                                            )
                                                          : null,
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                AdvertisementScreen(
                                                              tripId: trip[
                                                                      'trip_id']
                                                                  .toString(),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    // Discount badge
                                                    if (trip['discount'] !=
                                                            null &&
                                                        trip['discount'] >
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
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              30 /
                                                              100,
                                                          height: MediaQuery.of(
                                                                      context)
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
                                                        top: language == 0
                                                            ? 15
                                                            : 14,
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
                                                            alignment: Alignment
                                                                .center,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                30 /
                                                                100,
                                                            child: Text(
                                                              "${trip['discount']}% ${AppLanguage.offText[language]}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      AppFont
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
                                          SizedBox(
                                            width: screenWidth * 70 / 100,
                                            child: Text(
                                              AppLanguage
                                                  .advNodataMsg[language],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColor.primaryColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                    ] else ...[
                      //! PROPERTY TAB
                      isLoading
                          ? myAdsShimmerEffect(context)
                          : Expanded(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  children: [
                                    if (propertyList.isNotEmpty)
                                      Wrap(
                                        children: [
                                          ...List.generate(propertyList.length,
                                              (index) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Stack(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                PropertyAdvertisementScreen(
                                                              propertyAdId: propertyList[
                                                                          index]
                                                                      [
                                                                      'property_ad_id']
                                                                  .toString(),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            90 /
                                                            100,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          vertical: 5,
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          image:
                                                              DecorationImage(
                                                            image: propertyList[
                                                                            index]
                                                                        [
                                                                        'cover_image'] !=
                                                                    null
                                                                ? NetworkImage(
                                                                    "${AppConfigProvider.imageURL}${propertyList[index]['cover_image']}")
                                                                : const AssetImage(
                                                                        AppImage
                                                                            .imageFrame)
                                                                    as ImageProvider,
                                                            fit: BoxFit.cover,
                                                            colorFilter:
                                                                ColorFilter
                                                                    .mode(
                                                              Colors.black
                                                                  .withOpacity(
                                                                      0.3),
                                                              BlendMode.darken,
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

                                                            // 3 options (edit/delete)
                                                            (userType == 3 ||
                                                                    (userType ==
                                                                            2 &&
                                                                        manageMyAd ==
                                                                            1))
                                                                ? SizedBox(
                                                                    width: MediaQuery.of(context)
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
                                                                                propertyList[index]['property_ad_id'],
                                                                                2);
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width: screenWidth > 600
                                                                                ? MediaQuery.of(context).size.width * 5 / 100
                                                                                : MediaQuery.of(context).size.width * 6 / 100,
                                                                            height: screenWidth > 600
                                                                                ? MediaQuery.of(context).size.width * 5 / 100
                                                                                : MediaQuery.of(context).size.width * 6 / 100,
                                                                            decoration:
                                                                                const BoxDecoration(color: AppColor.secondaryColor, shape: BoxShape.circle),
                                                                            child:
                                                                                Image.asset(
                                                                              AppImage.menuCircle,
                                                                              color: AppColor.themeColor,
                                                                              fit: BoxFit.contain,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )
                                                                : SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        80 /
                                                                        100,
                                                                    height: MediaQuery.of(context)
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

                                                            //! Property name
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  80 /
                                                                  100,
                                                              child: Text(
                                                                propertyList[
                                                                            index]
                                                                        [
                                                                        'property_name_english'] ??
                                                                    "",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: AppColor
                                                                        .secondaryColor,
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontFamily),
                                                              ),
                                                            ),
                                                            // SizedBox(
                                                            //   height: MediaQuery.of(
                                                            //               context)
                                                            //           .size
                                                            //           .height *
                                                            //       .5 /
                                                            //       100,
                                                            // ),

                                                            //! City name
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
                                                                            .cityText[
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
                                                                            AppFont.fontFamily),
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
                                                                            AppFont.fontFamily),
                                                                  ),
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        63 /
                                                                        100,
                                                                    child: Text(
                                                                      "${propertyList[index]['city_name'] ?? ""}",
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: AppColor
                                                                              .secondaryColor,
                                                                          fontFamily:
                                                                              AppFont.fontFamily),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                            //! Property Type name
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
                                                                            .propertyType[
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
                                                                            AppFont.fontFamily),
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
                                                                            AppFont.fontFamily),
                                                                  ),
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        51.5 /
                                                                        100,
                                                                    child: Text(
                                                                      "${propertyList[index]['property_type_name'][language] ?? ""}",
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: AppColor
                                                                              .secondaryColor,
                                                                          fontFamily:
                                                                              AppFont.fontFamily),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                            //! Rating, members, price
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  80 /
                                                                  100,
                                                              child: Row(
                                                                children: [
                                                                  if (propertyList[index]
                                                                              [
                                                                              'rating'] !=
                                                                          null &&
                                                                      propertyList[index]['rating']
                                                                              .toString() !=
                                                                          "0.00") ...[
                                                                    Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      decoration: BoxDecoration(
                                                                          color: AppColor.secondaryColor.withOpacity(
                                                                              .4),
                                                                          borderRadius:
                                                                              BorderRadius.circular(20)),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                8.0,
                                                                            vertical:
                                                                                2),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            SizedBox(
                                                                              width: screenWidth > 600 ? MediaQuery.of(context).size.width * 2 / 100 : MediaQuery.of(context).size.width * 3 / 100,
                                                                              height: screenWidth > 600 ? MediaQuery.of(context).size.width * 2 / 100 : MediaQuery.of(context).size.width * 3 / 100,
                                                                              child: Image.asset(AppImage.starIcon),
                                                                            ),
                                                                            SizedBox(
                                                                              width: MediaQuery.of(context).size.width * 1 / 100,
                                                                            ),
                                                                            Text(
                                                                              propertyList[index]['rating']?.toString() ?? "",
                                                                              textAlign: TextAlign.center,
                                                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColor.secondaryColor, fontFamily: AppFont.fontFamily),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          2 /
                                                                          100,
                                                                    ),
                                                                  ],
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        20 /
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
                                                                            BorderRadius.circular(20)),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8.0,
                                                                          vertical:
                                                                              4),
                                                                      child:
                                                                          Text(
                                                                        "${(propertyList[index]['max_adult'] ?? 0) + (propertyList[index]['max_child'] ?? 0)}  ${AppLanguage.guestsText[language]}",
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                10,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: AppColor.secondaryColor,
                                                                            fontFamily: AppFont.fontFamily),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        2 /
                                                                        100,
                                                                  ),
                                                                  const Spacer(),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        color: AppColor
                                                                            .themeColor,
                                                                        borderRadius:
                                                                            BorderRadius.circular(5)),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8.0,
                                                                          vertical:
                                                                              4),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          Text(
                                                                            AppLanguage.startingFromText[language],
                                                                            style: const TextStyle(
                                                                                fontSize: 11,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: AppColor.secondaryColor,
                                                                                fontFamily: AppFont.fontFamily),
                                                                          ),
                                                                          Text(
                                                                            " ${propertyList[index]['starting_price']?.toString() ?? ""} KWD",
                                                                            style: const TextStyle(
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: AppColor.secondaryColor,
                                                                                fontFamily: AppFont.fontFamily),
                                                                          ),
                                                                        ],
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
                                                                  1 /
                                                                  100,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    // Discount badge
                                                    if (propertyList[index][
                                                                'discount_percentage'] !=
                                                            null &&
                                                        propertyList[index][
                                                                'discount_percentage'] >
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
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              30 /
                                                              100,
                                                          height: MediaQuery.of(
                                                                      context)
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
                                                        top: language == 0
                                                            ? 15
                                                            : 14,
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
                                                            alignment: Alignment
                                                                .center,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                30 /
                                                                100,
                                                            child: Text(
                                                              "${propertyList[index]['discount_percentage']}% ${AppLanguage.offText[language]}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      AppFont
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
                                    if (propertyList.isEmpty)
                                      Column(
                                        children: [
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  20 /
                                                  100),
                                          SizedBox(
                                            width: screenWidth * 70 / 100,
                                            child: Text(
                                              AppLanguage
                                                  .advNodataMsg[language],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColor.primaryColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),

                      // Expanded(
                      //   child: PropertyList(
                      //     propertyList: propertyList,
                      //     language: language,
                      //     manageMyAd: manageMyAd,
                      //     userType: userType,
                      //     viewMyAdd: viewMyAdd,
                      //   ),
                      // ),
                    ],

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
      BuildContext context, double screenWidth, int id, int adType) {
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
                                    if (adType == 1) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditAdvertisementScreen(
                                            tripId: id.toString(),
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditPropertyAdvertisementScreen(
                                            propertyAdId: id.toString(),
                                          ),
                                        ),
                                      );
                                    }
                                  } else if (optionsList[index]['id'] == 2) {
                                    deleteBottomSheet(context, screenWidth,
                                        id.toString(), adType);
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
  void deleteBottomSheet(BuildContext context, screenWidth, id, adType) {
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
                                adType == 0
                                    ? AppLanguage.deleteMsg[language]
                                    : AppLanguage.deleteAdMsg[language],
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
                                      if (adType == 1) {
                                        deleteAdApiCall(id);
                                      } else {
                                        deletePropAdApiCall(id);
                                      }
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
