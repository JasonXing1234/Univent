import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:univent/components/bulletin/bulletin_drawer.dart';
import 'package:univent/components/checklist/checklist_drawer.dart';
import 'package:univent/constants.dart';
import 'package:univent/models/flyer_data.dart';
import 'package:univent/models/todo_data.dart';
import 'package:univent/screens/add_flyer_screen.dart';
import 'package:univent/screens/bulletin_screen.dart';
import 'package:univent/screens/todo_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.fromRestart}) : super(key: key);

  static const String id = 'home_screen';
  final bool fromRestart;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _screenIndex = 1;
  static late bool isFromRestart;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool bulletinImplemented = false;
  bool isAdmin = false;
  // bool hasFlyers = false;
  String? selectedUniversity;

  void exitAlert() {
    Navigator.pop(context);
  }

  Widget selectUniversityPopup(BuildContext context) {
    // REFACTOR THIS
    List<DropdownMenuItem<String>> univeristyOptions = [
      DropdownMenuItem<String>(
          value: 'Brigham Young University',
          child: Text(
            'Brigham Young University',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          )),
      DropdownMenuItem<String>(
          value: 'Utah Valley University',
          child: Text('Utah Valley University',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.secondary))),
      DropdownMenuItem<String>(
          value: 'University of Utah',
          child: Text('University of Utah',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.secondary))),
      DropdownMenuItem<String>(
          value: 'Utah State University',
          child: Text('Utah State University',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.secondary))),
      DropdownMenuItem<String>(
          value: 'Other',
          child: Text('Other',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary)))
    ];
    return ProgressHUD(
      child: Builder(builder: (alertContext) {
        return AlertDialog(
          title: const Text('Select your University',
              style: TextStyle(fontSize: 24.0)),
          content: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return InputDecorator(
                decoration: kTextFieldDecoration,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: const Text(
                      'Select your University',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    items: univeristyOptions,
                    isExpanded: true,
                    value: selectedUniversity,
                    onChanged: (String? value) {
                      setState(() {
                        selectedUniversity = value!;
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedUniversity = '';
                });
                exitAlert();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final progress = ProgressHUD.of(alertContext);
                progress!.show();
                await _firestore
                    .collection('users')
                    .doc(_auth.currentUser?.uid)
                    .update({'university': selectedUniversity});
                progress.dismiss();
                exitAlert();
              },
              child: const Text('Submit'),
            )
          ],
        );
      }),
    );
  }

  Widget takeSurveyPopup(BuildContext context) {
    return AlertDialog(
      title: const Text('Please provide your feedack!',
          style: TextStyle(fontSize: 24.0)),
      content:
          const Text('Please take this survey to help us improve Univent!'),
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
            launchUrlString(
                'https://byu.az1.qualtrics.com/jfe/form/SV_41NG1aQf69YKN14',
                mode: LaunchMode.inAppWebView);
            exitAlert();
          },
          child: const Text('Ok'),
        )
      ],
    );
  }

  void checkAdmin() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .get()
        .then((value) {
      Map<String, dynamic>? userMap = value.data();
      if (userMap!.containsKey('is_admin')) {
        setState(() {
          isAdmin = value.get('is_admin');
        });
      }
    });
  }

  void checkBulletinImplemented() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .get()
        .then((value) async {
      Map<String, dynamic>? userMap = value.data();
      if (!userMap!.containsKey('university')) {
        await showDialog(
          context: context,
          builder: (context) => selectUniversityPopup(context),
        );
        selectedUniversity = selectedUniversity!.trim().toLowerCase();
      } else {
        selectedUniversity =
            value.get('university').toString().trim().toLowerCase();
      }
      setState(() {
        bulletinImplemented =
            selectedUniversity == 'brigham young university' ||
                selectedUniversity == 'byu';
      });
    });
  }

  void checkHasSeenPopup() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .get()
        .then((value) async {
      Map<String, dynamic>? userMap = value.data();
      if (!userMap!.containsKey('has_seen_popup')) {
        await showDialog(
          context: context,
          builder: (context) => takeSurveyPopup(context),
        );
        _firestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .update({'has_seen_popup': true});
      } else if (!value.get('has_seen_popup')) {
        // TODO: Implement this when we decide to show the popup to people that
        // just recently downloaded the app.
      }
    });
  }

  void checkFlyers() async {
    await Provider.of<FlyerData>(context, listen: false).fetchMyFlyers();
  }

  @override
  void initState() {
    super.initState();
    isFromRestart = widget.fromRestart;
    checkBulletinImplemented();
    checkHasSeenPopup();
    checkAdmin();
    checkFlyers();
  }

  static final List<Widget> _screenOptions = <Widget>[
    const BulletinScreen(),
    TodoScreen(fromRestart: isFromRestart)
  ];

  var scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildPopupDialog(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AddFlyerScreen.id);
              },
              style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                  fixedSize: const Size.fromHeight(40)),
              child: const Text('Post a flyer')),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade500,
                  textStyle: const TextStyle(fontSize: 20),
                  fixedSize: const Size.fromHeight(40)),
              child: const Text('Cancel')),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoData>(
      builder: (context, todoData, child) => Scaffold(
          key: scaffoldKey,
          onDrawerChanged: (isOpened) {
            if (isOpened) {
              Provider.of<FlyerData>(context, listen: false).fetchMyFlyers();
            }
          },
          appBar: AppBar(
            title: const FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                'univent',
                style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Provider.of<FlyerData>(context, listen: false).fetchMyFlyers();
                scaffoldKey.currentState?.openDrawer();
              },
            ),
            actions: _screenIndex == 0
                ? [
                    IconButton(
                      icon: const Icon(Icons.add_box_outlined),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              _buildPopupDialog(context),
                        );
                      },
                    ),
                  ]
                : [],
          ),
          body: _screenOptions.elementAt(_screenIndex),
          bottomNavigationBar: Visibility(
            visible: bulletinImplemented,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 0.2),
                ),
              ),
              child: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.pin), label: 'Bulletin'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.checklist), label: 'Checklist'),
                ],
                currentIndex: _screenIndex,
                onTap: (value) {
                  setState(() {
                    _screenIndex = value;
                  });
                },
              ),
            ),
          ),
          drawer: _screenIndex == 0
              ? BulletinDrawer(
                  scaffoldKey: scaffoldKey,
                  isAdmin: isAdmin,
                  hasFlyers:
                      Provider.of<FlyerData>(context).myFlyers.isNotEmpty,
                )
              : ChecklistDrawer(scaffoldKey: scaffoldKey)),
    );
  }
}
