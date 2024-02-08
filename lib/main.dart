import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_wall/auth/auth.dart';
import 'package:provider/provider.dart';
import './models/database_provider.dart';
// screens
import './screens/category_screen.dart';
import './screens/expense_screen.dart';
import './screens/all_expenses.dart';
import './models/food_edamam.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("run build");
    fetchFoodCalories('1 apple');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
        // Add other providers as needed...
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthPage(),
        //initialRoute: CategoryScreen.name,
        routes: {
          "cat": (context) => CategoryScreen(),
          "/expense_screen": (context) => ExpenseScreen(),
          "/all_expenses": (context) => AllExpenses(),
          //ExpenseScreen.name: (_) => const ExpenseScreen(),
          //AllExpenses.name: (_) => const AllExpenses(),
        },
      ),
    );
  }
}
