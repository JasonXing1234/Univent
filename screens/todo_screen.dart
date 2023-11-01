import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:univent/components/buttons/plain_text_button.dart';
import 'package:univent/models/todo_data.dart';
import 'package:provider/provider.dart';
import 'package:univent/screens/how_to_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key, required this.fromRestart}) : super(key: key);

  static const String id = 'todo_screen';
  final bool fromRestart;

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  String userName = '';
  String statusString = '';
  bool gettingTasks = false;

  final ItemScrollController _scrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    // if (!widget.fromRestart) {
    //   getICalLinks();
    // }
    // else {
    //   setState(() {
    //     gettingTasks = true;
    //   });
    //   if (getDisplayList().isEmpty) {
    //     setState(() {
    //       statusString = 'No tasks have been uploaded';
    //     });
    //   } else {
    //     setState(() {
    //       gettingTasks = false;
    //     });
    //   }
    // }
    if (getDisplayList().isEmpty) {
      getICalLinks();
    }
    listenForForegroundNotifications();
  }

  List<Widget> getDisplayList() {
    return Provider.of<TodoData>(context, listen: false).displayList;
  }

  Future<void> fetchDatabaseList() async {
    await Provider.of<TodoData>(context, listen: false).fetchDatabaseList();
  }

  void listenForForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // print('Got a message whilst in the foreground!');
      // print('Message data: ${message.data}');

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android.smallIcon,
              ),
            ));
      }
    });
  }

  Future<void> getICalLinks() async {
    setState(() {
      gettingTasks = true;
    });
    Provider.of<TodoData>(context, listen: false).getUserName();
    setState(() {
      statusString = 'Updating tasks from LS and Canvas';
    });
    await Provider.of<TodoData>(context, listen: false).updateTodosFromICal();
    setState(() {
      statusString = 'Loading tasks from database';
    });
    await fetchDatabaseList();
    if (getDisplayList().isEmpty) {
      setState(() {
        statusString = 'No tasks have been uploaded';
      });
    } else {}
    setState(() {
      gettingTasks = false;
    });
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 0.0),
          Expanded(
            child: RefreshIndicator(
              color: Colors.black,
              backgroundColor: Colors.white,
              onRefresh: () async {
                await getICalLinks();
              },
              child: Provider.of<TodoData>(context).displayList.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(20.0),
                            child: gettingTasks
                                ? Text(
                                    statusString,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                    textAlign: TextAlign.center,
                                  )
                                : Column(
                                    children: [
                                      Text(
                                        'No tasks have been uploaded',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                        textAlign: TextAlign.center,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: PlainTextButton(
                                          action: () {
                                            Navigator.pushNamed(
                                                context, HowToScreen.id);
                                          },
                                          title:
                                              'Click here to add your classes!',
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ])
                  : ScrollablePositionedList.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      initialScrollIndex:
                          Provider.of<TodoData>(context).getTodaysTaskIndex(),
                      itemScrollController: _scrollController,
                      itemCount:
                          Provider.of<TodoData>(context).displayList.length,
                      itemBuilder: (context, index) {
                        return Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child:
                              Provider.of<TodoData>(context).displayList[index],
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
