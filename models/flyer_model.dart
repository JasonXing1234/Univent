class FlyerModel {
  String uid;
  String title;
  String postDetails;
  String userID;
  String userEmail;
  String? photoURL;
  String? location;
  DateTime? timePosted;
  DateTime? eventDate;
  List<dynamic> rsvpList;
  String? actionLink;
  bool approved;

  FlyerModel(
    this.uid,
    this.title,
    this.postDetails,
    this.userID,
    this.userEmail,
    this.photoURL,
    this.location,
    this.timePosted,
    this.eventDate,
    this.rsvpList,
    this.actionLink,
    this.approved,
  );
}
