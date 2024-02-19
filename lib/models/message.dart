import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderEmail;
  final String receiverEmail;
  final String message;
  final Timestamp timestamp;
  Message(
      {required this.senderEmail,
      required this.receiverEmail,
      required this.timestamp,
      required this.message});

  Map<String, dynamic> toMap() {
    return {
      "senderEmail": senderEmail,
      "receiverEmail": receiverEmail,
      "message": message,
      "timestamp": timestamp,
    };
  }

//convert to map
}
