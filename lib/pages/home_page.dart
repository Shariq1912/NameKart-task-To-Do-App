import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do/data/database.dart';
import '../util/dialog_box.dart';
import '../util/todo_tile.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box('myBox');
  ToDoDataBase db = ToDoDataBase();
  final _controller = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
    super.initState();
  }

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDataBase();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          db.toDoList[index][1]
              ? '${db.toDoList[index][0]} marked as complete'
              : '${db.toDoList[index][0]} marked as incomplete',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void saveNewTask() {
    setState(() {
      _listKey.currentState?.insertItem(db.toDoList.length);
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void deleteTask(int index) {
    var removedItem = db.toDoList[index];
    setState(() {
      db.toDoList.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
            (context, animation) {
          return SizeTransition(
            sizeFactor: animation,
            child: ToDoTile(
              taskName: removedItem[0],
              taskCompleted: removedItem[1],
              onChanged: null,
              deleteFunction: null,
              editFunction: null,
            ),
          );
        },
        duration: const Duration(milliseconds: 300),
      );
    });
    db.updateDataBase();
  }

  void editTask(int index) {
    _controller.text = db.toDoList[index][0];

    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: () {
            setState(() {
              db.toDoList[index][0] = _controller.text;
            });
            _controller.clear();
            Navigator.of(context).pop();
            db.updateDataBase();
          },
          onCancel: () {
            _controller.clear();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TO DO'),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      body: AnimatedList(
        key: _listKey,
        initialItemCount: db.toDoList.length,
        itemBuilder: (context, index, animation) {
          return SizeTransition(
            sizeFactor: animation,
            child: ToDoTile(
              taskName: db.toDoList[index][0],
              taskCompleted: db.toDoList[index][1],
              onChanged: (value) => checkBoxChanged(value, index),
              deleteFunction: (context) => deleteTask(index),
              editFunction: (context) => editTask(index),
            ),
          );
        },
      ),
    );
  }
}
