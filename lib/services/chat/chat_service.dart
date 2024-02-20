import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:social_wall/models/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  //SEND MESSAGE
  Future<void> sendMessage(String receiverEmail, String message) async {
    print(receiverEmail);
    //get current user

    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();
    //create message
    Message newMessage = Message(
        senderEmail: currentUserEmail,
        receiverEmail: receiverEmail,
        timestamp: timestamp,
        message: message);
    //construct chat room id from current ıd receiver id
    List<String> ids = [currentUserEmail, receiverEmail];
    ids.sort();
    String chatRoomId = ids.join("_");
    print(chatRoomId);
    //add new messages to databases
    await _firebaseFirestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());
  }

  //Get MEssages
  Stream<QuerySnapshot> getMessages(String userEmail, String otherUserEmail) {
    print("GETGETGETGETEGETEGETEGETEGETGETEGETEGETEGETEGET");
    List<String> ids = [userEmail, otherUserEmail];
    ids.sort();
    String chatRoomId = ids.join("_");
    return _firebaseFirestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
