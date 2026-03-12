import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:the_boat_ownerside/controller/app_snack_bar_toast_message.dart';
import 'package:the_boat_ownerside/view/propertymodule/edit_prpertyAd_second_screen.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_loader.dart';
import '../authentication/login_screen.dart';
import '../../controller/app_button.dart';
import '../../controller/textinput.dart';
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_header.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class EditPropertyAdvertisementScreen extends StatefulWidget {
  static String routeName = './EditPropertyAdvertisementScreen';
  final String propertyAdId;
  const EditPropertyAdvertisementScreen(
      {super.key, required this.propertyAdId});

  @override
  State<EditPropertyAdvertisementScreen> createState() =>
      _EditProfileScreenScreenState();
}

class _EditProfileScreenScreenState
    extends State<EditPropertyAdvertisementScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController genderTextEditingController = TextEditingController();
  TextEditingController languageTextEditingController = TextEditingController();
  TextEditingController captainEnglishNameTextController =
      TextEditingController();
  TextEditingController captainArabicNameTextController =
      TextEditingController();
  TextEditingController captainNumberTextController = TextEditingController();
  TextEditingController activityTextEditingController = TextEditingController();
  TextEditingController boatTextEditingController = TextEditingController();
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController cityTextEditingController = TextEditingController();
  TextEditingController maxNumberTextController = TextEditingController();
  TextEditingController messageTextEditingController = TextEditingController();
  TextEditingController messageArabicTextEditingController =
      TextEditingController();
  TextEditingController coupanDiscountTextEditingController =
      TextEditingController();
  TextEditingController discountTextEditingController = TextEditingController();
  TextEditingController searchCountryTextEditingController =
      TextEditingController();
  TextEditingController searchCityTextEditingController =
      TextEditingController();
  TextEditingController searchActivityTextEditingController =
      TextEditingController();
  TextEditingController searchDestinationTextEditingController =
      TextEditingController();
  TextEditingController nationalityTextEditingController =
      TextEditingController();
  TextEditingController destinationTextEditingController =
      TextEditingController();
  TextEditingController couponCodeTextEditingController =
      TextEditingController();
  TextEditingController searchDestinationController = TextEditingController();

  DateTime? selectedDate;
  var sendDate = "";
  List genderList = [
    AppLanguage.maleText[language],
    AppLanguage.femaleText[language],
    AppLanguage.otherText[language]
  ];

  String isSelectedGender = AppLanguage.maleText[language];
  int selectedLanguage = 0;
  int selectedActivity = 0;
  int selectedGender = 0;
  int isSelectedNationality = 0;
  int isSelectedBoat = 0;
  int isSelectedCity = 0;
  int isSelectedDestination = 0;
  List<XFile> serverImageList = [];
  var fileName = 'NA';
  // late File _image;
  bool isApiCalling = false;
  XFile? coverImage;
  String showCoverImage = "";

  List languageList = [
    {
      "id": 1,
      "title": AppLanguage.englishText[language],
    },
    {
      "id": 2,
      "title": AppLanguage.arabicText[language],
    },
    {
      "id": 3,
      "title": AppLanguage.frenchText[language],
    },
    {
      "id": 4,
      "title": AppLanguage.italianText[language],
    },
    {
      "id": 5,
      "title": AppLanguage.koreanText[language],
    },
  ];

  List activityList = <dynamic>[];
  // List nationsList = <dynamic>[];
  // List nationsSearchList = <dynamic>[];
  List citySearchList = <dynamic>[];
  List activitySearchList = <dynamic>[];
  // List cityList = <dynamic>[];
  // List destinationList = <dynamic>[];
  List searchDestinationList = <dynamic>[];
  List<dynamic> boatList = <dynamic>[];
  int userId = 0;
  dynamic userDetails;
