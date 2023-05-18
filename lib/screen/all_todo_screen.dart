import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/service/todo_service.dart';

class AllTodoScreen extends StatefulWidget {
  const AllTodoScreen({super.key});

  @override
  State<AllTodoScreen> createState() => _AllTodoScreenState();
}

class _AllTodoScreenState extends State<AllTodoScreen> {
  TodoService todoService = TodoService();
  List<Todo> list = [];

  void refresh() async {
    var tmp = await todoService.read();

    setState(() {
      list = tmp;
    });
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    int? currnet_year = null;

    return Scaffold(
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
      body: list.length > 0
          ? Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  var todo = list[index];
                  var checkDate = todo.checkDate;
                  var content = todo.content;
                  bool current_year_visible = false;
                  if (currnet_year == null) {
                    currnet_year = checkDate.year;
                    current_year_visible = true;
                  }

                  if (currnet_year != checkDate.year) {
                    currnet_year = checkDate.year;
                    current_year_visible = true;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (current_year_visible)
                        Text(
                          "$currnet_year",
                          style: const TextStyle(fontSize: 24),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Text(DateFormat("MM월 dd일").format(checkDate)),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(content),
                            const Spacer(),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                todoService.delete(list[index].id!);
                                refresh();
                              },
                              icon: const Icon(Icons.delete),
                            )
                          ],
                        ),
                      ),
                    ],
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
