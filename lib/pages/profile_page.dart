import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_wall/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //user

  final currentUser = FirebaseAuth.instance.currentUser!;

  //all users
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  //edit field

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Color.fromARGB(255, 197, 0, 251),
              title: Text(
                "Edit " + field,
                style: const TextStyle(color: Colors.white),
              ),
              content: TextField(
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: "Enter new $field",
                    hintStyle: TextStyle(color: Colors.grey)),
                onChanged: (value) {
                  newValue = value;
                },
              ),
              actions: [
                // cancel button
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    )),

                //save button
                TextButton(
                    onPressed: () => Navigator.of(context).pop(newValue),
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ));

    //update in firestore
    if (newValue.trim().length > 0) {
      //only upadte if there is something in textfield
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.lime[300],
        /*appBar: AppBar(
          title: Text("Profile Page"),
          backgroundColor: Color.fromARGB(255, 197, 0, 251),
        ),*/
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(currentUser.email)
              .snapshots(),
          builder: (context, snapshot) {
            //get user data
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return ListView(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  //profile pic
                  Icon(
                    Icons.person,
                    size: 72,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  //user email
                  Text(
                    currentUser.email!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),

                  //user details
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text(
                      "My Details",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),

                  //username
                  MyTextBox(
                    text: userData['nameSurname'],
                    sectionName: 'Name',
                    onPressed: () => editField('name'),
                  ),

                  MyTextBox(
                    text: userData['heigth'],
                    sectionName: 'Heigth',
                    onPressed: () => editField('heigth'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: MyTextBox(
                          text: userData['heigth'],
                          sectionName: 'Heigth',
                          onPressed: () => editField('heigth'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: MyTextBox(
                          text: userData['weigth'],
                          sectionName: 'Weigth',
                          onPressed: () => editField('weigth'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: MyTextBox(
                          text: userData['age'],
                          sectionName: 'Age',
                          onPressed: () => editField('age'),
                        ),
                      ),
                    ],
                  ),

                  //bio
                  MyTextBox(
                    text: userData['bio'],
                    sectionName: 'bio',
                    onPressed: () => editField('bio'),
                  ),

                  const SizedBox(
                    height: 50,
                  ),

                  //user posts
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text(
                      "My Posts",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error${snapshot.error}'),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}
