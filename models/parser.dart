import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:univent/models/todo_model.dart';
import 'package:http/http.dart' as http;

class Parser {
  Future<List<TodoModel>> iCal(String iCalUrl, [String courseCode = '']) async {
    Uri link = Uri.parse(iCalUrl);
    http.Response response = await http.get(link);
    String linesString =
        const Utf8Decoder(allowMalformed: true).convert(response.bodyBytes);
    final iCalendar = ICalendar.fromString(linesString);

    bool isCanvas = link.host.split('.')[1] == 'instructure';
    bool isLS = link.host == 'learningsuite.byu.edu';
    bool isMax = link.host == 'max.byu.edu';

    List<TodoModel> result = [];
    for (var d in iCalendar.data) {
      String taskTitle = d["summary"];
      String taskDescription =
          (d["description"] == null) ? '' : d["description"];

      taskTitle = taskTitle.replaceAll('\\n', '');
      taskDescription = taskDescription.replaceAll('\\n', '');

      // bool isTask = true;

      // if (taskTitle == taskDescription) {
      //   isTask = false;
      // } else if (taskTitle.length > 60 && taskDescription.length > 60) {
      //   if (taskTitle.substring(0, 60) == taskDescription.substring(0, 60)) {
      //     isTask = false;
      //   }
      // }

      DateTime due = (d["dtend"] != null)
          ? d["dtend"].toDateTime()
          : d["dtstart"].toDateTime();

      String url = '';
      if (isCanvas) {
        if (taskTitle.toString().split("[").length > 1) {
          courseCode = taskTitle.toString().split("[")[1];
          courseCode = courseCode.split("]")[0];
        }
        taskTitle = taskTitle.toString().split("[")[0];
        url = d["url"];
      } else if (isLS) {
        url = "https://learningsuite.byu.edu/student/top/prioritizer";
        if (d["dtend"] != null) {
          due = due.subtract(const Duration(minutes: 1));
        } else {
          due = due.add(const Duration(hours: 23, minutes: 59));
        }
      } else if (isMax) {
        if (taskDescription.contains(', https://')) {
          url = taskDescription
              .split(', ')[taskDescription.split(', ').length - 1];
          taskDescription = taskDescription.split(', https://')[0];
        } else {
          // if (d['X-ALT-DESC'] != null) {
          // } else {
          url = 'https://max.byu.edu';
          // }
        }
      } else {
        url = link.host;
      }

      if (!isCanvas) {}

      result.add(TodoModel(
          d['uid'],
          taskTitle,
          taskDescription,
          due,
          courseCode,
          Uri.parse(url),
          Colors.grey.shade700,
          false,
          true,
          isCanvas,
          isLS,
          isMax,
          false));
    }

    return result;
  }
}
