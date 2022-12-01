import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quiz/App/admin/manageuser.dart';
import 'package:quiz/App/app.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:quiz/App/admin/manageorder.dart';

class ProfileScreen extends App {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  _ProfileScreenState();
  late var image;
  String name = "username";
  var isAdmin = false;

  @override
  void initState() {
    super.initState();

    image = const Icon(Icons.supervised_user_circle);

    getCurrentUser();
  }

  getCurrentUser() async {
    DataSnapshot ds = await FirebaseDatabase.instance
        .ref("users")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .get();
    name = ds.child("name").value as String;
    isAdmin = ds.child("isAdmin").value as bool;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonstyle = ButtonStyle(
        alignment: Alignment.centerLeft,
        shape: const MaterialStatePropertyAll(ContinuousRectangleBorder()),
        minimumSize: const MaterialStatePropertyAll(Size.fromHeight(40)),
        backgroundColor: MaterialStateProperty.all(Colors.grey[200]!));

    Widget widget = Scaffold(
        body: CustomScrollView(slivers: [
      SliverAppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark,
              statusBarColor: Colors.white),
          actions: [
            Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                title: const Text('Đăng xuất ?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Hủy'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                      child: const Text('Xác nhận'),
                                      onPressed: () {
                                        FirebaseAuth.instance.signOut();
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            "login",
                                            (route) => route.isCurrent);
                                      })
                                ]);
                          });
                    }))
          ],
          backgroundColor: Colors.lightBlue[200],
          title: Text(name),
          pinned: true,
          leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: image,
                onPressed: () {},
              ))),
      SliverList(
          delegate: SliverChildListDelegate([
        if (isAdmin)
          Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    child: const Text("Quản lý: ",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold))),
                Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16),
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton.icon(
                              icon: const Icon(Icons.menu_book),
                              style: buttonstyle,
                              onPressed: () => (() {}),
                              label: const Text(" Quản lý thông tin hàng hóa")),
                          TextButton.icon(
                              icon: const Icon(Icons.person_rounded),
                              style: buttonstyle,
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, ManageUsers.routename);
                              },
                              label: const Text(" Quản lý người dùng")),
                          TextButton.icon(
                              icon: const Icon(Icons.list_alt),
                              style: buttonstyle,
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, ManageOrders.routename);
                              },
                              label: const Text(" Quản lý đơn hàng"))
                        ]))
              ]),
        const Divider(),
        GestureDetector(
            onTap: () {},
            child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                          onPressed: () {},
                          icon: const Text("Đơn hàng của tôi",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          label: const Icon(Icons.arrow_forward_ios))
                    ]))),
        const Divider(),
      ]))
    ]));
    return widget;
  }
}
