import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String uid;
  final String displayName;
  final String email;
  final String? photoURL;
  final Timestamp lastSignIn;
  final String? fcmToken;

  ChatUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoURL,
    required this.lastSignIn,
    required this.fcmToken,
  });

  factory ChatUser.fromMap(Map<String, dynamic> map) {
    return ChatUser(
      uid: map['uid'] as String,
      displayName: map['displayName'] as String,
      email: map['email'] as String,
      photoURL: map['photoURL'] as String?,
      lastSignIn: map['lastSignIn'] as Timestamp,
      fcmToken: map['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'lastSignIn': lastSignIn,
      'fcmToken': fcmToken,
    };
  }
}