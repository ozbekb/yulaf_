import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_wall/models/user.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailsScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late double hedefKalori;

  List<UserC> groupMembers = [];

  @override
  void initState() {
    List<UserC> groupMembers = [];
    super.initState();
    hedefKalori = 0.0;
    _fetchGroupData();
    _fetchGroupMembers(widget.groupId);
  }

  Future<void> _fetchGroupData() async {
    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      if (groupSnapshot.exists) {
        setState(() {
          hedefKalori = (groupSnapshot.get('hedefKalori') ?? 0).toDouble();
          // ^^^ Explicitly cast to double, and provide a default value if null
        });
      } else {
        print('Group not found');
      }
    } catch (e) {
      print('Error fetching group data: $e');
    }
  }

  Future<void> _fetchGroupMembers(String groupId) async {
    try {
      // Assuming 'groups' is your Firestore collection name
      CollectionReference groupCollection =
          FirebaseFirestore.instance.collection('groups');

      // Get the document reference for the specified groupId
      DocumentReference groupDocRef = groupCollection.doc(groupId);

      // Get the snapshot of the group document
      DocumentSnapshot groupSnapshot = await groupDocRef.get();

      // Check if the document exists
      if (groupSnapshot.exists) {
        // Extract the 'members' field from the document data
        List<dynamic> membersData = groupSnapshot['members'] ?? [];
        print(membersData);
        try {
          // Assuming 'users' is your Firestore collection name
          CollectionReference usersCollection =
              FirebaseFirestore.instance.collection('Users');

          // Fetch user data for each email in the 'members' list
          for (var email in membersData) {
            QuerySnapshot userSnapshot =
                await usersCollection.where('email', isEqualTo: email).get();

            if (userSnapshot.docs.isNotEmpty) {
              // Assume each email is unique to a user; if not, handle accordingly
              DocumentSnapshot userDoc = userSnapshot.docs.first;

              UserC groupMember = UserC(
                fullname: userDoc['nameSurname'] ?? '',
                email: userDoc['email'] ?? '',
                total: (userDoc['total'] ?? 0).toDouble(),
              );
              print(groupMember.email);

              setState(() {
                groupMembers.add(groupMember);
              });
            }
          }
        } catch (e) {
          print('Error fetching user data: $e');
        }
      } else {
        // Handle the case where the group document does not exist
      }
    } catch (e) {
      // Handle errors, e.g., log or return a default value
      print('Error fetching group members: $e');
    }
  }

  Future<void> updateHedefKalori(double newHedefKalori) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .update({'hedefKalori': newHedefKalori});

        setState(() {
          hedefKalori = newHedefKalori;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Hedef Kalori updated successfully'),
        ));
      } else {
        print('No user signed in.');
      }
    } catch (e) {
      print('Error updating hedefKalori: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Group Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hedef Kalori: $hedefKalori',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  showHedefKaloriDialog();
                },
                child: const Text('Change Hedef Kalori'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Members:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              for (var member in groupMembers)
                ListTile(
                  title: Text(
                    member.fullname,
                    style: TextStyle(
                      color: member.total >= hedefKalori
                          ? Colors.green
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    member.email,
                    style: TextStyle(
                      color: member.total >= hedefKalori
                          ? Colors.green
                          : Colors.black,
                    ),
                  ),
                  trailing: Text(
                    'Total: ${member.total}',
                    style: TextStyle(
                      color: member.total >= hedefKalori
                          ? Colors.green
                          : Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ));
  }

  Future<Map<String, dynamic>> _getUserInfo(String email) async {
    // Assuming the structure is like: { "email1": {"name": "John", "total": 10}, "email2": {"name": "Jane", "total": 20}, ... }
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(email).get();
    Map<String, dynamic> userData =
        documentSnapshot.data() as Map<String, dynamic>;
    if (userData != null) {
      return {
        'name': userData['nameSurname'],
        'total': userData['total'],
      };
    } else {
      return {'name': 'N/A', 'total': 0};
    }
  }

  Future<void> showHedefKaloriDialog() async {
    double newHedefKalori = hedefKalori;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Hedef Kalori'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              newHedefKalori = double.parse(value);
            },
            decoration: InputDecoration(labelText: 'New Hedef Kalori'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                updateHedefKalori(newHedefKalori);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
