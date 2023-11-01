import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:univent/components/buttons/rounded_button.dart';
import 'package:univent/components/radio_check.dart';
import 'package:univent/components/rounded_text_field.dart';
import 'package:univent/models/flyer_data.dart';
import 'package:univent/models/flyer_model.dart';
import 'package:univent/models/todo_data.dart';
import 'package:uuid/uuid.dart';

class AddFlyerScreen extends StatefulWidget {
  const AddFlyerScreen({Key? key}) : super(key: key);

  static const id = 'add_flyer_link';

  @override
  State<AddFlyerScreen> createState() => _AddFlyerScreenState();
}

class _AddFlyerScreenState extends State<AddFlyerScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _functions = FirebaseFunctions.instance;

  String flyerUid = const Uuid().v4();
  String tempTitle = '';
  String tempDetails = '';
  String tempLocation = '';
  String imageUrl = '';
  String actionLink = '';
  // DateTime tempEventDate = DateTime.now();
  bool hasLink = false;

  DateTime tempEndDate = DateTime.now();
  String endFlyerButtonText = "Take down flyer on...";

  FocusNode pasteFocus = FocusNode();
  late TextEditingController _linkController;
  bool linkFieldSelected = false;

  TimeOfDay tempDueTimeOfDay = const TimeOfDay(hour: 23, minute: 59);
  String dateButtonText = 'Select Date';
  String timeButtonText = 'Select Time';

  @override
  void initState() {
    _linkController = TextEditingController();
    pasteFocus.addListener(() {
      if (!pasteFocus.hasFocus) {
        fieldDeselected();
      } else {
        fieldSelected();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
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

  Future<void> setImage(ImageSource source) async {
    XFile? image;
    try {
      image = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 20);
    } catch (e) {
      SnackBar snackBar = const SnackBar(
        content: Text('Invalid image was selected.'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // print(e.toString());
    }
    if (image == null) {
      return;
    }
    final ref = _storage.ref().child('flyers').child('$flyerUid.jpg');
    await ref.putFile(File(image.path));
    imageUrl = await ref.getDownloadURL();
    setState(() {
      imageUrl = imageUrl;
    });
  }

  void enterLinkCallback(value) {
    actionLink = value;
  }

  void exitAlert() {
    Navigator.pop(context);
  }

  Widget submitFlyerPopup(BuildContext context) {
    return AlertDialog(
      title: const Text('Submit Flyer', style: TextStyle(fontSize: 24.0)),
      content: const Text('Are you sure you want to submit this flyer?'),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () {
            exitAlert();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            String snackBarText =
                'Thanks for submitting a flyer! It will be reviewed within the next few hours.';
            Color snackBarColor = Colors.green;
            if (hasLink && actionLink.isEmpty) {
              snackBarText = 'No link was provided.';
              snackBarColor = Colors.red;
            } else if (imageUrl.isEmpty) {
              snackBarText = 'No flyer was provided.';
              snackBarColor = Colors.red;
            } else if (endFlyerButtonText == "Take down flyer on...") {
              snackBarText = 'No end date was provided.';
              snackBarColor = Colors.red;
            } else {
              if (hasLink && actionLink.isNotEmpty) {
                Uri url;
                try {
                  if (!actionLink.startsWith("https://")) {
                    actionLink = "https://$actionLink";
                  }
                  url = Uri.parse(actionLink);
                  // if (!url.hasScheme) {
                  //   url = url.replace(scheme: "https:");
                  // }
                  if (!url.isAbsolute) {
                    snackBarText = 'Invalid link was provided.';
                    snackBarColor = Colors.red;
                  } else {
                    FlyerModel flyer = FlyerModel(
                      flyerUid,
                      tempTitle,
                      tempDetails,
                      _auth.currentUser!.uid,
                      _auth.currentUser!.email!,
                      imageUrl,
                      tempLocation,
                      DateTime.now().toLocal(),
                      tempEndDate,
                      [],
                      actionLink,
                      false,
                    );
                    try {
                      _firestore.collection('reviews').doc(flyer.uid).set({
                        'uid': flyer.uid,
                        'rsvp_list': flyer.rsvpList,
                        'details': flyer.postDetails,
                        'post_time': flyer.timePosted,
                        'user': _auth.currentUser?.uid,
                        'email': _auth.currentUser!.email!,
                        'image_url': imageUrl,
                        'title': flyer.title,
                        'location': flyer.location,
                        'event_date': flyer.eventDate,
                        'action_link': flyer.actionLink,
                        'approved': false
                      }).then((value) async {
                        HttpsCallable callable =
                            _functions.httpsCallable('notifyAdmins');
                        await callable();
                      });
                    } catch (e) {
                      // print(e);
                    }
                    Provider.of<FlyerData>(context, listen: false)
                        .addReview(flyer);
                    Navigator.pop(context);
                  }
                } catch (e) {
                  snackBarText = 'An unexpected error occurred.';
                  snackBarColor = Colors.red;
                }
              } else {
                FlyerModel flyer = FlyerModel(
                  flyerUid,
                  tempTitle,
                  tempDetails,
                  _auth.currentUser!.uid,
                  _auth.currentUser!.email!,
                  imageUrl,
                  tempLocation,
                  DateTime.now().toLocal(),
                  tempEndDate,
                  [],
                  actionLink,
                  false,
                );
                try {
                  _firestore.collection('reviews').doc(flyer.uid).set({
                    'uid': flyer.uid,
                    'rsvp_list': flyer.rsvpList,
                    'details': flyer.postDetails,
                    'post_time': flyer.timePosted,
                    'user': _auth.currentUser?.uid,
                    'email': _auth.currentUser!.email!,
                    'image_url': imageUrl,
                    'title': flyer.title,
                    'location': flyer.location,
                    'event_date': flyer.eventDate,
                    'action_link': flyer.actionLink,
                    'approved': false
                  }).then((value) async {
                    HttpsCallable callable =
                        _functions.httpsCallable('notifyAdmins');
                    await callable();
                  });
                } catch (e) {
                  // print(e);
                }
                Provider.of<FlyerData>(context, listen: false).addReview(flyer);
                Navigator.pop(context);
              }
            }
            SnackBar snackBar = SnackBar(
              content: Text(snackBarText),
              backgroundColor: snackBarColor,
            );
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            exitAlert();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      text: 'Post a Flyer',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 35,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 32.0, horizontal: 16.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: imageUrl.isEmpty ? 64.0 : 0.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Provider.of<TodoData>(context).darkTheme
                              ? const Color.fromARGB(255, 75, 75, 75)
                              : Colors.black,
                          width: 1.0),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(32.0)),
                    ),
                    child: imageUrl.isEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Provider.of<TodoData>(context).darkTheme
                                  ? const Color.fromARGB(255, 75, 75, 75)
                                  : Colors.black,
                            ),
                            iconSize: imageUrl.isEmpty ? 100 : null,
                            onPressed: () async {
                              final progress = ProgressHUD.of(context);
                              progress!.showWithText('Loading');
                              await setImage(ImageSource.gallery);
                              progress.dismiss();
                            },
                          )
                        : ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(32.0)),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  placeholder: (context, url) => Center(
                                      child: Padding(
                                    padding: const EdgeInsets.all(100.0),
                                    child: Image.asset(
                                      Provider.of<TodoData>(context).darkTheme
                                          ? 'assets/splash_image_dark.png'
                                          : 'assets/splash_image_light.jpeg',
                                      width: 100,
                                      height: 100,
                                    ),
                                  )),
                                  errorWidget: (context, url, error) =>
                                      const Center(
                                    child: Text('Unable to load image...'),
                                  ),
                                ),
                                Positioned(
                                  left: 0.0,
                                  top: 0.0,
                                  child: FloatingActionButton(
                                    mini: true,
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    onPressed: () {
                                      setState(() {
                                        imageUrl = '';
                                      });
                                    },
                                    child: const Icon(Icons.remove),
                                  ),
                                )
                              ],
                            ),
                          ),
                  ),
                ),
                RadioCheck(
                    text: 'Send the student to an external link',
                    groupValue: hasLink,
                    action: (value) {
                      setState(() {
                        hasLink = value!;
                      });
                    }),
                hasLink
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          children: [
                            RoundedTextField(
                              hint: 'Provide Link',
                              callback: enterLinkCallback,
                              controller: _linkController,
                              focus: pasteFocus,
                              keyboardType: TextInputType.url,
                            ),
                            linkFieldSelected
                                ? InkWell(
                                    onTap: () async {
                                      Clipboard.getData(Clipboard.kTextPlain)
                                          .then((value) {
                                        String newText = value!.text as String;
                                        enterLinkCallback(newText);
                                        _linkController.text = newText;
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Paste from Clipboard',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Icon(Icons.paste,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      )
                    : const SizedBox(
                        height: 0.0,
                      ),
                RoundedButton(
                  title: Text(endFlyerButtonText),
                  action: () async {
                    DateTime? newDate = await showDatePicker(
                      context: context,
                      initialDate: tempEndDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 14)),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData(
                              colorScheme:
                                  Provider.of<TodoData>(context, listen: false)
                                          .darkTheme
                                      ? const ColorScheme.dark()
                                          .copyWith(primary: Colors.white)
                                      : const ColorScheme.light()
                                          .copyWith(primary: Colors.black)),
                          child: child!,
                        );
                      },
                    );
                    if (newDate == null) return;
                    setState(() {
                      tempEndDate = newDate;
                      endFlyerButtonText =
                          'Take down flyer on ${tempEndDate.month}/${tempEndDate.day}/${tempEndDate.year}';
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 32.0),
                  child: RoundedButton(
                    color: Theme.of(context).colorScheme.secondary,
                    action: () async {
                      showDialog(
                        context: context,
                        builder: (context) => submitFlyerPopup(context),
                      );
                    },
                    title: const Text('Submit for Review'),
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
