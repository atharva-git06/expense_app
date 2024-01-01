import 'package:expenseapp/constants/icons.dart';
import 'package:expenseapp/models/ex_category.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

import 'expense.dart';

class DatabaseProvider with ChangeNotifier {
  String _searchText = '';
  String get searchText => _searchText;
  set searchText(String value) {
    _searchText = value;
    notifyListeners();
  }
  //in-app memory for holding the expense categories temporarily

  List<ExpenseCategory> _categories = [];
  List<ExpenseCategory> get categories => _categories;

  List<Expense> _expenses = [];
  List<Expense> get expenses {
    return _searchText != ''
        ? _expenses
            .where(
              (e) => e.title.toLowerCase().contains(
                    _searchText.toLowerCase(),
                  ),
            )
            .toList()
        : _expenses;
  }

  Database? _database;
  Future<Database> get database async {
    final dbDirectory = await getDatabasesPath();
    const dbName = 'expense_tc.db';
    final path = join(dbDirectory, dbName);

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
    return _database!;
  }

  // _createDb function
  static const cTable = 'categoryTable';
  static const eTable = 'expenseTable';
  Future<void> _createDb(Database db, int version) async {
    //this method runs only once. when the database is being created
    //so create the tables here and we can insert initial values in this function

    await db.transaction((txn) async {
      //category table
      await txn.execute('''CREATE TABLE $cTable(
      title TEXT,
      entries INTEGER,
      totalAmount TEXT
      )''');

      //expense table
      await txn.execute('''CREATE TABLE $eTable(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      amount TEXT,
      date TEXT,
      category TEXT
      )''');

      //adding initial values
      for (int i = 0; i < icons.length; i++) {
        await txn.insert(cTable, {
          'title': icons.keys.toList()[i],
          'entries': 0,
          'totalAmount': (0.0).toString(),
        });
      }
    });
  }

  //method to fetch categories

  Future<List<ExpenseCategory>> fetchCategories() async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(cTable).then((data) {
        final converted = List<Map<String, dynamic>>.from(data);
        List<ExpenseCategory> nList = List.generate(converted.length,
            (index) => ExpenseCategory.fromString(converted[index]));
        //set the value of categories to nList
        _categories = nList;
        return _categories;
      });
    });
  }

  Future<void> updateCategory(
      String category, int nEntries, double nTotalAmount) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .update(
        cTable,
        {
          'entries': nEntries,
          'totalAmount': nTotalAmount.toString(),
        },
        where: 'title == ?', //in table where the title ==
        whereArgs: [category], //this category
      )
          .then((_) {
        //after updating in database update in our in-app memory
        var file =
            _categories.firstWhere((element) => element.title == category);
        file.entries = nEntries;
        file.totalAmount = nTotalAmount;
        notifyListeners();
      });
    });
  }

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
        // after inserting in a database we store it in in-app memory with new expenses with generated id
        final file = Expense(
            id: generatedId,
            title: exp.title,
            amount: exp.amount,
            date: exp.date,
            category: exp.category);

        //add it to '_expenses'
        _expenses.add(file);

        //notify about the change in value of '_expenses'
        notifyListeners();

        var ex = findCategory(exp.category);
        var data = calculateEntriesAndAmount(exp.category);
        updateCategory(
            exp.category, ex.entries + 1, ex.totalAmount + exp.amount);
      });
    });
  }

  Future<void> deleteExpense(int expId,String category,double amount) async{
    final db = await database;
    await db.transaction((txn) async{
      await txn.delete(eTable,where: 'id == ?', whereArgs: [expId]).then((_) {
       _expenses.removeWhere((element) => element.id == expId);
       notifyListeners();

     var ex =  findCategory(category);
       updateCategory(category, ex.entries -1, ex.totalAmount - amount);
      } );
    });
  }

  Future<List<Expense>> fetchExpenses(String category) async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(eTable,
          where: 'category == ?', whereArgs: [category]).then((data) {
        final converted = List<Map<String, dynamic>>.from(data);

        List<Expense> nList = List.generate(
            converted.length, (index) => Expense.fromString(converted[index]));
        _expenses = nList;
        return _expenses;
      });
    });
  }

  Future<List<Expense>> fetchAllExpenses() async {
    final db = await database;
    return await db.transaction(
      (txn) async {
        return await txn.query(eTable).then(
          (data) {
            final converted = List<Map<String, dynamic>>.from(data);
            List<Expense> nList = List.generate(
              converted.length,
              (index) => Expense.fromString(
                converted[index],
              ),
            );
            _expenses = nList;
            return _expenses;
          },
        );
      },
    );
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
    return _categories.fold(
        0.0, (previousValue, element) => previousValue + element.totalAmount);
  }

  List<Map<String, dynamic>> calculateWeekExpenses() {
    List<Map<String, dynamic>> data = [];

    for (int i = 0; i < 7; i++) {
      //1 total for each entry
      double total = 0.0;

      //subtract i from today to get previous dates
      final weekDay = DateTime.now().subtract(Duration(days: i));

      //check how many transactions happened that day
      for (int j = 0; j < _expenses.length; j++) {
        if (_expenses[j].date.year == weekDay.year &&
            _expenses[j].date.month == weekDay.month &&
            _expenses[j].date.day == weekDay.day) {
          //if found any then add amount to total
          total += _expenses[j].amount;
        }
      }
      data.add({'day': weekDay, 'amount': total});
    }
    return data;
  }
}
