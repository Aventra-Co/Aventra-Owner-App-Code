import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:the_boat_ownerside/controller/app_snack_bar_toast_message.dart';
import '../../controller/app_config_provider.dart';
import '../../controller/app_loader.dart';
import '../authentication/login_screen.dart';
import '../../controller/app_button.dart';
import '../../controller/app_footer.dart';
import '../../controller/textinput.dart';
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class EditPropertyAdSecondScreen extends StatefulWidget {
  static String routeName = './EditPropertyAdSecondScreen';

  const EditPropertyAdSecondScreen({
    super.key,
  });

  @override
  State<EditPropertyAdSecondScreen> createState() =>
      _EditPropertyAdSecondScreenState();
}

class _EditPropertyAdSecondScreenState extends State<EditPropertyAdSecondScreen> {
  TextEditingController _timeController = TextEditingController();
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  String sendStartTime = "";
  String sendEndTime = "";
  int tripTime = 0;
  int tripDate = 0;
  DateTime _focusedDay = DateTime.now();
  final List<String> _selectedDateStrings = [];
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  List<List<dynamic>> fetchedData = [];
  List<dynamic> addOnList = [];
  List<int> toCheckBox = [];
  bool isApiCalling = false;
  Map<int, List<TextEditingController>> controllersMap = {}; // key = addon_id
  List<dynamic> selectedAddOns = <dynamic>[];
  int userId = 0;
  dynamic userDetails;
  String? startTimeFormatted;
  String? endTimeFormatted;

  final TextEditingController oneDayController =
      TextEditingController(text: "300 KWD");
  final TextEditingController monthlyController =
      TextEditingController(text: "5000 KWD");
  final TextEditingController weekendController =
      TextEditingController(text: "350 KWD");
  final TextEditingController saturdayController =
      TextEditingController(text: "450 KD");
  final TextEditingController cancelDaysController = TextEditingController();

  bool parking = false;
  bool wifi = false;
  bool microwave = false;
  bool kettle = false;
  bool fridge = false;
  bool coffeeMachine = false;
  bool oneDay = false;
  bool weekend = false;
  bool weekday = false;
  bool fullweek = false;
  int isToggle = 0;

