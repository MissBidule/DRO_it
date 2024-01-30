import 'package:droit_app/models/realm_functions.dart';
import 'package:droit_app/screens/authentication/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:droit_app/screens/drawingBoard/draw_screen.dart';

String currentHost = "";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                  Text('Settings',
                      style: GoogleFonts.pangolin(
                          fontSize: 35, fontWeight: FontWeight.bold)),
                  
                    TextButton(
                        onPressed: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(

                          backgroundColor: Colors.white,
                          title: const Text('Do you want to log out ?'),
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
                                  Navigator.of(context).pop(),
                                  removeCurrentUserFromRealm(),
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => const Login()),
                                      (route) => false)
                                },
                              child: Image.asset("assets/images/yes.png"),
                            ),
                              ],
                            ),
                            
                          ],
                        ),),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red[200],
                        ),
                        child: const Icon(Icons.logout_rounded,
                            color: Color.fromARGB(255, 251, 0, 0),
                            size: 40,
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
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .push(CupertinoPageRoute(
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
                                  radius: 85,
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
                                          radius: 83,
                                        );
                                      }
                                      return CircleAvatar(
                                        backgroundImage:
                                            getImageFromString(snapshot.data!.docs[0].data().image).image,
                                        radius: 83,
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
                        const SizedBox(height: 15,),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(CupertinoPageRoute(
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
                        Center(
                          child: Text(currentHost,
                          style: const TextStyle(fontSize: 18),),
                        )
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child:  Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text('My previous profile drawings',
                                style: GoogleFonts.pangolin(
                                    fontSize: 25, fontWeight: FontWeight.bold)),
                          )),
                    
                    StreamBuilder(
                        stream: ppRef
                            .where("user", isEqualTo: currentHost)
                            .orderBy("timestamp", descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Expanded(
                                child: Text("No previous profile picture yet !"));
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
