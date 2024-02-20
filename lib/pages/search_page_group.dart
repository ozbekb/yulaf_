// search_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_wall/pages/challenge_option.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  late Stream<QuerySnapshot> _searchResults;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchResults =
        FirebaseFirestore.instance.collection('groups').snapshots();
  }

  void _performSearch(String query) {
    setState(() {
      _searchResults = FirebaseFirestore.instance
          .collection('groups')
          .where('groupName', isGreaterThanOrEqualTo: query)
          .where('groupName', isLessThan: query + 'z')
          .snapshots();
    });
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
      } catch (error) {
        // Handle error (show an error message, log the error, etc.)
      }
    } else {
      // Handle the case when the user is not signed in
    }
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
        } else {
          // User is already a member
        }
      } catch (error) {
        // Handle error (show an error message, log the error, etc.)
      }
    } else {
      // Handle the case when the user is not signed in
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Groups'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                _performSearch(query);
              },
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _searchResults,
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
                    child: Text('No matching groups found.'),
                  );
                }

                // Display the list of matching groups
                // Display the list of matching groups
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var groupData = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

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
                                  color: Colors
                                      .black), // Add border to create a box
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
                                Icons
                                    .group, // Specify the group icon you want to use
                                color: Colors
                                    .white, // Optionally set the icon color
                              ),

                              title: Text(
                                groupData['groupName'],
                                style: const TextStyle(
                                  fontSize:
                                      18.0, // Adjust the font size as needed
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
                                        leaveGroup(
                                            groupData['groupId'], context);
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
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  // Add delete button for the admin
                                  // Add delete button for the admin
                                  if (isAdmin)
                                    ElevatedButton(
                                      onPressed: () {
                                        // Handle deleting the group here
                                        deleteGroup(
                                            groupData['groupId'], context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .black, // Set button color to red
                                      ),
                                      child: Text('Delete'),
                                    ),
                                ],
                              ),
                            )));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
