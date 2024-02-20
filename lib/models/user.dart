import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserC {
  final String fullname;

  final String email;
  double total;

  UserC({
    required this.fullname,
    required this.email,
    required this.total,
  });

  factory UserC.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final fullname = data['nameSurname'] as String;

    final email = data['email'] as String;

    final total = data['total'];

    return UserC(
      fullname: fullname,
      email: email,
      total: total,
    );
  }
}
