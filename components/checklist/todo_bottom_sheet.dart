import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:univent/components/buttons/rounded_button.dart';
import 'package:univent/components/rounded_text_field.dart';
import 'package:univent/constants.dart';
import 'package:univent/models/todo_data.dart';
import 'package:univent/models/todo_model.dart';
import 'package:uuid/uuid.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

Future<void> showTodoBottomSheet(BuildContext parentContext,
    [TodoModel? todoModel]) async {
  String tempTaskName = todoModel == null ? '' : todoModel.taskTitle;
  String? tempClassId = todoModel?.courseCode;
  String? tempCustomClassId = '';
  String tempTaskDetails = todoModel == null ? '' : todoModel.taskDescription;

  DateTime tempDueDateTime = todoModel == null
      ? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
      : todoModel.dueDateTime.subtract(Duration(
          hours: todoModel.dueDateTime.hour,
          minutes: todoModel.dueDateTime.minute));
  TimeOfDay tempDueTimeOfDay = todoModel == null
      ? const TimeOfDay(hour: 23, minute: 59)
      : TimeOfDay(
          hour: todoModel.dueDateTime.hour,
          minute: todoModel.dueDateTime.minute);

  String timeButtonText = tempDueTimeOfDay.format(parentContext);
  String dateButtonText =
      '${tempDueDateTime.month}/${tempDueDateTime.day}/${tempDueDateTime.year}';

  bool allowCustomClass = false;
  bool allowCustomRepeat = false;
  bool allowRepeat = false;
  String? repeatOption;
  String endRepeatButtonText = "End Repeat on...";
  DateTime endRepeat = DateTime.now();

  final List<bool> selectedDayOptions = <bool>[
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  const List<Widget> dayOptions = <Widget>[
    Text('S'),
    Text('M'),
    Text('T'),
    Text('W'),
    Text('T'),
    Text('F'),
    Text('S')
  ];

  List<DropdownMenuItem<String>> courseOptions = [];
  for (var course
      in Provider.of<TodoData>(parentContext, listen: false).courses) {
    courseOptions.add(
      DropdownMenuItem<String>(
          value: course.name,
          child: Text(
            course.name,
            style:
                TextStyle(color: Theme.of(parentContext).colorScheme.secondary),
          )),
    );
  }
  if (courseOptions.where((element) => element.value == 'Other').isNotEmpty) {
    courseOptions.removeWhere((element) => element.value == 'Other');
  }
  courseOptions.add(
    DropdownMenuItem<String>(
        value: 'Other',
        child: Text(
          'Other',
          style:
              TextStyle(color: Theme.of(parentContext).colorScheme.secondary),
        )),
  );

  List<DropdownMenuItem<String>> repeatOptions = [
    DropdownMenuItem<String>(
        value: 'None',
        child: Text(
          'None',
          style:
              TextStyle(color: Theme.of(parentContext).colorScheme.secondary),
        )),
    DropdownMenuItem<String>(
        value: 'Every Day',
        child: Text(
          'Every Day',
          style:
              TextStyle(color: Theme.of(parentContext).colorScheme.secondary),
        )),
    DropdownMenuItem<String>(
        value: 'Every Week',
        child: Text('Every Week',
            style: TextStyle(
                color: Theme.of(parentContext).colorScheme.secondary))),
    DropdownMenuItem<String>(
        value: 'Every Month',
        child: Text('Every Month',
            style: TextStyle(
                color: Theme.of(parentContext).colorScheme.secondary))),
    DropdownMenuItem<String>(
        value: 'Every Year',
        child: Text('Every Year',
            style: TextStyle(
                color: Theme.of(parentContext).colorScheme.secondary))),
    DropdownMenuItem<String>(
        value: 'Custom...',
        child: Text('Custom...',
            style: TextStyle(
                color: Theme.of(parentContext).colorScheme.secondary)))
  ];

  void addTodo(
      BuildContext context, TodoModel newTodoModel, Color courseColor) {
    Provider.of<TodoData>(context, listen: false).addTodo(newTodoModel);
    Provider.of<TodoData>(context, listen: false)
        .editCourses(newTodoModel.courseCode, courseColor);
    _firestore
        .collection('todos')
        .doc(_auth.currentUser!.uid)
        .collection('items')
        .doc(newTodoModel.uid)
        .set({
      'task_title': newTodoModel.taskTitle,
      'task_description': newTodoModel.taskDescription,
      'course_code': newTodoModel.courseCode,
      'is_notification': newTodoModel.isNotification,
      'is_completed': newTodoModel.isCompleted,
      'is_custom': newTodoModel.isCustom,
      'is_canvas': newTodoModel.isCanvas,
      'is_ls': newTodoModel.isLS,
      'is_max': newTodoModel.isMax,
      'due_date': newTodoModel.dueDateTime.toUtc(),
      'url': newTodoModel.url
    });
  }

  bool isLeapYear(int year) =>
      ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0);

  int daysInMonth(int month, int year) {
    int days = 28 +
        (month + (month / 8).floor()) % 2 +
        2 % month +
        2 * (1 / month).floor();
    return (isLeapYear(year) && month == 2) ? 29 : days;
  }

  void addRepeatingTodos(
      BuildContext context, TodoModel newTodoModel, Color courseColor) {
    if (repeatOption == 'Every Day') {
      for (var i = 0; i <= endRepeat.difference(tempDueDateTime).inDays; i++) {
        TodoModel newTodo = TodoModel(
          // UniqueKey().toString(),
          const Uuid().v4(),
          newTodoModel.taskTitle,
          newTodoModel.taskDescription,
          newTodoModel.dueDateTime.add(Duration(days: i)),
          newTodoModel.courseCode,
          newTodoModel.url,
          newTodoModel.color,
          newTodoModel.isCompleted,
          newTodoModel.isNotification,
          newTodoModel.isCanvas,
          newTodoModel.isLS,
          newTodoModel.isMax,
          newTodoModel.isCustom,
        );
        addTodo(context, newTodo, courseColor);
      }
    }
    if (repeatOption == 'Every Week') {
      for (var i = 0;
          i <= endRepeat.difference(tempDueDateTime).inDays / 7;
          i++) {
        TodoModel newTodo = TodoModel(
          // UniqueKey().toString(),
          const Uuid().v4(),
          newTodoModel.taskTitle,
          newTodoModel.taskDescription,
          newTodoModel.dueDateTime.add(Duration(days: i * 7)),
          newTodoModel.courseCode,
          newTodoModel.url,
          newTodoModel.color,
          newTodoModel.isCompleted,
          newTodoModel.isNotification,
          newTodoModel.isCanvas,
          newTodoModel.isLS,
          newTodoModel.isMax,
          newTodoModel.isCustom,
        );
        addTodo(context, newTodo, courseColor);
      }
    }
    if (repeatOption == 'Every Month') {
      DateTime i = tempDueDateTime;
      while (endRepeat.difference(i).inDays > 0) {
        TodoModel newTodo = TodoModel(
          // UniqueKey().toString(),
          const Uuid().v4(),
          newTodoModel.taskTitle,
          newTodoModel.taskDescription,
          i,
          newTodoModel.courseCode,
          newTodoModel.url,
          newTodoModel.color,
          newTodoModel.isCompleted,
          newTodoModel.isNotification,
          newTodoModel.isCanvas,
          newTodoModel.isLS,
          newTodoModel.isMax,
          newTodoModel.isCustom,
        );
        addTodo(context, newTodo, courseColor);
        if (daysInMonth(i.month + 1, i.year) >= i.day) {
          i = DateTime(i.year, i.month + 1, i.day);
        } else if (daysInMonth(i.month + 2, i.year) >= i.day) {
          i = DateTime(i.year, i.month + 2, i.day);
        } else {
          i = DateTime(i.year, i.month + 3, i.day);
        }
      }
    }
    if (repeatOption == 'Every Year') {
      DateTime i = tempDueDateTime;
      while (endRepeat.difference(i).inDays > 0) {
        TodoModel newTodo = TodoModel(
          // UniqueKey().toString(),
          const Uuid().v4(),
          newTodoModel.taskTitle,
          newTodoModel.taskDescription,
          i,
          newTodoModel.courseCode,
          newTodoModel.url,
          newTodoModel.color,
          newTodoModel.isCompleted,
          newTodoModel.isNotification,
          newTodoModel.isCanvas,
          newTodoModel.isLS,
          newTodoModel.isMax,
          newTodoModel.isCustom,
        );
        addTodo(context, newTodo, courseColor);
        i = DateTime(i.year + 1, i.month, i.day);
      }
    }
    if (repeatOption == 'Custom...') {
      for (var i = 0; i <= endRepeat.difference(tempDueDateTime).inDays; i++) {
        if (selectedDayOptions[
            newTodoModel.dueDateTime.add(Duration(days: i)).weekday % 7]) {
          TodoModel newTodo = TodoModel(
            // UniqueKey().toString(),
            const Uuid().v4(),
            newTodoModel.taskTitle,
            newTodoModel.taskDescription,
            newTodoModel.dueDateTime.add(Duration(days: i)),
            newTodoModel.courseCode,
            newTodoModel.url,
            newTodoModel.color,
            newTodoModel.isCompleted,
            newTodoModel.isNotification,
            newTodoModel.isCanvas,
            newTodoModel.isLS,
            newTodoModel.isMax,
            newTodoModel.isCustom,
          );
          addTodo(context, newTodo, courseColor);
        }
      }
    }
  }

  showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (context) => StatefulBuilder(
              builder: (BuildContext context, StateSetter setLocalState) {
            return Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: InputDecorator(
                          decoration: kTextFieldDecoration,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor:
                                  Theme.of(context).colorScheme.surface,
                              hint: const Text(
                                'Class ID',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                              items: courseOptions,
                              isExpanded: true,
                              value: tempClassId,
                              onChanged: (String? value) {
                                setLocalState(() {
                                  tempClassId = value!;
                                  allowCustomClass = tempClassId == 'Other';
                                });
                              },
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(32.0)),
                            ),
                          ),
                        ),
                      ),
                      allowCustomClass
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RoundedTextField(
                                hint: 'Class ID',
                                callback: (value) {
                                  setLocalState(() {
                                    tempCustomClassId = value;
                                  });
                                },
                                initVal: tempCustomClassId,
                              ))
                          : const SizedBox(height: 0.0),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RoundedTextField(
                          initVal: tempTaskName,
                          hint: 'Assignment Title',
                          callback: (value) {
                            tempTaskName = value;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RoundedTextField(
                          initVal: tempTaskDetails,
                          hint: 'Assignment Details',
                          callback: (value) {
                            tempTaskDetails = value;
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RoundedButton(
                                color: Theme.of(context).colorScheme.secondary,
                                title: Text(dateButtonText),
                                action: () async {
                                  DateTime? newDate = await showDatePicker(
                                    context: context,
                                    initialDate: tempDueDateTime,
                                    firstDate: DateTime(2022),
                                    lastDate: DateTime(DateTime.now().year + 5),
                                    builder: (context, child) {
                                      return Theme(
                                        data: ThemeData(
                                            colorScheme: Provider.of<TodoData>(
                                                        context,
                                                        listen: false)
                                                    .darkTheme
                                                ? const ColorScheme.dark()
                                                    .copyWith(
                                                        primary: Colors.white)
                                                : const ColorScheme.light()
                                                    .copyWith(
                                                        primary: Colors.black)),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (newDate == null) return;
                                  setLocalState(() {
                                    tempDueDateTime = newDate;
                                    dateButtonText =
                                        '${tempDueDateTime.month}/${tempDueDateTime.day}/${tempDueDateTime.year}';
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RoundedButton(
                                color: Theme.of(context).colorScheme.secondary,
                                action: () async {
                                  TimeOfDay? newTime = await showTimePicker(
                                      builder: (context, child) {
                                        return Theme(
                                          data: ThemeData(
                                              colorScheme: Provider.of<
                                                              TodoData>(context,
                                                          listen: false)
                                                      .darkTheme
                                                  ? const ColorScheme.dark()
                                                      .copyWith(
                                                          primary: Colors.white)
                                                  : const ColorScheme.light()
                                                      .copyWith(
                                                          primary:
                                                              Colors.black)),
                                          child: child!,
                                        );
                                      },
                                      context: context,
                                      initialTime: tempDueTimeOfDay);
                                  if (newTime == null) return;
                                  setLocalState(() {
                                    tempDueTimeOfDay = newTime;
                                    timeButtonText =
                                        tempDueTimeOfDay.format(parentContext);
                                  });
                                },
                                title: Text(timeButtonText),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: InputDecorator(
                          decoration: kTextFieldDecoration,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor:
                                  Theme.of(context).colorScheme.surface,
                              hint: const Text(
                                'Repeat',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                              items: repeatOptions,
                              isExpanded: true,
                              value: repeatOption,
                              onChanged: (String? value) {
                                setLocalState(() {
                                  repeatOption = value!;
                                  allowCustomRepeat =
                                      repeatOption == 'Custom...';
                                  allowRepeat = repeatOption != 'None';
                                });
                              },
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(32.0)),
                            ),
                          ),
                        ),
                      ),
                      allowCustomRepeat
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ToggleButtons(
                                constraints: const BoxConstraints(
                                    minHeight: 45.0, minWidth: 45.0),
                                direction: Axis.horizontal,
                                onPressed: (int index) {
                                  setLocalState(() {
                                    selectedDayOptions[index] =
                                        !selectedDayOptions[index];
                                  });
                                },
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                selectedBorderColor:
                                    Theme.of(context).colorScheme.secondary,
                                selectedColor:
                                    Theme.of(context).colorScheme.secondary,
                                fillColor: Colors.grey,
                                color: Colors.grey,
                                borderColor: Colors.grey,
                                isSelected: selectedDayOptions,
                                children: dayOptions,
                              ),
                            )
                          : const SizedBox(height: 0.0),
                      allowRepeat
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RoundedButton(
                                color: Theme.of(context).colorScheme.secondary,
                                title: Text(endRepeatButtonText),
                                action: () async {
                                  DateTime? newDate = await showDatePicker(
                                    context: context,
                                    initialDate: tempDueDateTime,
                                    firstDate: DateTime(2022),
                                    lastDate: DateTime(DateTime.now().year + 5),
                                    builder: (context, child) {
                                      return Theme(
                                        data: ThemeData(
                                            colorScheme: Provider.of<TodoData>(
                                                        context,
                                                        listen: false)
                                                    .darkTheme
                                                ? const ColorScheme.dark()
                                                    .copyWith(
                                                        primary: Colors.white)
                                                : const ColorScheme.light()
                                                    .copyWith(
                                                        primary: Colors.black)),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (newDate == null) return;
                                  setLocalState(() {
                                    endRepeat = newDate;
                                    endRepeatButtonText =
                                        'End Repeat on ${endRepeat.month}/${endRepeat.day}/${endRepeat.year}';
                                  });
                                },
                              ),
                            )
                          : const SizedBox(height: 0.0),
                      SizedBox(
                        width: double.infinity,
                        child: RoundedButton(
                          color: Theme.of(context).colorScheme.secondary,
                          action: () {
                            String snackBarText = todoModel == null
                                ? 'Task added!'
                                : 'Task edited!';
                            Color snackBarColor = Colors.green;
                            if (tempTaskName.isNotEmpty &&
                                tempClassId != null) {
                              if (tempClassId == 'Other') {
                                courseOptions.add(
                                  DropdownMenuItem<String>(
                                      value: tempCustomClassId,
                                      child: Text(
                                        tempCustomClassId!,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      )),
                                );
                                tempClassId = tempCustomClassId;
                              }
                              if (todoModel != null) {
                                Provider.of<TodoData>(context, listen: false)
                                    .removeTodo(todoModel);
                              }
                              Color color = Colors.grey.shade700;
                              if (Provider.of<TodoData>(context, listen: false)
                                  .courseExists(tempClassId!)) {
                                color = Provider.of<TodoData>(context,
                                        listen: false)
                                    .courses
                                    .where((element) =>
                                        element.name == tempClassId)
                                    .elementAt(0)
                                    .displayColor;
                              } else {
                                color = Provider.of<TodoData>(context,
                                        listen: false)
                                    .colorOptions
                                    .elementAt(Provider.of<TodoData>(context,
                                                listen: false)
                                            .courses
                                            .length %
                                        7);
                              }
                              TodoModel newTodoModel = TodoModel(
                                  todoModel == null
                                      ? const Uuid().v4()
                                      // UniqueKey().toString()
                                      : todoModel.uid,
                                  tempTaskName,
                                  tempTaskDetails,
                                  tempDueDateTime.add(Duration(
                                      hours: tempDueTimeOfDay.hour,
                                      minutes: tempDueTimeOfDay.minute)),
                                  tempClassId!,
                                  todoModel?.url,
                                  color,
                                  todoModel == null
                                      ? false
                                      : todoModel.isCompleted,
                                  todoModel == null
                                      ? true
                                      : todoModel.isNotification,
                                  todoModel == null
                                      ? false
                                      : todoModel.isCanvas,
                                  todoModel == null ? false : todoModel.isLS,
                                  todoModel == null ? false : todoModel.isMax,
                                  todoModel == null
                                      ? true
                                      : todoModel.isCustom);
                              if (allowRepeat &&
                                  endRepeatButtonText != 'End Repeat on...') {
                                addRepeatingTodos(context, newTodoModel, color);
                              } else if (!allowRepeat) {
                                addTodo(context, newTodoModel, color);
                              } else {
                                snackBarText =
                                    'You must select an end repeat date.';
                                snackBarColor = Colors.red;
                              }
                              Navigator.pop(context);
                            } else {
                              snackBarText =
                                  'You must choose a class ID and task name.';
                              snackBarColor = Colors.red;
                              Navigator.pop(context);
                            }
                            SnackBar snackBar = SnackBar(
                              content: Text(snackBarText),
                              backgroundColor: snackBarColor,
                            );
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                          title: todoModel == null
                              ? const Text('Add Task')
                              : const Text('Edit Task'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }));
}
