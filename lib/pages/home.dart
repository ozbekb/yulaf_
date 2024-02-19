import "package:flutter/material.dart";
//import "package:huisa/utils/categories_list.dart";
//import "package:huisa/widgets/category_item.dart";
import 'package:social_wall/pages/dialogflow.dart';
import 'package:social_wall/widgets/homePageCard.dart';
// git remote set-url origin https://github.com/ACMHacettepeDevelopers/YULAF
// git remote set-url https://github.com/ACMHacettepeDevelopers/YULAF

class Home extends StatelessWidget {
  var titleStyle = const TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 255, 255, 255));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(176, 113, 137, 215),
        hoverElevation: 50,
        elevation: 50,
        splashColor: Colors.purple,
        shape: CircleBorder(),
        child: Icon(
          Icons.webhook,
          size: 35,
        ),
        onPressed: () {
          print(1);
          Navigator.of(context).pushNamed("dialog");
          print(2);
        },
        heroTag: 'uniqueTag',
      ),
      //appBar: AppBar(),
      body: GridView(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 2.7,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20),
        children: [
          //ElevatedButton(onPressed: signUpUser, child: const Text("Sign Up")),
          //ElevatedButton(onPressed: signInUser, child: const Text("Sign In")),
          homePageCard(
              titleStyle: titleStyle,
              imageUrl:
                  "https://images.unsplash.com/photo-1466637574441-749b8f19452f?q=80&w=2428&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
              title: "Calorie",
              route: "calorie",
              gradient1: const Color.fromARGB(255, 214, 40, 72),
              gradient2: const Color.fromARGB(255, 247, 162, 113),
              iconData: Icons.dining_outlined),

          homePageCard(
            imageUrl:
                "https://images.unsplash.com/photo-1558611848-73f7eb4001a1?q=80&w=2671&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            titleStyle: titleStyle,
            title: "Exercise",
            route: "video",
            gradient1: const Color(0xffbcc5ce),
            gradient2: const Color(0xff939fae),
            iconData: Icons.fitness_center,
          ),
          homePageCard(
            imageUrl:
                "https://images.unsplash.com/photo-1495214783159-3503fd1b572d?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            //"https://images.unsplash.com/photo-1625937286074-9ca519d5d9df?q=80&w=2532&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            titleStyle: titleStyle,
            gradient1: const Color.fromARGB(255, 142, 187, 239),
            gradient2: const Color.fromARGB(255, 188, 213, 248),
            route: 'recipe',
            title: 'Fit Recipes',
            iconData: Icons.cookie_rounded,
          ),

          homePageCard(
              imageUrl:
                  "https://images.unsplash.com/photo-1674834726923-3ba828d37846?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",

              // "https://images.unsplash.com/photo-1554284126-aa88f22d8b74?q=80&w=2494&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
              titleStyle: titleStyle,
              title: "CHALLANGE",
              route: "challenge_option",
              gradient1: const Color.fromARGB(255, 126, 58, 174),
              gradient2: const Color.fromARGB(255, 174, 58, 149),
              iconData: Icons.timer),

          /*
            for (final category in availableCategories)
              CategoryItem(category: category)
        
          */
        ],
      ),
    );
  }

  //Future<void> signUpUser() async {}
  //Future<void> signInUser() async {}
}
