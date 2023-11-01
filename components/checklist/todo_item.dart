import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:univent/components/buttons/rounded_button.dart';
import 'package:univent/constants.dart';
import 'package:univent/models/todo_data.dart';
import 'package:univent/models/todo_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:univent/components/checklist/todo_bottom_sheet.dart';
import 'package:flutter/services.dart' show rootBundle;

class TodoItem extends StatefulWidget {
  final TodoModel todoModel;
  const TodoItem({super.key, required this.todoModel});

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void goBack() {
    Navigator.pop(context);
  }

  void exitAlert() {
    Navigator.pop(context);
  }

  Widget sharePopup(BuildContext context) {
    return AlertDialog(
      title: const Text('Congratulations!', style: TextStyle(fontSize: 24.0)),
      content: const Text(
          'You finished all your tasks for today, share your success with a friend!'),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () {
            exitAlert();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final byteData = await rootBundle.load('assets/splash_image.gif');
            final file = File(
                '${(await getTemporaryDirectory()).path}/splash_image.gif');
            await file.writeAsBytes(byteData.buffer
                .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
            Share.shareXFiles([XFile(file.path)],
                text:
                    'I finished all my assignments for today! Keep track of yours on Univent: https://univent.io');
            exitAlert();
          },
          child: const Text('Share!'),
        ),
      ],
    );
  }

  Widget taskInfoPopup(BuildContext context) {
    DateFormat format = DateFormat('hh:mm a');
    return AlertDialog(
      shape: kRoundedBorder,
      title: Row(
        children: [
          Expanded(
            child: InkWell(
              child: Text(
                widget.todoModel.taskTitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (widget.todoModel.isCustom)
              ? Text(
                  'Due at ${format.format(widget.todoModel.dueDateTime)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const SizedBox(height: 0.0),
          const SizedBox(height: 16.0),
          Text(
            'Class: ${widget.todoModel.courseCode}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                widget.todoModel.taskDescription,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 15.0,
                ),
              ),
            ),
          )
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: widget.todoModel.isCustom
              ? SizedBox(
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: RoundedButton(
                          color: widget.todoModel.color,
                          title: const Text('Delete'),
                          action: () {
                            Provider.of<TodoData>(context, listen: false)
                                .removeTodo(widget.todoModel);
                            _firestore
                                .collection('todos')
                                .doc(_auth.currentUser!.uid)
                                .collection('items')
                                .doc(widget.todoModel.uid)
                                .delete();
                            if (Provider.of<TodoData>(context, listen: false)
                                    .getTodos()
                                    .where((element) =>
                                        element.courseCode ==
                                        widget.todoModel.courseCode)
                                    .length <=
                                1) {
                              Provider.of<TodoData>(context, listen: false)
                                  .removeCourse(widget.todoModel.courseCode);
                            }
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        flex: 1,
                        child: RoundedButton(
                          color: widget.todoModel.color,
                          action: () async {
                            Navigator.pop(context);
                            await showTodoBottomSheet(
                                context, widget.todoModel);
                          },
                          title: const Text('Edit'),
                        ),
                      ),
                    ],
                  ),
                )
              : RoundedButton(
                  color: widget.todoModel.color,
                  action: () => launchUrl(widget.todoModel.url!,
                      mode: LaunchMode.externalApplication),
                  title: widget.todoModel.isCanvas
                      ? const Text('View Assignment on Canvas')
                      : widget.todoModel.isLS
                          ? const Text('View Assignment on LS')
                          : (widget.todoModel.isMax)
                              ? const Text('View Assignment on Max')
                              : const Text('View Assignment online'),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      child: ElevatedButton(
        clipBehavior: Clip.hardEdge,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => taskInfoPopup(context),
          );
        },
        style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24.0))),
            backgroundColor: widget.todoModel.color,
            padding: const EdgeInsets.only(right: 16.0)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.only(right: 0.0),
            child: Container(
              width: 20.0,
              height: 70.0,
              color: widget.todoModel.color,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              alignment: Alignment.center,
              width: 32,
              height: 32,
              child: Transform.scale(
                  scale: 1.85,
                  child: Checkbox(
                    side: const BorderSide(width: 1.5),
                    checkColor: widget.todoModel.color,
                    activeColor: Colors.black,
                    shape: const CircleBorder(),
                    value: widget.todoModel.isCompleted,
                    onChanged: (value) {
                      setState(() {
                        widget.todoModel.isCompleted = value!;
                      });
                      _firestore
                          .collection('todos')
                          .doc(_auth.currentUser!.uid)
                          .collection('items')
                          .doc(widget.todoModel.uid)
                          .update(
                              {'is_completed': widget.todoModel.isCompleted});
                      if (Provider.of<TodoData>(context, listen: false)
                                  .getTodos()
                                  .where((element) =>
                                      element.isCompleted == true &&
                                      element.dueDateTime.year ==
                                          DateTime.now().year &&
                                      element.dueDateTime.month ==
                                          DateTime.now().month &&
                                      element.dueDateTime.day ==
                                          DateTime.now().day)
                                  .length ==
                              Provider.of<TodoData>(context, listen: false)
                                  .getTodos()
                                  .where((element) =>
                                      element.dueDateTime.year ==
                                          DateTime.now().year &&
                                      element.dueDateTime.month ==
                                          DateTime.now().month &&
                                      element.dueDateTime.day ==
                                          DateTime.now().day)
                                  .length &&
                          widget.todoModel.dueDateTime.year ==
                              DateTime.now().year &&
                          widget.todoModel.dueDateTime.month ==
                              DateTime.now().month &&
                          widget.todoModel.dueDateTime.day ==
                              DateTime.now().day) {
                        showDialog(
                          context: context,
                          builder: (context) => sharePopup(context),
                        );
                      }
                    },
                  )),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.todoModel.taskTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.todoModel.courseCode,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: IconButton(
              color: Colors.black,
              onPressed: () {
                setState(() {
                  widget.todoModel.isNotification =
                      !widget.todoModel.isNotification;
                });
                _firestore
                    .collection('todos')
                    .doc(_auth.currentUser!.uid)
                    .collection('items')
                    .doc(widget.todoModel.uid)
                    .update(
                        {'is_notification': widget.todoModel.isNotification});
              },
              icon: (widget.todoModel.isNotification)
                  ? const Icon(
                      Icons.notifications_active,
                      size: 32.0,
                    )
                  : const Icon(
                      Icons.notifications_off_outlined,
                      size: 32.0,
                    ),
            ),
          ),
        ]),
      ),
    );
  }
}
