import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';

class Comment {
  String? userid, comment, name;
  num? rate;
  Comment({this.userid, this.comment, this.rate, this.name});
  factory Comment.fromDS(DataSnapshot ds) {
    return Comment(
        userid: ds.key,
        name: ds.child("name").value as String,
        comment: ds.child("comment").value as String,
        rate: (ds.child("rate").value as num));
  }
  LinkedHashMap toMap() {
    LinkedHashMap map = LinkedHashMap();
    map['name'] = name;
    map['comment'] = comment;
    map['rate'] = rate;
    return map;
  }
}
