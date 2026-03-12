// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:the_boat_ownerside/view/propertymodule/edit_advertisement_property_screen.dart';
// import 'package:the_boat_ownerside/view/propertymodule/property_advertisement_screen.dart';
// import '../../controller/app_color.dart';
// import '../../controller/app_config_provider.dart';
// import '../../controller/app_constant.dart';
// import '../../controller/app_font.dart';
// import '../../controller/app_image.dart';
// import '../../controller/app_language.dart';
// import '../../controller/app_loader.dart';

// class PropertyList extends StatefulWidget {
//   final List<dynamic> propertyList;
//   final int language;
//   final int viewMyAdd;
//   final int manageMyAd;
//   final int userType;

//   const PropertyList({
//     super.key,
//     required this.propertyList,
//     required this.language,
//     required this.viewMyAdd,
//     required this.manageMyAd,
//     required this.userType,
//   });
//   @override
//   State<PropertyList> createState() => _PropertyListState();
// }

// class _PropertyListState extends State<PropertyList> {
//   List optionsList = [
//     {"id": 1, "title": AppLanguage.editText[language]},
//     {"id": 2, "title": AppLanguage.deleteText[language]},
//     {"id": 3, "title": AppLanguage.backText[language]}
//   ];
//   bool isApiCalling = false;

//   //=============================Delete Boat DETAILS===================================//
//   deleteAdApiCall(tripId) async {
//     setState(() {
//       isApiCalling = true;
//     });

//     Uri url = Uri.parse("${AppConfigProvider.apiUrl}delete_trip");

//     print("Url===> $url");

//     try {
//       http.MultipartRequest formData = http.MultipartRequest('POST', url);
//       formData.fields['trip_id'] = tripId.toString();

//       log("response--==> ${formData.fields}");
//       // print("response--==> ${formData.files}");
//       http.StreamedResponse response = await formData.send();
//       print("response--==> $response");
//       var responseString = await response.stream.toBytes();
//       var res = jsonDecode(utf8.decode(responseString));

//       if (response.statusCode == 200) {
//         print("res : $res");
//         if (res['success'] == true) {
//           getAllTripsApi(userId);
//           SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
//           setState(() {
//             isApiCalling = false;
//           });
//         } else {
//           setState(() {
//             isApiCalling = false;
//           });
//           // ignore: use_build_context_synchronously
//           SnackBarToastMessage.showSnackBar(context, res['msg'][language]);
//           if (res['active_status'] == 0) {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (context) => const Login()));
//           }
//         }
//       } else {
//         setState(() {
//           isApiCalling = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isApiCalling = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ProgressHUD(
//         inAsyncCall: isApiCalling,
//         opacity: 0.5,
//         child: _buildUIScreen(context));
//   }

//   Widget _buildUIScreen(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     double screenWidth = MediaQuery.of(context).size.width;

//     if (widget.propertyList.isEmpty) {
//       return Center(
//         child: Padding(
//           padding: EdgeInsets.only(top: size.height * 0.2),
//           child: Text(
//             AppLanguage.advNodataMsg[language],
//             style: const TextStyle(
//               fontFamily: AppFont.fontFamily,
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: AppColor.primaryColor,
//             ),
//           ),
//         ),
//       );
//     }