//==map====
  GoogleMapController? mapController;
  LatLng initialPosition = const LatLng(32.44745630896057, 14.723027497529984);
  bool mapshow = false;
  double lat = 32.44745630896057;
  double long = 14.723027497529984;
  double latitudex = 32.44745630896057;
  double longtitudex = 14.723027497529984;
  // String? _currentAddress;
  // Position? _currentPosition;
  TextEditingController controller = TextEditingController();
  var address;
  TextEditingController searchController = TextEditingController();
  List<dynamic> predictions = [];
  List<dynamic> selectedActivityList = [];
  List<dynamic> selectedActivityNameList = [];
  Timer? _debounce;
  dynamic tripDetails;
  List<dynamic> boatImageList = <dynamic>[];
  List deleteId = [];
  String boatCapacity = '0';
  DateTime? startDate;
  DateTime? endDate;
  String sendStartDate = "";
  String sendEndDate = "";
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  bool isCouponExist = false;

  int adultCount = 10;
  int childCount = 10;
  @override
  void initState() {
    super.initState();
  }

  //=============================GET Trip DETAILS===================================//
  Future<void> getTripDetailsApi() async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}view_trip_details?trip_id=${widget.propertyAdId}");

    String token = AppConstant.token;

    if (token.isEmpty) {
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token', // Use 'Bearer' if required
    };

    setState(() {
      isApiCalling = true;
    });

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);

        if (res['success'] == true) {
          var item = res['trip_arr'];
          tripDetails = (item != "NA") ? item[0] : {};

          // fillData();
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

  // fillData() {
  //   showCoverImage = tripDetails["trip_image"];
  //   boatImageList =
  //       tripDetails["tripImages"] != "NA" ? tripDetails["tripImages"] : [];
  //   isToggle = tripDetails["advertisement_type"];
  //   captainEnglishNameTextController.text = tripDetails["captain_name_english"];
  //   captainArabicNameTextController.text = tripDetails["captain_name_arabic"];
  //   captainNumberTextController.text = tripDetails["contact_number"];
  //   selectedGender = tripDetails["gender"];
  //   isSelectedGender = genderList[selectedGender];
  //   nationalityTextEditingController.text =
  //       tripDetails["country_name"][language];
  //   isSelectedNationality = tripDetails["country_id"];
  //   isSelectedDestination = tripDetails["destination_id"];
  //   destinationTextEditingController.text = tripDetails["destinaton"][language];
  //   isSelectedCity = tripDetails["city_id"];
  //   cityTextEditingController.text = tripDetails["city_name"][language];
  //   isSelectedBoat = tripDetails["boat_id"];
  //   boatTextEditingController.text = tripDetails["boat_name_english"];
  //   selectedActivityList = tripDetails["activity_ids"] != null
  //       ? tripDetails["activity_ids"].split(',')
  //       : [];

  //   pickUpTextEditingController.text = tripDetails["pickup_point"];
  //   maxNumberTextController.text = tripDetails["max_people"].toString();
  //   messageTextEditingController.text = tripDetails["description_english"];
  //   messageArabicTextEditingController.text = tripDetails["description_arabic"];
  //   discountTextEditingController.text =
  //       tripDetails["discount"] == 0 ? "" : tripDetails["discount"].toString();
  //   coupanDiscountTextEditingController.text =
  //       tripDetails["coupon_discount"] == 0
  //           ? ""
  //           : tripDetails["coupon_discount"].toString();
  //   lat = double.parse(tripDetails["latitude"].toString());
  //   long = double.parse(tripDetails["longitude"].toString());
  //   couponCodeTextEditingController.text = tripDetails["coupon_code"] ?? "";
  //   if (couponCodeTextEditingController.text.isNotEmpty &&
  //       couponCodeTextEditingController.text != "NA") {
  //     isCouponExist = true;
  //     startDate = DateTime.parse(tripDetails["coupon_start_date"]);
  //     endDate = DateTime.parse(tripDetails["coupon_end_date"]);
  //     startDateController.text = DateFormat('MMM dd, yyyy')
  //         .format(DateTime.parse(tripDetails["coupon_start_date"] ?? ""));
  //     endDateController.text = DateFormat('MMM dd, yyyy')
  //         .format(DateTime.parse(tripDetails["coupon_end_date"] ?? ""));
  //     sendStartDate = tripDetails["coupon_start_date"];
  //     sendEndDate = tripDetails["coupon_end_date"];
  //   } else {
  //     couponCodeTextEditingController.text = "";
  //   }
  //   getActivityApi(
  //     userId,
  //   );
  //   boatCapacity = tripDetails['boat_capacity'].toString().trim();
  //   activityTextEditingController.text = language == 0
  //       ? tripDetails["activity"][0]['english'][0]
  //       : tripDetails["activity"][0]['arabic'][0];
  //   selectedActivityNameList = language == 0
  //       ? tripDetails["activity"][0]['english']
  //       : tripDetails["activity"][0]['arabic'];
  //   getCitiesApi(userId);
  //   setState(() {});
  // }

  // searchResultCountry(String query) {
  //   var results1 = nationsSearchList
  //       .where((value) => value['country_name'][language]
  //           .toString()
  //           .toLowerCase()
  //           .contains(query.toLowerCase()))
  //       .toList();

  //   nationsList = [];

  //   nationsList = results1;

  //   setState(() {});
  // }

  searchResultCity(String query) {
    var results1 = citySearchList
        .where((value) => value['city_name'][language]
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    cityList = [];

    // cityList = results1;

    setState(() {});
  }

  //---------------------SEARCH FUNCTION COUNTRY--------------------///
  searchResultActivity(String query) {
    var results1 = activitySearchList
        .where((value) => value['name_english'][language]
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    activityList = [];

    activityList = results1;

    setState(() {});
  }

  int isToggle = 0;

  Future<void> _imgFromGallery() async {
    Navigator.pop(context);
    List<XFile>? images = await ImagePicker().pickMultiImage();

    List<File> data = [];

    // ignore: unnecessary_null_comparison
    if (images != null && images.length <= 7) {
      if (images.length == 1 || images.length <= 7) {
        images = images.sublist(0, min(7, images.length));

        for (var xFile in images) {
          File file = File(xFile.path);
          data.add(file);
        }

        List imageListdata = boatImageList;

        if (imageListdata.length <= 7) {
          for (var i = 0; i < data.length; i++) {
            imageListdata
                .add({"image": data[i], "status": true, "trip_image_id": 0});

            setState(() {
              boatImageList = imageListdata;
            });
          }
        }
        if (imageListdata.length > 7) {
          boatImageList = imageListdata.sublist(0, 7);

          setState(() {});
        }
      }
    } else {
      // ignore: use_build_context_synchronously
      // SnackBarToastMessage.showSnackBar(
      //     context, AppLanguage.selectonlyimageText[language]);
    }
  }

  Future<void> _imgFromCamera() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 1440,
      maxWidth: 1080,
    );

    if (image != null) {
      setState(() {
        boatImageList.add({"image": File(image.path), "trip_image_id": 0});
      });
    }
  }

  //-------------------------------IMAGE PICKER BOTTOM SHEET--------------------------//
  void imagePickerBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: Text(AppLanguage.photoGalleryText[language]),
                      onTap: () {
                        _imgFromGallery();
                        setState(() {});
                        // Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: Text(AppLanguage.cameraText[language]),
                    onTap: () {
                      _imgFromCamera();
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

//=============cover image picker===========
  //--------------------------------FROM CAMERA-----------------------//
  Future<void> _coverImgFromCamera() async {
    dynamic image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        // maxHeight: 450.0,
        // maxWidth: 450.0,
        imageQuality: 50);

    if (image != null) {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          coverImage = image;
          //  var _btnActive = true;
        });
      });
    } else {
      setState(() {
        //  var _btnActive = false;
      });
    }

    Navigator.of(context).pop();
  }

