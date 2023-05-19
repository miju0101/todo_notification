import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo/colors.dart';
import 'package:todo/screen/all_todo_screen.dart';
import 'package:todo/service/todo_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController content_controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TodoService>().read();
  }

  void createAndUpdate({Todo? todo}) {
    bool isCheck;
    DateTime date;
    TimeOfDay time;

    if (todo == null) {
      isCheck = false;
      date = DateTime.now();
      time = TimeOfDay.now();
      content_controller.clear();
    } else {
      isCheck = todo.isAlarm;
      date = todo.checkDate;
      time = TimeOfDay.fromDateTime(date);
      content_controller.text = todo.content;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(todo == null ? "할 일 추가" : "할 일 수정"),
        content: StatefulBuilder(builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text("할 일"),
              TextField(
                controller: content_controller,
              ),
              Row(
                children: [
                  const Text("날짜"),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2010),
                        lastDate: DateTime(2030),
                      );

                      if (selectedDate != null) {
                        setState(() {
                          date = selectedDate!;
                        });
                      }
                    },
                    child: Text(DateFormat("yyyy MM dd").format(date)),
                  )
                ],
              ),
              Row(
                children: [
                  const Text("알림"),
                  const Spacer(),
                  Switch(
                    value: isCheck,
                    onChanged: (value) {
                      setState(() {
                        isCheck = !isCheck;
                      });
                    },
                  )
                ],
              ),
              Visibility(
                child: TextButton(
                  onPressed: () async {
                    TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (selectedTime != null) {
                      setState(() {
                        time = selectedTime;
                      });
                    }
                  },
                  child: Text(
                    "${time.hour} : ${time.minute}",
                  ),
                ),
                visible: isCheck,
              )
            ],
          );
        }),
        actions: [
          TextButton(
            onPressed: () {
              if (todo == null) {
                //추가
                String content = content_controller.text;

                if (content.isEmpty) {
                  return;
                }

                var myTodo = Todo(
                  content: content,
                  isAlarm: isCheck,
                  checkDate: DateTime(
                      date.year, date.month, date.day, time.hour, time.minute),
                );

                context.read<TodoService>().create(myTodo);
              } else {
                String content = content_controller.text;

                if (content.isEmpty) {
                  return;
                }
                var myTodo = Todo(
                  content: content,
                  isAlarm: isCheck,
                  checkDate: date,
                );

                context.read<TodoService>().update(todo.id!, myTodo);
              }
              Navigator.pop(context);
            },
            child: const Text("완료"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("취소"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var todoService = context.watch<TodoService>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllTodoScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "할 일",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      createAndUpdate();
                    },
                    child: const Text("추가"),
                  )
                ],
              ),
              if (todoService.list.length > 0)
                SizedBox(
                  height: 10,
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: todoService.list.length,
                  itemBuilder: (context, index) {
                    Todo current_todo = todoService.list[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                current_todo.content,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              if (current_todo.isAlarm)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.alarm,
                                        size: 15,
                                      ),
                                      Text(
                                        DateFormat("a hh:mm")
                                            .format(current_todo.checkDate),
                                      )
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () =>
                                createAndUpdate(todo: current_todo),
                            icon: const Icon(Icons.edit, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () {
                              todoService.delete(current_todo.id!);
                            },
                            icon: const Icon(Icons.delete, color: Colors.white),
                          )
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
