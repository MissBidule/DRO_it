import 'package:droit_app/models/realm_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droit_app/models/currentUser.dart';
import 'package:droit_app/models/profile_picture.dart';
import 'package:droit_app/models/user.dart';
import 'package:droit_app/screens/drawingBoard/draw_screen.dart';
import 'package:droit_app/screens/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realm/realm.dart' as rdb;



var config = rdb.Configuration.local([CurrentUser.schema]);
var realm = rdb.Realm(config);

String currentHost = "";

final ppRef = FirebaseFirestore.instance
    .collection('profilePicture')
    .withConverter<ProfilePicture>(
      fromFirestore: (snapshots, _) =>
          ProfilePicture.fromJson(snapshots.data()!),
      toFirestore: (profilePic, _) => profilePic.toJson(),
    );

final userRef =
    FirebaseFirestore.instance.collection('user').withConverter<User>(
          fromFirestore: (snapshots, _) => User.fromJson(snapshots.data()!),
          toFirestore: (user, _) => user.toJson(),
        );

class ProfileSetUp extends StatefulWidget {
  const ProfileSetUp({super.key});

  @override
  State<ProfileSetUp> createState() => _ProfileSetUpState();
}

class _ProfileSetUpState extends State<ProfileSetUp> {
  @override
  Widget build(BuildContext context) {
    currentHost = getCurrentHost();
    return  Scaffold(
      body: Container(
         decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/login_image.png"),
                fit: BoxFit.cover)),
        child: Center(
          child: Column(
            children: [
             const Expanded(
                flex: 1,
                child: Text("   ")
                ),
              Flexible(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: const BoxDecoration(
                    color:  Color.fromRGBO(236, 234, 255, 1),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(45.0))),
                        width: 390.0,
                        height: 700.0,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        children: [
                          
                          Text('Your account has been created !',
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.pangolin(
                                  fontSize: 28, fontWeight: FontWeight.bold, )),
                                  
                          const SizedBox(height: 10),
                        
                          const Text("You can now draw you profile picture and your nickname ! This is how your friends will see you on the app !",
                            textAlign: TextAlign.center),
                          
                          const SizedBox(height: 10),
                  
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                builder: (context) =>
                                    const DrawScreen(state: ScreenState.profile),
                              ));
                            },
                            child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    radius: 72,
                                  ),
                                  StreamBuilder(
                                      stream: ppRef
                                          .where("user", isEqualTo: currentHost)
                                          .orderBy("timestamp", descending: true)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const CircleAvatar(
                                            backgroundImage:
                                                AssetImage("assets/images/empty.png"),
                                            radius: 70,
                                          );
                                        }
                                        return CircleAvatar(
                                          backgroundImage:
                                              getImageFromString(snapshot.data!.docs[0].data().image).image,
                                          radius: 70,
                                        );
                                      }),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.blueAccent[700],
                                      child: const Icon(Icons.draw,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                  
                          const SizedBox(height: 10),
                  
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const DrawScreen(state: ScreenState.username),
                              ));
                            },
                            child: Stack(clipBehavior: Clip.none, children: [
                              StreamBuilder(
                                  stream: userRef
                                      .where("email", isEqualTo: currentHost)
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
                                        width: 200,
                                        height: 70,
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
                                      width: 200,
                                      height: 70,
                                    );
                                  }),
                              Positioned(
                                top: -5,
                                right: -15,
                                child: CircleAvatar(
                                  backgroundColor: Colors.blueAccent[700],
                                  child: const Icon(Icons.draw,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ]),
                          ),
                  
                          const SizedBox(height: 35,),
                  
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(CupertinoPageRoute(
                                builder: (context) => const Home(),
                              ));
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.blueAccent[700]),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text('Tap to start !',
                                  style: GoogleFonts.pangolin(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                        )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Flexible(
                flex: 1,
                child: SizedBox(
                  width: 300,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}