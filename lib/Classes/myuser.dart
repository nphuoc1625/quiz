import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';

class MyUser {
  static final MyUser instance = MyUser._internal();
  String? name, mobile, address, id;
  bool? isadmin;
  LinkedHashMap? favorites;

  void refresh(DataSnapshot ds) {
    id = ds.key;
    name = ds.child("name").value as String;
    mobile = ds.child("mobile").value as String;
    address = ds.child("address").value as String;
    isadmin = ds.child("isAdmin").value as bool;
    if (ds.child("favorites").exists) {
      favorites = ds.child("favorites").value as LinkedHashMap;
    } else {
      favorites = {} as LinkedHashMap?;
    }
  }

  MyUser._internal();
}
