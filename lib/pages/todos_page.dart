import 'dart:html';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:todo2/fbApi.dart';
import 'package:todo2/providers/providers.dart';
import 'package:todo2/utils/debounce.dart';
import '../models/todos_model.dart';
import '../providers/active_todo_count.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({Key? key}) : super(key: key);

  @override
  _TodosPageState createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 40.0,
            ),
            child: Column(
              children: [
                TodoHeader(),
                CreateTodo(),
                SizedBox(height: 20.0,),
                SearchAndFilterTodo(),
                ShowTodos(),
                StreamBuilder<List<Todo>>(
                  stream: fbApi.readTodos(),
                  builder: (context, snapshot){
                    switch (snapshot.connectionState){
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        if(snapshot.hasError){
                          return Text('error');
                        } else{
                          final todos = snapshot.data;
                          final provider = Provider.of<TodoList>(context);
                          provider.setTodos(todos!);
                          return Text("", style: TextStyle(fontSize: 12),);
                        }
                    }

                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class TodoHeader extends StatelessWidget {

  const TodoHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.now();
    /*return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Daily Survey',
          style: TextStyle(fontSize: 30.0),
        ),
        Text(
          'Today is ${date.month}/${date.day}/${date.year}',
          style: TextStyle(fontSize: 15.0),
        ),
        Text(
          '${context.watch<ActiveTodoCount>().state.activeTodoCount} things todo',
          style: TextStyle(fontSize: 15.0, color: Colors.redAccent),
        ),
      ],
    );*/
    return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text(
    'Today is ${date.month}/${date.day}/${date.year}',
    style: TextStyle(fontSize: 30.0, color: Colors.green),
    ),
    Text(
    'ToDo List\n',
    style: TextStyle(fontSize: 28.0),
    ),
    Text(
    '${context.watch<ActiveTodoCount>().state.activeTodoCount} ToDo left',
    style: TextStyle(fontSize: 20.0, color: Colors.orange),
    ),
    ],
    );
  }
}


class CreateTodo extends StatefulWidget {
  const CreateTodo({Key? key}) : super(key: key);

  @override
  _CreateTodoState createState() => _CreateTodoState();
  }

  class _CreateTodoState extends State<CreateTodo> {

  final symptomItems = [
    'Fever or chills',
    'Cough',
    'Shortness of breath',
    'Fatigue',
    'Muscle aches',
    'Headache',
    'Loss of taste or smell',
    'Sore throat',
    'Runny nose',
    'None above',
  ];
  int index = 4;
  @override
  void initState(){
    super.initState();
    scrollController = FixedExtentScrollController(initialItem: index);
  }

  @override
  Widget buildPicker(BuildContext context) => SizedBox(
    width: 100,
    height: 300,
    child : CupertinoPicker(
      scrollController: scrollController,
      itemExtent: 64,
      selectionOverlay: Container(),
      children: symptomItems
          .map((symptomItems) => Center(
        child: Text(
          symptomItems,
          style: TextStyle(fontSize: 20),
        ),
      ))
          .toList(),
      onSelectedItemChanged: (index){
        setState(()=> this.index = index);
        final symptomItem = symptomItems[index];
        sympController.text = symptomItem;
        //print('Selected Item: $symptomItem');
      },
    ),
  );

  String? pmamValue = 'AM';
  String? hourValue = '01:00';
  final pmamList = ['AM','PM'];
  final hourList = [
    '01:00','02:00','03:00','04:00',
    '05:00','06:00','07:00','08:00',
    '09:00','10:00','11:00','12:00'
  ];
  @override
  DropdownMenuItem<String>buildPmamMenuItem(pmamValue) => DropdownMenuItem(
      value: pmamValue,
      child: Text(
        pmamValue,
      ),
  );

  late String thingsTodo;
  late String temperature;
  late String symptom;
  late String date;
  late String covidTest;
  late String time;
  DateTime currentDate = DateTime.now();

  TextEditingController dateController = TextEditingController();
  final thingsTodoController = TextEditingController();
  final tempController = TextEditingController();
  final covidTestController = TextEditingController();
  late TextEditingController sympController = TextEditingController();
  late FixedExtentScrollController scrollController;
  final timeController = TextEditingController();

  @override
  void dispose() {
    dateController.dispose();
    thingsTodoController.dispose();
    tempController.dispose();
    sympController.dispose();
    scrollController.dispose();
    covidTestController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(hintText: 'add your todo'),
      onTap: (){
        showDialog(
          context: context,
          builder: (context){
            bool _error = false;
            bool _intError = false;
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState){
                  return AlertDialog(
                    scrollable: true,
                    title: Text("Adds on list"),
                    content: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              autofocus: true,
                              onTap: () async {
                                DateTime? newDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000,1), lastDate: DateTime(2100,12));
                                if (newDate == null) return;
                                setState(()=>date="${newDate.toLocal().year}.${newDate.toLocal().month}.${newDate.toLocal().day}");
                                dateController.text = date;
                              },
                              controller: dateController,
                              readOnly: true,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(
                                labelText: 'Date',
                                errorText: _error ? 'Need to be chosen' : null,
                              ),
                            ),
                            TextFormField(
                              onTap: () async {
                                return showDialog(
                                    context: context,
                                    builder: (context){
                                    return StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                        return AlertDialog(
                                          title: Text('Set start time'),
                                          content: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Container(
                                                    width: 300,
                                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12), border: Border.all(
                                                          color: Colors.blue,
                                                          width: 1),
                                                    ),
                                                    child: DropdownButton<String>(
                                                      //hint: Text('AM'),
                                                      icon: Icon(
                                                          Icons.arrow_drop_down,
                                                          color: Colors.blue),
                                                      isExpanded: true,
                                                      value: pmamValue,
                                                      items: pmamList.map(
                                                          buildPmamMenuItem).toList(),
                                                      onChanged: (pmamValue) => setState(() => this.pmamValue = pmamValue),
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                  Container(
                                                    width: 300,
                                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: Colors.blue, width: 1),
                                                    ),
                                                    child: DropdownButton<String>(
                                                      icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                                                      isExpanded: true,
                                                      value: hourValue,
                                                      items: hourList.map((hourValue) => DropdownMenuItem<String>(
                                                            value: hourValue,
                                                            child: Text(hourValue),
                                                          )).toList(),
                                                      onChanged: (hourValue) {
                                                        setState(() {this.hourValue = hourValue;
                                                        }
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              )
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text('Cancel')
                                            ),
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context,
                                                        timeController.text = pmamValue.toString() + " " + hourValue.toString()),
                                                child: Text('Add')),
                                          ],
                                        );
                                      }
                                      );
                                    },
                                );
                              },
                              controller: timeController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Start time',
                                errorText: _error ? 'Need to be chosen' : null,
                              ),
                            ),

                            TextFormField(
                              controller: thingsTodoController,
                              decoration: InputDecoration(
                                labelText: 'Things todo',
                                errorText: _error ? 'Need to be filled' : null,
                              ),
                            ),
                            TextFormField(
                              controller: tempController,
                              decoration: InputDecoration(
                                labelText: 'Temperature(number)',
                                errorText: _error ? 'Need to be filled or integer value' : null,
                              ),
                            ),
                            TextFormField(
                              readOnly: true,
                              onTap: () async {
                                return showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Covid test Today?'),
                                        actions: [
                                          TextButton(onPressed: () =>
                                              Navigator.pop(context,
                                                  covidTestController.text =
                                                  'Yes'), child: Text('Yes'),),
                                          TextButton(onPressed: () =>
                                              Navigator.pop(context,
                                                  covidTestController.text =
                                                  'No'), child: Text('No'),),
                                        ],
                                      );
                                    },
                                );
                              },
                              controller: covidTestController,
                              decoration: InputDecoration(
                                labelText: 'Covid test today?',
                                errorText: _error? 'Need to be chosen' : null,
                              ),
                            ),
                            TextFormField(
                              controller: sympController,
                              onTap: (){
                                scrollController.dispose();
                                scrollController = FixedExtentScrollController(initialItem: index);

                                showCupertinoModalPopup(
                                    context: context,
                                    builder: (context)=> CupertinoActionSheet(
                                      actions: [buildPicker(context)],
                                      cancelButton: CupertinoActionSheetAction(
                                        child: Text('Cancel'),
                                        onPressed: (){Navigator.pop(context); sympController.text = "";} //=> Navigator.pop(context),
                                      ),
                                    ),
                                );
                              },
                              decoration: InputDecoration(
                                labelText: 'Symptoms',
                                errorText: _error ? 'Need to be chosen' : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(onPressed: (){
                        dateController.clear();
                        thingsTodoController.clear();
                        covidTestController.clear();
                        tempController.clear();
                        sympController.clear();
                        timeController.clear();
                        Navigator.pop(context);
                      },
                        child: Text('Cancel'),
                      ),



                      TextButton(
                        onPressed: () {
                          setState(() {
                            _error = dateController.text.isEmpty? true : false;
                            _error = thingsTodoController.text.isEmpty? true : false;
                            _error = covidTestController.text.isNotEmpty ? true : false;
                            _error = tempController.text.isEmpty? true : false;
                            _error = sympController.text.isEmpty? true : false;
                            _error = timeController.text.isEmpty? true : false;

                            if (!_error) {
                              date = dateController.text;
                              thingsTodo = thingsTodoController.text;
                              covidTest = covidTestController.text;
                              temperature = tempController.text;
                              symptom = sympController.text;
                              time = timeController.text;

                              if(date.trim().isNotEmpty==true&&covidTest.trim().isNotEmpty==true&&thingsTodo.trim().isNotEmpty==true
                                  &&temperature.trim().isNotEmpty==true&&symptom.trim().isNotEmpty==true&&time.trim().isNotEmpty){
                                if(double.parse(temperature).isNaN==false){
                                  final todo = Todo(
                                    id: DateTime.now().toString(),
                                    createdTime: DateTime.now(),
                                    date: date,
                                    time: time,
                                    whatTodo: thingsTodo,
                                    temp: temperature,
                                    covidCheck: covidTest,
                                    symptom: symptom,
                                  );
                                  //context.read<TodoList>().addTodo(todo);
                                  final provider = Provider.of<TodoList>(context, listen: false);
                                  provider.addTodo(todo);

                                  dateController.clear();
                                  thingsTodoController.clear();
                                  covidTestController.clear();
                                  tempController.clear();
                                  sympController.clear();
                                  timeController.clear();

                                  Navigator.pop(context);
                                }
                              }
                            }
                          });
                        },
                        child: Text('add'),
                      ),
                    ],
                  );
                });
          }
        );
      },
    );
  }
}


