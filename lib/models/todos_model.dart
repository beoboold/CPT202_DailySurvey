import 'package:equatable/equatable.dart';
import 'package:todo2/Utils.dart';
import 'package:uuid/uuid.dart';

Uuid uuid = Uuid();

class todoField {
  static const createdTime = 'createdTime';
}

class Todo {
  String id;
  DateTime createdTime;
   String date;
   String time;
   String whatTodo;
   String temp;
   String covidCheck;
   String symptom;
   bool completed;

  Todo({
    required this.id,
    required this.createdTime,
    required this.date,
    required this.time,
    required this.whatTodo,
    required this.temp,
    required this.covidCheck,
    required this.symptom,
    this.completed = false,
  });

  //@override
  //List<Object?> get props => [id,createdTime,date,time,whatTodo,temp,covidCheck,symptom, completed];

  //@override
  //bool get stringify => true;

  //ignore: empty_constructor_bodies
  static Todo fromJson(Map<String, dynamic> json)=>Todo(
    id: json['id'],
    createdTime: Utils.toDateTime(json['createdTime']),
    date: json['date'],
    time: json['time'],
    whatTodo: json['whatTodo'],
    temp: json['temperature'],
    covidCheck: json['covidCheck'],
    symptom: json['symptom'],
    completed: json['completed'],
  );

  Map<String, dynamic> toJson() =>{
    'id':id,
    'createdTime': Utils.fromDateTimeToJson(createdTime),
    'date':date,
    'time':time,
    'whatTodo':whatTodo,
    'temperature':temp,
    'covidCheck':covidCheck,
    'symptom':symptom,
    'completed':completed,
  };
}

  enum Filter {
  all,
    active,
    completed,
  }