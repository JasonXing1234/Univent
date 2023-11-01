import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:univent/models/flyer_data.dart';

class ReviewFlyerScreen extends StatefulWidget {
  const ReviewFlyerScreen({Key? key}) : super(key: key);

  static const String id = 'review_flyer_screen';

  @override
  State<ReviewFlyerScreen> createState() => _ReviewFlyerScreenState();
}

class _ReviewFlyerScreenState extends State<ReviewFlyerScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<FlyerData>(context, listen: false).fetchReviews();
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
                  text: 'Flyers to Review',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 35,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Provider.of<FlyerData>(context).reviews.isEmpty
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(20.0),
                    child: Text(
                      'No flyers to review yet',
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
                        await Provider.of<FlyerData>(context, listen: false)
                            .fetchReviews();
                      },
                      child: ListView.builder(
                        itemCount:
                            Provider.of<FlyerData>(context).reviews.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 16.0, 0.0, 0.0),
                                child: Text(
                                    'Submitted by: ${Provider.of<FlyerData>(context).reviews[index].flyerModel.userEmail}'),
                              ),
                              Provider.of<FlyerData>(context).reviews[index],
                            ],
                          );
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
