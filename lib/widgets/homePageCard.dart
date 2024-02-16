import 'package:flutter/material.dart';

class homePageCard extends StatelessWidget {
  const homePageCard({
    super.key,
    required this.titleStyle,
    required this.title,
    required this.route,
    required this.gradient1,
    required this.gradient2,
    required this.iconData,
    required this.imageUrl,
  });
  final TextStyle titleStyle;
  final String title;
  final String route;
  final Color gradient1;
  final Color gradient2;
  final IconData iconData;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(route);
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.18,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 0),
                blurRadius: 2,
                spreadRadius: 2,
                color: Colors.black26,
              ),
            ],
            /*
            gradient: LinearGradient(
                colors: [gradient1, gradient2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),*/
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: titleStyle),

            /*Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width / 6,
                )),*/
          ],
        ),
      ),
    );
  }
}
