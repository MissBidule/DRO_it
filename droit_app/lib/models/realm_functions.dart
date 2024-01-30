import 'dart:typed_data';
import 'package:droit_app/models/currentUser.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart' as rdb;
import 'package:realm/realm.dart';

var config = rdb.Configuration.local([CurrentUser.schema]);
var realm = rdb.Realm(config);

void currentFriendToRealm(String email) {
  var currentFriends = realm.all<CurrentUser>().query("type == 'friend'");
  if (currentFriends.isNotEmpty) {
    debugPrint(
        "Error! There already is a current friend: ${currentFriends.first.email}\n Deleting old friend and replacing with $email");
    realm.write(() => realm.delete(currentFriends.first));
  }
  CurrentUser currentFriend = CurrentUser(email, "friend");
  realm.write(() {
    realm.add(currentFriend);
  });
}

String getCurrentHost() {
  var currentHosts = realm.all<CurrentUser>().query("type == 'host'");
  if (currentHosts.isEmpty) {
    debugPrint("Error! There is no logged in user!");
    return "";
  } else {
    return currentHosts.first.email;
  }
}

void removeCurrentUserFromRealm() {
  var currentHosts = realm.all<CurrentUser>().query("type == 'host'");
  if (currentHosts.isEmpty) {
    debugPrint("Error! There is no current host!");
  } else {
    CurrentUser cUObject = currentHosts.first;
    if (cUObject.isValid) {
      realm.write(() => realm.delete(cUObject));
    } else {
      debugPrint("Error while deleting object $cUObject");
    }
  }
}

List<String> getCurrentUsers() {
  List<String> users = ["", ""];
  var currentHosts = realm.all<CurrentUser>().query("type == 'host'");
  if (currentHosts.isEmpty) {
    debugPrint("Error! There is no logged in user!");
  } else {
    users[0] = currentHosts.first.email;
  }
  var currentFriends = realm.all<CurrentUser>().query("type == 'friend'");
  if (currentFriends.isEmpty) {
    debugPrint("Error! There is no current friend!");
  } else {
    users[1] = currentFriends.first.email;
  }

  return users;
}

void removeCurrentFriendFromRealm() {
  var currentFriends = realm.all<CurrentUser>().query("type == 'friend'");
  if (currentFriends.isEmpty) {
    debugPrint("Error! There is no current friend!");
  } else {
    CurrentUser cFObject = currentFriends.first;
    if (cFObject.isValid) {
      realm.write(() => realm.delete(cFObject));
    } else {
      debugPrint("Error while deleting object $cFObject");
    }
  }
}

void loggedInUserToRealm(String email) {
  var config = rdb.Configuration.local([CurrentUser.schema]);
  var realm = rdb.Realm(config);
  var loggedInUsers = realm.all<CurrentUser>().query("type == 'host'");
  if (loggedInUsers.isNotEmpty) {
    debugPrint(
        "Error! There already is a logged in user: ${loggedInUsers.first.email}\n Deleting old user and replacing with $email");
    realm.write(() => realm.delete(loggedInUsers.first));
  }
  CurrentUser loggedInUser = CurrentUser(email, "host");
  realm.write(() {
    realm.add(loggedInUser);
  });
}

RealmResults<CurrentUser> getAllUsers() {
  return realm.all<CurrentUser>().query("type == 'friend'");
}

Image getImageFromString(String ImageData) {
  List<String> imageStringSplit = ImageData
      .replaceAll('[', '')
      .replaceAll(']', '')
      .trim()
      .split(",");
  List<int> imageInts = imageStringSplit
      .map((x) => int.parse(x))
      .toList();
  Uint8List imageBytes =
      Uint8List.fromList(imageInts);
  return Image.memory(imageBytes)
;}