import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';

class Order {
  static const UNCONFIRMED = 0;
  static const DELIVERING = 1;
  static const DELIVERED = 2;
  static const CANCELED = 3;

  String? id, userId, payMethod, coupon, time, address, userName;
  int? state, total;
  Map? items;

  Order(
      {this.id,
      this.userId,
      this.userName,
      this.payMethod,
      this.coupon,
      this.state,
      this.address,
      this.total,
      this.items,
      this.time});

  factory Order.fromDS(DataSnapshot ds) {
    return Order(
        id: ds.key,
        userId: ds.child("userId").value as String,
        userName: ds.child("userName").value as String,
        payMethod: ds.child("payMethod").value as String,
        coupon: (ds.child("coupon").exists
            ? ds.child("coupon").value as String
            : ""),
        address: (ds.child("address").exists
            ? ds.child("address").value as String
            : ""),
        state: ds.child("state").value as int,
        total: ds.child("total").value as int,
        time: ds.child("time").exists ? ds.child("time").value as String : "",
        items: ds.child("items").value as Map);
  }
}
