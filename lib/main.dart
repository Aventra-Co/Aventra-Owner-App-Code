import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'controller/app_color.dart';
import 'controller/app_connectivity.dart';
import 'controller/app_constant.dart';
import 'controller/app_font.dart';
import 'controller/one_signal_service.dart';
import 'controller/route_observer.dart';
import 'controller/routes.dart';
import 'view/authentication/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColor.secondaryColor,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  // Initialize OneSignal
  await initOneSignal(AppConstant.oneSignalAppId);
  await OneSignalService.initOneSignal();

  runApp(const MyApp());

// Initialize Firebase first
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: AppConstant.apiKey,
          appId: AppConstant.appId,
          messagingSenderId: AppConstant.messagingSenderId,
          projectId: AppConstant.projectId));
}

Future<void> initOneSignal(oneSignalAppId) async {
  print("initOneSignal ------ ");
  if (AppConstant.deviceType == "android") {
  } else {}
  await OneSignal.shared.setAppId(AppConstant.oneSignalAppId);

  print("Prompting for Permission");
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    print("Accepted permission: $accepted");
  });

  final status = await OneSignal.shared.getDeviceState();
  if (status != null) {
    print("main dart line 41");
    var tokenId = status.userId;
    if (tokenId != null) {
      print("player Id $tokenId");
      print(tokenId);
      AppConstant.playerID = tokenId;
      print("playerID : ${AppConstant.playerID}");
    }
  }

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    final status = await OneSignal.shared.getDeviceState();
    if (status != null) {
      print("status $status");
      final tokenId = status.userId;

      if (tokenId != null) {
        timer.cancel();
        AppConstant.playerID = tokenId;
        print('Interval stopped');
      }
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColor.themeColor),
          fontFamily: AppFont.fontFamily,
        ),
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
