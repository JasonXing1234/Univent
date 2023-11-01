import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:univent/components/buttons/rounded_button.dart';

class RemoveIcalLinkScreen extends StatefulWidget {
  const RemoveIcalLinkScreen({Key? key}) : super(key: key);

  static const id = 'remove_ical_link';

  @override
  State<RemoveIcalLinkScreen> createState() => _RemoveIcalLinkScreenState();
}

class _RemoveIcalLinkScreenState extends State<RemoveIcalLinkScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  List<dynamic> links = [];
  List<dynamic> names = [];

  @override
  void initState() {
    super.initState();
    setClassButtons();
  }

  Future<void> getICalLinks() async {
    links = [];
    names = [];
    final ldata = await _firestore
        .collection('ical_links')
        .doc(_auth.currentUser!.uid)
        .get();
    for (var link in ldata.data()!['links'].keys) {
      links.add(link);
    }
    for (var name in ldata.data()!['links'].values) {
      names.add(name);
    }
  }

  List<Widget> listOfClassButtons = [];

  void exitAlert() {
    Navigator.pop(context);
  }

  void setClassButtons() async {
    await getICalLinks();
    setState(() {
      listOfClassButtons = [];
      for (String className in names) {
        listOfClassButtons.add(
          SizedBox(
            width: double.infinity,
            child: RoundedButton(
              action: () {
                showDialog(
                  context: context,
                  builder: (context) => removeClassConfirmationPopup(
                      context, className, links, names),
                );
              },
              title: Text(className),
            ),
          ),
        );
      }
    });
  }

  Widget removeClassConfirmationPopup(BuildContext context, String className,
      List<dynamic> classLinks, List<dynamic> classTitles) {
    return AlertDialog(
      title: const Text('Remove A Class', style: TextStyle(fontSize: 24.0)),
      content: Text('Are you sure you want to remove $className?'),
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
            int classIndex = 0;
            for (String name in classTitles) {
              if (name == className) {
                break;
              }
              classIndex++;
            }
            await _firestore
                .collection('ical_links')
                .doc(_auth.currentUser!.uid)
                .set({
              'links': {classLinks[classIndex]: FieldValue.delete()}
            }, SetOptions(merge: true));
            setClassButtons();
            exitAlert();
          },
          child: Text('Remove $className'),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Click on a class to remove it',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            const SizedBox(
              height: 18.0,
            ),
            Column(
              children: listOfClassButtons,
            )
          ],
        ),
      ),
    );
  }
}
