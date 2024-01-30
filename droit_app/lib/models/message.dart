import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  Message({
    required this.image,
    required this.receiver,
    required this.sender,
    required this.timestamp,
  });

  Message.fromJson(Map<String, Object?> json)
      : this(
          image: json['image']! as String,
          receiver: json['receiver']! as String,
          sender: json['sender']! as String,
          timestamp: json['timestamp']! as Timestamp,
        );

  String image;
  String receiver;
  String sender;
  Timestamp timestamp;

  Map<String, Object?> toJson() {
    return {
      'image': image,
      'receiver': receiver,
      'sender': sender,
      'timestamp': timestamp,
    };
  }
}