class SearchAndFilterTodo extends StatelessWidget {
  final debounce = Debounce(milliseconds: 1000);

  SearchAndFilterTodo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
              labelText: 'Search your Todos (Keyword: What To do)',
              border: InputBorder.none,
              filled: true,
              prefixIcon: Icon(Icons.search),
        ),
          onChanged: (String? newSearchTerm) {
            if (newSearchTerm != null) {
              debounce.run(() {
                context.read<TodoSearch>().setSearchTerm(newSearchTerm);
              });
            }
          },
        ),
        SizedBox(height: 10.0,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            filterButton(context, Filter.all),
            filterButton(context, Filter.active),
            filterButton(context, Filter.completed ),
          ],
        ),
      ],
    );
  }

  Widget filterButton(BuildContext context, Filter filter) {
    return TextButton(
        onPressed: () {
          context.read<TodoFilter>().changeFilter(filter);
        },
        child: Text(
          filter == Filter.all
              ? 'All'
              : filter == Filter.active
                    ? 'Active'
                    : 'Completed',
          style: TextStyle(
            fontSize: 18.0,
            color: textColor(context, filter),
          ),
      ),
    );
  }

  Color textColor(BuildContext context, Filter filter) {
    final currentFilter = context.watch<TodoFilter>().state.filter;
    return currentFilter == filter ? Colors.orange : Colors.orange;
  }
}

