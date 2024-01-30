import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_wall/components/button.dart';
import 'package:social_wall/components/text_field.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controller
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  //sign user in

  void signIn() async {
    //show loading circle
    showDialog(context: context, builder: (context)=>const Center(
      child: CircularProgressIndicator(),
    ));


    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text, password: passwordTextController.text);


         //pop loading circle
    if(context.mounted) Navigator.pop(context);
    }
   
    
     on FirebaseAuthException catch(e){

      //pop loading circle
      Navigator.pop(context);
      //display error message
      displayMessage(e.code);
    }
  }


  //display a dialog message
  void displayMessage(String message){
    showDialog(context: context, builder: (context)=>AlertDialog(
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
                    Icons.lock,
                    size: 100,
                  ),

                  const SizedBox(
                    height: 50,
                  ),
                  //welcome back message
                  Text(
                    "Welcome back, You've been missed",
                    style: TextStyle(color: Colors.grey[700]),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  //email textfield

                  MyTextField(
                      controller: emailTextController,
                      hintText: 'Email',
                      obscureText: false),

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

                  //sign in button

                  MyButton(onTap: signIn, text: 'Sign In'),

                  const SizedBox(
                    height: 25,
                  ),

                  //go to register page

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a Member ?",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Register Now",
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
