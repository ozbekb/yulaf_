import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:social_wall/models/user.dart';
import 'package:social_wall/services/user_service.dart';
import 'package:social_wall/widgets/search_bar_custom.dart';
import 'package:social_wall/widgets/top_navi_custom.dart';
import 'package:social_wall/widgets/user_card.dart';

class SearchFriendsScreen extends StatefulWidget {
  const SearchFriendsScreen({super.key});

  @override
  State<SearchFriendsScreen> createState() => _SearchFriendsScreenState();
}

class _SearchFriendsScreenState extends State<SearchFriendsScreen> {
  Future<QuerySnapshot>? usersList;
  String usernameText = '';

  initSearchFromTheBeginning(String text) {
    if (text != '') {
      text = text.toLowerCase();

      // only get usernames that start with value from the textfield input and that letters are in that order
      String endText = text.substring(0, text.length - 1) +
          String.fromCharCode(text.codeUnitAt(text.length - 1) + 1);

      usersList = FirebaseFirestore.instance
          .collection("Users")
          .where("nameSurname", isGreaterThanOrEqualTo: text)
          .where("nameSurname", isLessThan: endText)
          .get();

      setState(() {
        usersList;
      });
    } else {
      setState(() {
        usersList = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color.fromARGB(70, 152, 142, 225),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TopNavigationCustom(
                leftIcon: Icons.arrow_back,
                mainText: "Find Friends",
                rightIcon: null,
                isSmall: true,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SearchBarCustom(
                    inputText: usernameText,
                    initSearch: initSearchFromTheBeginning),
              ),
              Visibility(
                visible: usersList != null,
                child: FutureBuilder(
                  future: usersList,
                  builder: (context, AsyncSnapshot snapshot) {
                    return snapshot.hasData
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              UserC friend = UserC.fromDocument(
                                  snapshot.data!.docs[index]);
                              return friend.email !=
                                      FirebaseAuth.instance.currentUser!.email
                                  ? FutureBuilder(
                                      future: checkIfIsFriend(
                                          getUserReferenceById(friend.email),
                                          FirebaseAuth
                                              .instance.currentUser!.email!),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        }

                                        if (!snapshot.hasData) {
                                          return const Center(
                                              child: Text('Loading...'));
                                        }
                                        bool isFriend = snapshot.data ?? false;
                                        return (UserCardCustom(
                                          user: friend,
                                          icon: isFriend
                                              ? Icons.person_remove
                                              : Icons.person_add,
                                          color: isFriend
                                              ? const Color(0xFFA41723)
                                              : const Color(0xFF0276B4),
                                          iconColor: const Color(0xFFEAEAEA),
                                          onTap: () async {
                                            if (isFriend == true) {
                                              final res = await removeFriend(
                                                  friend.email);
                                              Fluttertoast.showToast(
                                                msg: res == true
                                                    ? "Removed from friends!"
                                                    : "Error.",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor: res == true
                                                    ? const Color(0xFF528C9E)
                                                    : const Color(0xFFA41723),
                                                textColor: Colors.white,
                                              );
                                              if (res == true) {
                                                setState(() {
                                                  isFriend = false;
                                                });
                                              }
                                            } else {
                                              final res =
                                                  await addFriend(friend.email);
                                              Fluttertoast.showToast(
                                                msg: res == true
                                                    ? "Added as a friend!"
                                                    : "Error.",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor: res == true
                                                    ? const Color(0xFF528C9E)
                                                    : const Color(0xFFA41723),
                                                textColor: Colors.white,
                                              );
                                              if (res == true) {
                                                setState(() {
                                                  isFriend = true;
                                                });
                                              }
                                            }
                                          },
                                        ));
                                      },
                                    )
                                  : const SizedBox(height: 0);
                            },
                          )
                        : const SizedBox(
                            width: 0,
                          );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
