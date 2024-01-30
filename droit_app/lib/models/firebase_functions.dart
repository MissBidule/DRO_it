import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droit_app/models/user.dart';
import 'package:droit_app/models/message.dart';
import 'package:droit_app/models/conversation.dart';
import 'package:droit_app/models/profile_picture.dart';
import 'package:flutter/material.dart';

final conversationRef = FirebaseFirestore.instance
  .collection('conversation')
  .withConverter<Conversation>(
    fromFirestore: (snapshots, _) => Conversation.fromJson(snapshots.data()!),
    toFirestore: (conversation, _) => conversation.toJson(),
  );

final userRef =
  FirebaseFirestore.instance.collection('user').withConverter<User>(
        fromFirestore: (snapshots, _) => User.fromJson(snapshots.data()!),
        toFirestore: (user, _) => user.toJson(),
      );

final messageRef =
  FirebaseFirestore.instance.collection('message').withConverter<Message>(
        fromFirestore: (snapshots, _) => Message.fromJson(snapshots.data()!),
        toFirestore: (message, _) => message.toJson(),
      );

final ppRef = FirebaseFirestore.instance
  .collection('profilePicture')
  .withConverter<ProfilePicture>(
    fromFirestore: (snapshots, _) =>
        ProfilePicture.fromJson(snapshots.data()!),
    toFirestore: (profilePic, _) => profilePic.toJson(),
  );

void updateConversationShowing(currentHost, currentFriend, hidden) async {
  FirebaseFirestore.instance
    .collection('conversation')
    .doc("$currentHost:$currentFriend")
    .update({"hidden": hidden}).then(
        (value) => debugPrint("successfully updated hidden value!"),
        onError: (e) => {
          debugPrint("Error while updating hidden value: $e"),
        }
    );         
}

void updateConversationTimestamp(currentHost, currentFriend) async {
  //update lastchecked if the conv exists
  FirebaseFirestore.instance
      .collection('conversation')
      .doc("$currentHost:$currentFriend")
      .update({"lastChecked": Timestamp.now()}).then(
          (value) => debugPrint("successfully updated lastChecked value!"),
          onError: (e) => {
            debugPrint("Error while updating lastChecked value: $e"),
          }
      );
              
}

void updateConversationLastMessage(currentHost, currentFriend) async {
  Conversation newConvH, newConvF;
  FirebaseFirestore.instance
      .collection('conversation')
      .doc("$currentHost:$currentFriend")
      .update({"lastMessage": Timestamp.now(), "hidden": false}).then(
          (value) => debugPrint("successfully updated lastMessage value!"),
          onError: (e) => {
                //The conversation does not exist, adds it
                newConvH = Conversation(
                    host: currentHost,
                    friend: currentFriend,
                    lastMessage: Timestamp.now(),
                    lastChecked: Timestamp.now(),
                    hidden: false),
                conversationRef
                    .doc("$currentHost:$currentFriend")
                    .set(newConvH),
                newConvF = Conversation(
                    host: currentFriend,
                    friend: currentHost,
                    lastMessage: Timestamp.now(),
                    lastChecked: Timestamp.fromMillisecondsSinceEpoch(0),
                    hidden: false),
                conversationRef
                    .doc("$currentFriend:$currentHost")
                    .set(newConvF)
              });

  FirebaseFirestore.instance
      .collection('conversation')
      .doc("$currentFriend:$currentHost")
      .update({"lastMessage": Timestamp.now()}).then(
          (value) => debugPrint("successfully updated lastMessage value!"),
          onError: (e) =>
              debugPrint("Error while updating lastMessage value: $e"));
}

void updateUsernameDrawing(String imageString, currentHost) async {
    FirebaseFirestore.instance
        .collection('user')
        .doc(currentHost)
        .update({"username": imageString}).then(
            (value) => debugPrint("successfully updated username value!"),
            onError: (e) =>
                debugPrint("Error while updating username value: $e"));
  }