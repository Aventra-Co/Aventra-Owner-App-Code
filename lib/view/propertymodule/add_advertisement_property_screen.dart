import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_boat_ownerside/controller/app_snack_bar_toast_message.dart';
import 'package:the_boat_ownerside/view/propertymodule/add_property_Ad_secondscreen.dart';
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

class AddAdvertisementPropertyScreen extends StatefulWidget {
  static String routeName = './AddAdvertisementPropertyScreen';
  const AddAdvertisementPropertyScreen({super.key});

  @override
  State<AddAdvertisementPropertyScreen> createState() =>
      _AddAdvertisementPropertyScreenState();
}

class _AddAdvertisementPropertyScreenState
    extends State<AddAdvertisementPropertyScreen> {
  TextEditingController guardEnglishNameTextController =
      TextEditingController();
  TextEditingController guardArabicNameTextController = TextEditingController();
  TextEditingController guardNumberTextController = TextEditingController();
  TextEditingController activityTextEditingController = TextEditingController();
  TextEditingController propertyTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
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
  int isSelectedProperty = 0;
  int isSelectedCity = 0;
  int isSelectedDestination = 0;
  List<XFile> serverImageList = [];
  var fileName = 'NA';
  // late File _image;
  bool isApiCalling = false;
  XFile? coverImage;
  List activityList = <dynamic>[];
  List nationsList = <dynamic>[];
  List nationsSearchList = <dynamic>[];
  List citySearchList = <dynamic>[];
  List activitySearchList = <dynamic>[];
  List cityList = <dynamic>[];
  List destinationList = <dynamic>[];
  List searchDestinationList = <dynamic>[];
  List<dynamic> propertyList = <dynamic>[];
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
  TextEditingController controller = TextEditingController();
  TextEditingController searchController = TextEditingController();
  List<dynamic> predictions = [];
  List<dynamic> selectedActivityList = [];
  List<dynamic> selectedActivityNameList = [];
  Timer? _debounce;
  String boatCapacity = '0';
  int userType = 0;
  String country = '';
  String location = '';
  DateTime? startDate;
  DateTime? endDate;
  String sendStartDate = "";
  String sendEndDate = "";
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController searchDestinationController = TextEditingController();

  bool isCouponExist = false;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  int isToggle = 0;

  //--------------------------------FROM CAMERA-----------------------//
  Future<void> _imgFromCamera() async {
    dynamic pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 10,
    );

    if (pickedFile != null) {
      setState(() {
        if (serverImageList.length <= 7) {
          serverImageList.add(pickedFile!);

          if (serverImageList.length > 7) {
            serverImageList = serverImageList.sublist(0, 7);
          }
        }
      });
    } else {
      Navigator.of(context).pop();
    }

    // addNoteBottomSheet(context);
  }

//----- from gallary-------
  Future<void> _imgFromGallery() async {
    List<XFile>? images = await ImagePicker().pickMultiImage(
      maxHeight: 1440,
      maxWidth: 1080,
    );

    if (images.length <= 8) {
      images = images.sublist(0, min(7, images.length));

      setState(() {
        if (serverImageList.length <= 7) {
          serverImageList.addAll(images!);

          if (serverImageList.length > 7) {
            serverImageList = serverImageList.sublist(0, 7);
          }
        }
      });
    } else {
      Navigator.pop(context);
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
                        Navigator.of(context).pop();
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

//! ------------------------------FROM GALLERY------------------------//
  Future<void> _coverImgFromGallery() async {
    print("run");
    dynamic image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        // maxHeight: 450.0,
        // maxWidth: 450.0,
        imageQuality: 50);

    if (image != null) {
      print("image 243 $image");
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

  //!-------------------------------IMAGE PICKER BOTTOM SHEET--------------------------//
  void coverImagePickerBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
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
          );
        });
  }

  //!--------------------GET USER DETAILS-----------------------//
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
      userType = data['user_type'];
    }
    setState(() {
      isApiCalling = false;
    });

    setState(() {});
    getCountriesApi(userId);
    getDestinationApi(userId);
    getPropertyApi(userId);
    getCitiesApi(userId);
  }

  searchResultCity(String query) {
    citySearchList
        .where((value) => value['city_name'][language]
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    cityList = [];

    // cityList = results1;

    setState(() {});
  }

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  //!--------------------REFRESH FUNCION-----------------------//
  Future<Null> _refreshPage() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(const Duration(seconds: 1));
    // getTopStories(0);
    getUserDetails();
    return null;
  }

  //!=============Validate Coupon==================
  Future<void> validateCouponApiCall(userId, couponCode) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}check_coupon_exist?user_id=$userId?&coupon_code=$couponCode");
    print("url $url");
    setState(() {
      isApiCalling = true;
    });
    String token = AppConstant.token;

    if (token.isEmpty) {
      print("Token is missing!");
      // return;
    }

    Map<String, String> headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.get(url, headers: headers);
      print("response $response");

      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);
        print("res $res");

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

