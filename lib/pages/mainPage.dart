import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_wall/pages/friend_list_screen.dart';
//import 'package:yulaf_app/home/authentication_screen.dart';
//import 'package:yulaf_app/home/authentication_viewmodel.dart';
//import 'package:yulaf_app/home/chat.dart';
//import 'package:yulaf_app/home/home.dart';
//import 'package:yulaf_app/home/userScreen.dart';
//import 'package:yulaf_app/models/user.dart';
//import "feed.dart";
import 'home_page.dart';
import 'home.dart';
import 'package:social_wall/components/drawer.dart';
import 'package:social_wall/pages/profile_page.dart';

import 'package:flutter/material.dart';
import "package:google_nav_bar/google_nav_bar.dart";
//import '../providers/user_provider.dart';
import 'mainPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'homePageCard.dart';
import 'package:social_wall/screens/category_screen.dart';

class MainPage extends StatefulWidget {
  //final UserClass user;

  MainPage();
  //  HomePage({required this.user});

  @override
  State<MainPage> createState() => _HomeState();
}

class _HomeState extends State<MainPage> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions() {
    return [
      Home(),
      HomePage(),
      //FriendListScreen(), //Feed(), // Pass the user object to the Feed widget
      //CategoryScreen(), //Chat(),
      //Container(), //FeedbackScreen(),
      ProfilePage(),
    ];
  }

  void goToProfilePage() {
    //pop menu drawer
    Navigator.pop(context);

    //go to profile page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    print("hompage");
    return Scaffold(
      backgroundColor: Colors.white,
      //floatingActionButtonLocation: FloatingActionButtonLocation.endTop,

      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
      ),
      appBar: AppBar(
        //backgroundColor: Colors.blue.shade50,
        // appBar: AppBar(
        //title: Text("Social Wall"),
        //backgroundColor: Color.fromARGB(255, 197, 0, 251),
        actions: [
          //sign out button

          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendListScreen()),
                );
              },
              icon: Icon(Icons.chat))
        ],
        //),

        elevation: 0,
        title: const Text(
          'YULAF',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          return Center(
            child: _widgetOptions()[_selectedIndex],
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.deepPurple[300],
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.feed,
                  text: 'Feed',
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Profile',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
