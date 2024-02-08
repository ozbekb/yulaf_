import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/icons.dart';
import '../../models/expense.dart';
import './confirm_box.dart';
import 'package:provider/provider.dart';
import '/models/database_provider.dart';

class ExpenseCard extends StatelessWidget {
  final Expense exp;
  const ExpenseCard(this.exp, {super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);

    return Dismissible(
      key: ValueKey(exp.id),
      confirmDismiss: (_) async {
        showDialog(
          context: context,
          builder: (_) => ConfirmBox(exp: exp),
        );
        return null;
      },
      child: ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => ConfirmBox(exp: exp),
          );
          //ConfirmBox(exp: exp);
          //provider.deleteExpense(exp.id, exp.category, exp.amount);
        },
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icons[exp.category]),
        ),
        title: Text(exp.title),
        subtitle: Text(DateFormat('MMMM dd, yyyy').format(exp.date)),
        //trailing: Text(NumberFormat.currency(locale: 'ar_sa', symbol: 'LD')
        //  .format(exp.amount)),
      ),
    );
  }
}
