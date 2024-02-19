import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/text_field.dart';
import 'package:dropdown_search/dropdown_search.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  var genderCont = "";
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final heigthTextController = TextEditingController();
  final weigthTextController = TextEditingController();
  final nameTextController = TextEditingController();
  final ageTextController = TextEditingController();

  final confirmPasswordTextController = TextEditingController();

  void signUp() async {
    //show loading circle
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    //make sure password match
    if (passwordTextController.text != confirmPasswordTextController.text) {
      //pop loading circle
      Navigator.pop(context);
      //show error to user
      displayMessage("Passwords don't match!");
      return;
    }

    //try creating the user
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
              //gender: genderCont,
              //nameSurname: nameTextController.text,
              //heigth: heigthTextController.text,
              //weigth: weigthTextController.text,
              email: emailTextController.text,
              password: passwordTextController.text);

      //after creating the user, create a new document on firestore called Users
      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'username': emailTextController.text.split('@')[0],
        'nameSurname': nameTextController.text, //initial username
        'gender': genderCont,
        'heigth': heigthTextController.text,
        'weigth': weigthTextController.text,
        'age': ageTextController.text,
        'bio': 'Empty bio...', //intial bio
        "email": emailTextController.text,
        "status": "Unavalible",
        "total": 0.0,
      });
      DocumentReference getLoggedUserReference() {
        final userReference = FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser?.email);
        return userReference;
      }

      DocumentReference getUserReferenceById(userId) {
        final userReference =
            FirebaseFirestore.instance.collection('Users').doc(userId);
        return userReference;
      }

      Future<bool> addFriend(friendId) async {
        DocumentReference friendRef = getUserReferenceById(friendId);
        DocumentReference loggedRef = getLoggedUserReference();

        try {
          // add friend to logged user
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .collection('friends')
              .add({'user_ref': friendRef});

          // add friend to friend user
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(friendId)
              .collection('friends')
              .add({'user_ref': loggedRef});
          return true;
        } catch (err) {
          print('Error $err');
          return false;
        }
      }

      //pop laoding circle
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop loading circle
      Navigator.pop(context);
      //show error to user
      displayMessage(e.code);
    }
  }

  //display a dialog message
  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(message),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lime[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //logo
                  Icon(
                    Icons.supervised_user_circle,
                    size: 90,
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                  //welcome back message
                  Text(
                    "Lets create an account for you",
                    style: TextStyle(color: Colors.grey[700]),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  //email textfield
                  MyTextField(
                      controller: nameTextController,
                      hintText: 'Name',
                      obscureText: false),

                  const SizedBox(
                    height: 10,
                  ),

                  MyTextField(
                      controller: emailTextController,
                      hintText: 'Email',
                      obscureText: false),

                  const SizedBox(
                    height: 10,
                  ),
                  DropdownSearch<String>(
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        fillColor: Colors.lime.shade200,
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        hintText: "Gender",
                      ),
                    ),
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      showSelectedItems: true,
                      //disabledItemFn: (String s) => s.startsWith('I'),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Gender';
                      }
                      genderCont = value;
                      print(genderCont);
                      //return null;
                    },
                    items: ["Female", "Male", "Prefer not to say"],
                    /*Departments.bolumler.values
                          .expand((e) => e)
                          .toList()
                          .cast<String>(),
                          */
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: MyTextField(
                              controller: heigthTextController,
                              hintText: "Heigth",
                              obscureText: false)),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: MyTextField(
                              controller: weigthTextController,
                              hintText: "Weigth",
                              obscureText: false)),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: MyTextField(
                              controller: ageTextController,
                              hintText: "Age",
                              obscureText: false)),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  //password textfield

                  MyTextField(
                      controller: passwordTextController,
                      hintText: 'Password',
                      obscureText: true),

                  const SizedBox(
                    height: 10,
                  ),

                  //confirm password textfield
                  MyTextField(
                      controller: confirmPasswordTextController,
                      hintText: 'Confirm Password',
                      obscureText: true),

                  const SizedBox(
                    height: 10,
                  ),

                  //sign up button

                  MyButton(onTap: signUp, text: 'Sign Up'),

                  const SizedBox(
                    height: 25,
                  ),

                  //go to register page

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account ?",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Login Now",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          )),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
