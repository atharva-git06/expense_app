import 'package:expenseapp/models/database_provider.dart';
import 'package:expenseapp/widgets/expense_screen/confirm_box.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../constants/icons.dart';
import '../../models/expense.dart';

class ExpenseCard extends StatelessWidget {
  final Expense exp;
  const ExpenseCard({Key? key, required this.exp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context,listen:false);
    return Dismissible(
      key: ValueKey(exp.id),
      confirmDismiss:(_)async{
        showDialog(context: context, builder: (_)=>ConfirmBox(exp: exp));
      } ,
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icons[exp.category]),
        ),
        title: Text(exp.title),
        subtitle: Text(DateFormat('MMMM dd, yyyy').format(exp.date)),
        trailing: Text(NumberFormat.currency(locale: 'en_IN',symbol: '₹').format(exp.amount),),
      ),
    );
  }
}