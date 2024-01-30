import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droit_app/models/realm_functions.dart';
import 'package:droit_app/models/firebase_functions.dart';
import 'package:droit_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:droit_app/widgets/searchbar_widget.dart';

String currentHost = "";

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  @override
  Widget build(BuildContext context) {
    currentHost = getCurrentHost();
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              textBaseline: TextBaseline.alphabetic,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.blueAccent[700],
                ),
                Text('New conversation',
                    style: GoogleFonts.pangolin(
                        fontSize: 35, fontWeight: FontWeight.bold)),
                const SizedBox(width: 30)
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
            child: SearchBarWidget(),
          ),
          StreamBuilder(
              stream: conversationRef
                  .where(Filter.and(Filter("host", isEqualTo: currentHost), Filter("hidden", isEqualTo: false)))
                    .orderBy("lastMessage", descending: true)
                    .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Expanded(
                    child: SizedBox(),
                  );
                }
                return Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 0),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return StreamBuilder(
                          stream: userRef
                              .where("email", isEqualTo: snapshot.data!.docs[index].data().friend)
                              .snapshots(),
                          builder: (context, snapshot2) {
                            if (!snapshot2.hasData) {
                              return Card(
                                surfaceTintColor: Colors.white,
                            shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(20)),
                           elevation: 5,
                            child: InkWell(
                              onTap: () {
                                  // Function is executed on tap.
                              },
                              child: ListTile(
                              title: Center(child:Text(snapshot.data!.docs[index].data().friend,
                              style: const TextStyle(fontSize: 12),),)),)
                          );
                            }
                            return Card(
                              surfaceTintColor: Colors.white,
                            shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(20)),
                           elevation: 5,
                            child: InkWell(
                              onTap: () {
                                  currentFriendToRealm(
                                      snapshot.data!.docs[index].data().friend);
                                  Future.delayed(
                                      const Duration(milliseconds: 50), () {
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const ChatScreen()));
                              });
                              },
                              child: ListTile(
                              leading: Image(
                                image: getImageFromString(snapshot2.data!.docs[0].data().username).image,
                                height: 55,),
                              trailing: Text(
                                snapshot.data!.docs[index].data().friend,
                                style: const TextStyle(fontSize: 12),),),)
                          );
                        });}));
              })
        ],
      ),
    );
  }
}