import 'package:chatapp/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/message.dart';
import '../models/chat_user.dart';
import '../services/ai_service.dart';
import '../services/analytics_service.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final ChatUser peerUser;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.peerUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final CollectionReference _messagesRef =
  FirebaseFirestore.instance.collection('messages');

  String _getIndex() {
    var index = [widget.currentUserId, widget.peerUser.uid];
    index.sort();
    return index.join();
  }
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Scroll to bottom when messages load
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    // Log screen view for analytics
    AnalyticsService.logTelaChat();
  }
  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat com ${widget.peerUser.displayName.split(' ').first} (${widget.peerUser.email})'),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _messagesRef
                    .where('index', isEqualTo: _getIndex())
                    .orderBy('sentAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  debugPrint('Connection state: ${snapshot.connectionState}');
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text('No data returned.'));
                  }

                  final docs = snapshot.data!.docs;
                  debugPrint('Doc count: ${docs.length}');

                  if (docs.isEmpty) {
                    return const Center(child: Text('Envie sua primeira mensagem.'));
                  }

                  // Filter to only messages that also contain peerId.
                  final messages = docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Message.fromMap(doc.id, data);
                  }).toList();
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  return ListView(
                    controller: _scrollController,
                    children: messages.map((message) {
                      return MessageBubble(
                        message: "${message.text}\n${message.sentAt.toDate().toString()}\nEmotion: ${message.emotion}${message.emotionEmoji()}".trim(),
                        isSender: message.senderId == widget.currentUserId,
                        );
                    }).toList(),
                  );
                },
              )
          ),

          // Text field + send button
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        _sendMessage();
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  iconSize: 32,
                  color: Theme.of(context).primaryColor,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;


    final message = Message(
      id: '', // Vai ser criado no firebase
      senderId: widget.currentUserId,
      receiverId: widget.peerUser.uid,
      participants: [widget.currentUserId, widget.peerUser.uid],
      text: text,
      sentAt: Timestamp.now(),
      index: _getIndex(),
      emotion: "-"
    );

    final messageRef = await _messagesRef.add(message.toMap());
    String messageId = messageRef.id;

    AIService.analyzeEmotion(text).then((messageEmotion) {
      // Update the message with the analyzed emotion
      _messagesRef.doc(messageId).update({
        'emotion': messageEmotion
      });
    });

    _messageController.clear();

    // Log message sent event
    AnalyticsService.logEnviarMensagem();

    // Scroll to bottom after sending message
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }
}