// Simplified add advertisement validation method
  void addAdvertisementValidation(
      XFile? coverImage,
      List<XFile> serverImageList,
      String guardNameEnglish,
      String guardNameArabic,
      String number,
      String gender,
      String nationality,
      String destination,
      String property,
      String location,
      String city,
      String numOfPeople,
      String descEnglish,
      String descArabic,
      String couponCode,
      String startDate,
      String endDate,
      String couponDiscount,
      String discount) {
    // Perform all validations first
    String? validationError = _validateAddInputs(
      coverImage: coverImage,
      serverImageList: serverImageList,
      guardNameEnglish: guardNameEnglish,
      number: number,
      gender: gender,
      nationality: nationality,
      destination: destination,
      property: property,
      location: location,
      city: city,
      adult: adultCount.toString(),
      child: childCount.toString(),
      couponCode: couponCode,
      startDate: startDate,
      endDate: endDate,
      couponDiscount: couponDiscount,
      discount: discount,
    );

    // If validation fails, show error and return
    if (validationError != null) {
      SnackBarToastMessage.showSnackBar(context, validationError);
      return;
    }

    // If all validations pass, navigate to next screen
    _navigateToAddSecondScreen(
      coverImage,
      serverImageList,
      guardNameEnglish,
      guardNameArabic,
      number,
      couponDiscount,
      discount,
      couponCode,
      startDate,
      endDate,
      descEnglish,
      descArabic,
    );
  }

