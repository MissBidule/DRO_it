import 'package:droit_app/models/realm_functions.dart';
import 'package:droit_app/screens/drawingBoard/draw_screen.dart';
import 'package:droit_app/screens/friend_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:droit_app/models/message.dart';
import 'package:droit_app/models/firebase_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_indicator/loading_indicator.dart';

String currentHost = "";
String currentFriend = "";

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> users = getCurrentUsers();
    currentHost = users[0];
    currentFriend = users[1];
    updateConversationShowing(currentHost, currentFriend, false);

    return PopScope(
      canPop: true, //When false, blocks the current route from being popped.
      //will update timestamp when leaving in unconventional way
      onPopInvoked: (didPop) {
        updateConversationTimestamp(currentHost, currentFriend);
        return;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 236, 234, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 236, 234, 255),
          scrolledUnderElevation: 0,
          toolbarHeight: 10.0,
        ),
        body: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 50, 10),
                  child: IconButton(
                    onPressed: () {
                      removeCurrentFriendFromRealm();
                      Future.delayed(const Duration(milliseconds: 50), () {
                        Navigator.of(context).pop(context);
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.blueAccent[700],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) => const FriendScreen(),
                            ));
                          },
                          child: StreamBuilder(
                              stream: ppRef
                                  .where("user", isEqualTo: currentFriend)
                                  .orderBy("timestamp", descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircleAvatar(
                                    backgroundImage:
                                        AssetImage("assets/images/empty.png"),
                                    radius: 35.0,
                                  );
                                }
                                return CircleAvatar(
                                  backgroundImage: getImageFromString(
                                          snapshot.data!.docs[0].data().image)
                                      .image,
                                  radius: 35.0,
                                );
                              }),
                        ),
                        StreamBuilder(
                            stream: userRef
                                .where("email", isEqualTo: currentFriend)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(10, 0, 0, 0),
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
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  width: 125,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.rectangle,
                                      image: DecorationImage(
                                          image: getImageFromString(snapshot
                                                  .data!.docs[0]
                                                  .data()
                                                  .username)
                                              .image,
                                          fit: BoxFit.contain),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20.0))));
                            })
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
                child: StreamBuilder(
                    stream: messageRef
                        .where(Filter.or(
                            Filter.and(
                                Filter("receiver", isEqualTo: currentHost),
                                Filter("sender", isEqualTo: currentFriend)),
                            Filter.and(
                                Filter("receiver", isEqualTo: currentFriend),
                                Filter("sender", isEqualTo: currentHost))))
                        .orderBy("timestamp", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      updateConversationTimestamp(currentHost, currentFriend);
                      if (!snapshot.hasData) {
                        var phoneWidth = MediaQuery.of(context).size.width;
                        return Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Loading messages ...',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              SizedBox(height: phoneWidth / 10),
                              SizedBox(
                                height: phoneWidth / 4,
                                width: phoneWidth / 4,
                                child: const Center(
                                    child: LoadingIndicator(
                                  indicatorType: Indicator.ballScale,

                                  /// Required, The loading type of the widget
                                  colors: [Color.fromARGB(255, 41, 98, 255)],

                                  /// Optional, The color collections
                                  strokeWidth: 4,

                                  /// Optional, the stroke backgroundColor
                                )),
                              )
                            ],
                          ),
                        );
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return BubbleNormal(
                          text:
                              "No messages yet, draw one now !", //AssetImage(messages[index].imageUrl)),
                          color: Colors.blueAccent,
                          tail: true,
                          isSender: false,
                          textStyle: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        );
                      }
                      return ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: snapshot.data!.docs.length,
                          reverse: true,
                          itemBuilder: (BuildContext context, int index) {
                            Message message = snapshot.data!.docs[index].data();
                            return BubbleNormalImage(
                              id: 'id00$index',
                              image: getImageFromString(message.image),
                              color: Colors.blueAccent,
                              tail: true,
                              delivered: true,
                              isSender: message.sender == currentHost,
                            );
                          });
                    })),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 25),
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          const DrawScreen(state: ScreenState.chat),
                    ));
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.blueAccent[700]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text('Tap to draw something',
                        style: GoogleFonts.pangolin(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
