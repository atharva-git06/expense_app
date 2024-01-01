import 'package:expenseapp/screens/expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/ex_category.dart';

class CategoryCard extends StatelessWidget {
  final ExpenseCategory category;
  const CategoryCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context)
            .pushNamed(ExpenseScreen.name, arguments: category.title);
      },
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(category.icon),
      ),
      title: Text(category.title),
      subtitle: Text('entries: ${category.entries}'),
      trailing: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹')
          .format(category.totalAmount)),
    );
  }
}
