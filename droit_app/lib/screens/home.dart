import 'package:droit_app/models/conversation.dart';
import 'package:droit_app/models/realm_functions.dart';
import 'package:droit_app/models/firebase_functions.dart';
import 'package:droit_app/screens/chat_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:droit_app/screens/newchat_screen.dart';
import 'package:droit_app/screens/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

String currentHost = "";

final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

double radius = 15;
double iconSize = 20;
double distance = 15;

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    currentHost = getCurrentHost();
    registerNotification(context);
    configLocalNotification();
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 236, 234, 255),

        //Appbar is here used for the rest of the page to go down (maybe not optimal ?)
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 236, 234, 255),
          toolbarHeight: 10.0,
          scrolledUnderElevation: 0,
        ),

        //main container
        body: Column(
          children: [
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child:
                    //top of the page
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                      //user image
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(CupertinoPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ));
                            },
                            child: Stack(alignment: Alignment.center, children: [
                              CircleAvatar(
                                radius: MediaQuery.of(context).size.width * 0.075,//32.0,
                                backgroundColor: const Color.fromARGB(255, 0, 68, 255),
                              child: StreamBuilder(
                                  stream: ppRef
                                      .where("user", isEqualTo: currentHost)
                                      .orderBy("timestamp", descending: true)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return CircleAvatar(
                                        backgroundImage:
                                            const AssetImage("assets/images/empty.png"),
                                        radius: MediaQuery.of(context).size.width * 0.075 - 2,//30.0,
                                      );
                                    }
                                    return CircleAvatar(
                                      backgroundImage: getImageFromString(snapshot.data!.docs[0].data().image).image,
                                      radius: MediaQuery.of(context).size.width * 0.075 - 2,//30.0,
                                    );
                                  }),
                              ),
                              Positioned(
                              top: -12,
                              right: -12,
                              child: 
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.blueAccent[700]
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.of(context).push(CupertinoPageRoute(
                                          builder: (context) => const ProfileScreen(),
                                        ));
                                      },
                                      icon: const Icon(Icons.settings),
                                      color: Colors.white,
                                      iconSize: 12,
                                    ),
                                  ],
                                ),
                            ),
                          ]),
                          
                        ),
                      ),
                                    
                      //user name
                      Flexible(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Text('Hey  ',
                              style: GoogleFonts.pangolin(
                                  fontSize: 28,
                                  fontWeight: FontWeight
                                      .bold) //found the font in the google_fonts folder
                        
                              ),
                          StreamBuilder(
                              stream: userRef
                                  .where("email", isEqualTo: currentHost)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container(
                                      width: MediaQuery.of(context).size.width * 0.5 * 0.5,
                                      height: MediaQuery.of(context).size.width * 0.5 * 0.5 * 0.318,
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.rectangle,
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/images/empty_name.png"),
                                              fit: BoxFit.contain),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0))));
                                }
                                return Container(
                                    width: MediaQuery.of(context).size.width * 0.5 * 0.5,
                                    height: MediaQuery.of(context).size.width * 0.5 * 0.5 * 0.318,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.rectangle,
                                        image: DecorationImage(
                                            image: getImageFromString(snapshot.data!.docs[0].data().username).image,
                                            fit: BoxFit.fitHeight),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20.0))));
                              })
                        ]),
                      ),
                                    
                      //add button
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.blueAccent[700]
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.of(context).push(CupertinoPageRoute(
                                          builder: (context) => const NewChatScreen(),
                                        ));
                                      },
                                      icon: const Icon(Icons.add),
                                      color: Colors.white,
                                      iconSize: 20,
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

            //rest of the page here
            const Flexible(
              flex: 9,
              child: DiscussionContainer()),
          ],
        ));
  }

  void registerNotification(BuildContext context) async {
    await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (Platform.isAndroid) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          // check that user is not currently in chat with user that sends message
          var currentUsers = getAllUsers();
          if (!currentUsers.isEmpty) {
            currentFriend = currentUsers.first.email;
            if (!message.data["sender"].contains(currentFriend)) {
              showNotification(message.notification!);
            }
          } else {
            showNotification(message.notification!);
          }
        }
        return;
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        currentFriendToRealm(message.data["sender"]);
        Future.delayed(const Duration(milliseconds: 50), () {
          Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => const ChatScreen(),
          ));
        });
        return;
      });
    }

    firebaseMessaging.getToken().then((token) {
      FirebaseFirestore.instance
          .collection('user')
          .doc(currentHost)
          .update({'pushToken': token});
    }).catchError((err) {
      debugPrint(err.message.toString()); // Fluttertoast.showToast
    });
  }

  void configLocalNotification() {
    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("mipmap/ic_launcher");
    DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(RemoteNotification remoteNotification) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'com.example.droit_app',
      'Flutter chat demo',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    DarwinNotificationDetails iOSPlatformChannelSpecifics =
        const DarwinNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      platformChannelSpecifics,
      payload: null,
    );
  }
}

class DiscussionContainer extends StatelessWidget {
  const DiscussionContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        //set background image
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/draw-home.png"), fit: BoxFit.cover),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(45.0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //chat title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 8),
              child: Text(
                'Chats',
                style: GoogleFonts.pangolin(
                    fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
      
            //list of discussions
            const MyListView(),
          ],
        ),
      ),
    );
  }
}

