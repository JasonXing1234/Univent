import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:univent/models/flyer_data.dart';

class BulletinScreen extends StatefulWidget {
  const BulletinScreen({Key? key}) : super(key: key);

  static const String id = 'bulletin_screen';

  @override
  State<BulletinScreen> createState() => _BulletinScreenState();
}

class _BulletinScreenState extends State<BulletinScreen> {
  bool isRefresh = false;

  @override
  void initState() {
    super.initState();
    if (Provider.of<FlyerData>(context, listen: false).flyers.isEmpty) {
      isRefresh = true;
      Provider.of<FlyerData>(context, listen: false).fetchFlyers();
      isRefresh = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Provider.of<FlyerData>(context).flyers.isEmpty || isRefresh
          ? Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20.0),
              child: Text(
                'No flyers have been posted yet',
                style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.secondary),
                textAlign: TextAlign.center,
              ),
            )
          : RefreshIndicator(
              color: Colors.black,
              backgroundColor: Colors.white,
              onRefresh: () async {
                isRefresh = true;
                await Provider.of<FlyerData>(context, listen: false)
                    .fetchFlyers();
                isRefresh = false;
              },
              child: ListView.builder(
                itemCount: Provider.of<FlyerData>(context).flyers.length,
                itemBuilder: (context, index) => Provider.of<FlyerData>(context)
                        .flyers
                        .isNotEmpty
                    ? Provider.of<FlyerData>(context).flyers.elementAt(index)
                    : const SizedBox(height: 0.0),
              ),
            ),
    );
  }
}