class ShowTodos extends StatelessWidget {
  const ShowTodos({Key? key}) : super(key: key);

  Widget showBackground(int direction) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      color: Colors.red,
      alignment: direction == 0? Alignment.centerLeft : Alignment.centerRight,
      child: Icon(
        Icons.delete,
        size: 30.0,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todos = context.watch<FilteredTodos>().state.filteredTodos;
    return ListView.separated(

        primary: false,
        shrinkWrap: true,
        itemCount: todos.length,
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey,
          );
        },
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey(todos[index].createdTime),
            background: showBackground(0),
            secondaryBackground: showBackground(1),
            onDismissed: (_) {
              context.read<TodoList>().removeTodo(todos[index]);
            },
            confirmDismiss: (_) {
              return showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Delete'),
                      content: Text('Sure you want to DELETE?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false),
                          child: Text('No'),
                        ),
                        TextButton(onPressed: () => Navigator.pop(context, true),
                          child: Text('Yes'),
                        ),
                    ],
                    );
                  },
              );
            },
            child: TodoItem(
              todo: todos[index],
            ),
          );
        },
    );
  }
}

class TodoItem extends StatefulWidget {
  final Todo todo;

  const TodoItem({
    Key? key,
    required this.todo,
}) : super(key: key);

  @override
  _TodoItemState createState() => _TodoItemState();

}

