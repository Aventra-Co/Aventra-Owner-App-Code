import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../controller/app_color.dart';
import '../../../controller/app_constant.dart';
import '../../../controller/app_font.dart';
import '../../../controller/app_image.dart';
import '../../../controller/app_language.dart';
import '../../controller/app_button.dart';

class CancelBookingScreen extends StatelessWidget {
  const CancelBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final TextEditingController reasonController = TextEditingController();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height * 7 / 100,
              width: size.width,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Transform.rotate(
                        angle: language == 1 ? 3.1416 : 0,
                        child: SizedBox(
                          width: size.width * 0.07,
                          height: size.width * 0.07,
                          child: Image.asset(
                            AppImage.backIcon,
                            color: AppColor.black,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Cancel Booking',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppFont.fontFamily,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.05), // balance spacer
                  ],
                ),
              ),
            ),

            SizedBox(height: size.height * 0.02),

            // Text field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: reasonController,
                  maxLines: 5,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: AppFont.fontFamily,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Reason for cancel booking',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      fontFamily: AppFont.fontFamily,
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(size.width * 0.04),
                  ),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.04),

            // Submit button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: AppButton(
                  text: AppLanguage.submitButtonText[language], onPress: () {

                    Navigator.pop(context);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
