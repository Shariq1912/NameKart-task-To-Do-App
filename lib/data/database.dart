import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase{
  List toDoList = [];
  
  // Reference our Box
  final _myBox = Hive.box('myBox');

  // Run this method if this is the 1st Time ever opening this app
  void createInitialData(){
    toDoList = [
      ["Make Tutorial", false],
      ["Do Excercise", false],
  ];
  }

  // Load the data from Database
  void loadData(){
    toDoList = _myBox.get("TODOLIST");
  }

  // Update the Database
  void updateDataBase(){
    _myBox.put("TODOLIST", toDoList);
  } 
}