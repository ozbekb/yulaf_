import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:social_wall/models/user.dart';
import '../../models/database_provider.dart';
import 'package:social_wall/widgets/all_expenses_screen/all_expenses_fetcher.dart';

class TotalChart extends StatefulWidget {
  const TotalChart({super.key});

  @override
  State<TotalChart> createState() => _TotalChartState();
}

class _TotalChartState extends State<TotalChart> {
  AllExpensesFetcher allExpensesFetcher = new AllExpensesFetcher();

  @override
  void initState() {
    super.initState();
    _fetchProtein();
    // _fetchCarb();
    //_fetchFat();
  }

  Future<void> _fetchProtein() async {
    print("fetch protein");
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    await db.getProtein();
    setState(() {}); // Update the UI after fetching the protein value
  }

  Future<void> _fetchCarb() async {
    print("fetch carb");

    final db = Provider.of<DatabaseProvider>(context, listen: false);
    await db.getCarb();
    setState(() {}); // Update the UI after fetching the protein value
  }

  Future<void> _fetchFat() async {
    print("fetch fat");

    final db = Provider.of<DatabaseProvider>(context, listen: false);
    await db.getFat();
    setState(() {}); // Update the UI after fetching the protein value
  }

  // Function to update the total for a user in Firebase
  Future<void> updateTotalForUser(String? userEmail, double newTotal) async {
    print("update içi");
    print(newTotal);
    try {
      // Get the reference to the user document in Firestore
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');
      print("update after change");
      DocumentReference userRef = usersCollection.doc(userEmail);

      // Get the current user data
      DocumentSnapshot userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        print("CURRENT USSERRRRR!!!");
        UserC currentUser = UserC.fromDocument(userSnapshot);

        // Update the total property

        currentUser.total = newTotal;

        print(currentUser.total);

        // Update the total property in Firestore
        await userRef.update({'total': currentUser.total});
      } else {
        print('User not found');
      }
    } catch (e) {
      print('Error updating total: $e');
    }
  }

  Future<String?> getCurrentUserEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.email;
      } else {
        print('No user signed in.');
        return null;
      }
    } catch (e) {
      print('Error getting current user email: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (_, db, __) {
      var list = db.categories;
      print("CATEGORİES ");
      List<PieChartSectionData> pieChartSectionData = [
        PieChartSectionData(
          value: db.totalProtein,
          showTitle: false,
          //title: '20%',
          color: Color(0xffed733f),
        ),
        PieChartSectionData(
          value: db.totalcarb,
          showTitle: false,
          //title: '35%',
          color: Color(0xff584f84),
        ),
        PieChartSectionData(
          value: db.totalfat,
          showTitle: false,
          //title: '15%',
          color: Color(0xffd86f9b),
        ),
      ];
      //list.map((e) => print(e.title));

      //db.getProtein();

      print("total protein " + db.totalProtein.toString());
      print("total carb " + db.totalcarb.toString());
      print("total fat " + db.totalfat.toString());

      var total = db.calculateTotalExpenses();
      var totalcal = db.totalCal;
      User? user = FirebaseAuth.instance.currentUser;
      String? email = user?.email;
      updateTotalForUser(email, total);

      return Row(
        children: [
          Expanded(
            flex: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  alignment: Alignment.center,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Total Calorie: ${NumberFormat.currency(locale: 'ar_sa', symbol: 'Cal').format(totalcal)}',
                    textScaleFactor: 1.5,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Row(
                      children: [
                        Container(
                          width: 8.0,
                          height: 8.0,
                          color: Color(0xffed733f),
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          "Protein",
                        ),
                        const SizedBox(width: 5.0),
                        Text(total == 0
                            ? '0%'
                            : db.totalProtein.toStringAsFixed(2) +
                                " gr.") //'${((db.totalProtein / total) * 100).toStringAsFixed(2)}%'),
                      ],
                    )),
                const SizedBox(height: 8.0),
                Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Row(
                      children: [
                        Container(
                          width: 8.0,
                          height: 8.0,
                          color: Color(0xff584f84),
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          "Carbs.",
                        ),
                        const SizedBox(width: 5.0),
                        Text(total == 0
                            ? '0%'
                            : db.totalcarb.toStringAsFixed(2) +
                                " gr.") //'${((db.totalProtein / total) * 100).toStringAsFixed(2)}%'),
                      ],
                    )),
                const SizedBox(height: 8.0),
                Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Row(
                      children: [
                        Container(
                          width: 8.0,
                          height: 8.0,
                          color: Color(0xffd86f9b),
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          "Fat",
                        ),
                        const SizedBox(width: 5.0),
                        Text(total == 0
                            ? '0%'
                            : db.totalfat.toStringAsFixed(2) +
                                " gr.") //'${((db.totalProtein / total) * 100).toStringAsFixed(2)}%'),
                      ],
                    ))

                /*...list.map(
                  (e) => Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Row(
                      children: [
                        Container(
                          width: 8.0,
                          height: 8.0,
                          color: Colors.primaries[list.indexOf(e)],
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          e.title,
                        ),
                        const SizedBox(width: 5.0),
                        Text(total == 0
                            ? '0%'
                            : '${((e.totalAmount / total) * 100).toStringAsFixed(2)}%'),
                      ],
                    ),
                  ),
                ),*/
              ],
            ),
          ),
          Expanded(
            flex: 40,
            child: total != 0
                ? PieChart(
                    PieChartData(
                      centerSpaceRadius: 20.0,
                      sections: pieChartSectionData,

                      /*
                total != 0
                    ? list
                        .map(
                          (e) => PieChartSectionData(
                            showTitle: false,
                            value: e.totalAmount,
                            color: Colors.primaries[list.indexOf(e)],
                          ),
                        )
                        .toList()
                    : list
                        .map(
                          (e) => PieChartSectionData(
                            showTitle: false,
                            color: Colors.primaries[list.indexOf(e)],
                          ),
                        )
                        .toList(),
              */
                    ),
                  )
                : PieChart(PieChartData(centerSpaceRadius: 20.0, sections: [
                    PieChartSectionData(
                      //value: db.totalProtein,
                      showTitle: false,
                      //title: '20%',
                      color: Color(0xffed733f),
                    ),
                    PieChartSectionData(
                      //value: db.totalcarb,
                      showTitle: false,
                      //title: '35%',
                      color: Color(0xff584f84),
                    ),
                    PieChartSectionData(
                      // value: db.totalfat,
                      showTitle: false,
                      //title: '15%',
                      color: Color(0xffd86f9b),
                    ),
                  ])),
          ),
        ],
      );
    });
  }
}
