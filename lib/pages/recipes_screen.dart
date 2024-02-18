import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:google_fonts/google_fonts.dart';

class RecipeScreen extends StatefulWidget {
  RecipeScreen();

  @override
  RecipeScreenState createState() => RecipeScreenState();
}

class RecipeScreenState extends State<RecipeScreen> {
  RecipeScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recipe")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Recipes').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
//https://firebasestorage.googleapis.com/v0/b/yulaf-app.appspot.com/o/image%2Fimage_picker_47549D32-18A4-4147-99CB-1CCFBEA96BB6-93192-00000EA683DBAB03.jpg?alt=media&token=3f663011-fce0-438b-8b5d-e0049031c2c3
          return ListView(
            children: snapshot.data!.docs.map((document) {
              String imagePath = document['url'];
              String title = document['title'];
              String description = document['description'];
              print(description.split("*"));

              return FutureBuilder(
                future: getImageDownloadUrl(imagePath),
                builder:
                    (BuildContext context, AsyncSnapshot<String> urlSnapshot) {
                  if (urlSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
//image_picker_47549D32-18A4-4147-99CB-1CCFBEA96BB6-93192-00000EA683DBAB03.jpg
                  if (urlSnapshot.hasError) {
                    return Text('Error: ${urlSnapshot.error}');
                  }

                  String imageUrl = urlSnapshot.data!;

                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(title),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.network(imageUrl),
                                SizedBox(height: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: description.split('*').map((line) {
                                    return Text(line);
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Image.network(imageUrl,
                              height: 200,
                              fit: BoxFit.contain), // Adjust height as needed
                          ListTile(
                            title: Text(title),
                            subtitle: Text('Tap for details'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Future<String> getImageDownloadUrl(String imagePath) async {
    Reference ref = FirebaseStorage.instance.ref().child(imagePath);
    return await ref.getDownloadURL();
  }
}
