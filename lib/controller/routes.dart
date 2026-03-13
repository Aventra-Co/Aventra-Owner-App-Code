import 'package:flutter/material.dart';
import '../view/authentication/ResetPassword_screen.dart';
import '../view/authentication/forget_otp_verification.dart';
import '/view/other_screen/add_staff_screen.dart';
import '../view/other_screen/add_advertisement_screen.dart';
import '../view/other_screen/manage_staff_screen.dart';
import '/view/authentication/contact_us_screen.dart';
import '../view/authentication/delete_account_screen.dart';
import '../view/authentication/setting_screen.dart';
import '../view/content_screen/content_screen.dart';
import '/view/authentication/calender_screen.dart';
import '/view/authentication/inbox_screen.dart';
import '/view/authentication/my_ads_screen.dart';
import '/view/authentication/profile_screen.dart';
import '../view/authentication/contact_admin.dart';
import '../view/authentication/edit_profile_screen.dart';
import '../view/authentication/forgot_password_screen.dart';
import '../view/authentication/login_screen.dart';
import '../view/authentication/signup_screen.dart';
import '../view/authentication/home_screen.dart';

final Map<String, WidgetBuilder> routes = {
  Login.routeName: (context) => const Login(),
  Signup.routeName: (context) => const Signup(),
  ContactAdmin.routeName: (context) => const ContactAdmin(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  MyAdsScreen.routeName: (context) => const MyAdsScreen(),
  InboxScreen.routeName: (context) => const InboxScreen(),
  CalenderScreen.routeName: (context) => const CalenderScreen(),
  ProfileScreen.routeName: (context) => const ProfileScreen(),
  EditProfileScreen.routeName: (context) => const EditProfileScreen(),
  SettingScreen.routeName: (context) => const SettingScreen(),
  Content.routeName: (context) => const Content(),
  DeleteAccount.routeName: (context) => const DeleteAccount(),
  ContactUs.routeName: (context) => const ContactUs(),
  ManageStaffScreen.routeName: (context) => const ManageStaffScreen(),
  AddAdvertisementScreen.routeName: (context) => const AddAdvertisementScreen(),
  AddStaffScreen.routeName: (context) => const AddStaffScreen(),
  ForgetOTPVerificationHeader.routeName: (context) =>
      const ForgetOTPVerificationHeader(),
  ResetPasswordHeader.routeName: (context) => const ResetPasswordHeader(),
};
