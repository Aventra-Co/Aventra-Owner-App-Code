import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../helper/apis.dart';
import '../../model/chat_user.dart';
import '../../controller/app_firebase.dart';
import '/view/authentication/login_screen.dart';
import '../../controller/app_color.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_footer.dart';
import '../../controller/app_image.dart';
import '../../controller/one_signal_service.dart';
import '../../view/other_screen/notification.dart';

class Splash extends StatefulWidget {
  static String routeName = './Splash';
  Splash({super.key});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool status = false;
  String username = '';
  bool _isLoginSuccessful = false;
  bool _shouldNavigateToNotifications = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getUserDetails());
  }

  // Check for pending OneSignal notifications
  void _checkPendingNotifications() {
    // Check if there's a pending broadcast notification
    if (OneSignalService.hasPendingBroadcastNotification()) {
      _shouldNavigateToNotifications = true;
      print("Pending broadcast notification detected");
    }
  }

  // Handle navigation after login process
  void _handlePostLoginNavigation() {
    if (_isLoginSuccessful && _shouldNavigateToNotifications) {
      // Navigate to notifications screen
      print("Navigating to notifications after successful login");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Notifications()),
      );
      // Clear the pending notification
      OneSignalService.clearPendingNotifications();
    } else if (_isLoginSuccessful) {
      // Normal flow - go to home
      AppConstant.selectFooterIndex = 0;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyFooterPage(indexOfPage: 0),
        ),
      );
    } else {
      // Login failed - go to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

//-------------------------------GET USER DETAILS-----------------------//
  Future<dynamic> getUserDetails() async {
    // Check for pending notifications first
    _checkPendingNotifications();

    final prefs = await SharedPreferences.getInstance();
    dynamic langId = prefs.getString("language_id");
    if (langId != null) {
      langId = int.parse(langId);
      if (langId == 0) {
        language = 0;
      } else {
        language = 1;
      }
    } else {
      langId = 0;
    }
    dynamic userDetails = prefs.getString("userDetails");
    dynamic password = prefs.getString("password");
    log("$userDetails");

    if (userDetails != null) {
      print("Line 42");
      dynamic data = json.decode(userDetails);
      username = data['username'];
      print("data['username'] $username");
      print("password $password");

      if (data['profile_complete'] == 1) {
        log("line49");
        if (data['otp_verify'] == 1) {
          log("line51");
          await _performLogin(username, password);
        } else {
          _isLoginSuccessful = false;
          _handlePostLoginNavigation();
        }
      } else {
        _isLoginSuccessful = false;
        _handlePostLoginNavigation();
      }
    } else {
      _isLoginSuccessful = false;
      _handlePostLoginNavigation();
    }
  }

  // Separate login function for better organization
  Future<void> _performLogin(String username, String password) async {
    Uri url = Uri.parse("${AppConfigProvider.apiUrl}sign_in");
    print("Url $url");

    try {
      String playeID = AppConstant.playerID.toString();
      print("playeID line number 101 $playeID");
      http.MultipartRequest formData = http.MultipartRequest('POST', url);

      formData.fields['username'] = username.toString();
      formData.fields['password'] = password.toString();
      formData.fields['player_id'] = playeID.toString();
      formData.fields['device_type'] = AppConstant.deviceType.toString();

      log("formData.fields ${formData.fields}");

      http.StreamedResponse response = await formData.send();
      log("response--> $response");
      var responseString = await response.stream.toBytes();
      var res = jsonDecode(utf8.decode(responseString));

      if (response.statusCode == 200) {
        print("res : $res");
        if (res['success'] == true) {
          if (res['userDataArray'] != "NA") {
            // Login successful
            _isLoginSuccessful = true;

            AppConstant.token = res['token'];
            print("AppConstant.token ${AppConstant.token}");
            final prefs = await SharedPreferences.getInstance();
            print("prefs =================>$prefs");
            prefs.setString("userDetails", jsonEncode(res['userDataArray']));
            FirebaseProvider.firebaseCreateUser(true);
            APIs.userArry = res['userDataArray'];
            APIs.user_id = res['userDataArray']['user_id'].toString();
            log("88line${AppConstant.playerID}");

            await updateUser(res['userDataArray'],
                res['userDataArray']['user_id'], AppConstant.playerID);

            if (await userExists(res['userDataArray']['user_id']) && mounted) {
              log("93line${AppConstant.playerID}");
              await updateUser(res['userDataArray'],
                  res['userDataArray']['user_id'], AppConstant.playerID);
              print("mounted $mounted");
            } else {
              await createUser(
                  res['userDataArray']['user_id'], res['userDataArray']);
            }

            // Handle navigation based on notification status
            _handlePostLoginNavigation();
          } else {
            _isLoginSuccessful = false;
            _handlePostLoginNavigation();
          }
        } else {
          _isLoginSuccessful = false;
          _handlePostLoginNavigation();
        }
      } else {
        _isLoginSuccessful = false;
        _handlePostLoginNavigation();
      }
    } catch (e) {
      print("Login error: $e");
      _isLoginSuccessful = false;
      _handlePostLoginNavigation();
    }
  }

  static Future<void> createUser(userid, usserArry) async {
    print("user$usserArry");
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: userid.toString(),
        name: usserArry['fullname'] != null
            ? usserArry['fullname'].toString()
            : "",
        email: usserArry['email'] != null ? usserArry['email'].toString() : "",
        about: "Hey, I'm using We Chat!",
        image: usserArry['image'] != null ? usserArry['image'].toString() : "",
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '',
        mobile: "",
        playerId: AppConstant.playerID,
        groups: []);

    return await firestore
        .collection('users')
        .doc(userid.toString())
        .set(chatUser.toJson());
  }

  static Future<bool> userExists(userid) async {
    var doc = await firestore.collection('users').doc(userid.toString()).get();
    bool exists = doc.exists;

    // Print the status
    print("User exists: $exists");

    return exists;
  }

  static Future<void> updateUser(var usserArrey, userId, playerId) async {
    print("userId$userId");
    try {
      await firestore.collection('users').doc(userId.toString()).update({
        'playerId': playerId.toString(),
        'name': usserArrey['fullname'] != null
            ? usserArrey['fullname'].toString()
            : "",
        'email':
            usserArrey['email'] != null ? usserArrey['email'].toString() : "",
      });
      print("User updated successfully!");
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width * 100 / 100,
        height: MediaQuery.of(context).size.height * 100 / 100,
        decoration: const BoxDecoration(
          color: AppColor.primaryColor,
          image: DecorationImage(
            image: AssetImage(AppImage.newSplash),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width * 40 / 100,
                  height: MediaQuery.of(context).size.width * 40 / 100,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(1000),
                      child: Image.asset(AppImage.applogoImage))),
              if (_shouldNavigateToNotifications)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "Processing notification...",
                    style: TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontSize: 14,
                        color: AppColor.themeColor.withOpacity(0.7)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
