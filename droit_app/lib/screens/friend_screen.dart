import 'package:droit_app/widgets/detail_screen.dart';
import 'package:droit_app/models/realm_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:droit_app/models/firebase_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String currentHost = "";
String currentFriend = "";

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  @override
  Widget build(BuildContext context) {
    List <String> users = getCurrentUsers();
    currentHost = users[0];
    currentFriend = users[1];
    return Scaffold(
      backgroundColor: const Color.fromRGBO(236, 234, 255, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 236, 234, 255),
        scrolledUnderElevation: 0,
        toolbarHeight: 10.0,
      ),
      body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.blueAccent[700],
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.red[200],
                        ),
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
        
                            backgroundColor: Colors.white,
                            title: const Text('Are you sure ?'),
                            content: const Text('If you delete this friend, you will have to recreate a conversation with them to see it again.'),
                            actions: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context, 'Cancel'),
                                    child: Image.asset("assets/images/no.png"),
                                    
                                  ),
        
                                  GestureDetector(
                                onTap: () => { 
                                    updateConversationShowing(currentHost, currentFriend, true),
                                    removeCurrentFriendFromRealm(),
                                    Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst)
                                  },
                                child: Image.asset("assets/images/yes.png"),
                              ),
                                ],
                              ),
                              
                            ],
                          ),
                        ),
                        child: const Icon(CupertinoIcons.trash,
                            color: Color.fromARGB(255, 251, 0, 0),
                          ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                radius: 102,
                              ),
                              StreamBuilder(
                                  stream: ppRef
                                      .where("user", isEqualTo: currentFriend)
                                      .orderBy("timestamp", descending: true)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const CircleAvatar(
                                        backgroundImage:
                                            AssetImage("assets/images/empty.png"),
                                        radius: 100,
                                      );
                                    }
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (_) {
                                              return DetailScreen(
                                                image: getImageFromString(snapshot.data!.docs[0].data().image), tag: '',
                                              );
                                            }));
                                          },
                                          child: CircleAvatar(
                                          radius: 100,
                                          backgroundImage: getImageFromString(snapshot.data!.docs[0].data().image).image),);
                                  }),
                              
                            ]),
                        const SizedBox(height: 15,),
                        Stack(clipBehavior: Clip.none, children: [
                          StreamBuilder(
                              stream: userRef
                                  .where("email", isEqualTo: currentFriend)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                            color: Colors.blueAccent, width: 2),
                                        color: Colors.white,
                                        image: const DecorationImage(
                                            image: AssetImage(
                                                "assets/images/empty_name.png"))),
                                    width: 250,
                                    height: 83.33,
                                  );
                                }
                                return Container(
                                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      border: Border.all(
                                          color: Colors.blueAccent, width: 2),
                                      color: Colors.white,
                                      image: DecorationImage(
                                          image: getImageFromString(snapshot.data!.docs[0].data().username).image)),
                                  width: 250,
                                  height: 83,
                                );
                              }),
                          
                        ]),
                        Center(
                          child: Text(currentFriend,
                          style: const TextStyle(fontSize: 18),),
                        )
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Our drawings',
                                style: GoogleFonts.pangolin(
                                    fontSize: 28, fontWeight: FontWeight.bold))
                          
                    ),
                    StreamBuilder(
                        stream: messageRef
                        .where(Filter.or(
                            Filter.and(Filter("receiver", isEqualTo: currentHost),
                                Filter("sender", isEqualTo: currentFriend)),
                            Filter.and(
                                Filter("receiver", isEqualTo: currentFriend),
                                Filter("sender", isEqualTo: currentHost))))
                        .orderBy("timestamp", descending: true)
                        .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                                height: 200,
                                child: Text("No pictures yet, go back to draw to your friend !"));
                          }
                          return Expanded(
                            child: GridView.builder(
                                itemCount: snapshot.data!.docs.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3),
                                itemBuilder: (context, index) {
                                  return InstaImageViewer(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.fitWidth,
                                              image:
                                                  getImageFromString(snapshot.data!.docs[index].data().image).image)),
                                    ),
                                  );
                                })
                          );
                        }),                    
                  ],
                ),
              ),
            )
          ],
        ),
    );
  }

}