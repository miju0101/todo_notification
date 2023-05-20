import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo/colors.dart';
import 'package:todo/service/todo_service.dart';

class AllTodoScreen extends StatefulWidget {
  const AllTodoScreen({Key? key}) : super(key: key);

  @override
  State<AllTodoScreen> createState() => _AllTodoScreenState();
}

class _AllTodoScreenState extends State<AllTodoScreen> {
  @override
  void initState() {
    super.initState();
  }

  void update(Todo todo) {
    TextEditingController content_controller = TextEditingController();
    bool isCheck;
    DateTime date;
    TimeOfDay time;

    isCheck = todo.isAlarm;
    date = todo.checkDate;
    time = TimeOfDay.fromDateTime(date);
    content_controller.text = todo.content;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("할 일 수정"),
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
    int? currnet_year = null;
    var todoService = context.watch<TodoService>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("나의 할일 목록"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: todoService.list.length > 0
          ? Padding(
              padding: const EdgeInsets.all(15),
              child: ListView.builder(
                itemCount: todoService.list.length,
                itemBuilder: (context, index) {
                  var todo = todoService.list[index];
                  var checkDate = todo.checkDate;

                  bool current_year_visible = false;

                  if (currnet_year == null) {
                    currnet_year = checkDate.year;
                    current_year_visible = true;
                  }

                  if (currnet_year != checkDate.year) {
                    currnet_year = checkDate.year;
                    current_year_visible = true;
                  }

                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (current_year_visible)
                          Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 20,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "$currnet_year년",
                                  style: TextStyle(
                                      fontSize: 18, color: primaryColor),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat("MM월 dd일").format(checkDate),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 250,
                                    child: Text(
                                      todo.content,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  if (todo.isAlarm)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time_filled,
                                            size: 13,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            DateFormat("a hh:mm")
                                                .format(todo.checkDate),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                ],
                              ),
                              const Spacer(),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                            onPressed: () => update(todo),
                                            child: const Text("수정"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              todoService.delete(todo.id!);
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "삭제",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.more_vert_sharp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          : const Center(
              child: Text("데이터가 존재 하지 않습니다"),
            ),
    );
  }
}
