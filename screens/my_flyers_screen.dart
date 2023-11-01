import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:univent/models/flyer_data.dart';
import 'package:univent/models/flyer_model.dart';

class MyFlyersScreen extends StatefulWidget {
  const MyFlyersScreen({Key? key}) : super(key: key);

  static const String id = 'my_flyers_screen';

  @override
  State<MyFlyersScreen> createState() => _MyFlyersScreenState();
}

class _MyFlyersScreenState extends State<MyFlyersScreen> {
  bool isRefresh = false;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    if (Provider.of<FlyerData>(context, listen: false).myFlyers.isEmpty) {
      isRefresh = true;
      Provider.of<FlyerData>(context, listen: false).fetchMyFlyers();
      isRefresh = false;
    }
  }

  void exitAlert() {
    Navigator.pop(context);
  }

  Widget approveDeleteFlyerPopup(BuildContext context, FlyerModel flyerModel) {
    return AlertDialog(
      title: const Text('Delete Flyer', style: TextStyle(fontSize: 24.0)),
      content: const Text(
          'Are you sure you want to delete this flyer? This action cannot be undone.'),
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
            Provider.of<FlyerData>(context, listen: false)
                .removeFlyer(flyerModel);
            Provider.of<FlyerData>(context, listen: false)
                .removeMyFlyer(flyerModel);
            _firestore.collection('flyers').doc(flyerModel.uid).delete();
            _storage
                .ref()
                .child('flyers')
                .child('${flyerModel.uid}.jpg')
                .delete();
            exitAlert();
          },
          child: const Text('Delete'),
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
          child: Text(
            'univent',
            style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: 'My Flyers',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 35,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Provider.of<FlyerData>(context).myFlyers.isEmpty || isRefresh
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(20.0),
                    child: Text(
                      'You have not posted any flyers yet',
                      style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.secondary),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Expanded(
                    child: RefreshIndicator(
                      color: Colors.black,
                      backgroundColor: Colors.white,
                      onRefresh: () async {
                        isRefresh = true;
                        await Provider.of<FlyerData>(context, listen: false)
                            .fetchMyFlyers();
                        isRefresh = false;
                      },
                      child: ListView.builder(
                          itemCount:
                              Provider.of<FlyerData>(context).myFlyers.length,
                          itemBuilder: (context, index) {
                            return Provider.of<FlyerData>(context)
                                    .myFlyers
                                    .isNotEmpty
                                ? Stack(
                                    children: [
                                      Provider.of<FlyerData>(context)
                                          .myFlyers
                                          .elementAt(index),
                                      Positioned(
                                        left: 0.0,
                                        top: 0.0,
                                        child: FloatingActionButton(
                                          heroTag: '$index',
                                          mini: true,
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          onPressed: () {
                                            FlyerModel flyerModel =
                                                Provider.of<FlyerData>(context,
                                                        listen: false)
                                                    .myFlyers
                                                    .elementAt(index)
                                                    .flyerModel;
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    approveDeleteFlyerPopup(
                                                        context, flyerModel));
                                          },
                                          child: const Icon(Icons.remove),
                                        ),
                                      )
                                    ],
                                  )
                                : const SizedBox(height: 0.0);
                          }),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
