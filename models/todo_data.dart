import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:univent/constants.dart';
import 'package:univent/models/parser.dart';
import 'package:univent/components/checklist/todo_item.dart';
import 'package:univent/models/todo_model.dart';
import 'package:univent/models/course_model.dart';
import 'package:intl/intl.dart';
import 'package:univent/themes/theme_pref.dart';

class TodoData extends ChangeNotifier {
  final List<Widget> displayList = [];
  final List<TodoModel> _todos = [];
  final List<TodoModel> _filteredTodos = [];
  final List<Course> courses = [];
  final List<Color> colorOptions = [
    const Color(0xFF8ED2DE),
    const Color(0xFFFE938E),
    const Color(0xFFF5DE78),
    const Color(0xFF9DF598),
    const Color(0xFFFFBA68),
    const Color(0xFFCCBBFA),
    const Color(0xFFF9BEFA)
  ];

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  late bool filterCalendarItems;

  String userName = '';

  DarkThemePreference darkThemePreference = DarkThemePreference();

  late bool darkTheme = true;

  void setDarkTheme(bool value) {
    darkTheme = value;
    darkThemePreference.setDarkTheme(value);
    _updateDisplayList();
    notifyListeners();
  }

  /*
    EDIT TODOS
  */

  bool isCalItem(taskTitle, taskDescription) {
    if (taskTitle == taskDescription) {
      return true;
    } else if (taskTitle.length > 50 && taskDescription.length > 50) {
      if (taskTitle.substring(0, 50) == taskDescription.substring(0, 50)) {
        return true;
      }
    }
    return false;
  }

  void toggleCalendarFilter() async {
    filterCalendarItems = !filterCalendarItems;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('filterCalendarItems', filterCalendarItems);

    // CHECK TO ONLY FILTER IF IT'S A LS TASK!!!
    if (filterCalendarItems) {
      _filteredTodos.addAll(_todos.where(
          (element) => isCalItem(element.taskTitle, element.taskDescription)));
      _todos.removeWhere(
          (element) => isCalItem(element.taskTitle, element.taskDescription));
    } else {
      _todos.addAll(_filteredTodos.where(
          (element) => isCalItem(element.taskTitle, element.taskDescription)));
      _filteredTodos.removeWhere(
          (element) => isCalItem(element.taskTitle, element.taskDescription));
    }
    _updateDisplayList();

    notifyListeners();
  }

  void clearTodos() {
    _todos.clear();
    _filteredTodos.clear();
    notifyListeners();
  }

  void addTodo(TodoModel newTodo) {
    _todos.add(newTodo);
    _updateDisplayList();
    notifyListeners();
  }

  void addTodos(List<TodoModel> newTodos) {
    _todos.addAll(newTodos);
    _updateDisplayList();
    notifyListeners();
  }

  void removeTodo(TodoModel oldTodo) {
    _todos.remove(oldTodo);
    _updateDisplayList();
    notifyListeners();
  }

  List<TodoModel> getTodos() {
    return _todos;
  }

  void toggleFilter(int index) {
    courses[index].isFiltered = !courses[index].isFiltered;
    if (courses[index].isFiltered) {
      _filteredTodos.addAll(
          _todos.where((element) => courses[index].name == element.courseCode));
      _todos
          .removeWhere((element) => courses[index].name == element.courseCode);
    } else {
      _todos.addAll(_filteredTodos
          .where((element) => courses[index].name == element.courseCode));
      _filteredTodos
          .removeWhere((element) => courses[index].name == element.courseCode);
    }
    _updateDisplayList();
    notifyListeners();
  }

  /*
    EDIT COURSES
  */

  void removeCourse(String courseCode) {
    courses.removeWhere((element) => element.name == courseCode);
    notifyListeners();
  }

  void editCourses(String courseCode, Color color) {
    if (!courseExists(courseCode)) {
      courses.add(Course(courseCode, false, color));
    }
    notifyListeners();
  }

  bool courseExists(String courseName) {
    return courses.where((element) => element.name == courseName).isNotEmpty;
  }

  /*
    EDIT DISPLAY WIDGETS
  */

  String getDateString(String date) {
    DateFormat format = DateFormat("yyyy-MM-dd");
    String now = format.format(DateTime.now());
    String dateString = '';
    if (now == date) {
      dateString = 'today';
    } else if (format.format(DateTime.now().add(const Duration(days: 1))) ==
        date) {
      dateString = 'tomorrow';
    } else if (format
            .format(DateTime.now().subtract(const Duration(days: 1))) ==
        date) {
      dateString = 'yesterday';
    } else if (DateTime.now().difference(DateTime.parse(date)).inDays > 0) {
      dateString = 'past';
    } else {
      dateString = '${date.split('-')[1]}/${date.split('-')[2]}';
    }
    return dateString;
  }