class MyListView extends StatelessWidget {
  const MyListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        //need an expanded widget so the list can be put in a column (see DiscussionContainer widget)
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: StreamBuilder(
                stream: conversationRef
                    .where(Filter.and(Filter("host", isEqualTo: currentHost),
                        Filter("hidden", isEqualTo: false)))
                    .orderBy("lastMessage", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text(
                      "Conversations Loading !",
                      style: TextStyle(fontSize: 10),
                    );
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return  Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("No conversation yet ! Go make one !"),
                          Row(
                            children: [
                              const Text("To begin, click on "),
                              Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.blueAccent[700]
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(CupertinoPageRoute(
                                    builder: (context) => const NewChatScreen(),
                                  ));
                                },
                                icon: const Icon(Icons.add),
                                color: Colors.white,
                                iconSize: 15,
                              ),
                            ],
                          )
                            ],
                          ),
                          
                        ]);
                  }
                  return ListView.builder(
                    itemCount: (snapshot.data!.docs.length / 2)
                        .ceil(), //(items.length / 2).ceil(), //roud on top
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          DiscussionItem(
                              conversation: snapshot.data!.docs[index * 2]
                                  .data()), //display the left user
                          const SizedBox
                              .shrink(), // Espacement entre les éléments
                          DiscussionItem(
                              conversation: snapshot.data!.docs.length >
                                      index * 2 + 1
                                  ? snapshot.data!.docs[index * 2 + 1].data()
                                  : Conversation(
                                      friend: "empty",
                                      hidden: true,
                                      host: "empty",
                                      lastChecked: Timestamp
                                          .now(), //displays the right user if exist
                                      lastMessage: Timestamp(0, 0)))
                        ],
                      );
                    },
                  );
                })));
  }
}

class DiscussionItem extends StatefulWidget {
  const DiscussionItem({super.key, required this.conversation});

  final Conversation conversation; //parameter gave in the list

  @override
  State<DiscussionItem> createState() => _DiscussionItemState();
}

class _DiscussionItemState extends State<DiscussionItem> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 45, 5, 20),
        child: GestureDetector(
          onTap: widget.conversation.host != "empty"
                      ? () {
                          currentFriendToRealm(
                              widget.conversation.friend);
                          Future.delayed(
                              const Duration(milliseconds: 50), () {
                            Navigator.of(context)
                                .push(CupertinoPageRoute(
                              builder: (context) => const ChatScreen(),
                            ));
                          });
                        }
                      : () {},
          child: Stack(
            clipBehavior: Clip.none, //allow the circle to go out of the stack
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 130,
                decoration: ShapeDecoration(
                  color: widget.conversation.host != "empty"
                      ? Colors.white
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  shadows: [
                    BoxShadow(
                      color: widget.conversation.host != "empty"
                          ? const Color(0xFFE4E0FF)
                          : Colors.transparent,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Center(
                    child: widget.conversation.host == "empty"
                        ? ListTile(
                            //content of the stack
                            title: Image(
                            image: Image.asset("assets/images/empty.png").image,
                          ))
                        : StreamBuilder(
                            stream: userRef
                                .where("email",
                                    isEqualTo: widget.conversation.friend)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return ListTile(
                                  //content of the stack
                                  title: Image(
                                    image: Image.asset("assets/images/empty.png")
                                        .image,
                                  ),
                                );
                              }
                              return ListTile(
                                //content of the stack
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image(
                                      image: getImageFromString(snapshot.data!.docs[0].data().username).image,
                                      width: 90,
                                    ),
                                  ],
                                ),
                              );
                            })),
              ),
              Positioned(
                top: -45,
                child: Stack(alignment: Alignment.center, children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: widget.conversation.host != "empty"
                        ? widget.conversation.lastChecked.millisecondsSinceEpoch <
                                widget.conversation.lastMessage
                                    .millisecondsSinceEpoch
                            ? const Color.fromARGB(255, 0, 151, 251)
                            : const Color(0xFFE4E0FF)
                        : const Color.fromARGB(0, 230, 18, 18),
                    child: widget.conversation.host != "empty"
                        ? StreamBuilder(
                            stream: ppRef
                                .where("user",
                                    isEqualTo: widget.conversation.friend)
                                .orderBy("timestamp", descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircleAvatar(
                                  backgroundImage:
                                      AssetImage("assets/images/empty.png"),
                                  radius: 38,
                                );
                              }
                              return CircleAvatar(
                                backgroundImage: getImageFromString(snapshot.data!.docs[0].data().image).image,
                                radius: 38,
                              );
                            })
                        : const SizedBox.shrink(),
                  ),
                  Positioned(
                      top: -(radius + iconSize),
                      right: -(radius + iconSize + distance),
                      bottom: radius,
                      left: 0,
                      child: Icon(
                        CupertinoIcons.exclamationmark_circle_fill,
                        color: widget.conversation.lastChecked
                                    .millisecondsSinceEpoch <
                                widget.conversation.lastMessage
                                    .millisecondsSinceEpoch
                            ? const Color.fromARGB(255, 0, 151, 251)
                            : Colors.transparent,
                        size: iconSize.toDouble(),
                      )),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
