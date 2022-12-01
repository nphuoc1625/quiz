import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:quiz/Classes/User.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});
  static const String routename = "manageusers";
  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers>
    with TickerProviderStateMixin {
  List<User> users = [];
  late TabController _tabController;
  void getUsers() async {
    DataSnapshot ds =
        await FirebaseDatabase.instance.ref().child("users").get();

    for (DataSnapshot s in ds.children) {
      users.add(User.fromDS(s));
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _tabController = TabController(length: 3, vsync: this);
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.add))
            ],
            backgroundColor: Colors.blue[300],
            bottom: TabBar(
              isScrollable: true,
              indicatorColor: Colors.white,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              controller: _tabController,
              tabs: const [
                Tab(child: Text("Tất cả")),
                Tab(child: Text("Admin")),
                Tab(child: Text("Người dùng")),
              ],
            )),
        body: TabBarView(controller: _tabController, children: [
          userByRole(-1),
          userByRole(1),
          userByRole(0),
        ]));
  }

  Widget userByRole(int role) {
    bool isAdmin = false;
    if (role == 1) {
      isAdmin = true;
    } else if (role == 0) {
      isAdmin = false;
    }
    List<User> l;
    if (role == -1) {
      l = users;
    } else {
      l = List.from(users.where((element) => (element.isAdmin! == isAdmin)));
    }

    return ListView.builder(
        itemCount: l.length,
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        actionsAlignment: MainAxisAlignment.start,
                        actions: [
                          TextButton(
                              onPressed: () {}, child: const Text("Edit")),
                          if (l[index].isAdmin!)
                            TextButton(
                                onPressed: () {
                                  switchRole(l[index].id!, false);
                                },
                                child: const Text("Remove Admin")),
                          if (!l[index].isAdmin!)
                            TextButton(
                                onPressed: () {
                                  switchRole(l[index].id!, true);
                                },
                                child: const Text("Set as Admin"))
                        ]);
                  },
                );
              },
              child: Container(
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(blurRadius: 2, color: Colors.grey)
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text("${l[index].id}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text("${l[index].name}"),
                            Text("${l[index].address}")
                            //
                          ])),
                      l[index].isAdmin!
                          ? const Text("Admin")
                          : const Text("User")
                    ],
                  )));
        });
  }

  void switchRole(String id, bool isAdmin) {
    FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(id)
        .child("isAdmin")
        .set(isAdmin);
    users.forEach((element) {
      if (element.id! == id) element.isAdmin = !element.isAdmin!;
    });
    setState(() {});
    Navigator.pop(context);
  }
}
