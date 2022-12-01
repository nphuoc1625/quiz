import 'package:firebase_database/firebase_database.dart';

class Coupon {
  String? key, discripton;
  double amount;
  Coupon(this.key, this.discripton, this.amount);
  factory Coupon.fromDS(DataSnapshot ds) {
    String key = ds.key!;
    String discription = ds.child("discription").value as String;
    double amount = (ds.child("amount").value as int).toDouble();
    return Coupon(key, discription, amount);
  }
}