// ------------------------------FROM GALLERY------------------------//
  Future<void> _coverImgFromGallery() async {
    dynamic image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        // maxHeight: 450.0,
        // maxWidth: 450.0,
        imageQuality: 50);

    if (image != null) {
      Future.delayed(const Duration(seconds: 0), () {
        setState(() {
          coverImage = image;
          //  var _btnActive = true;
        });
      });
    } else {
      setState(() {
        //    var _btnActive = false;
      });
    }

    Navigator.of(context).pop();
  }

  //-------------------------------IMAGE PICKER BOTTOM SHEET--------------------------//
  void coverImagePickerBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: Text(AppLanguage.photoGalleryText[language]),
                      onTap: () {
                        _coverImgFromGallery();
                        setState(() {});
                        // Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: Text(AppLanguage.cameraText[language]),
                    onTap: () {
                      _coverImgFromCamera();
                      setState(() {});
                      // Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  //--------------------REFRESH FUNCION-----------------------//
  Future<Null> _refreshPage() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(const Duration(seconds: 1));
    // getTopStories(0);

    return null;
  }

  // =====================remove==============//
  removeItemFromList(index) {
    List itemListdemo = boatImageList;
    List deleteData = deleteId;
    if (boatImageList[index]['trip_image_id'] != 0) {
      deleteData.add(boatImageList[index]['trip_image_id']);
    }

    List itemList1 = [];
    if (itemListdemo.isNotEmpty) {
      for (var i = 0; i < itemListdemo.length; i++) {
        if (i != index) {
          itemList1.add(itemListdemo[i]);
        }
      }
    }
    setState(() {
      boatImageList = itemList1;
    });
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate:
          DateTime.now().add(const Duration(days: 365 * 5)), // 5 years from now
      helpText: AppLanguage.selectStartDateText[language],
      confirmText: AppLanguage.selectText[language],
      cancelText: AppLanguage.cancelText[language],
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColor.themeColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        startDateController.text = DateFormat('MMM dd, yyyy').format(picked);
        sendStartDate = DateFormat('yyyy-MM-dd').format(picked);

        // Clear end date if it's on or before the new start date
        // Since end date must be at least one day after start date
        final DateTime nextDayAfterNewStart =
            picked.add(const Duration(days: 1));
        if (endDate != null && endDate!.isBefore(nextDayAfterNewStart)) {
          endDate = null;
          endDateController.text = '';
          sendEndDate = '';
        }
      });
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    if (startDate == null) {
      SnackBarToastMessage.showSnackBar(
          context, AppLanguage.selectStartDateFirstMsg[language]);
      return;
    }

    // Calculate the next day after start date
    final DateTime nextDayAfterStart = startDate!.add(const Duration(days: 1));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? nextDayAfterStart,
      firstDate:
          nextDayAfterStart, // This ensures first selectable date is day after start date
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: AppLanguage.selectEndDateText[language],
      confirmText: AppLanguage.selectText[language],
      cancelText: AppLanguage.cancelText[language],
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColor.themeColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
        endDateController.text = DateFormat('MMM dd, yyyy').format(picked);
        sendEndDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  //!=============Validate Coupon==================
  Future<void> validateCouponApiCall(userId, couponCode) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}check_coupon_exist?user_id=$userId?&coupon_code=$couponCode");
    setState(() {
      isApiCalling = true;
    });
    String token = AppConstant.token;

    if (token.isEmpty) {
      // return;
    }

    Map<String, String> headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);

        if (res['success'] == true) {
          isCouponExist = res['exist_status'];
          if (!isCouponExist) {
            SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          }
          setState(() {
            isApiCalling = false;
          });
        } else {
          setState(() {
            isApiCalling = false;
          });
          // ignore: use_build_context_synchronously
          if (res['active_status'] == 0) {
            SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
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
  // ================= STATIC PROPERTY IMAGE LIST =================

  List<Map<String, dynamic>> propertyImageList = [
    {
      "trip_image_id": 1,
      "image": AppImage.boatImage,
    },
    {
      "trip_image_id": 1,
      "image": AppImage.boatImage,
    },
    {
      "trip_image_id": 1,
      "image": AppImage.boatImage,
    },
    {
      "trip_image_id": 1,
      "image": AppImage.boatImage,
    },
  ];

  List<Map<String, dynamic>> cityList = [
    {
      "city_id": 1,
      "city_name": {0: "Om Al Maradim Island", 1: "جزيرة أم المرادم"}
    },
    {
      "city_id": 2,
      "city_name": {0: "Garouh Island", 1: "جزيرة قاروه"}
    },
    {
      "city_id": 3,
      "city_name": {0: "Failaka Island", 1: "جزيرة فيلكا"}
    },
    {
      "city_id": 4,
      "city_name": {0: "Kubbar Island", 1: "جزيرة كبر"}
    },
  ];
  final List<String> destinationList = [
    'Om Al Maradem',
    'Qarouh',
    'Kubbar',
    'Om Al Namel',
    'Failka',
    'Ouha',
  ];
// Static property list - class ke andar add karo
  final List<Map<String, String>> propertyList = [
    {'name': 'PalmResort', 'type': 'Resort'},
    {'name': 'Sunset Farmhouse', 'type': 'Farmhouse'},
  ];
  String selectedDestination = '';

  final List<Map<String, dynamic>> staticNationsList = [
    {
      "country_id": 1,
      "country_name": {0: "Kuwaiti", 1: "كويتي"}
    },
    {
      "country_id": 2,
      "country_name": {0: "Saudi", 1: "سعودي"}
    },
    {
      "country_id": 3,
      "country_name": {0: "Emirati", 1: "إماراتي"}
    },
    {
      "country_id": 4,
      "country_name": {0: "Qatari", 1: "قطري"}
    },
    {
      "country_id": 5,
      "country_name": {0: "Bahraini", 1: "بحريني"}
    },
    {
      "country_id": 6,
      "country_name": {0: "Omani", 1: "عماني"}
    },
    {
      "country_id": 7,
      "country_name": {0: "Indian", 1: "هندي"}
    },
    {
      "country_id": 8,
      "country_name": {0: "Pakistani", 1: "باكستاني"}
    },
    {
      "country_id": 9,
      "country_name": {0: "Egyptian", 1: "مصري"}
    },
    {
      "country_id": 10,
      "country_name": {0: "Filipino", 1: "فلبيني"}
    },
  ];
  List<String> filteredDestinationList = [];
  List<Map<String, dynamic>> nationsList = [];
// int isSelectedNationality = 0;

  String selectedProperty = '';
  List<Map<String, String>> filteredPropertyList = [];
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
    double screenHeight = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.secondaryColor,
        body: RefreshIndicator(
          onRefresh: _refreshPage,
          color: AppColor.themeColor,
          child: Directionality(
            textDirection:
                language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            child: Container(
              width: MediaQuery.of(context).size.width * 100 / 100,
              height: MediaQuery.of(context).size.height * 100 / 100,
              color: AppColor.secondaryColor,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 100 / 100,
                    height: screenWidth > 600
                        ? null
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
                              : MediaQuery.of(context).size.height * 4 / 100,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Transform.rotate(
                                  angle: language == 1 ? 3.1416 : 0,
                                  child: Container(
                                    alignment: Alignment.center,
                                    color: Colors.transparent,
                                    width: MediaQuery.of(context).size.width *
                                        15 /
                                        100,
                                    height: MediaQuery.of(context).size.width *
                                        7 /
                                        100,
                                    child: Image.asset(AppImage.backIcon),
                                  ),
                                ),
                              ),

                              //profile
                              Container(
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width *
                                    70 /
                                    100,
                                child: Text(
                                  AppLanguage.editAdvText[language],
                                  style: const TextStyle(
                                      color: AppColor.secondaryColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: AppFont.fontFamily),
                                ),
                              ),

                              //setting
                              Container(
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width *
                                    15 /
                                    100,
                                height:
                                    MediaQuery.of(context).size.width * 7 / 100,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 10 / 100,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 2 / 100,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),
                          Stack(
                            children: [
                              // ================= MAIN PROPERTY IMAGE =================
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.20,
                                width: MediaQuery.of(context).size.width * 0.90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: const DecorationImage(
                                    image: AssetImage(AppImage.boatImage),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              Positioned(
                                top: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () {
                                    // remove image logic here
                                  },
                                  child: Container(
                                    height: 28,
                                    width: 28,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),
                          buildCoverImage(screenWidth),

                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            child: Text(
                              AppLanguage.addMoreText[language],
                              style: const TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.primaryColor),
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),
//! Property Image List
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth > 600 ? 38 : 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: List.generate(
                                    propertyImageList.length,
                                    (index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 6.0),
                                        child: SizedBox(
                                          width: screenWidth > 600
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  12 /
                                                  100
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  17 /
                                                  100,
                                          height: screenWidth > 600
                                              ? screenHeight <= 800
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      10 /
                                                      100
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      7 /
                                                      100
                                              : MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  8 /
                                                  100,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              // IMAGE
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 5),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    22 /
                                                    100,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    22 /
                                                    100,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.asset(
                                                    propertyImageList[index]
                                                        ['image'],
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),

                                              // CANCEL BUTTON
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    removeItemFromList(index);
                                                  },
                                                  child: SizedBox(
                                                    width: screenWidth > 600
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            4 /
                                                            100
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            5 /
                                                            100,
                                                    height: screenWidth > 600
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            4 /
                                                            100
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            5 /
                                                            100,
                                                    child: Image.asset(
                                                      AppImage.cancelIcon,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),

                          //!==============advertisement type==========

                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),

                          //!================Enter Captain Name in English field
                          CustomTextFormFieldBlackWidth(
                              controller: captainEnglishNameTextController,
                              hintText: "${AppLanguage.shawnText[language]}*",
                              keyboardtype: TextInputType.text,
                              maxLength: AppConstant.fullnameLength,
                              fillColorStatus: 0,
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              readOnly: false),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),

                          //!================Enter Captain Name in arabic field
                          CustomTextFormFieldBlackWidth(
                              controller: captainArabicNameTextController,
                              hintText: AppLanguage
                                  .enterGuardNameArabicText[language],
                              keyboardtype: TextInputType.text,
                              maxLength: AppConstant.fullnameLength,
                              fillColorStatus: 0,
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              readOnly: false),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),

                          //!================enter captain number field
                          CustomTextFormFieldBlackWidth(
                              controller: captainNumberTextController,
                              hintText:
                                  "${AppLanguage.enterGuardNumberText[language]}",
                              keyboardtype: TextInputType.number,
                              maxLength: AppConstant.mobileLength,
                              fillColorStatus: 0,
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              readOnly: false),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),

                          //!=============gender text===============
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            child: Text(
                              AppLanguage.genderText[language],
                              style: const TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.textColor),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 3 / 100),

                          SizedBox(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            child: Row(
                              children: [
                                //male
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedGender = 0;
                                      isSelectedGender = genderList[0];
                                    });
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        30 /
                                        100,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              6 /
                                              100,
                                          child: Image.asset(
                                            selectedGender == 0
                                                ? AppImage.markedCircleIcon
                                                : AppImage.circleIcon,
                                            color: AppColor.primaryColor,
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              4 /
                                              100,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              20 /
                                              100,
                                          child: Text(
                                            AppLanguage.maleText[language],
                                            style: const TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color: AppColor.textColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                //!female
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedGender = 1;
                                      isSelectedGender = genderList[1];
                                    });
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        30 /
                                        100,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              6 /
                                              100,
                                          child: Image.asset(
                                            selectedGender == 1
                                                ? AppImage.markedCircleIcon
                                                : AppImage.circleIcon,
                                            color: AppColor.primaryColor,
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              4 /
                                              100,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              20 /
                                              100,
                                          child: Text(
                                            AppLanguage.femaleText[language],
                                            style: const TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color: AppColor.textColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                //!company
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedGender = 2;
                                      isSelectedGender = genderList[2];
                                    });
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        30 /
                                        100,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              6 /
                                              100,
                                          child: Image.asset(
                                            selectedGender == 2
                                                ? AppImage.markedCircleIcon
                                                : AppImage.circleIcon,
                                            color: AppColor.primaryColor,
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              4 /
                                              100,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              20 /
                                              100,
                                          child: Text(
                                            AppLanguage.otherText[language],
                                            style: const TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color: AppColor.textColor),
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
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),

                          Container(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            height:
                                MediaQuery.of(context).size.height * .1 / 100,
                            color: AppColor.boaderColor,
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100,
                          ),

                          SizedBox(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            height:
                                MediaQuery.of(context).size.height * 5.5 / 100,
                            child: TextFormField(
                              readOnly: true,
                              style: const TextStyle(
                                  height: 1.1,
                                  color: AppColor.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                              textAlignVertical: TextAlignVertical.center,
                              controller: nationalityTextEditingController,
                              onTap: () {
                                dropDownModelForNationality(
                                    context, screenWidth);
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
                                      height:
                                          MediaQuery.of(context).size.width *
                                              5 /
                                              100,
                                      child: Image.asset(
                                        AppImage.dropDownIcon,
                                      ),
                                    ),
                                    onPressed: () {
                                      dropDownModelForNationality(
                                          context, screenWidth);
                                    },
                                  )),
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),

                          //!=== select destination===
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            height:
                                MediaQuery.of(context).size.height * 5.5 / 100,
                            child: TextFormField(
                              readOnly: true,
                              style: const TextStyle(
                                  height: 1.1,
                                  color: AppColor.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                              textAlignVertical: TextAlignVertical.center,
                              controller: destinationTextEditingController,
                              onTap: () {
                                dropDownModelForDestination(
                                    context, screenWidth);
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
                                      "${AppLanguage.chooseDestinationText[language]}",
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
                                      height:
                                          MediaQuery.of(context).size.width *
                                              5 /
                                              100,
                                      child: Image.asset(
                                        AppImage.dropDownIcon,
                                      ),
                                    ),
                                    onPressed: () {
                                      dropDownModelForDestination(
                                          context, screenWidth);
                                    },
                                  )),
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),

                          //!=== select activity===
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            height:
                                MediaQuery.of(context).size.height * 5.5 / 100,
                            child: TextFormField(
                              readOnly: true,
                              style: const TextStyle(
                                  height: 1.1,
                                  color: AppColor.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                              textAlignVertical: TextAlignVertical.center,
                              controller: activityTextEditingController,
                              onTap: () {
                                if (destinationTextEditingController
                                    .text.isEmpty) {
                                  SnackBarToastMessage.showSnackBar(
                                      context,
                                      AppLanguage
                                          .selectDestinationMsg[language]);
                                } else {
                                  dropDownModelForProperty(
                                    context,
                                    screenWidth,
                                  );
                                }
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
                                      "${AppLanguage.choosepropertyText[language]}",
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
                                      height:
                                          MediaQuery.of(context).size.width *
                                              5 /
                                              100,
                                      child: Image.asset(
                                        AppImage.dropDownIcon,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (destinationTextEditingController
                                          .text.isEmpty) {
                                        SnackBarToastMessage.showSnackBar(
                                            context,
                                            AppLanguage.selectDestinationMsg[
                                                language]);
                                      } else {
                                        dropDownModelForProperty(
                                          context,
                                          screenWidth,
                                        );
                                      }
                                    },
                                  )),
                            ),
                          ),

                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),

                          SizedBox(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            height:
                                MediaQuery.of(context).size.height * 5.5 / 100,
                            child: TextFormField(
                              readOnly: true,
                              style: const TextStyle(
                                  height: 1.1,
                                  color: AppColor.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                              textAlignVertical: TextAlignVertical.center,
                              controller: cityTextEditingController,
                              onTap: () {
                                dropDownModelForCity(context, screenWidth);
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
                                    "${AppLanguage.selectCityText[language]}*",
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
                                    String text =
                                        nationalityTextEditingController.text;
                                    if (text.isEmpty) {
                                      SnackBarToastMessage.showSnackBar(context,
                                          AppLanguage.nationalityMsg[language]);
                                    } else {
                                      dropDownModelForCity(
                                          context, screenWidth);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),

                          //!=== select pickup===
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            height:
                                MediaQuery.of(context).size.height * 5.5 / 100,
                            child: TextFormField(
                              readOnly: true,
                              style: const TextStyle(
                                  height: 1.1,
                                  color: AppColor.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                              textAlignVertical: TextAlignVertical.center,
                              controller: pickUpTextEditingController,
                              onTap: () {
                                setState(() {
                                  mapshow = true;
                                });
                                // alertBoxsearch(context);
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
                                      "${AppLanguage.enterPickUpText[language]}*",
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
                                      height:
                                          MediaQuery.of(context).size.width *
                                              5 /
                                              100,
                                      child: Image.asset(
                                        AppImage.mapIcon,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        mapshow = true;
                                      });

                                      // alertBoxsearch(context);
                                    },
                                  )),
                            ),
                          ),

                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),

                          //!================enter number of people

                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Max Number Of People*",
                                  style: TextStyle(
                                      color: AppColor.textColor,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16),
                                ),

                                SizedBox(height: size.height * 0.02),

                                // Adult counter
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Adult",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.02,
                                        vertical: size.height * 0.005,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                adultCount = (adultCount - 1)
                                                    .clamp(0, 10);
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                  size.width * 0.015),
                                              decoration: BoxDecoration(
                                                color: AppColor.themeColor
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.remove,
                                                size: 12,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.03),
                                          Text(
                                            adultCount.toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.03),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                adultCount = (adultCount + 1)
                                                    .clamp(0, 10);
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                  size.width * 0.01),
                                              decoration: BoxDecoration(
                                                color: AppColor.themeColor
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.add,
                                                size: 12,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.01),
                                Divider(
                                  color: AppColor.boaderColor,
                                  thickness: 1,
                                  height: 1,
                                ),
                                SizedBox(height: size.height * 0.02),

                                // Child counter
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Child",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.02,
                                        vertical: size.height * 0.005,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                childCount = (childCount - 1)
                                                    .clamp(0, 10);
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                  size.width * 0.015),
                                              decoration: BoxDecoration(
                                                color: AppColor.themeColor
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.remove,
                                                size: 12,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.03),
                                          Text(
                                            childCount.toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.03),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                childCount = (childCount + 1)
                                                    .clamp(0, 10);
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                  size.width * 0.01),
                                              decoration: BoxDecoration(
                                                color: AppColor.themeColor
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.add,
                                                size: 12,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.01),
                                Divider(
                                  color: AppColor.boaderColor,
                                  thickness: 1,
                                  height: 1,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),

                          //!==============description in english==========
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            child: Text(
                              AppLanguage.descriptionEnglishText[language],
                              style: const TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.primaryColor),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 1 / 100),

                          //! ----------- Message Input -------------
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            child: TextFormField(
                              style: const TextStyle(
                                  height: 1,
                                  color: AppColor.textColor,
                                  fontSize: 16),
                              keyboardType: TextInputType.multiline,
                              controller: messageTextEditingController,
                              maxLines: 7,
                              maxLength: AppConstant.describeLength,
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColor.boaderColor,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColor.boaderColor,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColor.themeColor,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 15),
                                  fillColor: AppColor.secondaryColor,
                                  filled: true,
                                  counterText: '',
                                  hintText: AppLanguage
                                      .descriptionEnglishText[language],
                                  hintStyle: const TextStyle(
                                      color: AppColor.textColor,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16)),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),

                          //!=============descriptionin arabic==========
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            child: Text(
                              AppLanguage.descriptionArabicText[language],
                              style: const TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.primaryColor),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 1 / 100),

                          SizedBox(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            child: TextFormField(
                              style: const TextStyle(
                                  height: 1,
                                  color: AppColor.textColor,
                                  fontSize: 16),
                              keyboardType: TextInputType.multiline,
                              controller: messageArabicTextEditingController,
                              maxLines: 7,
                              maxLength: AppConstant.describeLength,
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColor.boaderColor,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColor.boaderColor,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColor.themeColor,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 15),
                                  fillColor: AppColor.secondaryColor,
                                  filled: true,
                                  counterText: '',
                                  hintText: AppLanguage
                                      .descriptionArabicText[language],
                                  hintStyle: const TextStyle(
                                      color: AppColor.textColor,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16)),
                            ),
                          ),

                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),

                          //!================enter number of people

                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),

                          if (isCouponExist)
                            Column(
                              children: [
                                //! Start Date Field
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  child: TextFormField(
                                    controller: startDateController,
                                    readOnly: true,
                                    onTap: () => selectStartDate(context),
                                    decoration: InputDecoration(
                                        border: const UnderlineInputBorder(
                                          // Use UnderlineInputBorder
                                          borderSide: BorderSide(
                                              color: AppColor.boaderColor),
                                        ),
                                        enabledBorder:
                                            const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColor.boaderColor),
                                        ),
                                        focusedBorder:
                                            const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColor.themeColor,
                                              width: 1),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10),
                                        fillColor: Colors.transparent,
                                        filled: true,
                                        counterText: '',
                                        hintText:
                                            "${AppLanguage.selectStartDateText[language]}*",
                                        hintStyle: const TextStyle(
                                            color: AppColor.textColor,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16),
                                        suffixIcon: IconButton(
                                          icon: Container(
                                            alignment: language == 0
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                20 /
                                                100,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                5 /
                                                100,
                                            child: Image.asset(
                                              AppImage.calenderDeactiveIcon,
                                            ),
                                          ),
                                          onPressed: () =>
                                              selectStartDate(context),
                                        )),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        2 /
                                        100),

                                //! End Date Field
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  child: TextFormField(
                                    controller: endDateController,
                                    readOnly: true,
                                    onTap: () => selectEndDate(context),
                                    decoration: InputDecoration(
                                        border: const UnderlineInputBorder(
                                          // Use UnderlineInputBorder
                                          borderSide: BorderSide(
                                              color: AppColor.boaderColor),
                                        ),
                                        enabledBorder:
                                            const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColor.boaderColor),
                                        ),
                                        focusedBorder:
                                            const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColor.themeColor,
                                              width: 1),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10),
                                        fillColor: Colors.transparent,
                                        filled: true,
                                        counterText: '',
                                        hintText:
                                            "${AppLanguage.selectEndDateText[language]}*",
                                        hintStyle: const TextStyle(
                                            color: AppColor.textColor,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16),
                                        suffixIcon: IconButton(
                                          icon: Container(
                                            alignment: language == 0
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                20 /
                                                100,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                5 /
                                                100,
                                            child: Image.asset(
                                              AppImage.calenderDeactiveIcon,
                                            ),
                                          ),
                                          onPressed: () =>
                                              selectEndDate(context),
                                        )),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: startDate == null
                                          ? Colors.grey[500]
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        2 /
                                        100),
                              ],
                            ),

                          //!======enter coupon discount=============
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      60 /
                                      100,
                                  child: Text(
                                    AppLanguage.enterCoupanDisText[language],
                                    style: const TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: AppColor.textColor),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Center(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          25 /
                                          100,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              5 /
                                              100,
                                      child: TextFormField(
                                        readOnly: false,
                                        style: const TextStyle(
                                            height: 1.1,
                                            color: AppColor.textColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        keyboardType: TextInputType.number,
                                        controller:
                                            coupanDiscountTextEditingController,
                                        maxLength: 2,
                                        decoration: const InputDecoration(
                                            prefixIcon: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  child: Text(
                                                    "%",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            AppColor.textColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: AppColor.boaderColor),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: AppColor.boaderColor),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: AppColor.themeColor),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 0, horizontal: 7),
                                            fillColor: AppColor.secondaryColor,
                                            filled: true,
                                            counterText: '',
                                            hintText: "",
                                            hintStyle: TextStyle(
                                                color: AppColor.textColor,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //!================enter discount
                          CustomTextFormFieldBlackWidth(
                              controller: discountTextEditingController,
                              hintText:
                                  "${AppLanguage.enterDiscountText[language]}%",
                              keyboardtype: TextInputType.number,
                              maxLength: 2,
                              fillColorStatus: 0,
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              readOnly: false),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 5 / 100),

                          //!============next button=================//
                          AppButton(
                            text: AppLanguage.nextText[language],
                            onPress: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditPropertyAdSecondScreen()));
                            },
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  10 /
                                  100),
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
      ),
    );
  }

  Widget buildCoverImage(screenWidth) {
    final size = MediaQuery.of(context).size;
    if (coverImage == null && showCoverImage == "") {
      // Case 1: No image selected or shown yet
      return GestureDetector(
        onTap: () {
          coverImagePickerBottomSheet();
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColor.textColor,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: size.height * 0.01,
                    horizontal: size.width * 0.05),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    textAlign: TextAlign.left,
                    AppLanguage.pleaseUploadsidepicsText[language],
                    style: const TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 19,
                      fontWeight: FontWeight.w400,
                      color: AppColor.secondaryColor,
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    coverImagePickerBottomSheet();
                  },
                  child: SizedBox(
                    width: screenWidth > 600
                        ? MediaQuery.of(context).size.width * 0.1
                        : MediaQuery.of(context).size.width * 0.15,
                    height: screenWidth > 600
                        ? MediaQuery.of(context).size.width * 0.1
                        : MediaQuery.of(context).size.width * 0.15,
                    child:
                        Image.asset(AppImage.addImageIcon, fit: BoxFit.cover),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            ],
          ),
        ),
      );
    } else if (coverImage == null && showCoverImage != "") {
      // Case 2: Show image from URL
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.18,
              child: Image.network(
                "${AppConfigProvider.imageURL}$showCoverImage",
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(color: Colors.grey.shade300),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: MediaQuery.of(context).size.width * 0.01,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showCoverImage = "";
                });
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.06,
                child: Image.asset(AppImage.crossIcon),
              ),
            ),
          ),
        ],
      );
    } else {
      // Case 3: Local image picked
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.18,
              child: Image.file(
                File(coverImage!.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: MediaQuery.of(context).size.width * 0.01,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  coverImage = null;
                  showCoverImage = "";
                });
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.06,
                child: Image.asset(AppImage.crossIcon),
              ),
            ),
          ),
        ],
      );
    }
  }

  void dropDownModelForNationality(BuildContext context, screenWidth) {
    nationsList =
        List.from(staticNationsList); // reset every time dropdown opens

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
                        /// 🔶 Header
                        AppHeaderOrange(
                          text: AppLanguage.nationalityText[language],
                          onPress: () {
                            Navigator.pop(context);
                          },
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 4 / 100,
                        ),

                        /// 🔍 Search Field
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          height:
                              MediaQuery.of(context).size.height * 6.5 / 100,
                          child: TextFormField(
                            controller: searchCountryTextEditingController,
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
                                  nationsList =
                                      staticNationsList.where((country) {
                                    return country["country_name"][language]
                                        .toString()
                                        .toLowerCase()
                                        .contains(input.toLowerCase());
                                  }).toList();
                                } else {
                                  nationsList = List.from(staticNationsList);
                                }
                              });
                            },
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        /// 📋 List
                        Expanded(
                          child: nationsList.isEmpty
                              ? Center(
                                  child: Text(
                                    AppLanguage.noCitiesMsg[language],
                                    style: const TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: nationsList.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              2 /
                                              100,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isSelectedNationality =
                                                  nationsList[index]
                                                      ["country_id"];

                                              nationalityTextEditingController
                                                      .text =
                                                  nationsList[index]
                                                          ['country_name']
                                                      [language];

                                              Navigator.pop(context);
                                            });
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                90 /
                                                100,
                                            color: AppColor.secondaryColor,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  nationsList[index]
                                                          ['country_name']
                                                      [language],
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontSize: 17,
                                                    color:
                                                        AppColor.primaryColor,
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
                                                  child:
                                                      isSelectedNationality ==
                                                              nationsList[index]
                                                                  ["country_id"]
                                                          ? Image.asset(
                                                              AppImage
                                                                  .tickOrangeIcon,
                                                              fit: BoxFit.fill,
                                                            )
                                                          : null,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              2 /
                                              100,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              90 /
                                              100,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
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

  void dropDownModelForProperty(BuildContext context, screenWidth) {
    filteredPropertyList = List.from(propertyList);

    showModalBottomSheet<void>(
      constraints: BoxConstraints.expand(width: screenWidth),
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      backgroundColor: AppColor.secondaryColor,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: AppColor.secondaryColor,
                  child: Column(
                    children: [
                      // Image header
                      AppHeaderOrange(
                          text: AppLanguage.choosepropertyText[language],
                          onPress: () {
                            Navigator.pop(context);
                          }),

                      SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100),

                      // Property list
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                            vertical: MediaQuery.of(context).size.height * 0.01,
                          ),
                          child: Column(
                            children: List.generate(filteredPropertyList.length,
                                (index) {
                              final item = filteredPropertyList[index];
                              final isSelected =
                                  selectedProperty == item['name'];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedProperty = item['name']!;
                                  });
                                  // ✅ controller update karo agar hai toh
                                  // propertyTextEditingController.text = item['name']!;
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.height *
                                        0.015,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.018,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColor.themeColor
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade200,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name']!,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: AppFont.fontFamily,
                                              color: AppColor.primaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            item['type']!,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: AppFont.fontFamily,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // ✅ Tick icon selected pe
                                      if (isSelected)
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
                                          child: Image.asset(
                                            AppImage.tickOrangeIcon,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void dropDownModelForBoat(BuildContext context, screenWidth) {
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
                            text: AppLanguage.chooseBoatText[language],
                            onPress: () {
                              Navigator.pop(context);
                            }),
                        Expanded(
                            child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    3 /
                                    100,
                              ),
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
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: AppColor
                                                          .textLightColor,
                                                      blurRadius: 2.0,
                                                      offset: Offset(0, 4),
                                                    ),
                                                  ], //BoxShadow
                                                  color: isSelectedBoat ==
                                                          boatList[index]
                                                              ['boat_id']
                                                      ? AppColor.themeColor
                                                      : AppColor.secondaryColor,
                                                  border: Border.all(
                                                      width: 1,
                                                      color: AppColor
                                                          .textLightColor),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    selectBoat(index);
                                                    Navigator.pop(context);
                                                  },
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            80 /
                                                            100,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8.0),
                                                      child: Row(
                                                        children: [
                                                          //left side
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                45 /
                                                                100,
                                                            child: Column(
                                                              children: [
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      45 /
                                                                      100,
                                                                  child: Text(
                                                                    "${AppLanguage.yearText[language]}-${boatList[index]['boat_year']}",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: isSelectedBoat == boatList[index]['boat_id']
                                                                            ? AppColor
                                                                                .secondaryColor
                                                                            : AppColor
                                                                                .primaryColor,
                                                                        fontFamily:
                                                                            AppFont.fontFamily),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      45 /
                                                                      100,
                                                                  child: Text(
                                                                    "Capacity-${boatList[index]['boat_capacity']}",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: isSelectedBoat == boatList[index]['boat_id']
                                                                            ? AppColor
                                                                                .secondaryColor
                                                                            : AppColor
                                                                                .primaryColor,
                                                                        fontFamily:
                                                                            AppFont.fontFamily),
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
                                                            //color: Colors.amber,
                                                            child: Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      35 /
                                                                      100,
                                                                  // color: Colors.black,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            2.0),
                                                                    child: Text(
                                                                      boatList[
                                                                              index]
                                                                          [
                                                                          'boat_name_english'],
                                                                      textAlign:
                                                                          TextAlign
                                                                              .end,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color: isSelectedBoat == boatList[index]['boat_id']
                                                                              ? AppColor.secondaryColor
                                                                              : AppColor.primaryColor,
                                                                          fontFamily: AppFont.fontFamily),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
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
                            ],
                          ),
                        ))
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

  selectBoat(index) {
    setState(() {
      isSelectedBoat = boatList[index]['boat_id'];
      boatTextEditingController.text = boatList[index]['boat_name_english'];
      boatCapacity = boatList[index]['boat_capacity'].toString().trim();
    });
  }

  void dropDownModelForCity(BuildContext context, screenWidth) {
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
                        //image header
                        Container(
                          width: MediaQuery.of(context).size.width * 100 / 100,
                          height: screenWidth > 600
                              ? null
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
                                    ? MediaQuery.of(context).size.height *
                                        6 /
                                        100
                                    : MediaQuery.of(context).size.height *
                                        6 /
                                        100,
                              ),

                              //change lang
                              Container(
                                width: MediaQuery.of(context).size.width *
                                    100 /
                                    100,
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    //edit
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Transform.rotate(
                                        angle: language == 1 ? 3.1416 : 0,
                                        child: Container(
                                          color: Colors.transparent,
                                          alignment: Alignment.center,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              15 /
                                              100,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              7 /
                                              100,
                                          child: Image.asset(AppImage.backIcon),
                                        ),
                                      ),
                                    ),

                                    //profile
                                    Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width *
                                          70 /
                                          100,
                                      child: Text(
                                        AppLanguage.cityText[language],
                                        style: const TextStyle(
                                            color: AppColor.secondaryColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: AppFont.fontFamily),
                                      ),
                                    ),

                                    Container(
                                      alignment: Alignment.centerRight,
                                      width: MediaQuery.of(context).size.width *
                                          15 /
                                          100,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              7 /
                                              100,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    10 /
                                    100,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
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
                            controller: searchCityTextEditingController,
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
                                  searchResultCity(input);
                                } else {
                                  // cityList = citySearchList;
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),

                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                //trip list
                                Wrap(
                                  children: [
                                    ...List.generate(cityList.length, (index) {
                                      return Column(
                                        children: [
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                2 /
                                                100,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isSelectedCity =
                                                    cityList[index]["city_id"];
                                                cityTextEditingController.text =
                                                    cityList[index]['city_name']
                                                        [language];
                                                Navigator.pop(context);
                                              });
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  90 /
                                                  100,
                                              color: AppColor.secondaryColor,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    cityList[index]['city_name']
                                                        [language],
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontSize: 17,
                                                      color:
                                                          AppColor.primaryColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            5 /
                                                            100,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            5 /
                                                            100,
                                                    child: isSelectedCity ==
                                                            cityList[index]
                                                                ["city_id"]
                                                        ? Image.asset(
                                                            AppImage
                                                                .tickOrangeIcon,
                                                            fit: BoxFit.fill,
                                                          )
                                                        : null,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                2 /
                                                100,
                                          ),
                                          if (index < cityList.length)
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  90 /
                                                  100,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .2 /
                                                  100,
                                              color: AppColor.textColor,
                                            ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),

                                if (cityList.isEmpty) ...[
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        20 /
                                        100,
                                  ),
                                  Text(
                                    AppLanguage.noCitiesMsg[language],
                                    style: const TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColor.primaryColor),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        )
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

  void dropDownModelForDestination(BuildContext context, screenWidth) {
    filteredDestinationList = List.from(destinationList);

    showModalBottomSheet<void>(
      constraints: BoxConstraints.expand(width: screenWidth),
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      backgroundColor: AppColor.secondaryColor,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: AppColor.secondaryColor,
                  child: Column(
                    children: [
                      // Image header
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 20 / 100,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(AppImage.headerBgImage),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 6 / 100,
                            ),
                            Row(
                              children: [
                                // Back button
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    width: MediaQuery.of(context).size.width *
                                        15 /
                                        100,
                                    height: MediaQuery.of(context).size.width *
                                        7 /
                                        100,
                                    child: Image.asset(AppImage.backIcon),
                                  ),
                                ),
                                // Title
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      70 /
                                      100,
                                  child: Center(
                                    child: Text(
                                      AppLanguage.destinationText[language],
                                      style: const TextStyle(
                                        color: AppColor.secondaryColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: AppFont.fontFamily,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        15 /
                                        100),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100),

                      // Search field
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        height: MediaQuery.of(context).size.height * 6.5 / 100,
                        child: TextFormField(
                          style: const TextStyle(
                            height: 1.1,
                            color: AppColor.primaryColor,
                            fontFamily: AppFont.fontFamily,
                          ),
                          textAlignVertical: TextAlignVertical.center,
                          controller: searchDestinationController,
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
                                filteredDestinationList = destinationList
                                    .where((item) => item
                                        .toLowerCase()
                                        .contains(input.toLowerCase()))
                                    .toList();
                              } else {
                                filteredDestinationList =
                                    List.from(destinationList);
                              }
                            });
                          },
                        ),
                      ),

                      SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100),

                      // List
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: List.generate(
                                filteredDestinationList.length, (index) {
                              final item = filteredDestinationList[index];
                              final isSelected = selectedDestination == item;
                              return Column(
                                children: [
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              2 /
                                              100),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedDestination = item;
                                      });
                                      destinationTextEditingController.text =
                                          item; // ✅ yeh add karo
                                      Navigator.pop(context);
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
                                            item,
                                            style: const TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 17,
                                              color: AppColor.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (isSelected)
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
                                              child: Image.asset(
                                                AppImage.tickOrangeIcon,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              2 /
                                              100),
                                  // Divider
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        90 /
                                        100,
                                    height: MediaQuery.of(context).size.height *
                                        0.2 /
                                        100,
                                    color: AppColor.textColor,
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("${AppLanguage.loctionPermissionenableText[language]}")));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setLoction();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLanguage.LoctionPermissiondenaiedText[language])));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Geolocator.openLocationSettings();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              AppLanguage.LoctionpermissionpemanebtdeletedText[language])));
      return false;
    }
    return true;
  }

  Future<void> _getAddressFromLatLng(Position position,
      [StateSetter? modalSetState]) async {
    await placemarkFromCoordinates(position.latitude, position.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];

      final addressText =
          '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';

      if (modalSetState != null) {
        modalSetState(() {
          latitudex = position.latitude;
          longtitudex = position.longitude;
          initialPosition = LatLng(position.latitude, position.longitude);
          searchController.text = addressText;
        });

        mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 16.0)));
      } else {
        setState(() {
          mapshow = true;
          long = position.longitude;
          lat = position.latitude;
          initialPosition = LatLng(position.latitude, position.longitude);
          latitudex = position.latitude;
          longtitudex = position.longitude;
          searchController.text = addressText;
          isApiCalling = false;
        });

        mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: initialPosition, zoom: 16.0)));
      }
    }).catchError((e) {
      debugPrint(e);
    });
  }

  setLoction() {
    setState(() {
      latitudex = 32.44745630896057;
      longtitudex = 14.723027497529984;
      lat = 32.44745630896057;
      long = 14.723027497529984;
      initialPosition = LatLng(32.44745630896057, 14.723027497529984);
      isApiCalling = false;
      mapshow = true;
    });
  }

  locationAdreesSet() {
    setState(() {
      pickUpTextEditingController.text = searchController.text;
      lat = latitudex;
      long = longtitudex;
    });
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
