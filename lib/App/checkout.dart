import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:quiz/App/mycart.dart';
import 'package:quiz/Classes/Book.dart';
import 'package:quiz/Classes/coupon.dart';
import 'package:quiz/Classes/myuser.dart';
import 'package:quiz/Classes/order.dart';

import '../Classes/Cart.dart';

class CheckOut extends StatefulWidget {
  const CheckOut({super.key});
  static const routename = "checkout";
  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  late String address, paymethod, coupon, coupondes;
  int? total = 0;
  double? finaltotal = 0, discount = 0;
  List<Coupon> coupons = [];
  List<Book> books = [];
  bool? hascoupon = false, usemomo = false;
  late ListView listcoupons;

  void getUserCoupons() async {
    DataSnapshot ds = await FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(MyUser.instance.id!)
        .child("coupons")
        .get();
    for (var element in ds.children) {
      coupons.add(Coupon.fromDS(element));
    }
    buildCouponsList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getUserCoupons();
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    address = MyUser.instance.address!;
    paymethod = "Thanh toán khi nhận hàng";
    coupon = "Không dùng";
    coupondes = "";
    LinkedHashMap map =
        ModalRoute.of(context)!.settings.arguments! as LinkedHashMap;
    books = map['books'] as List<Book>;
    total = map['total'];
    calculateFinalTotal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "Thanh toán",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Sách mua",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                  children: List<Widget>.generate(books.length,
                                      (index) {
                                return Column(children: [
                                  SizedBox(
                                      height: 200,
                                      width: 200,
                                      child: books[index].image!)
                                ]);
                              })))),
                      Row(children: const [
                        Text("Địa chỉ: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18))
                      ]),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8)),
                          margin: const EdgeInsets.only(bottom: 8, top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.red),
                                Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(MyUser.instance.address!))),
                                TextButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                                color: Colors.white,
                                                padding:
                                                    const EdgeInsets.all(16),
                                                height: 150,
                                                child: ListView(children: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                          "Mặc định: ${MyUser.instance.address!}"))
                                                ]));
                                          }).then((value) {
                                        setState(() {});
                                      });
                                    },
                                    child: const Text("Thay Đổi"))
                              ])),
                      Row(children: const [
                        Text("Phương thức thanh toán: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18))
                      ]),
                      Container(
                          margin: const EdgeInsets.only(top: 4, bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            const Icon(Icons.payment, color: Colors.red),
                            Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(paymethod))),
                            TextButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                            color: Colors.white,
                                            padding: const EdgeInsets.all(16),
                                            height: 150,
                                            child: ListView(children: [
                                              TextButton(
                                                  onPressed: () {
                                                    paymethod =
                                                        "Thanh toán khi nhận hàng";
                                                    usemomo = false;
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                      "Thanh toán khi nhận hàng")),
                                              TextButton(
                                                  onPressed: () {
                                                    usemomo = true;
                                                    paymethod = "Momo";
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Momo"))
                                            ]));
                                      }).then((value) {
                                    setState(() {});
                                  });
                                },
                                child: const Text("Thay Đổi"))
                          ])),
                      Row(children: const [
                        Text("Mã giảm giá: ",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))
                      ]),
                      Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.payment, color: Colors.red),
                                Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(coupon),
                                              Text(coupondes,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis)
                                            ]))),
                                TextButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Scaffold(
                                              backgroundColor:
                                                  Colors.transparent,
                                              body: Container(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                color: Colors.white,
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: listcoupons),
                                              ),
                                            );
                                          }).then((value) {
                                        setState(() {});
                                      });
                                    },
                                    child: const Text("Thay Đổi"))
                              ])),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Chi tiết thanh toán",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Tổng ban đầu:"),
                                  Text("$total đ",
                                      style: const TextStyle(color: Colors.red))
                                ]),
                            if (hascoupon!)
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Mã giảm giá : "),
                                    Text("- $discount đ",
                                        style:
                                            const TextStyle(color: Colors.red))
                                  ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text("Phí ship"),
                                  Text("+20000 đ",
                                      style: TextStyle(color: Colors.red))
                                ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Tổng cuối"),
                                  Text("$finaltotal",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold))
                                ])
                          ])
                    ]))),
        bottomNavigationBar: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: ElevatedButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.blue;
                  }
                  return null;
                }),
                foregroundColor: const MaterialStatePropertyAll(Colors.white),
                minimumSize: const MaterialStatePropertyAll(Size(250, 60)),
                shape: MaterialStatePropertyAll(ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(40))),
                backgroundColor: const MaterialStatePropertyAll(Colors.blue),
              ),
              onPressed: () {
                if (!usemomo!) {
                  payOnDelivery().then((value) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Thanh toán thành công"),
                          actions: [
                            TextButton(
                                child: const Text("OKE"),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context, "SUCCESS");
                                })
                          ],
                        );
                      },
                    );
                  });
                }
              },
              child: const Text(
                "XÁC NHẬN",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),
        ));
  }

  Future<void> payOnDelivery() async {
    String pushKey =
        FirebaseDatabase.instance.ref().child("orders").push().key!;
    var items = {};
    List<int> counts = (ModalRoute.of(context)!.settings.arguments!
        as LinkedHashMap)['counts'];
    for (int i = 0; i < books.length; i++) {
      items.addAll({books[i].id: counts[i]});
      FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(MyUser.instance.id!)
          .child('cart')
          .child(books[i].id!)
          .remove();
      Cart.instance.removeWhere(books[i].id!);
    }

    print(DateTime.now().toString());

    var order = {
      'userId': MyUser.instance.id,
      'userName': MyUser.instance.name,
      'address': address,
      'total': finaltotal,
      'payMethod': "Khi nhận hàng",
      'state': Order.UNCONFIRMED,
      'time': DateTime.now().toString(),
      'items': items,
      if (hascoupon!) 'coupon': coupon else 'coupon': "none"
    };
    FirebaseDatabase.instance.ref('orders').child(pushKey).set(order);
  }

  void applyCoupon(index) {
    hascoupon = true;
    discount = (total! / 100) * coupons[index].amount;
    calculateFinalTotal();
  }

  void calculateFinalTotal() {
    finaltotal = total! - discount! + 20000;
  }

  void buildCouponsList() {
    listcoupons = ListView.builder(
        reverse: true,
        itemCount: coupons.length + 1,
        itemBuilder: (context, index) {
          if (index == coupons.length) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                  style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(0),
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.blue[100])),
                  onPressed: (() {
                    hascoupon = false;
                    discount = 0;
                    coupon = "Không dùng";
                    calculateFinalTotal();
                    Navigator.pop(context);
                  }),
                  child: const Text("Không dùng")),
            );
          }
          return Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 100,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: GestureDetector(
                onTap: () {
                  applyCoupon(index);
                  coupon = coupons[index].key!;
                  coupondes = coupons[index].discripton!;
                  Navigator.pop(context);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupons[index].key!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(coupons[index].discripton!)
                  ],
                ),
              ));
        });
  }
}
