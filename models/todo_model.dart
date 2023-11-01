import 'package:flutter/material.dart';

class TodoModel {
  String uid;
  String taskTitle;
  String taskDescription;
  DateTime dueDateTime;
  String courseCode;
  Uri? url;
  Color color;

  bool isCompleted;
  bool isNotification;
  bool isCanvas;
  bool isLS;
  bool isMax;
  bool isCustom;

  TodoModel(
    this.uid,
    this.taskTitle,
    this.taskDescription,
    this.dueDateTime,
    this.courseCode,
    this.url,
    this.color,
    this.isCompleted,
    this.isNotification,
    this.isCanvas,
    this.isLS,
    this.isMax,
    this.isCustom,
  );
}
