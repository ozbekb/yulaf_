import 'package:flutter/material.dart';
import 'package:social_wall/models/user.dart';

import 'package:social_wall/widgets/top_navi_custom.dart';
import 'package:social_wall/widgets/user_data_custom.dart';

class FriendsProfileScreen extends StatelessWidget {
  const FriendsProfileScreen({super.key, required this.user});
  final UserC user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2F4),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            TopNavigationCustom(
                leftIcon: Icons.arrow_back,
                mainText: user.fullname,
                rightIcon: null),
            const SizedBox(
              height: 20,
            ),
            UserDataCustom(
                canEdit: false,
                textTitle: "Kullanıcı Bilgileri",
                user: user,
                itemsList: [
                  {"icon": Icons.person, "text": user.email},
                ]),
          ],
        ),
      )),
    );
  }
}
