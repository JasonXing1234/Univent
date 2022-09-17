import 'package:flutter/material.dart';
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: HeaderBar(),
    body: Center(
    child: ElevatedButton(
    child: Text('SHOW HOME PAGE'),
    onPressed: () {
    showAboutDialog(
    context: context,
    applicationIcon: const Icon(
    Icons.local_fire_department,
    color: Colors.blueAccent,
    size: 45.0
    ),
    applicationName: "UNIVENT",
    applicationVersion: '1.0.0',
    applicationLegalese: 'Developed by Univent team'
    );
    },
    )
    ),);}
}