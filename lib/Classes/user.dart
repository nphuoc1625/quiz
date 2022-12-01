import 'package:firebase_database/firebase_database.dart';

class User {
  String? id, name, mobile, address;
  bool? isAdmin;
  User({
    this.id,
    this.name,
    this.isAdmin,
    this.mobile,
    this.address,
  });
  factory User.fromDS(DataSnapshot ds) {
    return User(
        id: ds.key,
        isAdmin: ds.child("isAdmin").value as bool,
        name: ds.child("name").value as String,
        mobile: ds.child("mobile").value as String,
        address: ds.child("address").value as String);
  }
}
