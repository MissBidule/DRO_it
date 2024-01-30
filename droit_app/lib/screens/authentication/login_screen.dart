import 'package:droit_app/models/profile_picture.dart';
import 'package:droit_app/models/user.dart';
import 'package:droit_app/models/realm_functions.dart';
import 'package:droit_app/screens/authentication/profile_setup.dart';
import 'package:droit_app/screens/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final userRef =
    FirebaseFirestore.instance.collection('user').withConverter<User>(
          fromFirestore: (snapshots, _) => User.fromJson(snapshots.data()!),
          toFirestore: (user, _) => user.toJson(),
        );

final ppRef = FirebaseFirestore.instance
    .collection('profilePicture')
    .withConverter<ProfilePicture>(
      fromFirestore: (snapshots, _) =>
          ProfilePicture.fromJson(snapshots.data()!),
      toFirestore: (profilePic, _) => profilePic.toJson(),
    );

bool firstLog = false;

class Login extends StatelessWidget {
  const Login({
    super.key,
  });

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) {
    return Future.delayed(loginTime).then((_) async {
      var error = "";
      await userRef.where("email", isEqualTo: data.name).get().then(
        (querySnapshot) {
          if (querySnapshot.size == 1) {
            User loginUser = querySnapshot.docs.first.data();
            if (loginUser.password == data.password) {
              loggedInUserToRealm(loginUser.email);
              error = "";
            } else {
              error = "Password does not match";
            }
          } else {
            debugPrint('User not exists');
            error = "User not exists";
          }
        },
        onError: (e) => debugPrint("Error completing: $e"),
      );
      if (error != "") return error;
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) {
    return Future.delayed(loginTime).then((_) async {
      var error = "";
      await userRef.where("email", isEqualTo: data.name).get().then(
        (querySnapshot) {
          if (querySnapshot.size == 1) {
            error = "User already exists";
          } else {
            firstLog = true;
            loggedInUserToRealm(data.name!);
            User newUser = User(
                email: data.name!,
                password: data.password!,
                username: emptyUsername,
                pushToken: "placeholder");
            userRef.doc(data.name!).set(newUser);
            ProfilePicture newPicture = ProfilePicture(
                image: emptyProfilePicture,
                user: data.name!,
                timestamp: Timestamp.now());
            ppRef.add(newPicture);
          }
        },
        onError: (e) => debugPrint("Error completing: $e"),
      );
      if (error != "") return error;
      return null;
    });
  }

  Future<String?> _recoverPassword(String email) {
    return Future.delayed(loginTime).then((_) async {
      var error = "";
      await userRef.where("email", isEqualTo: email).get().then(
        (querySnapshot) {
          if (querySnapshot.size == 0) {
            error = "User not exists";
          }
        },
        onError: (e) => debugPrint("Error completing: $e"),
      );
      if (error != "") return error;
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    firstLog = false;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/login_image.png"),
                fit: BoxFit.cover)),
        child: FlutterLogin(
          logo: const AssetImage('assets/images/logo.png'),
          onLogin: _authUser,
          onSignup: _signupUser,
          hideForgotPasswordButton: true,
          onSubmitAnimationCompleted: () {
            Navigator.of(context).pushReplacement(CupertinoPageRoute(
              builder: (context) =>
                  firstLog ? const ProfileSetUp() : const Home(),
            ));
          },
          theme: LoginTheme(
            pageColorLight: Colors.transparent,
            pageColorDark: Colors.transparent,
            primaryColor: Colors.blueAccent[700],
          ),
          onRecoverPassword: _recoverPassword,
        ),
      ),
    );
  }
}
