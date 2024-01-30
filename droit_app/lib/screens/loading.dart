import 'package:droit_app/screens/authentication/login_screen.dart';
import 'package:droit_app/screens/home.dart';
import 'package:droit_app/models/realm_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

String currentHost = "";

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    check(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 234, 255),

      //Appbar is here used for the rest of the page to go down (maybe not optimal ?)
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 236, 234, 255),
        toolbarHeight: 10.0,
        scrolledUnderElevation: 0,
      ),

      //main container
      body: const SpinKitThreeBounce(
              color: Colors.blueAccent,
              size: 50.0, 
)
    );
  }

  void check(BuildContext context) async {
    if (getCurrentHost() == "") {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (context) => const Login(),
        ));
      });
    } else {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (context) => const Home(),
        ));
      });
    }
  }
}
