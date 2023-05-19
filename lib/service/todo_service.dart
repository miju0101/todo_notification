import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class TodoService with ChangeNotifier {
  List<Todo> list = [];
  List<Todo> today_list = [];
  List<Todo> tomorrow_list = [];

  static Future<Database> connectionDB() async {
    return openDatabase(
      'todo.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE "todos" (
            "id" INTEGER NOT NULL,
            "content"	TEXT,
            "isAlarm"	INTEGER,
            "checkDate"	TEXT,
            PRIMARY KEY("id")
          )
          """);
      },
    );
  }

  void create(Todo todo) async {
    var db = await TodoService.connectionDB();
    var map = todo.toMap();
    await db.insert(
      "todos",
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    read();
  }

  void read() async {
    var db = await TodoService.connectionDB();
    List<Map<String, dynamic>> temp =
        await db.query("todos", orderBy: 'checkDate');
    list = temp
        .map(
          (e) => Todo(
            id: e["id"],
            content: e["content"],
            isAlarm: e["isAlarm"] == 0 ? false : true,
            checkDate: DateTime.parse(e["checkDate"]),
          ),
        )
        .toList();
    notifyListeners();
    readToday();
    readTomorow();
  }

  void readToday() {
    today_list = list.where((todo) {
      DateTime now = DateTime.now();
      return todo.checkDate.year == now.year &&
          todo.checkDate.month == now.month &&
          todo.checkDate.day == now.day;
    }).toList();
  }

  void readTomorow() {
    tomorrow_list = list.where((todo) {
      DateTime now = DateTime.now().add(const Duration(days: 1));
      return todo.checkDate.year == now.year &&
          todo.checkDate.month == now.month &&
          todo.checkDate.day == now.day;
    }).toList();
  }

  void update(int id, Todo todo) async {
    var db = await TodoService.connectionDB();

    await db.update(
      'todos',
      todo.toMap(),
      where: "id = ?",
      whereArgs: [id],
    );

    read();
  }

  void delete(int id) async {
    var db = await TodoService.connectionDB();
    await db.delete('todos', where: "id = ?", whereArgs: [id]);
    read();
  }
}

class Todo {
  final int? id;
  final String content;
  final bool isAlarm;
  final DateTime checkDate;

  Todo({
    this.id,
    required this.content,
    required this.isAlarm,
    required this.checkDate,
  });

  Map<String, dynamic> toMap() {
    int alarm = isAlarm ? 1 : 0;
    return {
      "content": content,
      "isAlarm": alarm,
      "checkDate": checkDate.toString(),
    };
  }

  factory Todo.fromJson(Map json) {
    bool isAlarm = json["isAlarm"] == 0 ? false : true;
    DateTime checkDate = DateTime.parse(json["checkDate"]);

    return Todo(
      id: json["id"],
      content: json["content"],
      isAlarm: isAlarm,
      checkDate: checkDate,
    );
  }
}
