import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_wall/pages/challenge_option.dart';

import 'package:social_wall/pages/search_page_group.dart';
import 'package:social_wall/services/database_service.dart';
import 'package:social_wall/widgets/widgets.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({
    super.key,
  });

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  late Stream<QuerySnapshot> _streamGroups;
  bool _isLoading = false;
  String groupName = "";
  String userName = "";

  @override
  void initState() {
    super.initState();
    _streamGroups = FirebaseFirestore.instance.collection('groups').snapshots();
  }

  User? user = FirebaseAuth.instance.currentUser;
  bool hasUserJoined(List<dynamic> currentMembers, String userId) {
    return currentMembers.contains(userId);
  }

  bool isCurrentUserAdmin(Map<String, dynamic> groupData) {
    String adminEmail = groupData['admin'];
    String currentUserEmail = user?.email ?? 'User email is null';

    return adminEmail == currentUserEmail;
  }

  popUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              title: const Text(
                "Create a group",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : TextField(
                          onChanged: (val) {
                            setState(() {
                              groupName = val;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(15),
                              )),
                        ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text(
                    "CANCEL",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (groupName != "") {
                      setState(() {
                        _isLoading = true;
                      });
                      DataBaseService(
                              email: FirebaseAuth.instance.currentUser!.email)
                          .createGroup(
                              userName,
                              FirebaseAuth.instance.currentUser!.email!,
                              groupName)
                          .whenComplete(() {
                        setState(() {
                          _isLoading = false;
                        });
                        Navigator.of(context).pop();
                        showSnakbar(context, Colors.green,
                            "Group created successfully.😍");
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text(
                    "CREATE",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              ],
            );
          }));
        });
  }

  // Method to handle deleting the group
  void deleteGroup(String groupId, var groupData) async {
    if (user != null) {
      try {
        // Assuming 'groups' collection contains adminId field for each group

        // Only allow the admin to delete the group
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .delete();

        // Update the UI to show that the group has been deleted
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Deleted group with ID: $groupId'),
        ));

        // Refresh the UI
        setState(() {});
      } catch (error) {}
    } else {}
  }

  void leaveGroup(String groupId, BuildContext context) async {
    if (user != null) {
      try {
        // Get the current list of members
        List<dynamic> currentMembers = [];
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            currentMembers = documentSnapshot['members'] ?? [];
          }
        });

        // Check if the user is a member before attempting to leave
        if (currentMembers.contains(user?.email)) {
          // Remove the user from the 'members' list
          currentMembers.remove(user?.email);

          // Update the group document with the new 'members' list
          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId)
              .update({
            'members': currentMembers,
          });

          // Update the UI to show that the user has left
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Left group with ID: $groupId'),
          ));

          // Refresh the UI
          setState(() {});
        } else {
          // User is not a member
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('You are not a member of the group.'),
          ));
        }
      } catch (error) {}
    } else {}
  }

  void joinGroup(String groupId) async {
    if (user != null) {
      // Assuming 'members' is a list in the group document
      try {
        // Get the current list of members
        List<dynamic> currentMembers = [];
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            currentMembers = documentSnapshot['members'] ?? [];
          }
        });

        // Check if the user is not already a member
        if (!currentMembers.contains(user?.email)) {
          // Add the user to the 'members' list
          currentMembers.add(user?.email);

          // Update the group document with the new 'members' list
          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId)
              .update({
            'members': currentMembers,
          });
          // Update the UI to show that the usser has joined
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Joined group with ID: $groupId'),
          ));

          // Refresh the UI
          setState(() {});

          // You can also navigate to a new screen or show a success message
        } else {}
      } catch (error) {}
    } else {}
  }

  // Add a method to navigate to the SearchPage
  void navigateToSearchPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group List'),
        actions: [
          // Add the search button to the app bar
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              navigateToSearchPage(context);
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _streamGroups,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No groups found.'),
            );
          }

          // Display the list of groups
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var groupData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              // Customize how you want to display each group item
              // Get the current list of members
              List<dynamic> currentMembers = groupData['members'] ?? [];

              // Check if the user has already joined the group
              bool userJoined =
                  hasUserJoined(currentMembers, user?.email ?? '');
              // Check if the current user is the admin of the group
              bool isAdmin = isCurrentUserAdmin(groupData);
              return GestureDetector(
                  onTap: () {
                    if (userJoined) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupDetailsScreen(
                              groupId: groupData["groupId"],
                            ),
                          ));
                    }
                  },
                  child: Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.black), // Add border to create a box
                        borderRadius:
                            const BorderRadius.all(Radius.circular(0)),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(255, 152, 142, 225),
                            Color.fromARGB(255, 191, 189, 210)
                          ],
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.group, // Specify the group icon you want to use
                          color: Colors.white, // Optionally set the icon color
                        ),

                        title: Text(
                          groupData['groupName'],
                          style: const TextStyle(
                            fontSize: 18.0, // Adjust the font size as needed
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Add a "Join" or "Joined" button based on the user's membership status
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Handle leaving the group here
                                if (userJoined) {
                                  leaveGroup(groupData['groupId'], context);
                                } else {
                                  joinGroup(groupData['groupId']);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: userJoined
                                    ? Color.fromARGB(255, 250, 140, 132)
                                    : Color.fromARGB(255, 194, 233, 201),
                              ),
                              child: Text(
                                userJoined ? 'Leave' : 'Join',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                            // Add delete button for the admin
                            // Add delete button for the admin
                            if (isAdmin)
                              ElevatedButton(
                                onPressed: () {
                                  // Handle deleting the group here
                                  deleteGroup(groupData['groupId'], context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.black, // Set button color to red
                                ),
                                child: Text('Delete'),
                              ),
                          ],
                        ),
                      )));

              // Add more widgets as needed based on your data model
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
