import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:todo2/models/todos_model.dart';
import 'package:todo2/providers/providers.dart';
import 'package:todo2/providers/todo_filter.dart';
import 'package:todo2/providers/todo_list.dart';
import 'package:todo2/providers/todo_search.dart';

class FilteredTodoState extends Equatable {
  final List<Todo> filteredTodos;

  FilteredTodoState({
    required this.filteredTodos,
  });

  factory FilteredTodoState.initial() {
    return FilteredTodoState(filteredTodos : []);
  }

  @override
  List<Object?> get props => [filteredTodos];

  @override
  bool get stringify => true;

  FilteredTodoState copyWith({
    List<Todo>? filteredTodos,
  }) {
    return FilteredTodoState(
      filteredTodos: filteredTodos ?? this.filteredTodos,
    );
  }
}

class FilteredTodos with ChangeNotifier {
  late FilteredTodoState _state;
  final List<Todo> initialFilteredTodos;

  FilteredTodos({
      required this.initialFilteredTodos,
  }) {
    //print('initialFilteredTodos: $initialFilteredTodos');
    _state = FilteredTodoState(filteredTodos: initialFilteredTodos);
}
    //FilteredTodoState _state = FilteredTodoState.initial();
  FilteredTodoState get state => _state;

  void update(TodoFilter todoFilter, TodoSearch todoSearch, TodoList todoList) {
    List<Todo> _filteredTodos;

    switch (todoFilter.state.filter) {
      case Filter.active:
        _filteredTodos = todoList.state.todos.where((Todo todo) => !todo.completed).toList();
        break;
      case Filter.completed:
        _filteredTodos = todoList.state.todos.where((Todo todo) => todo.completed).toList();
        break;
      case Filter.all:
      default:
        _filteredTodos = todoList.state.todos;
        break;
    }

    /*if (todoSearch.state.searchTerm.isNotEmpty) {
      _filteredTodos = _filteredTodos.where((Todo todo) => todo.whatTodo.toLowerCase().contains(todoSearch.state.searchTerm.toLowerCase())).toList();
    }*/
    if(_filteredTodos.where((Todo todo) => todo.date.toLowerCase().contains(todoSearch.state.searchTerm.toLowerCase())).toList().isNotEmpty){
      _filteredTodos = _filteredTodos.where((Todo todo) => todo.date.toLowerCase().contains(todoSearch.state.searchTerm.toLowerCase())).toList();
    }
    else if(_filteredTodos.where((Todo todo) => todo.time.toLowerCase().contains(todoSearch.state.searchTerm.toLowerCase())).toList().isNotEmpty){
      _filteredTodos = _filteredTodos.where((Todo todo) => todo.time.toLowerCase().contains(todoSearch.state.searchTerm.toLowerCase())).toList();
    }
    else if(_filteredTodos.where((Todo todo) => todo.whatTodo.toLowerCase().contains(todoSearch.state.searchTerm.toLowerCase())).toList().isNotEmpty){
      _filteredTodos = _filteredTodos.where((Todo todo) => todo.whatTodo.toLowerCase().contains(todoSearch.state.searchTerm.toLowerCase())).toList();
    }
    else if(_filteredTodos.where((Todo todo) => todo.temp.toLowerCase().contains(todoSearch.state.searchTerm.toLowerCase())).toList().isNotEmpty){
      _filteredTodos = _filteredTodos.where((Todo todo) => todo.temp.toLowerCase().contains(todoSearch.state.searchTerm.toLowerCase())).toList();
    }
    else if(_filteredTodos.where((Todo todo) => todo.covidCheck.toLowerCase().contains(todoSearch.state.searchTerm.toLowerCase())).toList().isNotEmpty){
      _filteredTodos = _filteredTodos.where((Todo todo) => todo.covidCheck.toLowerCase().contains(todoSearch.state.searchTerm.toLowerCase())).toList();
    }
    else if(_filteredTodos.where((Todo todo) => todo.symptom.toLowerCase().contains(todoSearch.state.searchTerm.toLowerCase())).toList().isNotEmpty){
      _filteredTodos = _filteredTodos.where((Todo todo) => todo.symptom.toLowerCase().contains(todoSearch.state.searchTerm.toLowerCase())).toList();
    }

    _state = _state.copyWith(filteredTodos: _filteredTodos);
    notifyListeners();

  }
}