class _TodoItemState extends State<TodoItem> {

  final editSymptomItems = [
    'Fever or chills',
    'Cough',
    'Shortness of breath',
    'Fatigue',
    'Muscle aches',
    'Headache',
    'Loss of taste or smell',
    'Sore throat',
    'Runny nose',
    'None above',
  ];
  int editIndex = 4;
  @override
  void initState(){
    super.initState();
    editScrollController = FixedExtentScrollController(initialItem: editIndex);
  }

  @override
  Widget editBuildPicker(BuildContext context) => SizedBox(
    height: 300,
    child : CupertinoPicker(
      scrollController: editScrollController,
      itemExtent: 64,
      selectionOverlay: Container(),
      children: editSymptomItems
          .map((symptomItems) => Center(
        child: Text(
          symptomItems,
          style: TextStyle(fontSize: 20),
        ),
      ))
          .toList(),
      onSelectedItemChanged: (index){
        setState(()=> this.editIndex = index);
        final symptomItem = editSymptomItems[index];
        sympEditingController.text = symptomItem;
        print('Selected Item: $symptomItem');
      },
    ),
  );

  String? editPmamValue='AM';
  String? editHourValue='01:00';
  final editPmamList = ['AM','PM'];
  final editHourList = [
    '01:00','02:00','03:00','04:00',
    '05:00','06:00','07:00','08:00',
    '09:00','10:00','11:00','12:00'
  ];
  @override
  DropdownMenuItem<String>buildPmamMenuItem(pmamValue) => DropdownMenuItem(
    value: pmamValue,
    child: Text(
      pmamValue,
    ),
  );
  DropdownMenuItem<String>buildHourMenuItem(hourValue)=>DropdownMenuItem(
    value: hourValue,
    child: Text(
      hourValue,
    ),
  );

  late TextEditingController dateEditingController = TextEditingController();
  late final thingsTodoEditingController=TextEditingController();
  late final tempEdtingController=TextEditingController();
  late final covidTestController=TextEditingController();
  late TextEditingController sympEditingController=TextEditingController();
  late FixedExtentScrollController editScrollController;
  final timeEditingController = TextEditingController();