// Separate validation logic for add advertisement
  String? _validateAddInputs({
    required XFile? coverImage,
    required List<XFile> serverImageList,
    required String guardNameEnglish,
    required String number,
    required String gender,
    required String nationality,
    required String destination,
    required String property,
    required String location,
    required String city,
    required String adult,
    required String child,
    required String couponCode,
    required String startDate,
    required String endDate,
    required String couponDiscount,
    required String discount,
  }) {
    // Basic field validations
    if (coverImage == null) {
      return AppLanguage.coverImageMsg[language];
    }

    if (serverImageList.isEmpty) {
      return AppLanguage.imagesMsg[language];
    }

    if (guardNameEnglish.isEmpty) {
      return AppLanguage.guardNameEngMsg[language];
    }

    if (number.isEmpty) {
      return AppLanguage.guardNumberMessage[language];
    }

    if (number.length < 7) {
      return AppLanguage.guardNumbervalidMessage[language];
    }

    if (gender.isEmpty) {
      return AppLanguage.genderMsg[language];
    }

    if (nationality.isEmpty) {
      return AppLanguage.nationalityMsg[language];
    }

    if (destination.isEmpty) {
      return AppLanguage.selectDestinationMsg[language];
    }

    if (property.isEmpty) {
      return AppLanguage.selectPropertyMsg[language];
    }

    if (location.isEmpty) {
      return AppLanguage.selectPropertyLocation[language];
    }

    if (city.isEmpty) {
      return AppLanguage.cityMsg[language];
    }
    // if (adultCount <= 0) {
    //   return AppLanguage.minPeopleMsg[language];
    // }
    // if (childCount <= 0) {
    //   return AppLanguage.minPeopleMsg[language];
    // }
    // int capacity = int.tryParse(boatCapacity) ?? 0;
    if ((adultCount + childCount) <= 0) {
      return AppLanguage.minPeopleMsg[language];
    }

    //! Coupon validations (only if coupon code is provided)
    if (couponCode.isNotEmpty) {
      String? couponError =
          _validateCoupon(couponCode, startDate, endDate, couponDiscount);
      if (couponError != null) return couponError;
    }

    //! Discount validation (only if discount is provided)
    if (discount.isNotEmpty) {
      String? discountError = _validateDiscount(discount);
      if (discountError != null) return discountError;
    }

    return null; // All validations passed
  }

  //! Separate coupon validation
  String? _validateCoupon(String couponCode, String startDate, String endDate,
      String couponDiscount) {
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(couponCode)) {
      return AppLanguage.couponCodeValidMsg[language];
    }

    if (couponCode.length != 8) {
      return AppLanguage.couponCodeLengthMsg[language];
    }

    if (!isCouponExist) {
      return AppLanguage.couponAlreadyExistMsg[language];
    }

    if (startDate.isEmpty) {
      return AppLanguage.selectStartDateMsg[language];
    }

    if (endDate.isEmpty) {
      return AppLanguage.selectEndDateMsg[language];
    }

    if (couponDiscount.isEmpty) {
      return AppLanguage.couponDiscountMsg[language];
    }
    int discountValue = int.tryParse(couponDiscount) ?? 0;
    if (discountValue == 0 || discountValue == 0.0) {
      return AppLanguage.couponDiscountGreaterMsg[language];
    }

    if (discountValue >= 100) {
      return AppLanguage.couponDiscountLessMsg[language];
    }

    return null;
  }

  //! Separate discount validation
  String? _validateDiscount(String discount) {
    int discountValue = int.tryParse(discount) ?? 0;
    if (discountValue == 0 || discountValue == 0.0) {
      return AppLanguage.discountGreaterMsg[language];
    }
    if (discountValue >= 100) {
      return AppLanguage.discountLesserMsg[language];
    }

    return null;
  }

  //! Separate navigation logic for add advertisement (no duplication)
  void _navigateToAddSecondScreen(
      XFile? coverImage,
      List<XFile> serverImageList,
      String guardNameEnglish,
      String guardNameArabic,
      String number,
      String couponDiscount,
      String discount,
      String couponCode,
      String startDate,
      String endDate,
      String descEnglish,
      String descArabic) {
    // Unfocus any active text fields
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPropertyAdSecondScreen(
          coverImage: coverImage,
          serverImageList: serverImageList,
          guardNameEnglish: guardNameEnglish,
          guardNameArabic: guardNameArabic,
          number: number,
          genderId: selectedGender.toString(),
          nationalityId: isSelectedNationality.toString(),
          destinationId: isSelectedDestination.toString(),
          activityId: selectedActivityList.join(", "),
          propertyId: isSelectedProperty.toString(),
          location: locationTextEditingController.text,
          lat: lat.toString(),
          long: long.toString(),
          cityId: isSelectedCity.toString(),
          adultCount: adultCount.toString(),
          childCount: childCount.toString(),
          descEng: descEnglish,
          descArab: descArabic,
          isPrivate: isToggle.toString(),
          couponDiscount: couponDiscount,
          discount: discount,
          couponCode: couponCode,
          startDate: sendStartDate,
          endDate: sendEndDate,
        ),
      ),
    );
  }

  //!=============================GET Countries DETAILS===================================//
  Future<void> getCountriesApi(userId) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}fetch_country_list?user_id=$userId");
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
          var item = res['country_arr'];
          nationsList = (item != "NA") ? item : [];
          nationsSearchList = (item != "NA") ? item : [];

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

  //!=============================GET destination DETAILS===================================//
  Future<void> getDestinationApi(userId) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}get_desctination?user_id=$userId");
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
          var item = res['destination_arr'];
          destinationList = (item != "NA") ? item : [];
          searchDestinationList = (item != "NA") ? item : [];

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

  //!=============================GET Property DETAILS===================================//
  Future<void> getPropertyApi(userId) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}get_all_owner_properties?user_id=$userId&type=3");
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
          propertyList = (item != "NA") ? item : [];
          // activitySearchList = (item != "NA") ? item : [];

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

  //!=============================GET cities DETAILS===================================//
  Future<void> getCitiesApi(userId) async {
    Uri url = Uri.parse(
        "${AppConfigProvider.apiUrl}fetch_city_by_country?$userId=5&country_id=$isSelectedNationality");
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
          var item = res['city_arr'];
          cityList = (item != "NA") ? item : [];
          citySearchList = (item != "NA") ? item : [];

          setState(() {
            isApiCalling = false;
          });
        } else {
          cityList = [];
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

  //!---------------------SEARCH FUNCTION COUNTRY--------------------///
  searchResultCountry(String query) {
    print(query);

    var results1 = nationsSearchList
        .where((value) => value['country_name'][language]
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    print("results1 $results1");

    nationsList = [];

    nationsList = results1;

    setState(() {});
  }

  //!---------------------SEARCH FUNCTION COUNTRY--------------------///
  searchResultDestination(String query) {
    print(query);

    var results1 = searchDestinationList
        .where((value) => value['destination'][language]
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    print("results1 $results1");

    destinationList = [];

    destinationList = results1;

    setState(() {});
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    _debounce?.cancel();
    super.dispose();
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

  String selectedProperty = '';
  String selectedDestination = '';
  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
        inAsyncCall: isApiCalling,
        opacity: 0.5,
        child: _buildUIScreen(context));
  }

  int adultCount = 0;
  int childCount = 0;

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
                              ? MediaQuery.of(context).size.height * 6 / 100
                              : MediaQuery.of(context).size.height * 4 / 100,
                        ),

                        //profile edit setting
                        Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              //back
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
                                  AppLanguage.addAdvText[language],
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
                          //!============upload cover image container
                          coverImage == null
                              ?
                              //take picture box
                              GestureDetector(
                                  onTap: () {
                                    coverImagePickerBottomSheet();
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        90 /
                                        100,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                        color: AppColor.textColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              2 /
                                              100,
                                        ),
                                        Container(
                                          // color: Colors.red,
                                          alignment: Alignment.center,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              90 /
                                              100,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0),
                                            child: Text(
                                              AppLanguage.uploadCoverImageMsg[
                                                  language],
                                              style: const TextStyle(
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      AppColor.secondaryColor),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              80 /
                                              100,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  coverImagePickerBottomSheet();
                                                },
                                                child: SizedBox(
                                                  width: screenWidth > 600
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          10 /
                                                          100
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          15 /
                                                          100,
                                                  height: screenWidth > 600
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          10 /
                                                          100
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          15 /
                                                          100,
                                                  child: Image.asset(
                                                    AppImage.addImageIcon,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              2 /
                                              100,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                90 /
                                                100,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                18 /
                                                100,
                                        child: Image.file(
                                          File(coverImage!.path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    //cross icon
                                    Positioned(
                                      top: 0,
                                      right: MediaQuery.of(context).size.width *
                                          3 /
                                          100,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            coverImage = null;
                                          });
                                        },
                                        child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                6 /
                                                100,
                                            child: Image.asset(
                                                AppImage.cancelRedIcon)),
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),

                          //!============upload image container
                          if (serverImageList.length < 7)
                            GestureDetector(
                              onTap: () {
                                imagePickerBottomSheet();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width *
                                    90 /
                                    100,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    color: AppColor.textColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              2 /
                                              100,
                                    ),
                                    Container(
                                      // color: Colors.red,
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width *
                                          90 /
                                          100,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: Text(
                                          AppLanguage.uploadImageMsg[language],
                                          style: const TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.secondaryColor),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          80 /
                                          100,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              imagePickerBottomSheet();
                                            },
                                            child: SizedBox(
                                              width: screenWidth > 600
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      10 /
                                                      100
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      15 /
                                                      100,
                                              height: screenWidth > 600
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      10 /
                                                      100
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      15 /
                                                      100,
                                              child: Image.asset(
                                                AppImage.addImageIcon,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              2 /
                                              100,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),

                          //!==============add image==========
                          if (serverImageList.isNotEmpty)
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              child: Text(
                                AppLanguage.addMoreText[language],
                                style: const TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.primaryColor),
                              ),
                            ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),

                          //!list
                          if (serverImageList.isNotEmpty)
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 100 / 100,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: screenWidth > 600 ? 38 : 20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: List.generate(
                                        serverImageList.length, (index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 6.0),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              // color: Colors.red,
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
                                                children: [
                                                  //image upload
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    child: SizedBox(
                                                      width: screenWidth > 600
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              10 /
                                                              100
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              15 /
                                                              100,
                                                      height: screenWidth > 600
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              10 /
                                                              100
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              15 /
                                                              100,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: Image.file(
                                                          File(serverImageList[
                                                                  index]
                                                              .path),
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  //cancel button
                                                  Positioned(
                                                    right: 0,
                                                    top: 0,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          serverImageList.removeWhere(
                                                              (element) =>
                                                                  element
                                                                      .path ==
                                                                  serverImageList[
                                                                          index]
                                                                      .path);
                                                        });
                                                      },
                                                      child: SizedBox(
                                                        width: screenWidth > 600
                                                            ? MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                4 /
                                                                100
                                                            : MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                5 /
                                                                100,
                                                        height: screenWidth >
                                                                600
                                                            ? MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                4 /
                                                                100
                                                            : MediaQuery.of(
                                                                        context)
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
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),

                          //!==============advertisement type==========
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 1 / 100),

                          //!================Enter Captain Name in English field
                          CustomTextFormFieldBlackWidth(
                              controller: guardEnglishNameTextController,
                              hintText:
                                  "${AppLanguage.enterGuardNameinEnglishText[language]}*",
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
                              controller: guardArabicNameTextController,
                              hintText: AppLanguage
                                  .enterGuardNameinArabicText[language],
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
                              controller: guardNumberTextController,
                              hintText:
                                  "${AppLanguage.enterGuardNumberText[language]}*",
                              keyboardtype: TextInputType.number,
                              maxLength: AppConstant.mobileLength,
                              fillColorStatus: 0,
                              inputFormatter: AppConstant.onlyDigitFormatter,
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

                          //!gender selection
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

                                //female
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

                                //company
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

                          //!line
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

                          //!=== nationality===
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
                                      "${AppLanguage.nationalityText[language]}*",
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
                                  hintText: AppLanguage
                                      .chooseDestinationText[language],
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

                          //!=== select boat===
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
                              controller: propertyTextEditingController,
                              onTap: () {
                                dropDownModelForProperty(context, screenWidth);
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
                                      AppLanguage.choosepropertyText[language],
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
                                      dropDownModelForProperty(
                                          context, screenWidth);
                                    },
                                  )),
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),

                          //!=== select city===
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
                                      AppLanguage.selectCityText[language],
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
                                      String text =
                                          nationalityTextEditingController.text;
                                      if (text.isEmpty) {
                                        SnackBarToastMessage.showSnackBar(
                                            context,
                                            AppLanguage
                                                .nationalityMsg[language]);
                                      } else {
                                        dropDownModelForCity(
                                            context, screenWidth);
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
                              controller: locationTextEditingController,
                              onTap: () {
                                setState(() {
                                  mapshow = true;
                                });

                                alertBoxsearch(context);
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
                                  hintText: AppLanguage
                                      .propertylocationText[language],
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
                                      alertBoxsearch(context);
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
                                Text(
                                  "${AppLanguage.maxNumberOfPeopleText[language]}*",
                                  style: const TextStyle(
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
                                      AppLanguage.adultText[language],
                                      style: const TextStyle(
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
                                                    .withOpacity(0.2),
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
                                                    .withOpacity(0.2),
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
                                const Divider(
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
                                      AppLanguage.childText[language],
                                      style: const TextStyle(
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
                                                    .withOpacity(0.2),
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
                                                    .withOpacity(0.2),
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
                                const Divider(
                                  color: AppColor.boaderColor,
                                  thickness: 1,
                                  height: 1,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 1 / 100),

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

                          //!==============descriptionin arabic==========
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

                          //!----------- Message Input Arabic-------------
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
                                  MediaQuery.of(context).size.height * 2 / 100),

                          //!================enter coupon code
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            height:
                                MediaQuery.of(context).size.height * 5.5 / 100,
                            child: TextFormField(
                              readOnly: false,
                              style: const TextStyle(
                                height: 1.1,
                                color: AppColor.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.text,
                              controller: couponCodeTextEditingController,
                              maxLength: 8,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9]')),
                              ],
                              onChanged: (value) {
                                if (value.length == 8) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  validateCouponApiCall(userId, value);
                                }
                              },
                              decoration: InputDecoration(
                                border: const UnderlineInputBorder(
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
                                    AppLanguage.enterCouponCodeText[language],
                                hintStyle: AppConstant.textFilledStyle,
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),

                          //!Start end date pickers
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
                                        inputFormatters:
                                            AppConstant.onlyDigitFormatter,
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
                              inputFormatter: AppConstant.onlyDigitFormatter,
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
                                addAdvertisementValidation(
                                  coverImage,
                                  serverImageList,
                                  guardEnglishNameTextController.text,
                                  guardArabicNameTextController.text,
                                  guardNumberTextController.text,
                                  isSelectedGender,
                                  nationalityTextEditingController.text,
                                  destinationTextEditingController.text,
                                  propertyTextEditingController.text,
                                  locationTextEditingController.text,
                                  cityTextEditingController.text,
                                  maxNumberTextController.text,
                                  messageTextEditingController.text,
                                  messageArabicTextEditingController.text,
                                  couponCodeTextEditingController.text,
                                  startDateController.text,
                                  endDateController.text,
                                  coupanDiscountTextEditingController.text,
                                  discountTextEditingController.text,
                                );
                              }),
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

  void dropDownModelForNationality(BuildContext context, screenWidth) {
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
                            text: AppLanguage.nationalityText[language],
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
                                  searchResultCountry(input);
                                } else {
                                  nationsList = nationsSearchList;
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
                            itemCount: nationsList.length,
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
                                        isSelectedNationality =
                                            nationsList[index]["country_id"];
                                        nationalityTextEditingController.text =
                                            nationsList[index]['country_name']
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
                                            nationsList[index]['country_name']
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
                                            child: isSelectedNationality ==
                                                    nationsList[index]
                                                        ["country_id"]
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
                                  if (index < nationsList.length)
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

  void dropDownModelForTrip(BuildContext context, screenWidth, screenHeight) {
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
                                        AppLanguage.activityText[language],
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
                            controller: searchActivityTextEditingController,
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
                                  // searchResultActivity(input);
                                } else {
                                  activityList = activitySearchList;
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
                                if (activityList.isNotEmpty)
                                  Wrap(
                                    children: [
                                      ...List.generate(activityList.length,
                                          (index) {
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
                                                  if (selectedActivityList
                                                      .contains(activityList[
                                                              index]
                                                          ["trip_type_id"])) {
                                                    selectedActivityList.remove(
                                                        activityList[index]
                                                            ["trip_type_id"]);
                                                    selectedActivityNameList
                                                        .remove(activityList[
                                                                    index]
                                                                ['name_english']
                                                            [language]);
                                                  } else {
                                                    selectedActivityList.add(
                                                        activityList[index]
                                                            ["trip_type_id"]);
                                                    selectedActivityNameList
                                                        .add(activityList[index]
                                                                ['name_english']
                                                            [language]);
                                                  }
                                                  activityTextEditingController
                                                          .text =
                                                      selectedActivityNameList
                                                          .join(", ");
                                                  // Navigator.pop(context);
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
                                                      activityList[index]
                                                              ['name_english']
                                                          [language],
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontSize: 17,
                                                        color: AppColor
                                                            .primaryColor,
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
                                                      child: selectedActivityList
                                                              .contains(
                                                                  activityList[
                                                                          index]
                                                                      [
                                                                      "trip_type_id"])
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
                                            if (index < activityList.length)
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
                                            if (index ==
                                                activityList.length - 1)
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    8 /
                                                    100,
                                              ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),

                                if (activityList.isEmpty)
                                  Column(
                                    children: [
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              20 /
                                              100),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                20 /
                                                100,
                                        height:
                                            MediaQuery.of(context).size.width *
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
                        AppButton(
                            text: AppLanguage.continueText[language],
                            onPress: () {
                              Navigator.pop(context);
                            }),
                        SizedBox(
                          height: screenHeight * 3 / 100,
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
                            text: AppLanguage.choosepropertyText[language],
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
                                  ...List.generate(propertyList.length,
                                      (index) {
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
                                            GestureDetector(
                                              onTap: () {
                                                selectBoat(index);
                                                Navigator.pop(context);
                                              },
                                              child: Container(
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
                                                    color: isSelectedProperty ==
                                                            propertyList[index]
                                                                ['property_id']
                                                        ? AppColor.themeColor
                                                        : AppColor
                                                            .secondaryColor,
                                                    border: Border.all(
                                                        width: 1,
                                                        color: AppColor
                                                            .textLightColor),
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
                                                                80 /
                                                                100,
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  color: AppColor
                                                                      .transparent,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      80 /
                                                                      100,
                                                                  child: Text(
                                                                    propertyList[index]
                                                                            [
                                                                            'property_name_english'] ??
                                                                        "",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: isSelectedProperty == propertyList[index]['property_id']
                                                                            ? AppColor
                                                                                .secondaryColor
                                                                            : AppColor
                                                                                .primaryColor,
                                                                        fontFamily:
                                                                            AppFont.fontFamily),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  color: AppColor
                                                                      .transparent,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      80 /
                                                                      100,
                                                                  child: Text(
                                                                    "${propertyList[index]['property_type_name'] ?? ""}",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: isSelectedProperty == propertyList[index]['property_id']
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
                                                        ],
                                                      ),
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
      isSelectedProperty = propertyList[index]['property_id'];
      propertyTextEditingController.text =
          propertyList[index]['property_name_english'];
      // boatCapacity = propertyList[index]['boat_capacity'].toString().trim();
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
                                  cityList = citySearchList;
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
                                        AppLanguage.destinationText[language],
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
                            controller: searchDestinationTextEditingController,
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
                                  searchResultDestination(input);
                                } else {
                                  destinationList = searchDestinationList;
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
                                    ...List.generate(destinationList.length,
                                        (index) {
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
                                                isSelectedDestination =
                                                    destinationList[index]
                                                        ["destination_id"];
                                                destinationTextEditingController
                                                        .text =
                                                    destinationList[index]
                                                            ['destination']
                                                        [language];
                                                // activityTextEditingController
                                                //     .clear();
                                                // selectedActivityNameList.clear();
                                                // selectedActivityList.clear();
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
                                                    destinationList[index]
                                                            ['destination']
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
                                                    child: isSelectedDestination ==
                                                            destinationList[
                                                                    index][
                                                                "destination_id"]
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
                                          if (index < destinationList.length)
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

  void alertBoxsearch(BuildContext context) {
    print("Opening bottom sheet...");

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: false,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, StateSetter modalSetState) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 3 / 100,
                      ),
                      CustomAppHeader(
                        text: AppLanguage.locationText[language],
                        onPress: () {
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            if (mapshow)
                              GoogleMap(
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: false,
                                mapType: MapType.normal,
                                initialCameraPosition: CameraPosition(
                                  target: initialPosition,
                                  zoom: 15.0,
                                ),
                                onMapCreated: (controller) {
                                  modalSetState(() {
                                    mapController = controller;
                                  });
                                },
                                onTap: (LatLng tappedLocation) {
                                  // When user taps on map, move pin and get address
                                  modalSetState(() {
                                    latitudex = tappedLocation.latitude;
                                    longtitudex = tappedLocation.longitude;
                                    initialPosition = tappedLocation;
                                  });
                                  _getAddressFromLatLng(
                                    Position(
                                      longitude: tappedLocation.longitude,
                                      latitude: tappedLocation.latitude,
                                      timestamp: DateTime.now(),
                                      accuracy: 0,
                                      altitude: 0,
                                      altitudeAccuracy: 0,
                                      heading: 0,
                                      speed: 0,
                                      speedAccuracy: 0,
                                      headingAccuracy: 0,
                                    ),
                                    modalSetState,
                                  );
                                },
                                markers: {
                                  Marker(
                                    markerId:
                                        const MarkerId('selected_location'),
                                    position: LatLng(latitudex, longtitudex),
                                    draggable: true,
                                    icon: BitmapDescriptor.defaultMarkerWithHue(
                                        BitmapDescriptor.hueRed),
                                    onDragEnd: (LatLng newPosition) {
                                      modalSetState(() {
                                        latitudex = newPosition.latitude;
                                        longtitudex = newPosition.longitude;
                                        initialPosition = newPosition;
                                      });
                                      _getAddressFromLatLng(
                                        Position(
                                          longitude: newPosition.longitude,
                                          latitude: newPosition.latitude,
                                          timestamp: DateTime.now(),
                                          accuracy: 0,
                                          altitude: 0,
                                          altitudeAccuracy: 0,
                                          heading: 0,
                                          speed: 0,
                                          speedAccuracy: 0,
                                          headingAccuracy: 0,
                                        ),
                                        modalSetState,
                                      );
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                  ),
                                },
                              ),
                            Column(
                              children: [
                                const SizedBox(height: 15),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      controller: searchController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            left: 16,
                                            top: 14,
                                            bottom: 14,
                                            right: 10),
                                        border: InputBorder.none,
                                        hintText: AppLanguage
                                            .searchLocation[language],
                                        hintStyle:
                                            TextStyle(color: Colors.grey[600]),
                                        prefixIcon: Icon(Icons.search,
                                            color: Colors.grey[600]),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            modalSetState(() {
                                              searchController.clear();
                                              predictions.clear();
                                            });
                                          },
                                        ),
                                      ),
                                      onChanged: (value) {
                                        fetchPlaceSuggestionsWithCallback(
                                            value, modalSetState);
                                        if (_debounce?.isActive ?? false)
                                          _debounce!.cancel();
                                        _debounce = Timer(
                                          const Duration(milliseconds: 300),
                                          () {},
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (predictions.isNotEmpty)
                              Positioned(
                                top: 85,
                                left: 15,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  child: ListView.builder(
                                    itemCount: predictions.length,
                                    itemBuilder: (context, index) {
                                      final suggestion = predictions[index];
                                      return ListTile(
                                        leading: const Icon(Icons.location_on,
                                            color: Colors.red),
                                        title: Text(suggestion['description']),
                                        onTap: () async {
                                          searchController.text =
                                              suggestion['description'];
                                          final placeId =
                                              suggestion['place_id'];
                                          final apiKey = AppConstant.mapkey;

                                          final detailsUrl =
                                              'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
                                          final response = await http
                                              .get(Uri.parse(detailsUrl));

                                          if (response.statusCode == 200) {
                                            final data =
                                                json.decode(response.body);
                                            final location = data['result']
                                                ['geometry']['location'];
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();

                                            modalSetState(() {
                                              latitudex = location['lat'];
                                              longtitudex = location['lng'];
                                              initialPosition = LatLng(
                                                  latitudex, longtitudex);
                                              predictions.clear();
                                            });

                                            mapController?.animateCamera(
                                              CameraUpdate.newCameraPosition(
                                                CameraPosition(
                                                  target: initialPosition,
                                                  zoom: 16,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _getCurrentPosition(
                                              modalSetState),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.13,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.13,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 8,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.my_location,
                                                color: Colors.blue,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.06,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    AppButton(
                                      text: AppLanguage.continueText[language],
                                      onPress: () {
                                        print(searchController.text);
                                        if (searchController.text.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor:
                                                  AppColor.themeColor,
                                              content: Text(
                                                AppLanguage
                                                    .locationMessage[language],
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                          return;
                                        } else {
                                          locationAdreesSet();
                                        }
                                      },
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.03),
                                  ],
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
            );
          },
        );
      },
    );
  }

  Future<void> fetchPlaceSuggestionsWithCallback(
      String input, Function modalSetState) async {
    if (input.isEmpty) {
      modalSetState(() => predictions = []);
      return;
    }

    final apiKey = AppConstant.mapkey;
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        modalSetState(() {
          predictions = data['predictions'];
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _getCurrentPosition([StateSetter? modalSetState]) async {
    // setState(() {
    //   isApiCalling = true;
    // });
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      if (modalSetState != null) {
        // Called from modal
        _getAddressFromLatLng(position, modalSetState);
      } else {
        // Called from initState
        // setState(() => _currentPosition = position);
        _getAddressFromLatLng(position);
      }
    }).catchError((e) {
      print("Line 71");
      debugPrint(e);
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLanguage.loctionPermissionenableText[language])));
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
      print("Line 95${position.latitude}");

      final addressText =
          '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';

      if (modalSetState != null) {
        modalSetState(() {
          latitudex = position.latitude;
          longtitudex = position.longitude;
          initialPosition = LatLng(position.latitude, position.longitude);
          country = addressText;
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
          country = addressText;
          searchController.text = addressText;
          isApiCalling = false;
        });

        mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: initialPosition, zoom: 16.0)));
      }

      print("Line 95${mapshow}");
      print("Line 100000${country}");
    }).catchError((e) {
      print("Line 95");
      debugPrint(e);
    });
  }

  setLoction() {
    setState(() {
      latitudex = 32.44745630896057;
      longtitudex = 14.723027497529984;
      lat = 32.44745630896057;
      long = 14.723027497529984;
      initialPosition = const LatLng(32.44745630896057, 14.723027497529984);
      isApiCalling = false;
      mapshow = true;
    });
  }

  locationAdreesSet() {
    setState(() {
      locationTextEditingController.text = searchController.text;
      lat = latitudex;
      long = longtitudex;
    });
    print("LatLong: $lat and $long");
    Navigator.pop(context);
  }
}
