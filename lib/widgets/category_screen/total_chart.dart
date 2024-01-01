import 'package:expenseapp/models/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class TotalChart extends StatelessWidget {
  const TotalChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (context, db, __) {
      var list = db.categories;
      var total = db.calculateTotalExpenses();
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
                    'Total Expense: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(total)}',
                    textScaleFactor: 1.5,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                ...list.map(
                  (e) => Padding(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          color: Colors.primaries[list.indexOf(e)],
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(e.title),
                        const SizedBox(
                          width: 5.0,
                        ),
                        Text( total == 0 ? '0%':
                            '${((e.totalAmount / total) * 100).toStringAsFixed(2)}%'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 40,
            child: PieChart(
              PieChartData(
                  centerSpaceRadius: 20,
                  sections: total != 0
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
                          .toList()),
            ),
          ),
        ],
      );
    });
  }
}
