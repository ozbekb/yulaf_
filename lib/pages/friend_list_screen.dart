import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:social_wall/models/user.dart';
import 'package:social_wall/pages/search_friends.dart';
import 'package:social_wall/services/user_service.dart';
import 'package:social_wall/widgets/error_message_custom.dart';
import 'package:social_wall/widgets/top_navi_custom.dart';
import 'package:social_wall/widgets/unanimated_route.dart';
import 'package:social_wall/widgets/user_card.dart';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({
    super.key,
  });

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  late Stream<QuerySnapshot> _streamFriends;

  @override
  void initState() {
    super.initState();
    _streamFriends = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .collection('friends')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            TopNavigationCustom(
              leftIcon: Icons.arrow_back,
              mainText: "Friends",
              rightIcon: Icons.person_add_alt_1,
              isSmall: true,
              rightOnTap: () => {
                Navigator.push(
                  context,
                  UnanimatedRoute(
                      builder: (context) => const SearchFriendsScreen()),
                )
              },
            ),
            StreamBuilder<QuerySnapshot>(
                stream: _streamFriends,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final friends = snapshot.data!.docs;

                  return SizedBox(
                    height: friends.length * 91,
                    child: friends.isEmpty
                        ? const ErrorMessageCustom(text: "Add friends.")
                        : ListView.builder(
                            itemCount: friends.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final riderRef = friends[index]['user_ref']
                                  as DocumentReference;

                              return FutureBuilder<DocumentSnapshot>(
                                future: riderRef.get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }

                                  if (snapshot.hasData &&
                                      snapshot.data!.exists) {
                                    final userObject =
                                        UserC.fromDocument(snapshot.data!);

                                    return UserCardCustom(
                                        user: userObject,
                                        icon: Icons.person_remove,
                                        iconColor: const Color(0xFFA41723),
                                        color: const Color(0xFFF9B0B0),
                                        onTap: () async {
                                          final res = await removeFriend(
                                              userObject.email);
                                          Fluttertoast.showToast(
                                            msg: res == true
                                                ? "Removed from friends."
                                                : "Error.",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: res == true
                                                ? const Color(0xFF528C9E)
                                                : const Color(0xFFA41723),
                                            textColor: Colors.white,
                                          );
                                        });
                                  } else {
                                    return const Text('User not found');
                                  }
                                },
                              );
                            }),
                  );
                })
          ],
        ),
      )),
    );
  }
}
