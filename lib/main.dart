import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo2/pages/todos_page.dart';
import 'package:todo2/providers/providers.dart';
import 'package:todo2/providers/todo_filter.dart';
import 'package:todo2/providers/todo_list.dart';
import 'package:todo2/providers/todo_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDYGtkkafIwgda2gKSMtEGthmST9AnmCuk",
      appId: "1:980483613918:android:76e6d4c554976208298e4f",
      messagingSenderId: "980483613918",
      projectId: "dailysurvey-75441",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TodoFilter>(
          create: (context) => TodoFilter(),
        ),
        ChangeNotifierProvider<TodoSearch>(
          create: (context) => TodoSearch(),
        ),
        ChangeNotifierProvider<TodoList>(
          create: (context) => TodoList(),
        ),
        ChangeNotifierProxyProvider<TodoList, ActiveTodoCount>(
          create: (context) => ActiveTodoCount(initialActiveTodoCount: context.read<TodoList>().state.todos.length),
          update: (BuildContext context, TodoList todoList, ActiveTodoCount? activeTodoCount,) =>
              activeTodoCount!..update(todoList),
        ),
        ChangeNotifierProxyProvider3<TodoFilter,
            TodoSearch,
            TodoList,
            FilteredTodos>(
          create: (context) => FilteredTodos(initialFilteredTodos: context.read<TodoList>().state.todos,),
              update: (BuildContext context,
              TodoFilter todoFilter,
              TodoSearch todoSearch,
              TodoList todoList,
              FilteredTodos? filteredTodos) =>
              filteredTodos!..update(todoFilter, todoSearch, todoList),
        ),
      ],
      child: MaterialApp(
        title: 'Todo Provider',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const TodosPage(),
      ),
    );
  }
}
