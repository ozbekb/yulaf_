import 'package:flutter/material.dart';

import 'package:social_wall/components/my_list_tile.dart';
import 'package:social_wall/pages/friend_list_screen.dart';
import 'package:social_wall/pages/group_list_page.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignOut;
  const MyDrawer(
      {super.key, required this.onProfileTap, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color.fromARGB(255, 152, 142, 225),
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //header
              const DrawerHeader(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 64,
                ),
              ),

              //home list tile
              MyListTile(
                icon: Icons.home,
                text: 'H O M E',
                onTap: () => Navigator.pop(context),
              ),

              //profile list tile
              MyListTile(
                  icon: Icons.person,
                  text: 'P R O F I L E',
                  onTap: onProfileTap),
              MyListTile(
                  icon: Icons.chat,
                  text: 'CHALLENGE GROUPS',
                  onTap: () {
                    // Navigate to ChatPage when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const GroupListScreen(), // You might need to pass user data to ChatPage
                      ),
                    );
                  }),
              MyListTile(
                  icon: Icons.chat,
                  text: 'FRIENDS',
                  onTap: () {
                    // Navigate to ChatPage when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const FriendListScreen(), // You might need to pass user data to ChatPage
                      ),
                    );
                  }),
            ],
          ),

          //logout list tile
          MyListTile(icon: Icons.logout, text: 'L O G O U T', onTap: onSignOut),
        ],
      ),
    );
  }
}
