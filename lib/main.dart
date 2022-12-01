// ignore_for_file: prefer_const_constructors, unused_import

import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:quiz/App/admin/manageuser.dart';
import 'package:quiz/App/booklist.dart';
import 'package:quiz/App/checkout.dart';
import 'package:quiz/App/admin/manageorder.dart';
import 'package:quiz/App/searchpage.dart';
import 'package:quiz/Auth/setinfo.dart';
import 'package:quiz/Classes/Book.dart';
import 'package:quiz/App/bookdetail.dart';
import 'package:quiz/Auth/signup.dart';
import 'App/mycart.dart';
import 'firebase_options.dart';

import 'package:quiz/Auth/signin.dart';
import 'package:quiz/App/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.black,
      useMaterial3: true,
      textTheme: GoogleFonts.montserratTextTheme(),
    ),
    debugShowCheckedModeBanner: false,
    initialRoute: 'welcome',
    routes: {
      '/': (context) => App(),
      'welcome': (context) => WelcomeScreen(),
      'login': (context) => LoginScreen(),
      'bookdetail': (context) => BookDetail(),
      App.routename: (context) => App(),
      MyCart.routename: (context) => MyCart(),
      SearchPage.routeName: (context) => SearchPage(),
      SignUpScreen.routename: (context) => SignUpScreen(),
      SetInfo.routename: (context) => SetInfo(),
      BookList.routename: (context) => BookList(),
      CheckOut.routename: (context) => CheckOut(),
      ManageOrders.routename: (context) => ManageOrders(),
      ManageUsers.routename: (context) => ManageUsers()
    },
  ));
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(seconds: 0), () {
        if (FirebaseAuth.instance.currentUser != null) {
          Fluttertoast.showToast(
              msg:
                  "Welcome back ${FirebaseAuth.instance.currentUser!.displayName}",
              toastLength: Toast.LENGTH_SHORT);
          Navigator.popAndPushNamed(context, App.routename);
        } else {
          Navigator.of(context).popAndPushNamed("login");
        }
      });
    });
    Container screen = Container(
        alignment: Alignment.center,
        color: Color.fromARGB(255, 0, 140, 255),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Welcome",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                decoration: TextDecoration.none,
              ),
            )
          ],
        ));

    return screen;
  }
}
