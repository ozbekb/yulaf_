import 'package:cloud_firestore/cloud_firestore.dart';

class UserC {
  final String fullname;

  final String email;

  UserC({
    required this.fullname,
    required this.email,
  });

  factory UserC.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final fullname = data['nameSurname'] as String;

    final email = data['email'] as String;

    return UserC(
      fullname: fullname,
      email: email,
    );
  }
}
