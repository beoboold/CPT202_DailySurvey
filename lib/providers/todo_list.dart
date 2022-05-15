import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:todo2/fbApi.dart';
import 'package:todo2/models/todos_model.dart';
import '../Utils.dart';
import 'providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class TodoListState extends Equatable with ChangeNotifier {
  late final List<Todo> todos;

  TodoListState({
    required this.todos,
  });

  factory TodoListState.initial(){
    return TodoListState( todos: [

    ]);
  }

  @override
  List<Object?> get props => [todos];

  @override
  bool get stringify => true;

  TodoListState copyWith({
    required List<Todo> todos,
  }) {
    return TodoListState(
      todos: todos,
    );
  }
}


  class TodoList with ChangeNotifier {

    TodoListState _state = TodoListState.initial();
    TodoListState get state => _state;

    void updateState(){
      final loadData = fbApi.readTodos();
      final newTodo = loadData as Todo;
      final newTodos = [..._state.todos, newTodo];

      _state = _state.copyWith(todos: newTodos);
      notifyListeners();
    }

    void addTodo(Todo todo) => fbApi.createTodo(todo);

    void setTodos(List<Todo> Todos)=>
        WidgetsBinding.instance?.addPostFrameCallback((_) {
           final newTodo = Todos;
           _state = _state.copyWith(todos: newTodo);
          notifyListeners();
        });

    void editTodo(Todo todo, String id, DateTime createdTime, String editDate,String editTime, String editWhatTodo, String editTemp,String editCovidTest, String editSymptom) {
      todo.id = id;
      todo.createdTime = createdTime;
      todo.date = editDate;
      todo.time = editTime;
      todo.whatTodo = editWhatTodo;
      todo.temp = editTemp;
      todo.covidCheck = editCovidTest;
      todo.symptom = editSymptom;
      fbApi.updateTodo(todo);
    }


    void toggleTodo(Todo todo, String id) {
      todo.completed = !todo.completed;
      fbApi.updateTodo(todo);
    }

    void removeTodo(Todo todo) => fbApi.deleteTodo(todo);
  }