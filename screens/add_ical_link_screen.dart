import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:univent/components/buttons/plain_text_button.dart';
import 'package:univent/components/rounded_text_field.dart';
import 'package:univent/models/parser.dart';
import 'package:univent/models/todo_model.dart';
import 'package:univent/screens/home_screen.dart';
import 'package:univent/screens/how_to_screen.dart';
import 'package:univent/components/buttons/rounded_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:univent/components/buttons/rounded_button.dart';
class AddIcalLinkScreen extends StatefulWidget {
  const AddIcalLinkScreen({Key? key}) : super(key: key);

  static const id = 'add_ical_link';

  @override
  State<AddIcalLinkScreen> createState() => _AddIcalLinkScreenState();
}

class _AddIcalLinkScreenState extends State<AddIcalLinkScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late TextEditingController _linkController;
  late TextEditingController _nameController;
  String link = '';
  String name = '';
  FocusNode pasteFocus = FocusNode();
  bool linkFieldSelected = false;

  bool isCanvasLink = true;

  @override
  void initState() {
    _linkController = TextEditingController();
    _nameController = TextEditingController();
    pasteFocus.addListener(() {
      if (!pasteFocus.hasFocus) {
        fieldDeselected();
      } else {
        fieldSelected();
      }
    });

    super.initState();
  }

  void fieldSelected() async {
    bool hasPasteData = await Clipboard.hasStrings();
    setState(() {
      linkFieldSelected = true && hasPasteData;
    });
  }

  void fieldDeselected() {
    setState(() {
      linkFieldSelected = false;
    });
  }

  @override
  void dispose() {
    _linkController.dispose();
    _nameController.dispose();

    super.dispose();
  }

  Future<bool> retreiveTodosFromICal(url, className) async {
    bool success = true;
    List<TodoModel> todoList = [];
    try {
      todoList = await Parser().iCal(url, className);
    } catch (e) {
      // print(e);
      success = false;
    }
    if (success) {
      for (var todo in todoList) {
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
          'due_date': todo.dueDateTime,
          'url': todo.url.toString()
        });
      }
    }
    return success;
  }

  FocusScopeNode getPageFocus() {
    return FocusScope.of(context);
  }

  void enterLinkCallback(value) {
    link = value;
    Uri url = Uri.parse(link);
    if (url.isAbsolute) {
      setState(() {
        if (url.host.split('.').length > 1) {
          if (url.host.split('.')[1] == "instructure") {
            isCanvasLink = true;
          } else {
            isCanvasLink = false;
          }
        }
      });
    } else {
      setState(() {
        isCanvasLink = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void displaySnackBar(SnackBar snackBar) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.fitWidth,
          child: Text('univent',
              style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)),
        ),
      ),
      body: ProgressHUD(
        child: Builder(builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListView(

              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),

                  child: Column(

                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                        child: Text.rich(
                          textAlign: TextAlign.center,
                          TextSpan(
                            text: 'How to add\nyour classes',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 35,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: SizedBox(
                            width: 300,
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontSize: 36),
                                children: <TextSpan>[
                                  const TextSpan(
                                      text: 'Learning Suite\n\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 40,
                                          color: Colors.blueGrey)),
                                  const TextSpan(
                                      style: TextStyle(fontSize: 32),
                                      text:
                                      '1. Open Learning Suite in a web browser on your phone. '),
                                  TextSpan(
                                      text: "Go to Learning Suite",
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 32,
                                          decoration: TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          launchUrl(
                                              Uri.parse(
                                                  'https://learningsuite.byu.edu/student/top'),
                                              mode: LaunchMode.externalApplication);
                                        }),
                                  const TextSpan(
                                      style: TextStyle(fontSize: 32),
                                      text:
                                      '\nSelect one of your classes.\n2. Open the left menu bar by clicking on the icon in the top left. Select “Schedule.”\n3. Select “iCalendar Feed” in the top right corner and copy the URL.\n4. Paste the URL above and enter the class ID.\n5. Click “Add Link.”Repeat with your other classes.\n\n\n'),
                                  const TextSpan(
                                      text: 'Canvas\n\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 40,
                                          color: Colors.red)),
                                  const TextSpan(
                                      style: TextStyle(fontSize: 32),
                                      text:
                                      '1. Open Canvas in a web browser on your phone. '),
                                  TextSpan(
                                      text: "Go to Canvas",
                                      style: const TextStyle(
                                          fontSize: 32,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          launchUrl(
                                              Uri.parse('https://byu.instructure.com/'),
                                              mode: LaunchMode.externalApplication);
                                        }),
                                  const TextSpan(
                                      style: TextStyle(fontSize: 32),
                                      text:
                                      "\n2. Open the left menu bar by clicking the icon in the top left. Select “Calendar.\n3. Scroll to the bottom of the page and select “Calendar Feed.”\n4. Copy the URL.\n5. Paste the URL above. This one link will contain all of your canvas classes.")
                                ],
                              ),
                              textScaleFactor: 0.5,
                            )),
                      ),

                    ],
                  ),
                ),
                const SizedBox(
                  height: 24.0,
                ),
                RoundedTextField(
                  hint: 'Enter iCalendar Link',
                  callback: enterLinkCallback,
                  controller: _linkController,
                  focus: pasteFocus,
                  keyboardType: TextInputType.url,
                ),
                !isCanvasLink
                    ? RoundedTextField(
                  controller: _nameController,
                  callback: (value) {
                    name = value;
                  },
                  hint: 'Enter Title of Class (e.g. CS 110)',
                )
                    : const SizedBox(
                  height: 24.0,
                ),
                linkFieldSelected
                    ? InkWell(
                        onTap: () async {
                          Clipboard.getData(Clipboard.kTextPlain).then((value) {
                            String newText = value!.text as String;
                            enterLinkCallback(newText);
                            _linkController.text = newText;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Paste from Clipboard',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Icon(Icons.paste,
                                color: Theme.of(context).colorScheme.secondary),
                          ],
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 24.0,
                ),
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RoundedButton(
                      title: const Text('Finish'),
                      action: () {
                        Navigator.pushNamed(context, HomeScreen.id,
                            arguments: false);
                      },
                    ),
                    RoundedButton(
                      color: Theme.of(context).colorScheme.secondary,
                      title: const Text('Add Link'),
                      action: () async {
                        String snackBarText = 'Link successfully added!';
                        Color snackBarColor = Colors.green;
                        final progress = ProgressHUD.of(context);
                        if (link.isNotEmpty) {
                          String classCode = '';
                          Uri url = Uri.parse(link);
                          if (url.isAbsolute) {
                            progress!.showWithText('Loading');
                            if (url.host.split('.')[1] == 'instructure') {
                              classCode = 'canvas';
                            } else {
                              classCode = name;
                            }
                            if (await retreiveTodosFromICal(link, classCode)) {
                              await _firestore
                                  .collection('ical_links')
                                  .doc(_auth.currentUser!.uid)
                                  .set({
                                'links': {link: classCode}
                              }, SetOptions(merge: true));
                            } else {
                              snackBarText =
                                  'Not a valid iCalendar link. The link is probably private or broken.';
                              snackBarColor = Colors.red;
                            }
                            progress.dismiss();
                          } else {
                            snackBarText = 'Invalid link';
                            snackBarColor = Colors.red;
                          }
                        } else {
                          snackBarText = 'Please enter a link';
                          snackBarColor = Colors.red;
                        }
                        SnackBar snackBar = SnackBar(
                          content: Text(snackBarText),
                          backgroundColor: snackBarColor,
                        );
                        displaySnackBar(snackBar);
                        _linkController.clear();
                        _nameController.clear();
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          isCanvasLink = true;
                        });
                      },
                    ),
                  ],
                ),
                PlainTextButton(
                  action: () {
                    Navigator.pushNamed(context, HowToScreen.id);
                  },
                  title: 'Forgot how to get this link? Click here!',
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
