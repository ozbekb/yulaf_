import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

    print('Admin Email: $adminEmail');
    print('Current User Email: $currentUserEmail');

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
                    primary: Theme.of(context).primaryColor,
                  ),
                  child: const Text("CANCEL"),
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
                    primary: Theme.of(context).primaryColor,
                  ),
                  child: const Text("CREATE"),
                )
              ],
            );
          }));
        });
  }

  // Method to handle deleting the group
  void deleteGroup(String groupId, var groupData) async {
    // Assuming you have a user authentication system
    // Replace the following line with your actual user authentication logic
    // FirebaseUser user = FirebaseAuth.instance.currentUser;

    // Check if user is signed in
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
      } catch (error) {
        print('Error deleting group: $error');
        // Handle error (show an error message, log the error, etc.)
      }
    } else {
      // Handle the case when the user is not signed in
      print('User not signed in. Cannot delete group.');
    }
  }

  void leaveGroup(String groupId, BuildContext context) async {
    // Assuming you have a user authentication system
    // Replace the following line with your actual user authentication logic
    // FirebaseUser user = FirebaseAuth.instance.currentUser;

    // Check if user is signed in
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
      } catch (error) {
        print('Error leaving group: $error');
        // Handle error (show an error message, log the error, etc.)
      }
    } else {
      // Handle the case when the user is not signed in
      print('User not signed in. Cannot leave group.');
    }
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
          print('Joined group with ID: $groupId');
        } else {
          // User is already a member
          print('User is already a member of the group.');
        }
      } catch (error) {
        print('Error joining group: $error');
        // Handle error (show an error message, log the error, etc.)
      }
    } else {
      // Handle the case when the user is not signed in
      print('User not signed in. Cannot join group.');
    }
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
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => GroupDetailsScreen(
                    //         groupId: groupData['groupId'],
                    //       ),
                    //     ));
                  },
                  child: ListTile(
                    title: Text(groupData['groupName']),

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
                            primary: userJoined ? Colors.red : Colors.blue,
                          ),
                          child: Text(userJoined ? 'Leave' : 'Join'),
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
                              primary: Colors.black, // Set button color to red
                            ),
                            child: Text('Delete'),
                          ),
                      ],
                    ),
                  ));

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
