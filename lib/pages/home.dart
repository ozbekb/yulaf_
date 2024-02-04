import "package:flutter/material.dart";
//import "package:huisa/utils/categories_list.dart";
//import "package:huisa/widgets/category_item.dart";
import 'package:social_wall/widgets/homePageCard.dart';
// git remote set-url origin https://github.com/ACMHacettepeDevelopers/YULAF
// git remote set-url https://github.com/ACMHacettepeDevelopers/YULAF

class Home extends StatelessWidget {
  var titleStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 255, 255, 255));
  @override
  Widget build(BuildContext context) {
    return GridView(
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
            title: "KALORİ",
            route: "",
            gradient1: const Color.fromARGB(255, 214, 40, 72),
            gradient2: const Color.fromARGB(255, 247, 162, 113),
            iconData: Icons.dining_outlined),
        homePageCard(
          titleStyle: titleStyle,
          gradient1: const Color.fromARGB(255, 142, 187, 239),
          gradient2: const Color.fromARGB(255, 188, 213, 248),
          route: '',
          title: 'DİYET',
          iconData: Icons.cookie_rounded,
        ),
        homePageCard(
          titleStyle: titleStyle,
          title: "SPOR",
          route: "",
          gradient1: const Color(0xffbcc5ce),
          gradient2: const Color(0xff939fae),
          iconData: Icons.fitness_center,
        ),
        homePageCard(
            titleStyle: titleStyle,
            title: "CHALLANGE",
            route: "",
            gradient1: const Color.fromARGB(255, 126, 58, 174),
            gradient2: const Color.fromARGB(255, 174, 58, 149),
            iconData: Icons.timer),

        /*
        for (final category in availableCategories)
          CategoryItem(category: category)

      */
      ],
    );
  }

  //Future<void> signUpUser() async {}
  //Future<void> signInUser() async {}
}
