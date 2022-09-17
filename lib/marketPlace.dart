import 'package:flutter/material.dart';
class MarketplacePage extends StatelessWidget {
  const MarketplacePage({Key? key}) : super(key: key);
  static const String routeName = '/marketplace';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: HeaderBar(),
      body: Center(
          child: ElevatedButton(
            child: Text('SHOW MARKETPLACE PAGE'),
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