// search_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

                    return ListTile(
                      title: Text(groupData['groupName']),
                      // Customize how you want to display each matching group item
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (userJoined) {
                                leaveGroup(groupData['groupId'], context);
                              } else {
                                joinGroup(groupData['groupId']);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  userJoined ? Colors.red : Colors.blue,
                            ),
                            child: Text(userJoined ? 'Leave' : 'Join'),
                          ),
                          // Add delete button for the admin
                          if (isAdmin)
                            ElevatedButton(
                              onPressed: () {
                                deleteGroup(groupData['groupId'], context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              child: Text('Delete'),
                            ),
                        ],
                      ),
                    );
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
