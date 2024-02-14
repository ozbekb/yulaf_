import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:social_wall/components/comment.dart';
import 'package:social_wall/components/like_button.dart';
import 'package:social_wall/helper/helper_method.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'comment_button.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final String? imageUrl;
  final List<String> likes;

  const WallPost(
      {super.key,
      required this.user,
      required this.time,
      required this.message,
      required this.postId,
      required this.likes,
      required this.imageUrl});

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final FirebaseStorage storage = FirebaseStorage.instance;

  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  //comment text controller
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  //toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    Future<String> downloadURL(String imageName) async {
      String downloadURL =
          await storage.ref("image/$imageName").getDownloadURL();
      return downloadURL;
    } //Access the document in firebase

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      //if the post is now liked, add the users email to the liked field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email]),
        'ImageUrl': widget.imageUrl,
      });
    } else {
      //if the post is unliked , remove the users email from liked field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email]),
        'ImageUrl': widget.imageUrl,
      });
    }
  }

  //add a comment
  void addComment(String commentText) {
    //write a comment to firestore under the comments collection of this post
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now(), //remember to format this when displaying
    });
  }

  //show a dialog box for adding comment
  void showCommentDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Add Comment"),
              content: TextField(
                controller: _commentTextController,
                decoration: InputDecoration(hintText: "Write a comment..."),
              ),
              actions: [
                //cancel button
                TextButton(
                    onPressed: () => {
                          Navigator.pop(context),
                          _commentTextController.clear()
                        },
                    //clear controller

                    child: Text("Cancel")),

                //post button
                TextButton(
                    onPressed: () => {
                          addComment(_commentTextController.text),
                          //pop box
                          Navigator.pop(context),

                          _commentTextController.clear(),
                        },
                    child: Text("Post")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    //print("İMAGE URL");
    //print(widget.imageUrl);

    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 20,
          ),

          //message and user email
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.user.split("@")[0],
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                // Display the image if available
                if (widget.imageUrl != null) Image.network(widget.imageUrl!),

                /*SizedBox(
                    width: 100,
                    height: 100,
                    child: FutureBuilder<String>(
                      future: downloadURL(widget
                          .imageUrl), // replace with the actual image name
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            // Handle error
                            print("errrorrrr");
                            //print(downloadURL(widget.imageUrl));
                            return Container(); // Placeholder or error handling widget
                          }

                          // Display the image using the obtained URL
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(snapshot.data!),
                          );
                        } else {
                          // Display a loading indicator or placeholder while waiting for the URL
                          return Text("no image");
                        }
                      },
                    ),
                  ),*/

                /*SizedBox(
                      width: 300,
                      height: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.imageUrl!,
                        ),
                      )),*/
                Text(
                  widget.message,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),

                /* const SizedBox(
                  height: 5,
                ),*/

                const SizedBox(
                  height: 20,
                ),
                //buttons

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //LIKE
                    Column(
                      children: [
                        //like button
                        LikeButton(isLiked: isLiked, onTap: toggleLike),

                        const SizedBox(
                          height: 5,
                        ),

                        //like count

                        Text(widget.likes.length.toString())
                      ],
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    //COMMENT
                    Column(
                      children: [
                        //comment button
                        CommentButton(onTap: showCommentDialog),

                        const SizedBox(
                          height: 5,
                        ),

                        //comment count

                        Text(
                          "",
                          style: TextStyle(color: Colors.blue),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                //comments under the post
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("User Posts")
                        .doc(widget.postId)
                        .collection("Comments")
                        .orderBy("CommentTime", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      //show loading circle if no data yet
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return ListView(
                        shrinkWrap: true, //for nested lists
                        physics: NeverScrollableScrollPhysics(),
                        children: snapshot.data!.docs.map((doc) {
                          //get the comment
                          final commentData =
                              doc.data() as Map<String, dynamic>;

                          //return the comment
                          return Comment(
                              text: commentData["CommentText"],
                              user: commentData["CommentedBy"],
                              time: formatDate(commentData["CommentTime"]));
                        }).toList(),
                      );
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      widget.time,
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /*Future<String> downloadURL(String imageName) async {
    print("downloadURl FUNCTION ");
    //String downloadURL = await storage.ref("files/$imageName").getDownloadURL();

    String downloadURL = await storage.ref(imageName).getDownloadURL();
    print("downloaded url " + downloadURL);
    return downloadURL;
  }*/
}