  void addTag(
      String dateTag, String date, List<Widget> children, bool insertLine) {
    List<Widget> childrenList = [];
    for (Widget child in children) {
      childrenList.add(child);
    }
    if (dateTag.isNotEmpty && children.isNotEmpty) {
      bool expand = dateTag == 'past' ? false : true;
      displayList.add(
        Container(
          key: PageStorageKey(date),
          decoration: insertLine
              ? BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: darkTheme ? Colors.white : Colors.black,
                          width: 0.2)))
              : const BoxDecoration(),
          padding: EdgeInsets.fromLTRB(
              0.0, 0.0, 0.0, dateTag == 'yesterday' ? 20.0 : 0.0),
          child: ExpansionTile(
            title: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 12.0, 0.0, 0.0),
              child: Text(dateTag,
                  style: kDateTextStyle.copyWith(
                      color: darkTheme ? Colors.white : Colors.black,
                      fontSize: dateTag == 'today'
                          ? 24.0
                          : (dateTag != 'yesterday' &&
                                  dateTag != 'tomorrow' &&
                                  dateTag != 'past')
                              ? 18.0
                              : 20.0,
                      fontWeight: dateTag == 'today'
                          ? FontWeight.bold
                          : FontWeight.normal)),
            ),
            iconColor: darkTheme ? Colors.white : Colors.black,
            collapsedIconColor: Colors.grey.shade600,
            initiallyExpanded: expand,
            children: childrenList,
          ),
        ),
      );
    }
  }

  void _updateDisplayList() {
    String date = '';
    String dateTag = '';
    String lastDate = '';
    String lastDateTag = '';
    DateFormat format = DateFormat("yyyy-MM-dd");
    List<Widget> dateTodos = [];
    bool includeLine = false;
    bool lineAlreadyIncluded = false;

    displayList.clear();

    _todos.sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
    for (TodoModel item in _todos) {
      date = format.format(item.dueDateTime);
      dateTag = getDateString(date);
      if (dateTag != lastDateTag) {
        if (lastDate.isNotEmpty) {
          includeLine =
              (DateTime.now().compareTo(DateTime.parse(lastDate)) <= 0 ||
                      lastDateTag == 'today') &&
                  !lineAlreadyIncluded;
          if (!lineAlreadyIncluded) {
            lineAlreadyIncluded = includeLine;
          }
        }
        addTag(lastDateTag, lastDate, dateTodos, includeLine);
        dateTodos.clear();
        lastDateTag = dateTag;
      }
      if (dateTag == 'past' && date != lastDate) {
        dateTodos.add(Row(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(38.0, 12.0, 0.0, 6.0),
            child: Text(
              '${date.split('-')[1]}/${date.split('-')[2]}',
              key: Key(date),
              style: kDateTextStyle.copyWith(
                  color: darkTheme ? Colors.white : Colors.black),
            ),
          ),
        ]));
      }
      dateTodos.add(TodoItem(todoModel: item));
      lastDate = date;
    }
    addTag(lastDateTag, lastDate, dateTodos, includeLine);
  }

  int getTodaysTaskIndex() {
    DateTime today = DateTime.now();
    int index = 0;
    for (Widget displayWidget in displayList) {
      String date = displayWidget.key.toString().split('\'')[1];
      String dateTag = getDateString(date);
      if (dateTag == "today" || dateTag == "tomorrow") {
        return index;
      }
      if (dateTag != "past" && dateTag != 'yesterday') {
        if (DateTime.parse(date).difference(today).inDays > 0) {
          return index;
        }
      }
      index++;
    }
    return index;
  }

  /*
    UPDATE DATA FROM DATABASE
  */

  Future<void> fetchDatabaseList() async {
    final prefs = await SharedPreferences.getInstance();
    clearTodos();
    courses.clear();
    int colorIndex = 0;
    await _firestore
        .collection('todos')
        .doc(_auth.currentUser!.uid)
        .collection('items')
        .get()
        .then(((value) {
      for (var result in value.docs) {
        String courseCode = result.get('course_code');
        Course currentCourse;
        Iterable<Course> courseSubList =
            courses.where((element) => element.name == courseCode);
        if (courseSubList.isEmpty) {
          currentCourse =
              Course(courseCode, false, colorOptions[colorIndex % 7]);
          courses.add(currentCourse);
          colorIndex++;
        } else {
          currentCourse = courseSubList.elementAt(0);
        }

        DateTime dueDate = result.get('due_date').toDate();
        final todoModel = TodoModel(
          result.id,
          result.get('task_title'),
          result.get('task_description'),
          dueDate.toLocal(),
          courseCode,
          result.get('url') == null ? null : Uri.parse(result.get('url')),
          currentCourse.displayColor,
          result.get('is_completed'),
          result.get('is_notification'),
          result.get('is_canvas'),
          result.get('is_ls'),
          result.get('is_max'),
          result.get('is_custom'),
        );

        final bool? filterCalItems = prefs.getBool('filterCalendarItems');
        if (filterCalItems != null) {
          filterCalendarItems = filterCalItems;
        } else {
          filterCalendarItems = true;
        }
        // TODO: CHECK IF IS LS FOR CAL FILTER
        if (!(filterCalendarItems &&
            isCalItem(
                result.get('task_title'), result.get('task_description')))) {
          _todos.add(todoModel);
        } else {
          _filteredTodos.add(todoModel);
        }
      }
    }));
    for (int i = 0; i < courses.length; i++) {
      if (_todos
          .where((element) => (element.courseCode == courses[i].name))
          .isEmpty) {
        courses.remove(courses[i]);
      }
    }
    _updateDisplayList();
  }

  Future<void> getUserName() async {
    final userInfo =
        await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    userName = userInfo.data()!['name'];
    notifyListeners();
  }

  Future<void> updateTodosFromICal() async {
    List<dynamic> links = [];
    List<dynamic> names = [];
    final ldata = await _firestore
        .collection('ical_links')
        .doc(_auth.currentUser!.uid)
        .get();
    if (ldata.data() != null) {
      for (var link in ldata.data()!['links'].keys) {
        links.add(link);
      }
      for (var name in ldata.data()!['links'].values) {
        names.add(name);
      }
    }
    List<String> allTodoUids = [];
    for (var i = 0; i < links.length; i++) {
      List<TodoModel> todoList = await Parser().iCal(links[i], names[i]);
      for (var todo in todoList) {
        allTodoUids.add(todo.uid);
        _firestore
            .collection('todos')
            .doc(_auth.currentUser!.uid)
            .collection('items')
            .doc(todo.uid)
            .get()
            .then((value) async {
          if (value.exists) {
            _firestore
                .collection('todos')
                .doc(_auth.currentUser!.uid)
                .collection('items')
                .doc(todo.uid)
                .set({
              'task_title': todo.taskTitle,
              'task_description': todo.taskDescription,
              'is_custom': false,
              'is_canvas': todo.isCanvas,
              'is_ls': todo.isLS,
              'is_max': todo.isMax,
              'due_date': todo.dueDateTime.toUtc(),
              'url': todo.url.toString()
            }, SetOptions(merge: true));
          } else {
            _firestore
                .collection('todos')
                .doc(_auth.currentUser!.uid)
                .collection('items')
                .doc(todo.uid)
                .set({
              'task_title': todo.taskTitle,
              'task_description': todo.taskDescription,
              'course_code': todo.courseCode,
              'is_notification': todo.isNotification,
              'is_completed': todo.isCompleted,
              'is_custom': false,
              'is_canvas': todo.isCanvas,
              'is_ls': todo.isLS,
              'is_max': todo.isMax,
              'due_date': todo.dueDateTime.toUtc(),
              'url': todo.url.toString()
            });
          }
        });
      }
    }
    await _firestore
        .collection('todos')
        .doc(_auth.currentUser!.uid)
        .collection('items')
        .get()
        .then(((value) {
      for (var result in value.docs) {
        if (result.get('is_custom')) {
          _firestore
              .collection('todos')
              .doc(_auth.currentUser!.uid)
              .collection('items')
              .doc(result.id)
              .set({
            'task_title': result.get('task_title'),
            'task_description': result.get('task_description'),
            'course_code': result.get('course_code'),
            'is_notification': result.get('is_notification'),
            'is_completed': result.get('is_completed'),
            'is_custom': true,
            'is_canvas': false,
            'is_ls': false,
            'is_max': false,
            'due_date': result.get('due_date'),
            'url': result.get('url')
          });
        } else if (!allTodoUids.contains(result.id)) {
          _firestore
              .collection('todos')
              .doc(_auth.currentUser!.uid)
              .collection('items')
              .doc(result.id)
              .delete();
        }
      }
    }));
    // await _firestore
    //     .collection('todos')
    //     .doc(_auth.currentUser!.uid)
    //     .collection('items')
    //     .get()
    //     .then(((value) {
    //   for (var result in value.docs) {
    //     if (!allTodoUids.contains(result.id) && !result.get('is_custom')) {
    //       _firestore
    //           .collection('todos')
    //           .doc(_auth.currentUser!.uid)
    //           .collection('items')
    //           .doc(result.id)
    //           .delete();
    //     }
    //   }
    // }));
  }
}
