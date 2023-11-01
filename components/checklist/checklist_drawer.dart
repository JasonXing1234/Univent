import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:univent/components/buttons/list_button.dart';
import 'package:univent/components/buttons/rounded_button.dart';
import 'package:univent/components/checklist/todo_bottom_sheet.dart';
import 'package:univent/constants.dart';
import 'package:univent/models/todo_data.dart';
import 'package:univent/screens/add_ical_link_screen.dart';
import 'package:univent/screens/colors_screen.dart';
import 'package:univent/screens/how_to_screen.dart';
import 'package:univent/screens/logout_screen.dart';
import 'package:univent/screens/remove_ical_link_screen.dart';

class ChecklistDrawer extends StatelessWidget {
  const ChecklistDrawer({required this.scaffoldKey, super.key});

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Welcome, ${Provider.of<TodoData>(context).userName}!',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            ListButton(
              icon: CupertinoIcons.slider_horizontal_3,
              action: () {
                scaffoldKey.currentState?.closeDrawer();
                showDialog(
                  context: context,
                  builder: (context) => filterPopup(context),
                );
              },
              title: 'Filter Tasks',
            ),
            ListButton(
              icon: Icons.add_task,
              action: () async {
                scaffoldKey.currentState?.closeDrawer();
                await showTodoBottomSheet(context);
              },
              title: 'Add Custom Task',
            ),
            ListButton(
              icon: Icons.add_link,
              action: () {
                Navigator.pushNamed(context, AddIcalLinkScreen.id);
              },
              title: 'Add iCalendar Link',
            ),
            ListButton(
              icon: Icons.link_off,
              action: () {
                Navigator.pushNamed(context, RemoveIcalLinkScreen.id);
              },
              title: 'Remove iCalendar Link',
            ),
            ListButton(
              icon: Icons.color_lens,
              action: () {
                Navigator.pushNamed(context, ColorsScreen.id);
              },
              title: 'Colors',
            ),
            ListButton(
              icon: Icons.logout,
              action: () {
                Navigator.pushNamed(context, LogoutScreen.id);
              },
              title: 'Log Out',
            ),
            ListButton(
              icon: Icons.question_mark,
              action: () {
                Navigator.pushNamed(context, HowToScreen.id);
              },
              title: 'Help',
            ),
          ],
        ),
      ),
    );
  }
}

Widget filterPopup(BuildContext context) {
  return AlertDialog(
    contentPadding: const EdgeInsets.fromLTRB(26.0, 8.0, 8.0, 0.0),
    actionsPadding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
    shape: kRoundedBorder,
    title: Row(
      children: [
        Expanded(
          child: InkWell(
            child: Text(
              'Filter by class',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 18.0,
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
    content: SizedBox(
      width: double.maxFinite,
      child: ListView.builder(
        itemCount: Provider.of<TodoData>(context).courses.length,
        itemBuilder: (context, index) {
          final classes = Provider.of<TodoData>(context).courses;
          String classID = classes[index].name;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Transform.scale(
                        scale: 1.85,
                        child: Checkbox(
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 1.5),
                          checkColor: Theme.of(context).colorScheme.primary,
                          activeColor: Theme.of(context).colorScheme.secondary,
                          shape: const CircleBorder(),
                          value: !classes[index].isFiltered,
                          onChanged: (value) {
                            Provider.of<TodoData>(context, listen: false)
                                .toggleFilter(index);
                          },
                        ));
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      classID,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    ),
    actions: [
      Container(
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 0.1))),
        width: double.maxFinite,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26.0, 8.0, 8.0, 8.0),
          child: Row(
            children: [
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Transform.scale(
                      scale: 1.85,
                      child: Checkbox(
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 1.5),
                        checkColor: Theme.of(context).colorScheme.primary,
                        activeColor: Theme.of(context).colorScheme.secondary,
                        shape: const CircleBorder(),
                        value:
                            !Provider.of<TodoData>(context).filterCalendarItems,
                        onChanged: (value) {
                          Provider.of<TodoData>(context, listen: false)
                              .toggleCalendarFilter();
                        },
                      ));
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Include all schedule items",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      SizedBox(
        width: double.infinity,
        child: RoundedButton(
          color: Theme.of(context).colorScheme.secondary,
          action: () {
            Navigator.pop(context);
          },
          title: const Text('Apply Filter'),
        ),
      ),
    ],
  );
}
