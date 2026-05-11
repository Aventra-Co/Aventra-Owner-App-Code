// ignore_for_file: sized_box_for_whitespace
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../chat/chat_user_card.dart';
import '../../helper/apis.dart';
import '../../model/chat_user.dart';
import '../../model/message.dart';
import '../../controller/app_color.dart';
import '../../controller/app_constant.dart';
import '../../controller/app_font.dart';
import '../../controller/app_footer.dart';
import '../../controller/app_image.dart';
import '../../controller/app_language.dart';

class InboxScreen extends StatefulWidget {
  static String routeName = './InboxScreen';
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  TextEditingController searchTextController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<dynamic> chatList = [
    {
      'name': 'Mahmoud Tst',
      'message': 'yes go for it',
      'time': '1 min ago',
      'unread': 1,
      'image': AppImage.boatImage,
    },
    {
      'name': 'Jaxson Herwitz',
      'message': 'yes go for it',
      'time': '15 min ago',
      'unread': 0,
      'image': AppImage.carBgImage,
    },
    {
      'name': 'Mahmoud Albandar',
      'message': 'yes go for it',
      'time': '30 min ago',
      'unread': 0,
      'image': AppImage.boatImage,
    },
    {
      'name': 'Jaxson Herwitz',
      'message': 'yes go for it',
      'time': '40 min ago',
      'unread': 0,
      'image': AppImage.carBgImage,
    },
  ];
  int userId = 0;
  dynamic data;
  dynamic userDataArr;
  int userType = 0;
  bool _isSearching = false;
  List<ChatUser> _allUsers = [];
  List<ChatUser> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    getUserDetails();
    APIs.getSelfInfo();
    _searchController.addListener(_onSearchChanged);

    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.user_id != "") {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });

    FocusManager.instance.primaryFocus?.unfocus();
  }

  //----------------------------GET USER DETAILS--------------------------------//
  Future<dynamic> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    data = prefs.getString("userDetails");

    // print("userDetails $userDetails");
    if (data == null) {

    } else {
      userDataArr = jsonDecode(data);
      userId = userDataArr['user_id'] ?? 0;
      userType = userDataArr['user_type'] ?? 0;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

// Update your _onSearchChanged method
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _filteredUsers = _allUsers.where((user) {
          return user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return WillPopScope(
       onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) => const MyFooterPage(indexOfPage: 0)),
          ),
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColor.secondaryColor,
        body: Container(
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
                    color: AppColor.themeColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50))),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 7 / 100,
                    ),

                    //manage text
                    Container(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      alignment: Alignment.center,
                      child: Text(
                        AppLanguage.messagesText[language],
                        style: const TextStyle(
                            color: AppColor.secondaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFont.fontFamily),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 3 / 100,
              ),

              // User List
              Expanded(
                child: StreamBuilder<List<ChatUser>>(
                  stream: getChatUsersSorted(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(child: CircularProgressIndicator());

                      case ConnectionState.active:
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        // Update _allUsers when new data arrives
                        _allUsers = snapshot.data ?? [];

                        // Apply search filter if searching
                        final displayUsers =
                            _isSearching ? _filteredUsers : _allUsers;

                        if (displayUsers.isEmpty) {
                          return Center(
                            child: Text(
                              _isSearching
                                  ? 'No matching users found!'
                                  : 'No users available!',
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: displayUsers.length,
                          padding: const EdgeInsets.only(top: 2),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Builder(
                              builder: (context) {
                                if (displayUsers.isNotEmpty) {
                                  return ChatUserCard(
                                      user: displayUsers[index]);
                                } else {
                                  return Column(
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                20 /
                                                100,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                90 /
                                                100,
                                        child: const Text(
                                          'No users available',
                                          style: TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.primaryColor),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            );
                          },
                        );
                    }
                  },
                ),
              ),

            

              const NoInternetBanner(),
            ],
          ),
        ),
      ),
    );
  }

  Stream<List<ChatUser>> getChatUsersSorted() {
    return APIs.getMyUsersId().asyncExpand((myUsersSnapshot) {
      return Stream.fromFuture(() async {
        var userIds = myUsersSnapshot.docs.map((e) => e.id).toList();
        if (userIds.isEmpty) {
          final partnerIds =
              await APIs.getChatPartnerIdsFromChatsCollection(limit: 500);
          userIds = partnerIds.toList();
        }

        if (userIds.isEmpty) return <ChatUser>[];

        final users = (await APIs.getUsersByIdsOnce(userIds))
            .where((u) => u.id != APIs.user_id)
            .toList();

        final List<MapEntry<ChatUser, DateTime>> userLastMessageTimes = [];

        for (final user in users) {
          try {
            DateTime lastMessageTime = DateTime(0);
            final String conversationId =
                await APIs.resolveConversationId(user.id);
            final messageQuery =
                await APIs.getLastMessageByConversationId(conversationId).first;

            if (messageQuery.docs.isNotEmpty) {
              final latestMessage =
                  Message.fromJson(messageQuery.docs.first.data());
              lastMessageTime = _parseMessageTime(latestMessage.sent);
            }

            userLastMessageTimes.add(MapEntry(user, lastMessageTime));
          } catch (_) {
            userLastMessageTimes.add(MapEntry(user, DateTime(0)));
          }
        }

        userLastMessageTimes.sort((a, b) => b.value.compareTo(a.value));
        return userLastMessageTimes.map((entry) => entry.key).toList();
      }());
    });
  }

  DateTime _parseMessageTime(dynamic sentTime) {
    if (sentTime == null) return DateTime(0);
    if (sentTime is Timestamp) return sentTime.toDate();
    if (sentTime is String) {
      final dateTime = DateTime.tryParse(sentTime);
      if (dateTime != null) return dateTime;

      final epochMillis = int.tryParse(sentTime);
      if (epochMillis != null)
        return DateTime.fromMillisecondsSinceEpoch(epochMillis);
    }
    if (sentTime is int) return DateTime.fromMillisecondsSinceEpoch(sentTime);
    if (sentTime is DateTime) return sentTime;
    return DateTime(0);
  }
}
