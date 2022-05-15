import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:todo2/providers/todo_list.dart';
import 'Utils.dart';
import 'models/todos_model.dart';

class fbApi {
  static Future<String> createTodo(Todo todo) async{
    final docTodo = FirebaseFirestore.instance.collection('todo').doc();
    todo.id = docTodo.id;
    await docTodo.set(todo.toJson());

    return docTodo.id;
  }
  static Stream<List<Todo>> readTodos() =>FirebaseFirestore.instance
      .collection('todo')
      .orderBy(todoField.createdTime, descending: false)
      .snapshots()
      .transform(Utils.transformer(Todo.fromJson));

      static Future updateTodo(Todo todo) async {
        final docTodo = FirebaseFirestore.instance.collection('todo').doc(todo.id);

        await docTodo.update(todo.toJson());
      }

      static Future deleteTodo(Todo todo) async{
        final docTodo = FirebaseFirestore.instance.collection('todo').doc(todo.id);
        await docTodo.delete();
      }
}