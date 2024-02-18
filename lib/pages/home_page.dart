import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_wall/components/drawer.dart';
import 'package:social_wall/components/text_field.dart';
import 'package:social_wall/components/wall_post.dart';
import 'package:social_wall/helper/helper_method.dart';
import 'package:social_wall/pages/profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;
import 'package:social_wall/services/image_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //text controller
  final textController = TextEditingController();
  String imageUrl = "";
  File? _photo;

  final ImagePicker _picker = ImagePicker();

  //sign user out
  /*void signOut() {
    FirebaseAuth.instance.signOut();
  }*/

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        //uploadImageToFirebase(_photo, "deneme");
        uploadFile();
      } else {
        print('No image captured.');
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null)
      return; // Check if there is a selected photo; if not, return

    final fileName = Path.basename(_photo!.path);
    //fileName = fileName + (DateTime.now().toString()); // Get the file name from the path
    //imageUrl = fileName;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final destination =
        'files/$timestamp-$fileName'; // Define the destination path in Firebase Storage
    print("DESTINATION");
    print(destination);
    imageUrl = destination;

    try {
      final ref = firebase_storage.FirebaseStorage.instance.ref(
          destination); // Create a reference to the destination path in Firebase Storage

      await ref.putFile(_photo!); // Upload the file to the specified location
    } catch (e) {
      print(e);
      print(
          'error occurred'); // Print an error message if an exception occurs during the upload
    }
  }

  //post message
  void postMessage() {
    //only post if there is something in textfield
    print("image url : " + imageUrl);
    if (textController.text.isNotEmpty) {
      //store in firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
        'ImageUrl': imageUrl
      });
    }

    //clear the text field
    setState(() {
      textController.clear();
    });
  }

  //navigate to profile page
  /* void goToProfilePage() {
    //pop menu drawer
    Navigator.pop(context);

    //go to profile page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {});
          // Add your onPressed code here!
          print(" PHOTOO " + imageUrl);
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text('New Post'),
                  content: SafeArea(
                    child: Container(
                      child: Wrap(
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Gallery'),
                            onTap: () {
                              imgFromGallery();
                              setState(() {
                                print(" PHOTOO2 " + imageUrl);
                              }); // Call function to pick image from the gallery
                              //Navigator.of(context)
                              //.pop(); // Close the bottom sheet after selection
                            },
                          ),
                          /*ListTile(
                            title: CircleAvatar(
                              radius: 55,
                              backgroundColor:
                                  Color.fromARGB(255, 101, 121, 230),
                              child: _photo != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.file(
                                        _photo!,
                                        width: 300,
                                        height: 300,
                                        fit: BoxFit.fitHeight,
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          //color: Colors.pink,
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      width: 100,
                                      height: 100,
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                            ),
                          ),*/
                          /*
                          new ListTile(
                            leading: new Icon(Icons.photo_camera),
                            title: new Text('Camera'),
                            onTap: () {
                              imgFromCamera(); // Call function to capture image from the camera
                              Navigator.of(context)
                                  .pop(); // Close the bottom sheet after selection
                            },
                          ),*/
                          Container(
                            //height: 300,
                            width: 500,
                            //color: Colors.pink,
                            child: MyTextField(
                                controller: textController,
                                hintText: "Explanation",
                                obscureText: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  /* 
                  new Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("New Post"),
                    ],
                  ),*/
                  actions: [
                    TextButton(
                      onPressed: (() {
                        postMessage();
                        Navigator.of(context).pop();
                      }),
                      child: const Text('Add'),
                    ),
                    // icon: const Icon(Icons.arrow_circle_up)),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      //textColor: Theme.of(context).primaryColor,
                      child: const Text('Close'),
                    ),
                  ],
                );
              });
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
      /*appBar: AppBar(
        title: Text("Social Wall"),
        backgroundColor: Color.fromARGB(255, 197, 0, 251),
        actions: [
          //sign out button

          IconButton(onPressed: signOut, icon: Icon(Icons.logout))
        ],
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
      ),*/
      body: Center(
        child: Column(
          children: [
            //the wall
            Expanded(
                child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .orderBy("TimeStamp", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      //get the message
                      final post = snapshot.data!.docs[index];
                      return WallPost(
                        imageUrl: post['ImageUrl'],
                        user: post['UserEmail'],
                        message: post['Message'],
                        postId: post.id,
                        likes: List<String>.from(post['Likes'] ?? []),
                        time: formatDate(post['TimeStamp']),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error : ${snapshot.error}'),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            )),

            //post message
            /*
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  //textfield
                  Expanded(
                    child: MyTextField(
                        controller: textController,
                        hintText: "Write something on the wall...",
                        obscureText: false),
                  ),

                  //post button
                  IconButton(
                      onPressed: postMessage,
                      icon: const Icon(Icons.arrow_circle_up))
                ],
              ),
            ),

            //logged in as
            Text(
              "Logged in as: " + currentUser.email!,
              style: TextStyle(
                  color: Color.fromARGB(255, 197, 0, 251),
                  fontWeight: FontWeight.bold),
            ), */

            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }

  Future<String> getImageDownloadUrl(String imagePath) async {
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child(imagePath);
    return await ref.getDownloadURL();
  }
}