//     return ListView.builder(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: EdgeInsets.symmetric(
//         horizontal: size.width * 0.05,
//         vertical: size.height * 0.02,
//       ),
//       itemCount: widget.propertyList.length,
//       itemBuilder: (context, index) {

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Stack(
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     // Navigator.push(
//                     //   context,
//                     //   MaterialPageRoute(
//                     //     builder: (context) => AdvertisementScreen(
//                     //       tripId: widget.propertyList[index]['trip_id'].toString(),
//                     //     ),
//                     //   ),
//                     // );
//                   },
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 90 / 100,
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 5,
//                     ),
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(30),
//                       image: DecorationImage(
//                         image: widget.propertyList[index]['trip_image'] != null
//                             ? NetworkImage(
//                                 "${AppConfigProvider.imageURL}${widget.propertyList[index]['trip_image']}")
//                             : const AssetImage(AppImage.imageFrame)
//                                 as ImageProvider,
//                         fit: BoxFit.cover,
//                         colorFilter: ColorFilter.mode(
//                           Colors.black.withOpacity(0.3),
//                           BlendMode.darken,
//                         ),
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           height: MediaQuery.of(context).size.height * 1 / 100,
//                         ),

//                         // 3 options (edit/delete)
//                         (widget.userType == 3 ||
//                                 (widget.userType == 2 &&
//                                     widget.manageMyAd == 1))
//                             ? SizedBox(
//                                 width: MediaQuery.of(context).size.width *
//                                     80 /
//                                     100,
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     GestureDetector(
//                                       onTap: () {
//                                         optionsBottomSheet(
//                                             context,
//                                             screenWidth,
//                                             widget.propertyList[index]
//                                                 ['trip_id']);
//                                       },
//                                       child: Container(
//                                         width: screenWidth > 600
//                                             ? MediaQuery.of(context)
//                                                     .size
//                                                     .width *
//                                                 5 /
//                                                 100
//                                             : MediaQuery.of(context)
//                                                     .size
//                                                     .width *
//                                                 6 /
//                                                 100,
//                                         height: screenWidth > 600
//                                             ? MediaQuery.of(context)
//                                                     .size
//                                                     .width *
//                                                 5 /
//                                                 100
//                                             : MediaQuery.of(context)
//                                                     .size
//                                                     .width *
//                                                 6 /
//                                                 100,
//                                         decoration: const BoxDecoration(
//                                             color: AppColor.secondaryColor,
//                                             shape: BoxShape.circle),
//                                         child: Image.asset(
//                                           AppImage.menuCircle,
//                                           color: AppColor.themeColor,
//                                           fit: BoxFit.contain,
//                                         ),
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               )
//                             : SizedBox(
//                                 width: MediaQuery.of(context).size.width *
//                                     80 /
//                                     100,
//                                 height: MediaQuery.of(context).size.height *
//                                     3 /
//                                     100,
//                               ),
//                         SizedBox(
//                           height: screenWidth > 600
//                               ? MediaQuery.of(context).size.height * 9 / 100
//                               : MediaQuery.of(context).size.height * 2 / 100,
//                         ),

//                         // Boat name
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width * 80 / 100,
//                           child: Text(
//                             widget.propertyList[index]['boat_name_english'],
//                             style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColor.secondaryColor,
//                                 fontFamily: AppFont.fontFamily),
//                           ),
//                         ),

//                         // City name
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width * 80 / 100,
//                           child: Row(
//                             children: [
//                               Text(
//                                 AppLanguage.pickUpText[language],
//                                 style: const TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w500,
//                                     color: AppColor.secondaryColor,
//                                     fontFamily: AppFont.fontFamily),
//                               ),
//                               const Text(
//                                 " \u2022 ",
//                                 style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w500,
//                                     color: AppColor.secondaryColor,
//                                     fontFamily: AppFont.fontFamily),
//                               ),
//                               SizedBox(
//                                 width: MediaQuery.of(context).size.width *
//                                     63 /
//                                     100,
//                                 child: Text(
//                                   "${widget.propertyList[index]['city_name'][language] ?? ""}",
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w500,
//                                       color: AppColor.secondaryColor,
//                                       fontFamily: AppFont.fontFamily),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         // Advertisement type
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width * 80 / 100,
//                           child: Row(
//                             children: [
//                               Text(
//                                 AppLanguage.advTypeText[language],
//                                 style: const TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w500,
//                                     color: AppColor.secondaryColor,
//                                     fontFamily: AppFont.fontFamily),
//                               ),
//                               const Text(
//                                 " \u2022 ",
//                                 style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w500,
//                                     color: AppColor.secondaryColor,
//                                     fontFamily: AppFont.fontFamily),
//                               ),
//                               SizedBox(
//                                 // width: MediaQuery.of(context)
//                                 //         .size
//                                 //         .width *
//                                 //     6 /
//                                 //     100,
//                                 child: Text(
//                                   widget.propertyList[index]
//                                               ['advertisement_type'] ==
//                                           0
//                                       ? AppLanguage.privateText[language]
//                                       : AppLanguage.publicText[language],
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w500,
//                                       color: AppColor.secondaryColor,
//                                       fontFamily: AppFont.fontFamily),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         // Rating, members, price
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width * 80 / 100,
//                           child: Row(
//                             children: [
//                               if (widget.propertyList[index]['rating']
//                                       .toString() !=
//                                   "0.00")
//                                 Container(
//                                   alignment: Alignment.center,
//                                   decoration: BoxDecoration(
//                                       color: AppColor.secondaryColor
//                                           .withOpacity(.4),
//                                       borderRadius: BorderRadius.circular(20)),
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 8.0, vertical: 2),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         SizedBox(
//                                           width: screenWidth > 600
//                                               ? MediaQuery.of(context)
//                                                       .size
//                                                       .width *
//                                                   2 /
//                                                   100
//                                               : MediaQuery.of(context)
//                                                       .size
//                                                       .width *
//                                                   3 /
//                                                   100,
//                                           height: screenWidth > 600
//                                               ? MediaQuery.of(context)
//                                                       .size
//                                                       .width *
//                                                   2 /
//                                                   100
//                                               : MediaQuery.of(context)
//                                                       .size
//                                                       .width *
//                                                   3 /
//                                                   100,
//                                           child: Image.asset(AppImage.starIcon),
//                                         ),
//                                         SizedBox(
//                                           width: MediaQuery.of(context)
//                                                   .size
//                                                   .width *
//                                               1 /
//                                               100,
//                                         ),
//                                         Text(
//                                           widget.propertyList[index]['rating']
//                                               .toString(),
//                                           textAlign: TextAlign.center,
//                                           style: const TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w600,
//                                               color: AppColor.secondaryColor,
//                                               fontFamily: AppFont.fontFamily),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               SizedBox(
//                                 width:
//                                     MediaQuery.of(context).size.width * 2 / 100,
//                               ),
//                               Container(
//                                 width: MediaQuery.of(context).size.width *
//                                     23 /
//                                     100,
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                     color:
//                                         AppColor.secondaryColor.withOpacity(.4),
//                                     borderRadius: BorderRadius.circular(20)),
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8.0, vertical: 2),
//                                   child: Text(
//                                     "${widget.propertyList[index]['max_people']}  ${AppLanguage.membersText[language]}",
//                                     textAlign: TextAlign.center,
//                                     style: const TextStyle(
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.w600,
//                                         color: AppColor.secondaryColor,
//                                         fontFamily: AppFont.fontFamily),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 width:
//                                     MediaQuery.of(context).size.width * 2 / 100,
//                               ),
//                               const Spacer(),
//                               Container(
//                                 decoration: BoxDecoration(
//                                     color: AppColor.themeColor,
//                                     borderRadius: BorderRadius.circular(5)),
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8.0, vertical: 4),
//                                   child: Text(
//                                     "${widget.propertyList[index]['price_per_hour']} KWD",
//                                     style: const TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w600,
//                                         color: AppColor.secondaryColor,
//                                         fontFamily: AppFont.fontFamily),
//                                   ),
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                         SizedBox(
//                           height: MediaQuery.of(context).size.height * 2 / 100,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Discount badge
//                 if (widget.propertyList[index]['discount'] != null &&
//                     widget.propertyList[index]['discount'] > 0) ...[
//                   Positioned(
//                     top: language == 0 ? -30 : -30,
//                     left: language == 0 ? -22 : null,
//                     right: language == 1 ? -22 : null,
//                     child: SizedBox(
//                       width: MediaQuery.of(context).size.width * 30 / 100,
//                       height: MediaQuery.of(context).size.height * 15 / 100,
//                       child: Image.asset(language == 0
//                           ? AppImage.discountStrip
//                           : AppImage.discountStripInverted),
//                     ),
//                   ),
//                   Positioned(
//                     top: language == 0 ? 15 : 14,
//                     left: language == 0 ? -25 : null,
//                     right: language == 1 ? -25 : null,
//                     child: Transform.rotate(
//                       angle: language == 0 ? -.65 : .65,
//                       child: Container(
//                         alignment: Alignment.center,
//                         width: MediaQuery.of(context).size.width * 30 / 100,
//                         child: Text(
//                           "${widget.propertyList[index]['discount']}% ${AppLanguage.offText[language]}",
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                               fontFamily: AppFont.fontFamily,
//                               fontSize: 11,
//                               fontWeight: FontWeight.w800,
//                               color: AppColor.secondaryColor),
//                         ),
//                       ),
//                     ),
//                   )
//                 ]
//               ],
//             ),
//             SizedBox(
//               height: MediaQuery.of(context).size.height * 3 / 100,
//             )
//           ],
//         );

//         // return Column(
//         //   children: [
//         //     GestureDetector(
//         //       onTap: () {
//         //         Navigator.push(
//         //           context,
//         //           MaterialPageRoute(
//         //             builder: (context) => PropertyAdvertisementScreen(
//         //               tripId: trip['trip_id'].toString(),
//         //             ),
//         //           ),
//         //         );
//         //       },
//         //       child: Stack(
//         //         children: [
//         //           Container(
//         //             height: size.height * 0.23,
//         //             width: double.infinity,
//         //             decoration: BoxDecoration(
//         //               borderRadius: BorderRadius.circular(25),
//         //               image: DecorationImage(
//         //                 image: AssetImage(trip['trip_image']),
//         //                 fit: BoxFit.cover,
//         //               ),
//         //             ),
//         //             child: Container(
//         //               decoration: BoxDecoration(
//         //                 borderRadius: BorderRadius.circular(25),
//         //                 gradient: LinearGradient(
//         //                   begin: Alignment.bottomCenter,
//         //                   end: Alignment.topCenter,
//         //                   colors: [
//         //                     Colors.black.withOpacity(0.8),
//         //                     Colors.transparent,
//         //                   ],
//         //                 ),
//         //               ),
//         //               padding: EdgeInsets.all(size.width * 0.04),
//         //               child: Column(
//         //                 crossAxisAlignment: CrossAxisAlignment.start,
//         //                 children: [
//         //                   /// 3 DOT ICON
//         //                   Align(
//         //                     alignment: Alignment.topRight,
//         //                     child: GestureDetector(
//         //                       onTap: () {
//         //                         optionsBottomSheet(
//         //                           context,
//         //                           screenWidth,
//         //                         );
//         //                       },
//         //                       child: Container(
//         //                         height: size.height * 0.05,
//         //                         width: size.width * 0.07,
//         //                         decoration: const BoxDecoration(
//         //                           shape: BoxShape.circle,
//         //                           color: Colors.white,
//         //                         ),
//         //                         child: const Icon(
//         //                           Icons.more_vert,
//         //                           size: 18,
//         //                           color: AppColor.themeColor,
//         //                         ),
//         //                       ),
//         //                     ),
//         //                   ),

//         //                   const Spacer(),

//         //                   Text(
//         //                     trip['boat_name_english'] ?? "",
//         //                     style: const TextStyle(
//         //                       fontSize: 18,
//         //                       fontWeight: FontWeight.w600,
//         //                       color: Colors.white,
//         //                       fontFamily: AppFont.fontFamily,
//         //                     ),
//         //                   ),

//         //                   SizedBox(height: size.height * 0.005),

//         //                   /// LOCATION
//         //                   Text(
//         //                     trip['city_name'][language] ?? "",
//         //                     style: const TextStyle(
//         //                       fontSize: 12,
//         //                       fontWeight: FontWeight.w500,
//         //                       color: Colors.white70,
//         //                       fontFamily: AppFont.fontFamily,
//         //                     ),
//         //                   ),

//         //                   SizedBox(height: size.height * 0.01),

//         //                   Row(
//         //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         //                     children: [
//         //                       Container(
//         //                         padding: const EdgeInsets.symmetric(
//         //                             horizontal: 10, vertical: 4),
//         //                         decoration: BoxDecoration(
//         //                           color: Colors.white.withOpacity(.2),
//         //                           borderRadius: BorderRadius.circular(20),
//         //                         ),
//         //                         child: Text(
//         //                           "${trip['max_people']} ${AppLanguage.guestsText[language]}",
//         //                           style: const TextStyle(
//         //                             fontSize: 11,
//         //                             fontWeight: FontWeight.w500,
//         //                             color: Colors.white,
//         //                             fontFamily: AppFont.fontFamily,
//         //                           ),
//         //                         ),
//         //                       ),

//         //                       /// PRICE BADGE
//         //                       Container(
//         //                         padding: EdgeInsets.symmetric(
//         //                             horizontal: size.width * 0.04,
//         //                             vertical: size.height * 0.01),
//         //                         decoration: BoxDecoration(
//         //                           color: AppColor.themeColor,
//         //                           borderRadius: BorderRadius.circular(6),
//         //                         ),
//         //                         child: Text(
//         //                           "${trip['price_per_hour']} KWD/Day",
//         //                           style: const TextStyle(
//         //                             fontSize: 13,
//         //                             fontWeight: FontWeight.w600,
//         //                             color: Colors.white,
//         //                             fontFamily: AppFont.fontFamily,
//         //                           ),
//         //                         ),
//         //                       ),
//         //                     ],
//         //                   ),
//         //                 ],
//         //               ),
//         //             ),
//         //           ),
//         //         ],
//         //       ),
//         //     ),
//         //     SizedBox(height: size.height * 0.03),
//         //   ],
//         // );
//       },
//     );
//   }

// //=====================options bottomsheet===============
//   void optionsBottomSheet(
//       BuildContext context, double screenWidth, int tripId) {
//     showModalBottomSheet<void>(
//       isScrollControlled: true,
//       context: context,
//       constraints: BoxConstraints.expand(width: screenWidth),
//       enableDrag: true,
//       isDismissible: true,
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             double itemHeight = 50; // Approximate height of each item
//             double maxHeight = MediaQuery.of(context).size.height * 0.5;
//             double calculatedHeight = (optionsList.length * itemHeight) + 40;
//             double bottomSheetHeight =
//                 calculatedHeight < maxHeight ? calculatedHeight : maxHeight;

//             return GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: Container(
//                 width: screenWidth,
//                 color: Colors.black.withOpacity(0.3),
//                 child: Center(
//                   child: Container(
//                     width: screenWidth * 0.85,
//                     constraints: BoxConstraints(
//                       maxHeight: bottomSheetHeight,
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                     decoration: BoxDecoration(
//                       color: AppColor.secondaryColor,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: SingleChildScrollView(
//                       // Ensures no overflow
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min, // Prevent overflow
//                         children: [
//                           ListView.separated(
//                             shrinkWrap:
//                                 true, // Prevents unnecessary space usage
//                             physics:
//                                 const NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
//                             padding: const EdgeInsets.symmetric(vertical: 10),
//                             itemCount: optionsList.length,
//                             separatorBuilder: (context, index) => const Divider(
//                               color: AppColor.boaderColor,
//                               thickness: 1,
//                               height: 10,
//                             ),
//                             itemBuilder: (context, index) {
//                               return GestureDetector(
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                   if (optionsList[index]['id'] == 1) {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             EditPropertyAdvertisementScreen(
//                                           tripId: tripId.toString(),
//                                         ),
//                                       ),
//                                     );
//                                   } else if (optionsList[index]['id'] == 2) {
//                                     deleteBottomSheet(context, screenWidth,
//                                         tripId.toString());
//                                   }
//                                 },
//                                 child: Container(
//                                   color: Colors.transparent,
//                                   width: screenWidth * 0.85,
//                                   alignment: Alignment.center,
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 12),
//                                   child: Text(
//                                     optionsList[index]['title'],
//                                     style: const TextStyle(
//                                       fontFamily: AppFont.fontFamily,
//                                       fontSize: 17,
//                                       color: AppColor.textColor,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

// //=====================Delete bottomsheet===============
//   void deleteBottomSheet(BuildContext context, screenWidth, tripId) {
//     showModalBottomSheet<void>(
//         isScrollControlled: true,
//         context: context,
//         constraints: BoxConstraints.expand(width: screenWidth),
//         enableDrag: false,
//         isDismissible: false,
//         backgroundColor: AppColor.primaryColor.withOpacity(0.1),
//         builder: (BuildContext context) {
//           return StatefulBuilder(
//             builder: ((context, setState) {
//               return GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: Container(
//                   height: MediaQuery.of(context).size.height * 100 / 100,
//                   width: MediaQuery.of(context).size.width * 100 / 100,
//                   color: AppColor.primaryColor.withOpacity(0.1),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         // height: MediaQuery.of(context).size.height * 31 / 100,
//                         width: MediaQuery.of(context).size.width * 85 / 100,
//                         // color: Colors.red,
//                         decoration: const BoxDecoration(
//                           color: AppColor.secondaryColor,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(20),
//                             topRight: Radius.circular(20),
//                             bottomLeft: Radius.circular(20),
//                             bottomRight: Radius.circular(20),
//                           ),
//                         ),

//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             SizedBox(
//                               height:
//                                   MediaQuery.of(context).size.width * 10 / 100,
//                             ),
//                             Container(
//                               //color: Colors.amber,
//                               alignment: Alignment.center,
//                               width:
//                                   MediaQuery.of(context).size.width * 55 / 100,
//                               child: Text(
//                                 AppLanguage.deleteText[language],
//                                 style: const TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w600,
//                                     fontFamily: AppFont.fontFamily),
//                               ),
//                             ),
//                             SizedBox(
//                                 height: MediaQuery.of(context).size.height *
//                                     2 /
//                                     100),
//                             Container(
//                               //color: Colors.amber,
//                               alignment: Alignment.center,
//                               width:
//                                   MediaQuery.of(context).size.width * 75 / 100,
//                               child: Text(
//                                 AppLanguage.deleteMsg[language],
//                                 style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     fontFamily: AppFont.fontFamily),
//                               ),
//                             ),
//                             SizedBox(
//                               height:
//                                   MediaQuery.of(context).size.height * 4 / 100,
//                             ),
//                             SizedBox(
//                               width:
//                                   MediaQuery.of(context).size.width * 65 / 100,
//                               height:
//                                   MediaQuery.of(context).size.width * 13 / 100,
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       Navigator.pop(context);
//                                     },
//                                     child: Container(
//                                       alignment: Alignment.center,
//                                       width: MediaQuery.of(context).size.width *
//                                           30 /
//                                           100,
//                                       height:
//                                           MediaQuery.of(context).size.height *
//                                               5 /
//                                               100,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(30),
//                                         //color: Colors.red,
//                                         border: Border.all(
//                                           color: AppColor.primaryColor,
//                                           width: 1,
//                                         ),
//                                       ),
//                                       child: Text(
//                                         AppLanguage.backButtonText[language],
//                                         style: const TextStyle(
//                                             color: AppColor.primaryColor,
//                                             fontFamily: AppFont.fontFamily,
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 14),
//                                       ),
//                                     ),
//                                   ),
//                                   GestureDetector(
//                                     onTap: () {
//                                       deleteAdApiCall(tripId);
//                                       Navigator.pop(context);
//                                     },
//                                     child: Container(
//                                       alignment: Alignment.center,
//                                       width: MediaQuery.of(context).size.width *
//                                           30 /
//                                           100,
//                                       height:
//                                           MediaQuery.of(context).size.height *
//                                               5 /
//                                               100,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(30),
//                                         color: AppColor.themeColor,
//                                         border: Border.all(
//                                           color: AppColor.themeColor,
//                                           width: 1,
//                                         ),
//                                       ),
//                                       child: Text(
//                                         AppLanguage.yesText[language],
//                                         style: const TextStyle(
//                                             color: AppColor.secondaryColor,
//                                             fontFamily: AppFont.fontFamily,
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 14),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               height:
//                                   MediaQuery.of(context).size.height * 6 / 100,
//                             ),
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               );
//             }),
//           );
//         });
//   }
// }