  @override
  void dispose() {
    dateEditingController.dispose();
    thingsTodoEditingController.dispose();
    tempEdtingController.dispose();
    covidTestController.dispose();
    sympEditingController.dispose();
    editScrollController.dispose();
    timeEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showDialog(context: context,
            builder: (context) {
              bool _error = false;
              dateEditingController.text = widget.todo.date;
              timeEditingController.text = widget.todo.time;
              thingsTodoEditingController.text = widget.todo.whatTodo;
              tempEdtingController.text = widget.todo.temp;
              covidTestController.text = widget.todo.covidCheck;
              sympEditingController.text = widget.todo.symptom;
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return AlertDialog(
                      title: Text('Edit Todo'),
                      content: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Form(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextFormField(
                                autofocus: true,
                                onTap: () async{
                                  DateTime? editDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000,1),
                                      lastDate: DateTime(2100,12),
                                  );
                                  if(editDate==null) return;
                                  setState(()=>dateEditingController.text="${editDate.toLocal().year}.${editDate.toLocal().month}.${editDate.toLocal().day}");
                                },
                                controller: dateEditingController,
                                readOnly: true,
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                  labelText: 'Edit date',
                                  errorText: _error ? 'Need to be filled' : null,
                                ),
                              ),

                              TextFormField(
                                onTap: () async {
                                  return showDialog(
                                    context: context,
                                    builder: (context){
                                      return StatefulBuilder(
                                          builder: (BuildContext context, StateSetter setState) {
                                            return AlertDialog(
                                              title: Text('Edit your time'),
                                              content: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      Container(
                                                        width: 300,
                                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(12), border: Border.all(
                                                            color: Colors.blue,
                                                            width: 1),
                                                        ),
                                                        child: DropdownButton<String>(
                                                          //hint: Text('AM'),
                                                          icon: Icon(
                                                              Icons.arrow_drop_down,
                                                              color: Colors.blue),
                                                          isExpanded: true,
                                                          value: editPmamValue,
                                                          items: editPmamList.map(
                                                              buildPmamMenuItem).toList(),
                                                          onChanged: (editPmamValue) => setState(() => this.editPmamValue = editPmamValue),
                                                        ),
                                                      ),
                                                      SizedBox(height: 20),
                                                      Container(
                                                        width: 300,
                                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                                                          border: Border.all(color: Colors.blue, width: 1),
                                                        ),
                                                        child: DropdownButton<String>(
                                                          icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                                                          isExpanded: true,
                                                          value: editHourValue,
                                                          items: editHourList.map((editHourValue) => DropdownMenuItem<String>(
                                                            value: editHourValue,
                                                            child: Text(editHourValue),
                                                          )).toList(),
                                                          onChanged: (hourValue) {
                                                            setState(() {this.editHourValue = hourValue;
                                                            }
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                              ),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text('Cancel')
                                                ),
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context,
                                                            timeEditingController.text =
                                                                editPmamValue.toString() + " " + editHourValue.toString()),
                                                    child: Text('Edit')),
                                              ],
                                            );
                                          }
                                      );
                                    },
                                  );
                                },
                                controller: timeEditingController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Edit start time',
                                  errorText: _error ? 'Need to be chosen' : null,
                                ),
                              ),
                              TextFormField(
                                controller: thingsTodoEditingController,
                                decoration: InputDecoration(
                                  labelText: 'Edit things todo',
                                  errorText: _error ? 'Need to be filled or integer value' : null,
                                ),
                              ),
                              TextFormField(
                                controller: tempEdtingController,
                                decoration: InputDecoration(
                                  labelText: 'Edit temperature(number)',
                                  errorText: _error ? 'Need to be filled or integer value' : null,
                                ),
                              ),
                              TextFormField(
                                onTap: () async {
                                  return showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Covid test Today?'),
                                        actions: [
                                          TextButton(onPressed: () =>
                                              Navigator.pop(context,
                                                  covidTestController.text =
                                                  'Yes'), child: Text('Yes'),),
                                          TextButton(onPressed: () =>
                                              Navigator.pop(context,
                                                  covidTestController.text =
                                                  'No'), child: Text('No'),),
                                        ],
                                      );
                                    },
                                  );
                                },
                                readOnly: true,
                                controller: covidTestController,
                                decoration: InputDecoration(
                                  labelText: 'Covid test today?',
                                  errorText: _error? 'Need to be filled' : null,
                                ),
                              ),
                              TextFormField(
                                controller: sympEditingController,
                                onTap: (){
                                  editScrollController.dispose();
                                  editScrollController = FixedExtentScrollController(initialItem: editIndex);
                                  showCupertinoModalPopup(
                                    context: context,
                                    builder: (context)=> CupertinoActionSheet(
                                      actions: [editBuildPicker(context)],
                                      cancelButton: CupertinoActionSheetAction(
                                        child: Text('Cancel'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                  );
                                },
                                decoration: InputDecoration(
                                  labelText: 'Edit Symptoms',
                                  errorText: _error ? 'Need to be filled' : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _error = dateEditingController.text.isEmpty? true : false;
                              _error = timeEditingController.text.isEmpty? true : false;
                              _error = thingsTodoEditingController.text.isEmpty? true : false;
                              _error = tempEdtingController.text.isEmpty? true : false;
                              _error = covidTestController.text.isEmpty? true : false;
                              _error = sympEditingController.text.isEmpty? true : false;

                              if (!_error) {
                                if(dateEditingController.text.trim().isNotEmpty==true&&
                                    timeEditingController.text.trim().isNotEmpty==true&&
                                    thingsTodoEditingController.text.trim().isNotEmpty==true&&
                                    tempEdtingController.text.trim().isNotEmpty==true&&
                                    covidTestController.text.trim().isNotEmpty==true&&
                                    sympEditingController.text.trim().isNotEmpty==true){
                                  if(double.parse(tempEdtingController.text).isNaN==false){
                                    context.read<TodoList>().editTodo(widget.todo, widget.todo.id,widget.todo.createdTime,dateEditingController.text,timeEditingController.text,
                                        thingsTodoEditingController.text,tempEdtingController.text,
                                        covidTestController.text,sympEditingController.text);
                                    Navigator.pop(context);
                                  }
                                }
                              }
                            });
                          },
                          child: Text('Edit'),
                        ),
                      ],
                    );
                  },
              );
              },
        );
      },

      leading: Checkbox(
        value: widget.todo.completed,
        onChanged: (bool? checked) {
          context.read<TodoList>().toggleTodo(widget.todo,widget.todo.id);
        },
      ),

      title: Text("Date : ${widget.todo.date} \nStart : ${widget.todo.time} \nWhat To Do : ${widget.todo.whatTodo} \nTemperature : ${widget.todo.temp} \nCovid Test : ${widget.todo.covidCheck} \nSyomtom : ${widget.todo.symptom}"),

    );
  }
}