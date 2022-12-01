import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:quiz/mywidget.dart';

import '../../Classes/order.dart';

class ManageOrders extends StatefulWidget {
  static const String routename = "manageorder";

  const ManageOrders({super.key});

  @override
  State<ManageOrders> createState() => _ManageOrdersState();
}

class _ManageOrdersState extends State<ManageOrders>
    with TickerProviderStateMixin {
  List<Order> orders = [];
  late TabController _tabController;
  void getOrders() async {
    DataSnapshot ds =
        await FirebaseDatabase.instance.ref().child("orders").get();
    for (DataSnapshot s in ds.children) {
      orders.add(Order.fromDS(s));
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _tabController = TabController(length: 5, vsync: this);
    getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
            backgroundColor: Colors.blue[300],
            bottom: TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                controller: _tabController,
                tabs: const [
                  Tab(child: Text("Tất cả")),
                  Tab(child: Text("Chưa xác nhận")),
                  Tab(child: Text("Đang giao")),
                  Tab(child: Text("Đã giao")),
                  Tab(child: Text("Đã hủy")),
                ],
                onTap: (value) {})),
        body: TabBarView(controller: _tabController, children: [
          orderByState(-1),
          orderByState(Order.UNCONFIRMED),
          orderByState(Order.DELIVERING),
          orderByState(Order.DELIVERED),
          orderByState(Order.CANCELED)
        ]));
  }

  Widget orderByState(int orderstate) {
    List<Order> l;
    if (orderstate == -1) {
      l = orders;
    } else {
      l = List.from(orders.where((element) => (element.state! == orderstate)));
    }

    return ListView.builder(
        itemCount: l.length,
        itemBuilder: (context, index) {
          return Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(blurRadius: 2, color: Colors.grey)],
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${l[index].id}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text("${l[index].userName}")
                        ]),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Ngày tạo:"),
                        Text("${l[index].time}"),
                      ],
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Phương thức:"),
                          Text("${l[index].payMethod}")
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tổng:",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          Text("${l[index].total}",
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold))
                        ]),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)),
                          child: Text(MyWidget.textOfState(l[index].state!),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Container()),
                        if (l[index].state != Order.DELIVERED &&
                            l[index].state != 3)
                          GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        actions: [
                                          TextButton(
                                            child: const Text("Hủy"),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          TextButton(
                                              child: const Text("OKE"),
                                              onPressed: () {
                                                orders.forEach((element) {
                                                  if (element.id ==
                                                      l[index].id) {
                                                    element.state =
                                                        element.state! + 1;
                                                    setOrderState(element.id!,
                                                        element.state! + 1);
                                                  }
                                                });

                                                Navigator.pop(context);

                                                setState(() {});
                                              })
                                        ],
                                        title: const Text("Xác nhận ?"),
                                        shape: ContinuousRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      );
                                    });
                              },
                              child: MyWidget.buttonByState(l[index].state!)),
                        if (l[index].state != Order.DELIVERED &&
                            l[index].state != Order.CANCELED)
                          GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        actions: [
                                          TextButton(
                                            child: const Text("Hủy"),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          TextButton(
                                              child: const Text("OKE"),
                                              onPressed: () {
                                                orders.forEach((element) {
                                                  if (element.id ==
                                                      l[index].id) {
                                                    element.state =
                                                        Order.CANCELED;
                                                    setOrderState(element.id!,
                                                        Order.CANCELED);
                                                  }
                                                });
                                                Navigator.pop(context);
                                                setState(() {});
                                              })
                                        ],
                                        title: const Text("Xác nhận ?"),
                                        shape: ContinuousRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      );
                                    });
                              },
                              child: MyWidget.buttonByState(3))
                      ],
                    )
                  ]));
        });
  }

  void setOrderState(String id, int state) {
    FirebaseDatabase.instance
        .ref()
        .child("orders")
        .child(id)
        .child("state")
        .set(state);
  }
}
