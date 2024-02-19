import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_wall/components/chat_bubble.dart';
import 'package:social_wall/components/text_field.dart';
import 'package:social_wall/services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  const ChatPage({
    super.key,
    required this.receiverUserEmail,
  });
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void sendMessages() async {
    await _chatService.sendMessage(
        widget.receiverUserEmail, _messageController.text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
      ),
      body: Column(children: [
        //messages
        Expanded(
          child: _buildMessageList(),
        ),

        //user input
        _builidMessageInput(),
        const SizedBox(
          height: 25,
        )
      ]),
    );
  }

  // build messages list
  Widget _buildMessageList() {
    print(
        "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBVBVBVBVBVBVBVBBBBBBBBBBBBBBBBBBBBB");
    return StreamBuilder(
        stream: _chatService.getMessages(widget.receiverUserEmail,
            _firebaseAuth.currentUser!.email as String),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return Text("Error${snapshot.error}");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading..");
          }
          return ListView(
            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          );
        }));
  }
  // buildMessageitem

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    //allign messages left right
    print(
        "AAAAAAAAAAASASADFSGFGHGJHGJHGJHGJDHJHSFDHKVBDKSJNGLDKNGLDKNGLKDJGLKRJTHLKRTKJH");
    print(data["senderEmail"]);
    var alignment = (data["senderEmail"] == _firebaseAuth.currentUser?.email)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Container(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment:
                  (data["senderEmail"] == _firebaseAuth.currentUser?.email)
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                Text(data["senderEmail"]),
                const SizedBox(
                  height: 5,
                ),
                ChatBubble(message: data["message"]),
              ]),
        ));
  }

  //build message input
  Widget _builidMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          //text field
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: "Enter Message",
              obscureText: false,
            ),
          ),
          //send button
          IconButton(
              onPressed: sendMessages,
              icon: const Icon(
                Icons.arrow_upward,
                size: 40,
              ))
        ],
      ),
    );
  }
}
