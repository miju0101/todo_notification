import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class TodoService with ChangeNotifier {
  List<Todo> list = [];
  List<Todo> today_list = [];
  List<Todo> tomorrow_list = [];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  TodoService() {
    initializeNotification();
  }

  void initializeNotification() async {
    final androidSetting = AndroidInitializationSettings("@mipmap/ic_launcher");

    var initializeSettings = InitializationSettings(android: androidSetting);

    await flutterLocalNotificationsPlugin.initialize(initializeSettings);

    tz.initializeTimeZones();
  }

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
    int id = await db.insert(
      "todos",
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(id);
    createNotification(id, todo);
    read();
  }

  void createNotification(int id, Todo todo) {
    const androidDetails = AndroidNotificationDetails(
        'channelId', 'channelName',
        channelDescription: 'Channel desc',
        priority: Priority.high,
        importance: Importance.max);

    const details = NotificationDetails(android: androidDetails);

    tz.TZDateTime alarmTime = tz.TZDateTime.from(todo.checkDate, tz.local);

    if (alarmTime.isAfter(DateTime.now())) {
      flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        "투두 알림",
        "'${todo.content}' 할 시간이에요 ~ ＾ω＾",
        alarmTime,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print("알림 생성 완료");
    }
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

    createNotification(id, todo);

    read();
  }

  void delete(int id) async {
    var db = await TodoService.connectionDB();
    await db.delete('todos', where: "id = ?", whereArgs: [id]);
    flutterLocalNotificationsPlugin.cancel(id);
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
