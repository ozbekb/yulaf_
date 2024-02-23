import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/icons.dart';
import './ex_category.dart';
import './expense.dart';
import '/./models/food_edamam.dart';

class DatabaseProvider with ChangeNotifier {
  double totalProtein = 0.0;
  double totalcarb = 0.0;
  double totalfat = 0.0;
  double totalCal = 0.0;
  String _searchText = '';

  String get searchText => _searchText;
  set searchText(String value) {
    _searchText = value;
    notifyListeners();
    // when the value of the search text changes it will notify the widgets.
  }

  // in-app memory for holding the Expense categories temporarily
  List<ExpenseCategory> _categories = [];
  List<ExpenseCategory> get categories => _categories;

  List<Expense> _expenses = [];
  // when the search text is empty, return whole list, else search for the value
  List<Expense> get expenses {
    return _searchText != ''
        ? _expenses
            .where((e) =>
                e.title.toLowerCase().contains(_searchText.toLowerCase()))
            .toList()
        : _expenses;
  }

  Database? _database;
  Future<Database> get database async {
    // database directory
    final dbDirectory = await getDatabasesPath();
    // database name
    const dbName = 'expense_tc.db';
    // full path
    final path = join(dbDirectory, dbName);

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb, // will create this separately
    );

    return _database!;
  }

  // _createDb function
  static const cTable = 'categoryTable';
  static const eTable = 'expenseTable';
  Future<void> _createDb(Database db, int version) async {
    // this method runs only once. when the database is being created
    // so create the tables here and if you want to insert some initial values
    // insert it in this function.

    await db.transaction((txn) async {
      // category table
      await txn.execute('''CREATE TABLE $cTable(
        title TEXT,
        entries INTEGER,
        totalAmount TEXT
      )''');
      // expense table
      await txn.execute('''CREATE TABLE $eTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount TEXT,
        date TEXT,
        category TEXT
      )''');

      // insert the initial categories.
      // this will add all the categories to category table and initialize the 'entries' with 0 and 'totalAmount' to 0.0
      for (int i = 0; i < icons.length; i++) {
        await txn.insert(cTable, {
          'title': icons.keys.toList()[i],
          'entries': 0,
          'totalAmount': (0.0).toString(),
        });
      }
    });
  }

  // method to fetch categories

  Future<List<ExpenseCategory>> fetchCategories() async {
    // get the database
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(cTable).then((data) {
        // 'data' is our fetched value
        // convert it from "Map<String, object>" to "Map<String, dynamic>"
        final converted = List<Map<String, dynamic>>.from(data);
        // create a 'ExpenseCategory'from every 'map' in this 'converted'
        List<ExpenseCategory> nList = List.generate(converted.length,
            (index) => ExpenseCategory.fromString(converted[index]));
        // set the value of 'categories' to 'nList'
        _categories = nList;
        // return the '_categories'
        return _categories;
      });
    });
  }

  Future<void> updateCategory(
    String category,
    int nEntries,
    double nTotalAmount,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .update(
        cTable, // category table
        {
          'entries': nEntries, // new value of 'entries'
          'totalAmount': nTotalAmount.toString(), // new value of 'totalAmount'
        },
        where: 'title == ?', // in table where the title ==
        whereArgs: [category], // this category.
      )
          .then((_) {
        // after updating in database. update it in our in-app memory too.
        var file =
            _categories.firstWhere((element) => element.title == category);
        file.entries = nEntries;
        file.totalAmount = nTotalAmount;
        notifyListeners();
      });
    });
  }
  // method to add an expense to database

  Future<void> addExpense(Expense exp) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .insert(
        eTable,
        exp.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      )
          .then((generatedId) {
        // after inserting in a database. we store it in in-app memory with new expense with generated id
        final file = Expense(
            id: generatedId,
            title: exp.title,
            amount: exp.amount,
            date: exp.date,
            category: exp.category);
        // add it to '_expenses'

        _expenses.add(file);
        // notify the listeners about the change in value of '_expenses'
        notifyListeners();
        // after we inserted the expense, we need to update the 'entries' and 'totalAmount' of the related 'category'
        var ex = findCategory(exp.category);

        updateCategory(
            exp.category, ex.entries + 1, ex.totalAmount + exp.amount);
      });
    });
  }

  Future<void> deleteExpense(int expId, String category, double amount) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(eTable, where: 'id == ?', whereArgs: [expId]).then((_) {
        // remove from in-app memory too
        _expenses.removeWhere((element) => element.id == expId);
        notifyListeners();
        // we have to update the entries and totalamount too

        var ex = findCategory(category);
        updateCategory(category, ex.entries - 1, ex.totalAmount - amount);
      });
    });
  }

  Future<List<Expense>> fetchExpenses(String category) async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(eTable,
          where: 'category == ?', whereArgs: [category]).then((data) {
        final converted = List<Map<String, dynamic>>.from(data);
        //
        List<Expense> nList = List.generate(
            converted.length, (index) => Expense.fromString(converted[index]));
        _expenses = nList;
        print("run for " + category);
        for (Expense e in _expenses) {
          print(e.title);
          print(e.date.day.toString() + " " + DateTime.now().day.toString());
          if (e.date.day != DateTime.now().day) {
            deleteExpense(e.id, e.category, e.amount);
          }
        }
        return _expenses;
      });
    });
  }

  Future<List<Expense>> fetchAllExpenses() async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(eTable).then((data) {
        final converted = List<Map<String, dynamic>>.from(data);
        List<Expense> nList = List.generate(
            converted.length, (index) => Expense.fromString(converted[index]));
        _expenses = nList;
        print("all expenses");
        for (Expense e in _expenses) {
          print(e.title);
        }
        //print(_expenses);
        // _expenses.map((e) => print(e.title));
        return _expenses;
      });
    });
  }

  ExpenseCategory findCategory(String title) {
    return _categories.firstWhere((element) => element.title == title);
  }

  Map<String, dynamic> calculateEntriesAndAmount(String category) {
    double total = 0.0;
    var list = _expenses.where((element) => element.category == category);
    for (final i in list) {
      total += i.amount;
    }
    return {'entries': list.length, 'totalAmount': total};
  }

  double calculateTotalExpenses() {
    print("CALCULATE TOTAL");
    for (ExpenseCategory e in _categories) {
      //print(e.title + e.totalAmount.toString() + e.entries.toString());
    }

    return _categories.fold(
        0.0, (previousValue, element) => previousValue + element.totalAmount);
  }

  List<Map<String, dynamic>> calculateWeekExpenses() {
    List<Map<String, dynamic>> data = [];

    // we know that we need 7 entries
    for (int i = 0; i < 4; i++) {
      // 1 total for each entry
      double total = 0.0;
      // subtract i from today to get previous dates.
      final weekDay = DateTime.now().subtract(Duration(days: i));

      // check how many transacitons happened that day
      for (int j = 0; j < _expenses.length; j++) {
        if (_expenses[j].date.year == weekDay.year &&
            _expenses[j].date.month == weekDay.month &&
            _expenses[j].date.day == weekDay.day) {
          // if found then add the amount to total
          total += _expenses[j].amount;
        }
      }

      // add to a list
      data.add({'day': weekDay, 'amount': total});
    }
    // return the list
    return data;
  }

  Future<double> getProtein() async {
    double result = 0.0;
    totalCal = 0.0;
    totalcarb = 0.0;
    totalfat = 0.0;

    var list = await fetchAllExpenses();

    // List to store the futures of fetching food data
    List<Future<Map<String, dynamic>>> foodDataFutures = [];

    for (Expense e in list) {
      foodDataFutures.add(EdamamAPI.fetchFoodData(e.title));
    }

    // Wait for all the asynchronous operations to complete
    List<Map<String, dynamic>> foodDataList =
        await Future.wait(foodDataFutures);

    for (Map<String, dynamic> foodData in foodDataList) {
      print("here");
      for (Expense e in list) {
        //print("foodDATA " + foodData.entries.elementAt(5).key);
        print(e.title + " ****** " + foodData.entries.first.value.toString());
        if (e.title == foodData.entries.first.value.toString()) {
          double amount = 0.0;
          amount = e.amount;
          print("FORRRRR");

          print(e.title + "  -------- " + e.amount.toString());
          final parsedFoodData = EdamamAPI.parseFoodData(foodData);
          result += double.parse(parsedFoodData["protein"].toString());
          totalcarb += double.parse(parsedFoodData["carbs"].toString());
          totalfat += double.parse(parsedFoodData["fat"].toString());
          double size =
              double.parse(parsedFoodData["servingSizeWeight"].toString());
          double cal = double.parse(parsedFoodData["calories"].toString());
          //Expense e = list.fi
          //totalCal += ((amount / size) * cal);
          print("REAL CAL ");
          print((amount / size) * cal);
          totalCal += ((amount / size) * cal);

          //totalCal += double.parse(parsedFoodData["calories"].toString());

          print("Size " + size.toString());
          //break;
        }
      }
      print("here2");

      /*final parsedFoodData = EdamamAPI.parseFoodData(foodData);
      result += double.parse(parsedFoodData["protein"].toString());
      totalcarb += double.parse(parsedFoodData["carbs"].toString());
      totalfat += double.parse(parsedFoodData["fat"].toString());
      double size =
          double.parse(parsedFoodData["servingSizeWeight"].toString());
      double cal = double.parse(parsedFoodData["calories"].toString());
      //Expense e = list.fi

      totalCal += double.parse(parsedFoodData["calories"].toString());

      print("Size " + size.toString());*/
    }

    totalProtein = result;
    print(totalProtein);
    print("result " + result.toString());

    return result;
    //final provider = Provider.of<DatabaseProvider>(context, listen: false);

    /* double result = 0.0;
    var list = await fetchAllExpenses();

//list.map((e) => null)

    for (Expense e in list) {
      final food = await EdamamAPI.fetchFoodData(e.title);
      final foodData = EdamamAPI.parseFoodData(food);
      //print(foodData["protein"]);
      result += double.parse(foodData["protein"].toString());
    }
    print(result);
    totalProtein = result;

    return result;*/
  }

  Future<double> getCarb() async {
    double result = 0.0;
    var list = await fetchAllExpenses();

    // List to store the futures of fetching food data
    List<Future<Map<String, dynamic>>> foodDataFutures = [];

    for (Expense e in list) {
      foodDataFutures.add(EdamamAPI.fetchFoodData(e.title));
    }

    // Wait for all the asynchronous operations to complete
    List<Map<String, dynamic>> foodDataList =
        await Future.wait(foodDataFutures);

    for (Map<String, dynamic> foodData in foodDataList) {
      final parsedFoodData = EdamamAPI.parseFoodData(foodData);
      result += double.parse(parsedFoodData["carbs"].toString());
    }

    totalcarb = result;
    print(totalcarb);
    print("result " + result.toString());

    return result;
  }

  Future<double> getFat() async {
    double result = 0.0;
    var list = await fetchAllExpenses();

    // List to store the futures of fetching food data
    List<Future<Map<String, dynamic>>> foodDataFutures = [];

    for (Expense e in list) {
      foodDataFutures.add(EdamamAPI.fetchFoodData(e.title));
    }

    // Wait for all the asynchronous operations to complete
    List<Map<String, dynamic>> foodDataList =
        await Future.wait(foodDataFutures);

    for (Map<String, dynamic> foodData in foodDataList) {
      final parsedFoodData = EdamamAPI.parseFoodData(foodData);
      result += double.parse(parsedFoodData["fat"].toString());
    }

    totalfat = result;
    print(totalfat);
    print("result " + result.toString());

    return result;
  }
}
