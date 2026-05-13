import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:the_boat_ownerside/firebase_options.dart';
import 'controller/app_color.dart';
import 'controller/app_connectivity.dart';
import 'controller/app_constant.dart';
import 'controller/app_font.dart';
import 'controller/one_signal_service.dart';
import 'controller/route_observer.dart';
import 'controller/routes.dart';
import 'view/authentication/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> initFirebaseAuth() async {
  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
      debugPrint('✅ Firebase Auth: signed in anonymously');
    }
    else {
      debugPrint('✅ Firebase Auth: already signed in');
    }
  }
  catch (e) {
    debugPrint('❌ Firebase Auth failed: $e');
  }
}

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColor.secondaryColor,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    runApp(const MyApp());
    unawaited(initFirebaseAuth());
    unawaited(OneSignalService.initOneSignal());
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

Future<void> initOneSignal() async {
  print("initOneSignal ------ ");
  OneSignal.initialize(AppConstant.oneSignalAppId);

  print("Prompting for Permission");
  await OneSignal.Notifications.requestPermission(true);

  final String? tokenId = OneSignal.User.pushSubscription.id;
  if (tokenId != null) {
    AppConstant.playerID = tokenId;
    print("playerID : ${AppConstant.playerID}");
  }

  OneSignal.User.pushSubscription.addObserver((state) {
    final String? id = state.current.id;
    if (id != null) {
      AppConstant.playerID = id;
      print("playerID updated: ${AppConstant.playerID}");
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData appTheme = ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColor.themeColor,
        brightness: Brightness.light,
      ),
      fontFamily: AppFont.fontFamily,
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      timePickerTheme: const TimePickerThemeData(
        backgroundColor: Colors.white,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.themeColor,
        ),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ConnectionProvider()..initialize()),
      ],
      child: MaterialApp(
        navigatorObservers: [routeObserver],
        title: 'Aventra Owner',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: appTheme,
        darkTheme: appTheme,
        routes: routes,
        home: const AppInitializer(),
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OneSignalService.setAppInitialized(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Splash(); // Your splash screen will handle the rest
  }
}
