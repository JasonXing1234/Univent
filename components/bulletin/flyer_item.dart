import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:univent/models/flyer_data.dart';
import 'package:univent/models/flyer_model.dart';
import 'package:univent/models/todo_data.dart';
import 'package:url_launcher/url_launcher.dart';

class FlyerItem extends StatefulWidget {
  const FlyerItem({Key? key, required this.flyerModel}) : super(key: key);

  final FlyerModel flyerModel;

  @override
  State<FlyerItem> createState() => _FlyerItemState();
}

class _FlyerItemState extends State<FlyerItem> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  bool goSelected = false;

  @override
  void initState() {
    goSelected = widget.flyerModel.rsvpList.contains(_auth.currentUser?.uid);
    super.initState();
  }

  void exitAlert() {
    Navigator.pop(context);
  }

  Widget approveFlyerPopup(BuildContext context) {
    return AlertDialog(
      title: const Text('Approve Flyer', style: TextStyle(fontSize: 24.0)),
      content: const Text(
          'Are you sure you want to approve this flyer? Be sure to check that the provided link is safe before approving it.'),
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
            _firestore
                .collection('reviews')
                .doc(widget.flyerModel.uid)
                .delete();
            Provider.of<FlyerData>(context, listen: false)
                .removeReview(widget.flyerModel);
            widget.flyerModel.approved = true;
            _firestore.collection('flyers').doc(widget.flyerModel.uid).set({
              'uid': widget.flyerModel.uid,
              'rsvp_list': widget.flyerModel.rsvpList,
              'details': widget.flyerModel.postDetails,
              'post_time': widget.flyerModel.timePosted,
              'user': widget.flyerModel.userID,
              'email': widget.flyerModel.userEmail,
              'image_url': widget.flyerModel.photoURL,
              'title': widget.flyerModel.title,
              'location': widget.flyerModel.location,
              'event_date': widget.flyerModel.eventDate,
              'action_link': widget.flyerModel.actionLink,
              'approved': widget.flyerModel.approved
            });
            Provider.of<FlyerData>(context, listen: false)
                .addFlyer(widget.flyerModel);
            exitAlert();
          },
          child: const Text('Approve'),
        ),
      ],
    );
  }

  Widget rejectFlyerPopup(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject Flyer', style: TextStyle(fontSize: 24.0)),
      content: const Text('Are you sure you want to reject this flyer?'),
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
            _firestore
                .collection('reviews')
                .doc(widget.flyerModel.uid)
                .delete();
            _storage
                .ref()
                .child('flyers')
                .child('${widget.flyerModel.uid}.jpg')
                .delete();
            Provider.of<FlyerData>(context, listen: false)
                .removeReview(widget.flyerModel);
            exitAlert();
          },
          child: const Text('Reject'),
        ),
      ],
    );
  }

  void selectGo() {
    if (widget.flyerModel.approved) {
      if (goSelected) {
        setState(() {
          goSelected = false;
          widget.flyerModel.rsvpList.remove(_auth.currentUser!.uid);
        });
        _firestore.collection('flyers').doc(widget.flyerModel.uid).update({
          'rsvp_list': FieldValue.arrayRemove([_auth.currentUser?.uid])
        });
      } else {
        if (widget.flyerModel.actionLink != null) {
          if (widget.flyerModel.actionLink!.isNotEmpty) {
            launchUrl(Uri.parse(widget.flyerModel.actionLink!),
                mode: LaunchMode.inAppWebView);
          }
        }
        setState(() {
          goSelected = true;
          widget.flyerModel.rsvpList.add(_auth.currentUser!.uid);
        });
        _firestore.collection('flyers').doc(widget.flyerModel.uid).update({
          'rsvp_list': FieldValue.arrayUnion([_auth.currentUser?.uid])
        });
      }
    } else {
      if (widget.flyerModel.actionLink != null) {
        if (widget.flyerModel.actionLink!.isNotEmpty) {
          launchUrl(Uri.parse(widget.flyerModel.actionLink!),
              mode: LaunchMode.inAppWebView);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Provider.of<TodoData>(context).darkTheme
                  ? const Color.fromARGB(255, 75, 75, 75)
                  : Colors.black,
              width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(32.0)),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32.0),
                    topRight: Radius.circular(32.0)),
                child: CachedNetworkImage(
                  key: ValueKey(widget.flyerModel.photoURL!),
                  fit: BoxFit.cover,
                  maxHeightDiskCache: 700,
                  imageUrl: widget.flyerModel.photoURL!,
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
                  errorWidget: (context, url, error) => const Center(
                    child: Text('Unable to load image...'),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0.0, 8.0),
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            selectGo();
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(32.0)),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                              child: Row(
                                children: [
                                  Text(
                                    'GO',
                                    style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        color: goSelected
                                            ? Colors.green
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                  ),
                                  Transform.scale(
                                    scale: 1.5,
                                    child: Checkbox(
                                      value: goSelected,
                                      onChanged: (value) {
                                        selectGo();
                                      },
                                      checkColor: Colors.green,
                                      fillColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.transparent),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      widget.flyerModel.approved
                          ? Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
                              child: IconButton(
                                onPressed: () async {
                                  // TODO: INCREMENT SHARE COUNT
                                  var file = await DefaultCacheManager()
                                      .getSingleFile(
                                          widget.flyerModel.photoURL!);
                                  XFile result = XFile(file.path);
                                  Share.shareXFiles([result],
                                      text:
                                          'Check this out! Download Univent to see more: https://univent.io');
                                },
                                icon: const Icon(
                                  CupertinoIcons.paperplane,
                                  size: 32.0,
                                ),
                              ),
                            )
                          : const SizedBox(width: 0.0)
                    ],
                  ),
                  widget.flyerModel.approved &&
                          widget.flyerModel.userID == _auth.currentUser?.uid
                      ? Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0),
                          child: Column(
                            children: [
                              const Text(
                                'RSVPs',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${widget.flyerModel.rsvpList.length}',
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        )
                      : !widget.flyerModel.approved
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 8.0),
                                  child: FloatingActionButton(
                                    elevation: 0.0,
                                    heroTag: 'Approve-${widget.flyerModel.uid}',
                                    backgroundColor: Colors.green,
                                    child: const Icon(
                                      Icons.check,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            approveFlyerPopup(context),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 8.0),
                                  child: FloatingActionButton(
                                    elevation: 0.0,
                                    heroTag: 'Reject-${widget.flyerModel.uid}',
                                    backgroundColor: Colors.red,
                                    child: const Icon(
                                      Icons.close,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            rejectFlyerPopup(context),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(width: 0.0),
                ],
              )
            ]),
      ),
    );
  }
}
