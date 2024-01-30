import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  Conversation({
    required this.friend,
    required this.hidden,
    required this.host,
    required this.lastChecked,
    required this.lastMessage,
  });

  Conversation.fromJson(Map<String, Object?> json)
      : this(
          friend: json['friend']! as String,
          hidden: json['hidden']! as bool,
          host: json['host']! as String,
          lastChecked: json['lastChecked']! as Timestamp,
          lastMessage: json['lastMessage']! as Timestamp,
        );

  String friend;
  bool hidden;
  String host;
  Timestamp lastChecked;
  Timestamp lastMessage;

  Map<String, Object?> toJson() {
    return {
      'friend': friend,
      'hidden': hidden,
      'host': host,
      'lastChecked': lastChecked,
      'lastMessage': lastMessage
    };
  }
}
