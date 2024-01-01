
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/database_provider.dart';
class AllExpensesList extends StatelessWidget {
  const AllExpensesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (_,db,__){
        var list = db.expenses;
        return list.isNotEmpty? ListView.builder(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()
          ),
          itemCount: list.length,
          itemBuilder: (_,i)=>ListTile(title: Text(list[i].title),),
        ): const Center(
          child: Text('No Entries Found'),
        );
      },
    );
  }
}