  bool petFriendly = false;
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColor.secondaryColor,
        body: Directionality(
          textDirection:
              language == 1 ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 100 / 100,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  height: MediaQuery.of(context).size.height * 20 / 100,
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
                        height: MediaQuery.of(context).size.height * 4 / 100,
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

                            Container(
                              alignment: Alignment.center,
                              width:
                                  MediaQuery.of(context).size.width * 70 / 100,
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
                              width:
                                  MediaQuery.of(context).size.width * 15 / 100,
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
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.03),

                        // Price heading
                        const Text(
                          "Price",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(height: size.height * 0.015),

                        _buildPriceRow(
                          label: "One day  (2pm till next day 12 afternoon)",
                          // subLabel: "",
                          value: oneDay,
                          onChanged: (val) => setState(() => oneDay = val!),
                          controller: oneDayController,
                          size: size,
                        ),

                        SizedBox(height: size.height * 0.015),

                        _buildPriceRow(
                          label: "Weekday (Sun-Wed)",
                          value: weekday,
                          onChanged: (val) => setState(() => weekday = val!),
                          controller: monthlyController,
                          size: size,
                        ),

                        SizedBox(height: size.height * 0.015),

// Weekend
                        _buildPriceRow(
                          label: "Weekend (Thu-Sat)",
                          value: weekend,
                          onChanged: (val) => setState(() => weekend = val!),
                          controller: weekendController,
                          size: size,
                        ),

                        SizedBox(height: size.height * 0.015),

// Saturday
                        _buildPriceRow(
                          label: "Full week (Sun-Sat)",
                          value: fullweek,
                          onChanged: (val) => setState(() => fullweek = val!),
                          controller: saturdayController,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.02),

                        Text(
                          AppLanguage.whatThisPlaceOffersText[language],
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(height: size.height * 0.015),

                        // Checkboxes - 2 columns
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _buildCheckbox(
                                      AppLanguage.tvText[language], parking,
                                      (val) {
                                    setState(() => parking = val!);
                                  }),
                                  _buildCheckbox(
                                      AppLanguage.wifiText[language], wifi,
                                      (val) {
                                    setState(() => wifi = val!);
                                  }),
                                  _buildCheckbox(
                                      AppLanguage.acText[language], fridge,
                                      (val) {
                                    setState(() => fridge = val!);
                                  }),
                                  _buildCheckbox(
                                      AppLanguage.fridgeText[language], fridge,
                                      (val) {
                                    setState(() => fridge = val!);
                                  }),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildCheckbox(
                                      AppLanguage.beddingText[language],
                                      microwave, (val) {
                                    setState(() => microwave = val!);
                                  }),
                                  _buildCheckbox(
                                      AppLanguage.microwaveText[language],
                                      microwave, (val) {
                                    setState(() => microwave = val!);
                                  }),
                                  _buildCheckbox(
                                      AppLanguage.kettleText[language], kettle,
                                      (val) {
                                    setState(() => kettle = val!);
                                  }),
                                  _buildCheckbox(
                                      AppLanguage.coffeeMachineText[language],
                                      coffeeMachine, (val) {
                                    setState(() => coffeeMachine = val!);
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.03),

                        // Pet Friendly
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              AppLanguage.petFriendlyText[language],
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: size.width * 0.12),
                            Row(
                              children: [
                                /// YES
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isToggle = 0;
                                    });
                                  },
                                  child: const Text(
                                    "Yes",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),

                                SizedBox(width: size.width * 0.02),

                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isToggle = 0;
                                    });
                                  },
                                  child: SizedBox(
                                    width: size.width * 6 / 100,
                                    height: size.width * 6 / 100,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.asset(
                                        isToggle == 0
                                            ? AppImage.markedCircleIcon
                                            : AppImage.circleIcon,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: size.width * 0.05),

                                /// NO
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isToggle = 1;
                                    });
                                  },
                                  child: const Text(
                                    "No",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),

                                SizedBox(width: size.width * 0.02),

                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isToggle = 1;
                                    });
                                  },
                                  child: SizedBox(
                                    width: size.width * 6 / 100,
                                    height: size.width * 6 / 100,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.asset(
                                        isToggle == 1
                                            ? AppImage.markedCircleIcon
                                            : AppImage.circleIcon,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.02),

                        Text(
                          AppLanguage.customerCanceldaysText[language],
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),

                        Row(
                          children: [
                            const Text(
                              "Free to cancel before",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            SizedBox(
                              width: size.width * 0.15,
                              height: size.height * 0.05,
                              child: TextFormField(
                                controller: cancelDaysController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 2,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(0)),
                                    borderSide:
                                        BorderSide(color: AppColor.themeColor),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            const Text(
                              "days",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.03),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: size.height * 0.06,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) =>
                                          MyFooterPage(indexOfPage: 1,))));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.themeColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child:  Text(
                             AppLanguage.submitButtonText[language],
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.08),
                      ],
                    ),
                  ),
                ),

                // Container(
                //   width: double.infinity,
                //   child: const NoInternetBanner(),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontFamily: AppFont.fontFamily,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColor.themeColor,
          side: const BorderSide(
            color: AppColor.themeColor,
            width: 1.5,
          ),
          checkColor: Colors.white,
        ),
      ],
    );
  }

  Widget Customfild(
      String startingText, TextEditingController controller, int id) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 45 / 100,
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 15 / 100,
            child: Text(
              startingText,
              style: const TextStyle(
                color: AppColor.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: AppFont.fontFamily,
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 2 / 100),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 18 / 100,
              height: MediaQuery.of(context).size.height * 5 / 100,
              child: TextFormField(
                readOnly: !toCheckBox.contains(id),
                style: const TextStyle(
                    height: 1.1,
                    color: AppColor.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.number,
                controller: controller,
                onChanged: (value) {
                  fetchAllPrices();
                },
                decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.textColor),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.textColor),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.themeColor),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 7),
                    fillColor: AppColor.secondaryColor,
                    filled: true,
                    counterText: '',
                    hintText: AppLanguage.priceText[language],
                    hintStyle: const TextStyle(
                        color: AppColor.textColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 10)),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // log("$controllersMap");
              setState(() {
                if (toCheckBox.contains(id)) {
                  toCheckBox.remove(id);
                  selectedAddOns.removeWhere((element) =>
                      element['addon_subcategory_id'].toString() ==
                      id.toString());
                  log("Final selectedAddOns: $selectedAddOns");
                } else {
                  toCheckBox.add(id);
                }
              });
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 3 / 100,
              width: MediaQuery.of(context).size.width * 9 / 100,
              child: toCheckBox.contains(id)
                  ? Image.asset(AppImage.tickOrangeIcon)
                  : Image.asset(AppImage.orangeBoxIcon),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required TextEditingController controller,
    required Size size,
  }) {
    const double checkboxSize = 24; // default checkbox visual size

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Checkbox + Label
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.scale(
              scale: 1,
              child: SizedBox(
                width: checkboxSize,
                height: checkboxSize,
                child: Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: value,
                  onChanged: onChanged,
                  activeColor: AppColor.themeColor,
                  side: const BorderSide(
                    color: AppColor.themeColor,
                    width: 1.5,
                  ),
                  checkColor: Colors.white,
                ),
              ),
            ),
            SizedBox(width: size.width * 0.02),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: AppFont.fontFamily,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: size.height * 0.01),

        /// Price Row (EXACT same left alignment as checkbox)
        Padding(
          padding: EdgeInsets.only(right: checkboxSize + size.width * 0.001),
          child: Row(
            children: [
              SizedBox(
                child: const Text(
                  "Price",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: AppFont.fontFamily,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.03),
              SizedBox(
                width: size.width * 0.35,
                height: size.height * 0.05,
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: AppFont.fontFamily,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      borderSide: BorderSide(color: AppColor.themeColor),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: size.height * 0.02),
      ],
    );
  }

  void fetchAllPrices() {
    for (var entry in controllersMap.entries) {
      final addonId = entry.key;
      final controllerList = entry.value;

      final addon = addOnList.firstWhere((e) => e['addon_id'] == addonId);
      final subcategories = addon['subcategories'];

      for (int i = 0; i < controllerList.length; i++) {
        final priceText = controllerList[i].text.trim();
        final subcategoryId = subcategories[i]['addon_subcategory_id'];

        // Check if entry already exists
        final existingIndex = selectedAddOns.indexWhere((element) =>
            element['addon_id'] == addonId.toString() &&
            element['addon_subcategory_id'] == subcategoryId.toString());

        final newEntry = {
          "addon_id": addonId.toString(),
          "addon_subcategory_id": subcategoryId.toString(),
          "price": priceText,
          "checked": "1",
          "checkStatus": "1",
        };

        if (existingIndex != -1) {
          selectedAddOns[existingIndex] = newEntry; // update existing
        } else {
          selectedAddOns.add(newEntry); // add new
        }

        // Optional debug print
        print(
            'Saved: Addon ID: $addonId | Subcategory ID: $subcategoryId | Price: $priceText');
      }
    }

    selectedAddOns.removeWhere((element) {
      final price = element['price']?.toString().trim();
      return price == null || price.isEmpty;
    });

    log("Final selectedAddOns: $selectedAddOns");
  }
}

class CustomTextFormFieldSmallBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  //final int maxLength;
  // final int fillColorStatus;
  final bool readOnly;
  // ignore: prefer_typing_uninitialized_variables
  //var keyboardtype;

  CustomTextFormFieldSmallBox(
      {super.key,
      required this.controller,
      required this.hintText,
      //  required this.keyboardtype,
      //required this.maxLength,
      //  required this.fillColorStatus,
      required this.readOnly});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 18 / 100,
        height: MediaQuery.of(context).size.height * 5 / 100,
        child: TextFormField(
          readOnly: readOnly,
          style: const TextStyle(
              height: 1.1,
              color: AppColor.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w400),
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.number,
          controller: controller,
          onChanged: (value) {},
          decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.textColor),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.textColor),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.themeColor),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 7),
              fillColor: AppColor.secondaryColor,
              filled: true,
              counterText: '',
              hintText: hintText,
              hintStyle: const TextStyle(
                  color: AppColor.textColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 10)),
        ),
      ),
    );
  }
}
