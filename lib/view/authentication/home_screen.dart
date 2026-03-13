import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:the_boat_ownerside/controller/app_shimmers.dart';
import 'package:the_boat_ownerside/view/propertymodule/property_ongoing_detail_screen.dart';
import 'package:the_boat_ownerside/view/propertymodule/upcoming_detail_screen.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_snack_bar_toast_message.dart';
import '../other_screen/weather_screen.dart';
import '/view/other_screen/upcoming_details.dart';
import '../other_screen/notification.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_language.dart';
import '/view/other_screen/details_screen.dart';
import '../../controller/app_color.dart';
import '../../controller/app_font.dart';
import '../../controller/app_image.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = './HomeScreen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _baseUrl = 'https://!api.open-meteo.com/v1/forecast';
  int toggleStatus = 1;
  int status = 1;
  List<dynamic> ongoingTripsList = <dynamic>[];
  List<dynamic> upcomingTripsList = <dynamic>[];
  bool isApiCalling = false;
  bool isLoading = true;
  int userId = 0;
  dynamic data;
  dynamic userDataArr;
  int viewHome = 0;
  int manageHome = 0;
  int userType = 0;
  dynamic permissions = {};
  double lat = 22.7196;
  double long = 75.8577;
  var weatherData;
  dynamic cityData = {};
  int notificationCount = 0;
  dynamic temperatureData = {};

  int selectedTab = 0;
  @override
  void initState() {
    super.initState();
    getUserDetails();
    fetchLocation();
  }

  //!----------------------------GET USER DETAILS--------------------------------//!
  Future<dynamic> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    data = prefs.getString("userDetails");

    //! print("userDetails $userDetails");
    if (data == null) {
      //! print("worked");
      //! SnackBarToastMessage.showSnackBar(
      //!     context, AppLanguage.notRegisteredMsg[language]);
      //! Navigator.push(
      //!     context, MaterialPageRoute(builder: (context) => const Login()));
    } else {
      userDataArr = jsonDecode(data);
      userId = userDataArr['user_id'] ?? 0;
      userType = userDataArr['user_type'] ?? 0;
    }

    //! print("userDataArr $userDataArr");
    profileApiCall(userId);
    setState(() {});
  }

  //!------------------------View Profile API CALL--------------------------------//!
  Future<void> profileApiCall(userId) async {
    setState(() {
      isLoading = true;
    });
    Uri url =
        Uri.parse("${AppConfigProvider.apiUrl}view_profile?user_id=$userId");

    String token = AppConstant.token;

    if (token.isEmpty) {
      //! return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token', //! Use 'Bearer' if required
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);

        if (res['success'] == true) {
          var item = res['user_arr'];
          permissions = (item != "NA") ? item : {};

          viewHome = permissions['view_home'] ?? 0;
          manageHome = permissions['manage_home'] ?? 0;

          if (userType == 3 ||
              (userType == 2 && manageHome == 1) ||
              (userType == 2 && viewHome == 1)) {
            homePageApiCall(userId);
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
          //! ignore: use_build_context_synchronously
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          if (res['active_status'] == 0) {
            localstorageclearbutton();
            //! Navigator.push(context,
            //!     MaterialPageRoute(builder: (context) => const Login()));
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

//!-----------------Sign Out-----------------------
  localstorageclearbutton() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userDetails');
    prefs.remove('password');

    log("Worked");

    Navigator.push(
      //! ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  //!------------------------HOME PAGE API CALL--------------------------------//!
  Future<void> homePageApiCall(userId) async {
    setState(() {
      isApiCalling = true;
      isLoading = true;
    });
    Uri url =
        Uri.parse("${AppConfigProvider.apiUrl}home_page_api?user_id=$userId");

    print("URL $url");

    String token = AppConstant.token;

    if (token.isEmpty) {
      //! return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token', //! Use 'Bearer' if required
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        dynamic res = jsonDecode(response.body);

        if (res['success'] == true) {
          var item = res['upcoming_trip'];
          upcomingTripsList = (item != "NA") ? item : [];
          item = res['ongoing_trip'];
          ongoingTripsList = (item != "NA") ? item : [];
          notificationCount = res['notificationCount'];

          setState(() {
            isApiCalling = false;
            isLoading = false;
          });
        } else {
          setState(() {
            isApiCalling = false;
            isLoading = false;
          });
          //! ignore: use_build_context_synchronously
          SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
          if (res['active_status'] == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Login()));
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

  void fetchLocation() async {
    try {
      Position? position = await getCurrentLocation();
      if (position != null) {
        lat = position.latitude;
        long = position.longitude;
        fetchWeather(latitude: lat, longitude: long);
      }
    } catch (e) {}
  }

  //!!get current location
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    //! Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      //! Location services are not enabled
      SnackBarToastMessage.showSnackBar(
          context, 'Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    //! Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        //! Permissions are denied
        SnackBarToastMessage.showSnackBar(
            context, 'Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      //! Permissions are permanently denied
      SnackBarToastMessage.showSnackBar(
          context, 'Location permissions are permanently denied');
      return Future.error('Location permissions are permanently denied');
    }

    //! Get the current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  //!!fetch weather data
  //! Future<void> fetchWeather() async {
  //!   log("fetchWeatherruned");
  //!   //! setState(() {
  //!   //!   isApiCalling = true;
  //!   //! });
  //!   final url =
  //!       'https://!api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$long&units=imperial&appid=${AppConstant.weatherApiKey}';
  //!   final response = await http.get(Uri.parse(url));
  //!   if (response.statusCode == 200) {
  //!     setState(() {
  //!       weatherData = json.decode(response.body);
  //!       cityData = weatherData?['list'][0];
  //!       //! cityName = 'Oxford, Mississippi';
  //!       //! cityName = weatherData?['city']['name'];
  //!       //! pop = (cityData["pop"]);
  //!       String fahrenheitStr = cityData['main']['temp'].toString();
  //!       temperature = convertFahrenheitToCelsius(fahrenheitStr);
  //!       weatherDesc = cityData['weather'][0]['description'].toString();
  //!       isApiCalling = false;
  //!       setState(() {});
  //!       print('weatherData$weatherData');
  //!       //! print('City Name $cityName');
  //!       print('City data $cityData');
  //!     });
  //!   }
  //! }
  //! String convertFahrenheitToCelsius(String fahrenheitStr) {
  //!   try {
  //!     double fahrenheit = double.parse(fahrenheitStr);
  //!     double celsius = (fahrenheit - 32) * 5 / 9;
  //!     return celsius.toStringAsFixed(0); //! Returns Celsius as a string
  //!   } catch (e) {
  //!     return "Invalid input"; //! You can customize this error message
  //!   }
  //! }

  //!!======Fetch Weather API==============
  Future<Map<String, dynamic>?> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    //! Build the URI with all required parameters
    final uri = Uri.parse('$_baseUrl?'
        'latitude=$latitude&'
        'longitude=$longitude&'
        'hourly=temperature_2m,windspeed_10m,winddirection_10m,relativehumidity_2m,weathercode,precipitation,cloudcover&'
        'wind_speed_unit=kmh&'
        'timezone=auto&'
        'apikey=${AppConstant.weatherKey}');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        //! log("weatherData: $data");
        log("getCurrentTemperature${getCurrentWeatherData(data)}");
        temperatureData = getCurrentWeatherData(data);
        AppConstant.temperature =
            temperatureData["temperature"].toStringAsFixed(0);
        AppConstant.unit = temperatureData["temperatureUnit"].toString();
        AppConstant.weatherDesc =
            temperatureData["weatherDescription"].toString();
        AppConstant.weatherIcon = temperatureData["weatherIcon"].toString();
        setState(() {});
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

//! Function to get weather description from WMO weather codes
  String getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return AppLanguage.clearSkyText[language];
      case 1:
        return AppLanguage.mainlyClearText[language];
      case 2:
        return AppLanguage.partlyCloudyText[language];
      case 3:
        return AppLanguage.overcastText[language];
      case 45:
        return AppLanguage.fogText[language];
      case 48:
        return AppLanguage.depositingRimeFogText[language];
      case 51:
        return AppLanguage.lightDrizzleText[language];
      case 53:
        return AppLanguage.moderateDrizzleText[language];
      case 55:
        return AppLanguage.denseDrizzleText[language];
      case 56:
        return AppLanguage.lightFreezingDrizzleText[language];
      case 57:
        return AppLanguage.denseFreezingDrizzleText[language];
      case 61:
        return AppLanguage.slightRainText[language];
      case 63:
        return AppLanguage.moderateRainText[language];
      case 65:
        return AppLanguage.heavyRainText[language];
      case 66:
        return AppLanguage.lightFreezingRainText[language];
      case 67:
        return AppLanguage.heavyFreezingRainText[language];
      case 71:
        return AppLanguage.slightSnowFallText[language];
      case 73:
        return AppLanguage.moderateSnowFallText[language];
      case 75:
        return AppLanguage.heavySnowFallText[language];
      case 77:
        return AppLanguage.snowGrainsText[language];
      case 80:
        return AppLanguage.slightRainShowersText[language];
      case 81:
        return AppLanguage.moderateRainShowersText[language];
      case 82:
        return AppLanguage.violentRainShowersText[language];
      case 85:
        return AppLanguage.slightSnowShowersText[language];
      case 86:
        return AppLanguage.heavySnowShowersText[language];
      case 95:
        return AppLanguage.thunderstormText[language];
      case 96:
        return AppLanguage.thunderstormSlightHailText[language];
      case 99:
        return AppLanguage.thunderstormHeavyHailText[language];
      default:
        return AppLanguage.unknownWeatherText[language];
    }
  }

//! Function to get weather icon based on weather code
  String getWeatherIcon(int weatherCode) {
    switch (weatherCode) {
      case 0:
      case 1:
        return '☀️'; //! Clear/Sunny
      case 2:
      case 3:
        return '⛅'; //! Cloudy
      case 45:
      case 48:
        return '🌫️'; //! Fog
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        return '🌧️'; //! Rain
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return '❄️'; //! Snow
      case 95:
      case 96:
      case 99:
        return '⛈️'; //! Thunderstorm
      default:
        return '🌤️'; //! Default
    }
  }

  Map<String, dynamic>? getCurrentWeatherData(
      Map<String, dynamic> weatherData) {
    try {
      //! Get current date and hour
      final now = DateTime.now();
      final currentHour = now.hour;
      final today = DateTime(now.year, now.month, now.day);

      //! Extract hourly data from the API response
      final hourlyData = weatherData['hourly'] as Map<String, dynamic>?;
      if (hourlyData == null) {
        return null;
      }

      //! Get arrays from API response
      final timeArray = hourlyData['time'] as List<dynamic>?;
      final temperatureArray = hourlyData['temperature_2m'] as List<dynamic>?;
      final weatherCodeArray = hourlyData['weathercode'] as List<dynamic>?;
      final windSpeedArray = hourlyData['windspeed_10m'] as List<dynamic>?;
      final windDirectionArray =
          hourlyData['winddirection_10m'] as List<dynamic>?;
      final humidityArray = hourlyData['relativehumidity_2m'] as List<dynamic>?;
      final precipitationArray = hourlyData['precipitation'] as List<dynamic>?;
      final cloudCoverArray = hourlyData['cloudcover'] as List<dynamic>?;

      if (timeArray == null || temperatureArray == null) {
        return null;
      }

      //! Find the index for current hour of today
      int? currentIndex;

      for (int i = 0; i < timeArray.length; i++) {
        final timeString = timeArray[i] as String;
        final dateTime = DateTime.parse(timeString);

        //! Check if this matches current date and hour
        if (dateTime.year == today.year &&
            dateTime.month == today.month &&
            dateTime.day == today.day &&
            dateTime.hour == currentHour) {
          currentIndex = i;
          break;
        }
      }

      if (currentIndex == null) {
        return null;
      }

      //! Helper function to safely convert numeric values from API
      double? safeToDouble(dynamic value) {
        if (value == null) return null;
        if (value is num) return value.toDouble();
        return null;
      }

      //! Extract current weather data with safe type conversions
      final currentTemperature = safeToDouble(temperatureArray[currentIndex]);
      final weatherCode = weatherCodeArray?[currentIndex] as int? ?? 0;
      final windSpeed = safeToDouble(windSpeedArray?[currentIndex]);
      final windDirection = safeToDouble(windDirectionArray?[currentIndex]);
      final humidity = safeToDouble(humidityArray?[currentIndex]);
      final precipitation = safeToDouble(precipitationArray?[currentIndex]);
      final cloudCover = safeToDouble(cloudCoverArray?[currentIndex]);

      if (currentTemperature == null) {
        return null;
      }

      //! Format current date
      final formattedDate =
          '${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}';

      return {
        'date': formattedDate,
        'hour': currentHour,
        'temperature': currentTemperature,
        'temperatureUnit': '°C',
        'weatherCode': weatherCode,
        'weatherDescription': getWeatherDescription(weatherCode),
        'weatherIcon': getWeatherIcon(weatherCode),
        'windSpeed': windSpeed,
        'windSpeedUnit': 'km/h',
        'windDirection': windDirection,
        'humidity': humidity,
        'humidityUnit': '%',
        'precipitation': precipitation ?? 0.0,
        'precipitationUnit': 'mm',
        'cloudCover': cloudCover,
        'cloudCoverUnit': '%',
        'timestamp': timeArray[currentIndex],
      };
    } catch (e) {
      return null;
    }
  }

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  //!------------REFRESH FUNCION---------------//!
  Future<Null> _refreshPage() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(const Duration(seconds: 1));
    getUserDetails();
    return null;
  }

  final List<Map<String, dynamic>> ongoingBookings = [
    {
      'boat_name': 'Greenleaf Villa',
      'boat_type': 'Riyadh – Al Narjis',
      'booking_id': '4567687687',
      'status': 'Ongoing',
      'amount': '200 KWD',
      'date': '2026-02-18',
      'image': AppImage.house2Icon,
      'status_color': AppColor.green,
    },
    {
      'boat_name': 'Palm Resort Chalet',
      'boat_type': 'Jeddah – Obhur',
      'booking_id': '4567687687',
      'status': 'Ongoing',
      'amount': '220 KWD',
      'date': '2024-11-05',
      'image': AppImage.house1Icon,
      'status_color': AppColor.green,
    },
    {
      'boat_name': 'Sunset Farmhouse',
      'boat_type': 'Diriyah – Riyadh',
      'booking_id': '4567687687',
      'status': 'Ongoing',
      'amount': '240 KWD',
      'date': '2024-11-05',
      'image': AppImage.house2Icon,
      'status_color': AppColor.green,
    },
  ];
  final List<Map<String, dynamic>> upcomingBookings = [
    {
      'boat_name': 'Palm Resort Chalet',
      'boat_type': 'Jeddah – Obhur',
      'booking_id': '4567687687',
      'status': 'Upcoming',
      'amount': '200 KWD',
      'date': '2024-11-05',
      'image': AppImage.house1Icon,
      'status_color': AppColor.themeColor, // Orange
    },
    {
      'boat_name': 'Royal Majlis Villa',
      'boat_type': 'Jeddah – Obhur',
      'booking_id': '4567687687',
      'status': 'Upcoming',
      'amount': '220 KWD',
      'date': '2024-11-05',
      'image': AppImage.house2Icon,
      'status_color': AppColor.themeColor,
    },
    {
      'boat_name': 'Oasis Garden Chalet',
      'boat_type': 'Jeddah – Obhur',
      'booking_id': '4567687687',
      'status': 'Upcoming',
      'amount': '240 KWD',
      'date': '2024-11-05',
      'image': AppImage.house1Icon,
      'status_color': AppColor.themeColor,
    },
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    double screenWidth = MediaQuery.of(context).size.width;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return WillPopScope(
      onWillPop: () async {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return true;
      },
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
                  //!image header
                  Container(
                    width: MediaQuery.of(context).size.width * 100 / 100,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(AppImage.headerBgImage),
                            fit: BoxFit.cover),
                        //! color: AppColor.themeColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50))),
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 4 / 100,
                        ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const WeatherScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1 /
                                                100,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                65 /
                                                100,
                                        child: Row(
                                          children: [
                                            Text(
                                              AppConstant.weatherIcon,
                                              style: const TextStyle(
                                                  color:
                                                      AppColor.secondaryColor,
                                                  fontSize: 34,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily:
                                                      AppFont.fontFamily),
                                            ),
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    2 /
                                                    100),
                                            Text(
                                              "${AppConstant.temperature}${AppConstant.unit}",
                                              style: const TextStyle(
                                                  color:
                                                      AppColor.secondaryColor,
                                                  fontSize: 42,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily:
                                                      AppFont.fontFamily),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    notificationCount = 0;
                                  });
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Notifications()));
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      alignment: Alignment.centerRight,
                                      width: MediaQuery.of(context).size.width *
                                          10 /
                                          100,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              9 /
                                              100,
                                      child: Image.asset(
                                          AppImage.deactiveNotificationIcon),
                                    ),
                                    if (notificationCount != 0)
                                      Positioned(
                                        right: 0,
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: screenWidth * 5 / 100,
                                          height: screenWidth * 5 / 100,
                                          decoration: BoxDecoration(
                                              color: AppColor.redcolor,
                                              borderRadius:
                                                  BorderRadius.circular(100)),
                                          child: Text(
                                            notificationCount > 9
                                                ? "9+"
                                                : "$notificationCount",
                                            style: const TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.secondaryColor),
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        //!sunny cloud text
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Text(
                            AppConstant.weatherDesc,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColor.secondaryColor,
                                fontFamily: AppFont.fontFamily),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 3 / 100,
                        ),

                        //!toggle buttons
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //! Sea
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    status = 1;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width *
                                      42 /
                                      100,
                                  decoration: BoxDecoration(
                                      color: status == 1
                                          ? AppColor.themeColor
                                          : AppColor.secondaryColor,
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

                              //!property
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    status = 2;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width *
                                      42 /
                                      100,
                                  decoration: BoxDecoration(
                                      color: status == 2
                                          ? AppColor.themeColor
                                          : AppColor.secondaryColor,
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

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 5 / 100,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 4 / 100,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 90 / 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //! Ongoing
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              toggleStatus = 1;
                              selectedTab = 0;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 42 / 100,
                            decoration: BoxDecoration(
                                color: toggleStatus == 1
                                    ? AppColor.themeColor
                                    : AppColor.secondaryColor,
                                border: Border.all(color: AppColor.themeColor),
                                borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: screenWidth > 600 ? 15 : 8.0),
                              child: Text(
                                AppLanguage.ongoingText[language],
                                style: TextStyle(
                                    fontSize: screenWidth > 600 ? 20 : 14,
                                    fontWeight: FontWeight.w700,
                                    color: toggleStatus == 1
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
                              selectedTab = 1;
                              toggleStatus = 2;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 42 / 100,
                            decoration: BoxDecoration(
                                color: toggleStatus == 2
                                    ? AppColor.themeColor
                                    : AppColor.secondaryColor,
                                border: Border.all(color: AppColor.themeColor),
                                borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: screenWidth > 600 ? 15 : 8.0),
                              child: Text(
                                AppLanguage.upcomingText[language],
                                style: TextStyle(
                                    fontSize: screenWidth > 600 ? 20 : 14,
                                    fontWeight: FontWeight.w700,
                                    color: toggleStatus == 2
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

                  SizedBox(height: size.height * 0.02),

                  // ...bookings.map((booking) => _buildBookingCard(
                  //       context,
                  //       size,
                  //       booking,
                  //     )),
                  // upcoming Booking cards
                  // ...upcomingBookings
                  //     .map((booking) => _buildUpcomingBookingCard(
                  //           size,
                  //           booking,
                  //         )),

                  if (status == 1) ...[
                    isLoading
                        ? tripsShimmerEffect(context)
                        : Expanded(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              3 /
                                              100),

                                  //!ongoing list
                                  if (toggleStatus == 1)
                                    (ongoingTripsList.isNotEmpty)
                                        ? Wrap(
                                            children: [
                                              ...List.generate(
                                                  ongoingTripsList.length,
                                                  (index) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    //!coupon card
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              3 /
                                                              100,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (userType == 3 ||
                                                                (userType ==
                                                                        2 &&
                                                                    manageHome ==
                                                                        1)) {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          DetailsScreen(
                                                                    tripId: ongoingTripsList[index]
                                                                            [
                                                                            'trip_booking_id']
                                                                        .toString(),
                                                                  ),
                                                                ),
                                                              );
                                                            }
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
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 7.0,
                                                                    style: BorderStyle
                                                                        .solid),
                                                                boxShadow: const [
                                                                  BoxShadow(
                                                                    color: Color(
                                                                        0xffBEC3C7),
                                                                    blurRadius:
                                                                        9.0,
                                                                    offset:
                                                                        Offset(
                                                                            1,
                                                                            0),
                                                                  ),
                                                                ], //!BoxShadow
                                                                color: AppColor
                                                                    .secondaryColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child: SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    80 /
                                                                    100,
                                                                child: Row(
                                                                  children: [
                                                                    //!image
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          15 /
                                                                          100,
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          15 /
                                                                          100,
                                                                      decoration: BoxDecoration(
                                                                          //! color: Colors.red,
                                                                          borderRadius: BorderRadius.circular(10)),
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                          child: ongoingTripsList[index]['trip_image'] != null
                                                                              ? Image.network(
                                                                                  '${AppConfigProvider.imageURL}${ongoingTripsList[index]['trip_image']}',
                                                                                  fit: BoxFit.cover,
                                                                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                                                    if (loadingProgress == null) {
                                                                                      return child;
                                                                                    } else {
                                                                                      return Shimmer.fromColors(
                                                                                        baseColor: Colors.grey.shade300,
                                                                                        highlightColor: Colors.grey.shade100,
                                                                                        child: Container(
                                                                                          color: Colors.grey.shade300,
                                                                                        ),
                                                                                      );
                                                                                    }
                                                                                  },
                                                                                )
                                                                              : Image.asset(
                                                                                  AppImage.imageFrame,
                                                                                  fit: BoxFit.cover,
                                                                                ),
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

                                                                    //!left side
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          40 /
                                                                          100,
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          SizedBox(
                                                                            width: MediaQuery.of(context).size.width *
                                                                                40 /
                                                                                100,
                                                                            child:
                                                                                Text(
                                                                              ongoingTripsList[index]['boat_name_english'],
                                                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColor.primaryColor, fontFamily: AppFont.fontFamily),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width: MediaQuery.of(context).size.width *
                                                                                40 /
                                                                                100,
                                                                            child:
                                                                                const Text(
                                                                              "Boat",
                                                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColor.textColor, fontFamily: AppFont.fontFamily),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height: MediaQuery.of(context).size.height *
                                                                                .5 /
                                                                                100,
                                                                          ),
                                                                          SizedBox(
                                                                            width: MediaQuery.of(context).size.width *
                                                                                40 /
                                                                                100,
                                                                            child:
                                                                                Text(
                                                                              ongoingTripsList[index]['random_booking_id'].toString(),
                                                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColor.primaryColor, fontFamily: AppFont.fontFamily),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),

                                                                    //!right side
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          23 /
                                                                          100,
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                        children: [
                                                                          SizedBox(
                                                                            width: MediaQuery.of(context).size.width *
                                                                                23 /
                                                                                100,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(bottom: 2.0),
                                                                              child: Text(
                                                                                AppLanguage.todayText[language],
                                                                                textAlign: TextAlign.end,
                                                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColor.green, fontFamily: AppFont.fontFamily),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width: MediaQuery.of(context).size.width *
                                                                                23 /
                                                                                100,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(bottom: 2.0),
                                                                              child: Text(
                                                                                "KD${ongoingTripsList[index]['total_amount']}",
                                                                                textAlign: TextAlign.end,
                                                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColor.cyan, fontFamily: AppFont.fontFamily),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width: MediaQuery.of(context).size.width *
                                                                                23 /
                                                                                100,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(bottom: 2.0),
                                                                              child: Text(
                                                                                ongoingTripsList[index]['booking_date'],
                                                                                textAlign: TextAlign.end,
                                                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColor.textColor, fontFamily: AppFont.fontFamily),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              3 /
                                                              100,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              3 /
                                                              100,
                                                    )
                                                  ],
                                                );
                                              }),
                                            ],
                                          )
                                        : Column(
                                            children: [
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      20 /
                                                      100),
                                              //!!text msg
                                              SizedBox(
                                                width: screenWidth * 70 / 100,
                                                child: Text(
                                                  AppLanguage
                                                      .homeNodataMsg[language],
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColor
                                                          .primaryColor),
                                                ),
                                              ),
                                            ],
                                          ),

                                  //!upcoming list
                                  if (toggleStatus == 2)
                                    (upcomingTripsList.isNotEmpty)
                                        ? Wrap(
                                            children: [
                                              ...List.generate(
                                                  upcomingTripsList.length,
                                                  (index) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    //!coupon card
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              3 /
                                                              100,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (userType == 3 ||
                                                                (userType ==
                                                                        2 &&
                                                                    manageHome ==
                                                                        1)) {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          UpcomingDetailsScreen(
                                                                            tripId:
                                                                                upcomingTripsList[index]['trip_booking_id'].toString(),
                                                                          )));
                                                            }
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
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 7.0,
                                                                    style: BorderStyle
                                                                        .solid),
                                                                boxShadow: const [
                                                                  BoxShadow(
                                                                    color: Color(
                                                                        0xffBEC3C7),
                                                                    blurRadius:
                                                                        9.0,
                                                                    offset:
                                                                        Offset(
                                                                            1,
                                                                            0),
                                                                  ),
                                                                ], //!BoxShadow
                                                                color: AppColor
                                                                    .secondaryColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child: SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    80 /
                                                                    100,
                                                                child: Row(
                                                                  children: [
                                                                    //!image
                                                                    Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          15 /
                                                                          100,
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          15 /
                                                                          100,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(10)),
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                          child: upcomingTripsList[index]['trip_image'] != null
                                                                              ? Image.network(
                                                                                  '${AppConfigProvider.imageURL}${upcomingTripsList[index]['trip_image']}',
                                                                                  fit: BoxFit.cover,
                                                                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                                                    if (loadingProgress == null) {
                                                                                      return child;
                                                                                    } else {
                                                                                      return Shimmer.fromColors(
                                                                                        baseColor: Colors.grey.shade300,
                                                                                        highlightColor: Colors.grey.shade100,
                                                                                        child: Container(
                                                                                          color: Colors.grey.shade300,
                                                                                        ),
                                                                                      );
                                                                                    }
                                                                                  },
                                                                                )
                                                                              : Image.asset(
                                                                                  AppImage.imageFrame,
                                                                                  fit: BoxFit.cover,
                                                                                ),
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

                                                                    //!left side
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          40 /
                                                                          100,
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          SizedBox(
                                                                            width: MediaQuery.of(context).size.width *
                                                                                40 /
                                                                                100,
                                                                            child:
                                                                                Text(
                                                                              upcomingTripsList[index]['boat_name_english'],
                                                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColor.primaryColor, fontFamily: AppFont.fontFamily),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width: MediaQuery.of(context).size.width *
                                                                                40 /
                                                                                100,
                                                                            child:
                                                                                Text(
                                                                              AppLanguage.boatText[language],
                                                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColor.textColor, fontFamily: AppFont.fontFamily),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height: MediaQuery.of(context).size.height *
                                                                                .5 /
                                                                                100,
                                                                          ),
                                                                          SizedBox(
                                                                            width: MediaQuery.of(context).size.width *
                                                                                40 /
                                                                                100,
                                                                            child:
                                                                                Text(
                                                                              upcomingTripsList[index]['random_booking_id'].toString(),
                                                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColor.primaryColor, fontFamily: AppFont.fontFamily),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),

                                                                    //!right side
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          23 /
                                                                          100,
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                        children: [
                                                                          SizedBox(
                                                                            width: MediaQuery.of(context).size.width *
                                                                                23 /
                                                                                100,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(bottom: 2.0),
                                                                              child: Text(
                                                                                AppLanguage.upcomingText[language],
                                                                                textAlign: TextAlign.end,
                                                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColor.themeColor, fontFamily: AppFont.fontFamily),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width: MediaQuery.of(context).size.width *
                                                                                23 /
                                                                                100,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(bottom: 2.0),
                                                                              child: Text(
                                                                                "KD${upcomingTripsList[index]['total_amount']}",
                                                                                textAlign: TextAlign.end,
                                                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColor.cyan, fontFamily: AppFont.fontFamily),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width: MediaQuery.of(context).size.width *
                                                                                23 /
                                                                                100,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(bottom: 2.0),
                                                                              child: Text(
                                                                                upcomingTripsList[index]['booking_date'],
                                                                                textAlign: TextAlign.end,
                                                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColor.textColor, fontFamily: AppFont.fontFamily),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              3 /
                                                              100,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              3 /
                                                              100,
                                                    )
                                                  ],
                                                );
                                              }),
                                            ],
                                          )
                                        : Column(
                                            children: [
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      20 /
                                                      100),
                                              //!!text msg
                                              SizedBox(
                                                width: screenWidth * 70 / 100,
                                                child: Text(
                                                  AppLanguage
                                                      .homeNodataMsg[language],
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColor
                                                          .primaryColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                ],
                              ),
                            ),
                          ),
                  ] else ...[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Show ongoing or upcoming based on selectedTab
                            ...(selectedTab == 0
                                    ? ongoingBookings
                                    : upcomingBookings)
                                .asMap()
                                .entries
                                .map((entry) => _buildBookingCard(
                                      size,
                                      entry.value,
                                      entry.key,
                                    )),

                            SizedBox(height: size.height * 0.02),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const NoInternetBanner(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Size size, Map<String, dynamic> booking, index) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.01,
      ),
      child: GestureDetector(
        onTap: () {
          if (selectedTab == 0 && index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PropertyDetailsScreen(),
              ),
            );
          } else if (selectedTab == 1 && index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TripStartDetailsScreen(),
              ),
            );
          }
        },
        child: Container(
          padding: EdgeInsets.all(size.width * 0.03),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left - Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  booking['image'],
                  width: size.width * 0.15,
                  height: size.width * 0.15,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(width: size.width * 0.03),

              // Middle - Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['boat_name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    SizedBox(height: size.height * 0.002),
                    Text(
                      booking['boat_type'],
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text(
                      booking['booking_id'],
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Right - Status, Amount, Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    booking['status'],
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w500,
                      color: booking['status_color'],
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    booking['amount'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w600,
                      color: AppColor.cyan,
                    ),
                  ),
                  SizedBox(height: size.height * 0.002),
                  Text(
                    booking['date'],
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingBookingCard(
    Size size,
    Map<String, dynamic> booking,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.01,
      ),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.all(size.width * 0.03),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left - Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  booking['image'],
                  width: size.width * 0.15,
                  height: size.width * 0.15,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(width: size.width * 0.03),

              // Middle - Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['boat_name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    SizedBox(height: size.height * 0.002),
                    Text(
                      booking['boat_type'],
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text(
                      booking['booking_id'],
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w500,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Right - Status, Amount, Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    booking['status'],
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w500,
                      color: booking['status_color'], //  Orange for upcoming
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    booking['amount'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w600,
                      color: AppColor.cyan,
                    ),
                  ),
                  SizedBox(height: size.height * 0.002),
                  Text(
                    booking['date'],
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
