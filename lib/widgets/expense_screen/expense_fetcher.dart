import 'package:expenseapp/models/database_provider.dart';
import 'package:expenseapp/widgets/expense_screen/expense_chart.dart';
import 'package:expenseapp/widgets/expense_screen/expense_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseFetcher extends StatefulWidget {
  final String category;
  const ExpenseFetcher({Key? key, required this.category}) : super(key: key);

  @override
  State<ExpenseFetcher> createState() => _ExpenseFetcherState();
}

class _ExpenseFetcherState extends State<ExpenseFetcher> {
  late Future _expenseList;
  Future _getExpenseList() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return await provider.fetchExpenses(widget.category);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _expenseList = _getExpenseList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _expenseList,
        builder: (_, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children:  [
                SizedBox(height: 250,child: ExpenseChart(category: widget.category,),),
                const Expanded(child: ExpenseList()),
              ],
            ),
          );
        }
      } else {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    });
  }
}
