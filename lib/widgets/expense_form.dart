import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/database_provider.dart';
import '../constants/icons.dart';
import '../models/expense.dart';
import '/./models/food_edamam.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _title = TextEditingController();
  final _amount = TextEditingController();
  var foodName = "";
  var foodCal = "";
  var foodProt = "";
  var foodFat = "";
  var foodCarb = "";

  DateTime? _date;
  String _initialValue = 'Other';

  //
  _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2022),
        lastDate: DateTime.now());

    if (pickedDate != null) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  void changeText() {
    setState(() {});
  }

  //
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // title
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Title of expense',
              ),
            ),
            const SizedBox(height: 20.0),
            // amount
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount of expense',
              ),
            ),
            const SizedBox(height: 20.0),

            // date picker
            /*Row(
              children: [
                Expanded(
                  child: Text(_date != null
                      ? DateFormat('MMMM dd, yyyy').format(_date!)
                      : 'Select Date'),
                ),
                IconButton(
                  onPressed: () => _pickDate(),
                  icon: const Icon(Icons.calendar_month),
                ),
              ],
            ),*/
            const SizedBox(height: 10.0),

            ElevatedButton.icon(
              onPressed: () async {
                final foodDat2 = await EdamamAPI.fetchFoodData(_title.text);
                final foodDat = EdamamAPI.parseFoodData(foodDat2);
                print(foodDat);
                //foodName = "banana";
                //print(foodDat["calories"]);
                foodName = foodDat["foodName"];
                foodCal = foodDat["calories"].toString();
                foodProt = foodDat["protein"].toString();
                foodFat = foodDat["fat"].toString();
                foodCarb = foodDat["carbs"].toString();

                changeText();
                setState(() {
                  print(foodName);
                });
              },
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
            const SizedBox(height: 20.0),

            Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                //color: Colors.blue,
                child: foodName != ""
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "name : " + foodName,
                            //style: TextStyle(fontSize: 15),
                          ),
                          Text("calorie : " + foodCal),
                          Text("protein : " + foodProt),
                          Text("carbs : " + foodCal),
                          Text("fat : " + foodFat),
                        ],
                      )
                    : Text("")),
            const SizedBox(height: 20.0),

            // category
            Row(
              children: [
                const Expanded(child: Text('Category')),
                Expanded(
                  child: DropdownButton(
                    items: icons.keys
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    value: _initialValue,
                    onChanged: (newValue) {
                      setState(() {
                        _initialValue = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: () {
                if (_title.text != '' && _amount.text != '') {
                  // create an expense
                  final file = Expense(
                    id: 0,
                    title: _title.text,
                    amount: double.parse(_amount.text),
                    date: _date != null ? _date! : DateTime.now(),
                    category: _initialValue,
                  );
                  // add it to database.
                  provider.addExpense(file);
                  // close the bottomsheet
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
