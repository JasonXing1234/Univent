import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:univent/components/bulletin/flyer_item.dart';
import 'package:univent/models/flyer_model.dart';

class FlyerData extends ChangeNotifier {
  final List<FlyerItem> flyers = [];
  final List<FlyerItem> reviews = [];
  final List<FlyerItem> myFlyers = [];

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void addFlyer(FlyerModel flyer) {
    flyers.add(FlyerItem(flyerModel: flyer));
    notifyListeners();
  }

  void removeFlyer(FlyerModel flyer) {
    flyers.removeWhere((element) => element.flyerModel.uid == flyer.uid);
    notifyListeners();
  }

  void addReview(FlyerModel flyer) {
    reviews.add(FlyerItem(flyerModel: flyer));
    notifyListeners();
  }

  void removeReview(FlyerModel flyer) {
    reviews.removeWhere((element) => element.flyerModel.uid == flyer.uid);
    notifyListeners();
  }

  void addMyFlyer(FlyerModel flyer) {
    myFlyers.add(FlyerItem(flyerModel: flyer));
    notifyListeners();
  }

  void removeMyFlyer(FlyerModel flyer) {
    myFlyers.removeWhere((element) => element.flyerModel.uid == flyer.uid);
    notifyListeners();
  }

  Future<void> fetchFlyers() async {
    flyers.clear();
    await _firestore.collection('flyers').get().then(((value) {
      for (var result in value.docs) {
        flyers.add(
          FlyerItem(
            flyerModel: FlyerModel(
              result.get('uid'),
              result.get('title'),
              result.get('details'),
              result.get('user'),
              result.get('email'),
              result.get('image_url'),
              result.get('location'),
              result.get('post_time').toDate(),
              result.get('event_date').toDate(),
              result.get('rsvp_list'),
              result.get('action_link'),
              result.get('approved'),
            ),
          ),
        );
      }
    }));
    flyers.sort(
        (a, b) => a.flyerModel.eventDate!.compareTo(b.flyerModel.eventDate!));
    notifyListeners();
  }

  Future<void> fetchReviews() async {
    reviews.clear();
    await _firestore.collection('reviews').get().then(((value) {
      for (var result in value.docs) {
        reviews.add(
          FlyerItem(
            flyerModel: FlyerModel(
              result.get('uid'),
              result.get('title'),
              result.get('details'),
              result.get('user'),
              result.get('email'),
              result.get('image_url'),
              result.get('location'),
              result.get('post_time').toDate(),
              result.get('event_date').toDate(),
              result.get('rsvp_list'),
              result.get('action_link'),
              result.get('approved'),
            ),
          ),
        );
      }
    }));
    reviews.sort(
        (a, b) => a.flyerModel.timePosted!.compareTo(b.flyerModel.timePosted!));
    notifyListeners();
  }

  Future<void> fetchMyFlyers() async {
    myFlyers.clear();
    await _firestore.collection('flyers').get().then(((value) {
      for (var result in value.docs) {
        if (result.get('user') == _auth.currentUser?.uid) {
          myFlyers.add(
            FlyerItem(
              flyerModel: FlyerModel(
                result.get('uid'),
                result.get('title'),
                result.get('details'),
                result.get('user'),
                result.get('email'),
                result.get('image_url'),
                result.get('location'),
                result.get('post_time').toDate(),
                result.get('event_date').toDate(),
                result.get('rsvp_list'),
                result.get('action_link'),
                result.get('approved'),
              ),
            ),
          );
        }
      }
    }));
    myFlyers.sort(
        (a, b) => a.flyerModel.eventDate!.compareTo(b.flyerModel.eventDate!));
    notifyListeners();
  }
}
