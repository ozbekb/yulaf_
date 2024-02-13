// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addUserDetails(
  String fullname,
  String email,
) async {
  try {
    await FirebaseFirestore.instance.collection('Users').doc(email).set({
      "fullname": fullname,
      "email": email,
    });
  } catch (e) {
    print("Error adding user: $e");
  }
}

DocumentReference getLoggedUserReference() {
  final userReference = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser?.email);
  return userReference;
}

DocumentReference getUserReferenceById(userId) {
  final userReference =
      FirebaseFirestore.instance.collection('Users').doc(userId);
  return userReference;
}

Future<bool> addFriend(friendId) async {
  DocumentReference friendRef = getUserReferenceById(friendId);
  DocumentReference loggedRef = getLoggedUserReference();

  try {
    // add friend to logged user
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .collection('friends')
        .add({'user_ref': friendRef});

    // add friend to friend user
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(friendId)
        .collection('friends')
        .add({'user_ref': loggedRef});
    return true;
  } catch (err) {
    print('Error $err');
    return false;
  }
}

Future<bool> removeFriend(friendId) async {
  DocumentReference friendRef = getUserReferenceById(friendId);
  DocumentReference loggedRef = getLoggedUserReference();

  try {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .collection('friends')
        .where('user_ref', isEqualTo: friendRef)
        .get()
        .then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(friendId)
        .collection('friends')
        .where('user_ref', isEqualTo: loggedRef)
        .get()
        .then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    return true;
  } catch (err) {
    print('Error $err');
    return false;
  }
}

Future<bool> checkIfIsFriend(DocumentReference friendRef, String userId) async {
  final ridersSnapshot = await FirebaseFirestore.instance
      .collection("Users")
      .doc(userId)
      .collection('friends')
      .where('user_ref', isEqualTo: friendRef)
      .get();

  if (ridersSnapshot.docs.isEmpty) {
    return false;
  } else {
    return true;
  }
}
