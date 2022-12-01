// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quiz/App/booklist.dart';
import 'package:quiz/App/home.dart';
import './profile.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);
  static const routename = "app";

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  bool firstback = false;
  var _selectedindex = 0;
  PageController _pageController = PageController();
  late List<Widget> bodychildren;
  late List<Widget> categories = List.empty(growable: true);

  //
  void getCategories() async {
    DataSnapshot ds =
        await FirebaseDatabase.instance.ref().child("categories").get();
    for (DataSnapshot i in ds.children) {
      categories.add(
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, BookList.routename,
                arguments: {"type": "cate", "value": i.value as String});
          },
          child: Text(
            i.value as String,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
      categories.add(Divider(thickness: 1));
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    // getuser();
    getCategories();
    // getCart();
    setbodychildren();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (firstback) {
          return true;
        } else {
          firstback = true;
          Fluttertoast.showToast(msg: "Press back again to exit");
          Future.delayed(Duration(seconds: 2), () {
            firstback = false;
          });
        }
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: bodychildren,
        ),
        bottomNavigationBar: Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              selectedIconTheme: IconThemeData(size: 30, color: Colors.amber),
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black,
              unselectedLabelStyle: TextStyle(fontSize: 14),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore_rounded),
                  label: 'Trang chủ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category_outlined),
                  activeIcon: Icon(Icons.category),
                  label: 'Thể loại',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Tôi',
                ),
              ],
              onTap: (value) {
                _selectedindex = value;
                _pageController.jumpToPage(_selectedindex);
                setState(() {});
              },
              currentIndex: _selectedindex,
            )),
      ),
    );
  }

  void setbodychildren() {
    bodychildren = [
      Home(),
      Center(
          widthFactor: double.infinity,
          heightFactor: double.infinity,
          child: ListView(
            children: categories,
          )),
      ProfileScreen()
    ];
  }
}
