import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final List<String> participants;
  final String text;
  final Timestamp sentAt;
  final String index;
  final String emotion;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.participants,
    required this.text,
    required this.sentAt,
    required this.index,
    required this.emotion,
  });

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    return Message(
      id: id,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      participants: List<String>.from(map['participants']),
      text: map['text'] as String,
      sentAt: map['sentAt'] as Timestamp,
      index: map['index'] as String,
      emotion: map['emotion'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'participants': participants,
      'text': text,
      'sentAt': sentAt,
      'index': index,
      'emotion': emotion,
    };
  }

  String emotionEmoji() {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'fearful':
        return '😨';
      case 'surprised':
        return '😮';
      case 'neutral':
        return '😐';
      default:
        return '';
    }
  }
}