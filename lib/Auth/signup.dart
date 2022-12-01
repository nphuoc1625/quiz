// ignore_for_file: unused_import, prefer_typing_uninitialized_variables
// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiz/App/app.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  static const routename = "signup";
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  FToast fToast = FToast();
  late TextEditingController _email, _password, _repassword;
  bool _obscure = true;
  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _repassword = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
    _repassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(top: 80, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                textAlign: TextAlign.center,
                "Đăng ký",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.blue[900]),
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: emailAndPassword(),
              ),
              SizedBox(
                height: 10.0,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      minimumSize: Size.fromHeight(50)),
                  onPressed: () async {
                    if (_email.text.isEmpty || _password.text.isEmpty) {
                      Fluttertoast.showToast(
                          toastLength: Toast.LENGTH_SHORT,
                          msg: "Tài khoản hoặc mật khẩu trống! ");
                    } else if (_password.text != _repassword.text) {
                      Fluttertoast.showToast(
                          toastLength: Toast.LENGTH_SHORT,
                          msg: "Nhập lại mật khẩu không khớp");
                    }

                    {
                      try {
                        if (await signup()) {
                          Navigator.pop(context, [_email.text, _password.text]);
                        }
                      } on FirebaseAuthException catch (e) {
                        Fluttertoast.showToast(
                            toastLength: Toast.LENGTH_SHORT, msg: e.code);
                      }
                    }
                    //
                  },
                  child: Text(
                    "Đăng Ký",
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                  )),
              SizedBox(
                height: 10.0,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Quay lại"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> signup() async {
    UserCredential credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: _email.text, password: _password.text);
    if (credential.user != null) {
      return true;
    }
    return false;
  }

  emailAndPassword() {
    return [
      Text(
        "Email",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
      ),
      TextField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          fillColor: Colors.blue[100],
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
          border:
              OutlineInputBorder(borderSide: BorderSide.none, gapPadding: 0),
          hintText: "example@gmail.com",
          hintStyle: TextStyle(
            color: Color.fromARGB(186, 255, 255, 255),
          ),
        ),
        style: TextStyle(fontWeight: FontWeight.w700),
        cursorColor: Colors.white,
      ),
      SizedBox(
        height: 10.0,
      ),
      Text(
        "Mật khẩu",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
      ),
      TextField(
        controller: _password,
        obscureText: _obscure,
        decoration: InputDecoration(
          suffixIcon: IconButton(
              onPressed: () {
                _obscure = !_obscure;
                setState(() {});
              },
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off)),
          fillColor: Colors.blue[100],
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
          border:
              OutlineInputBorder(borderSide: BorderSide.none, gapPadding: 0),
          hintText: "abc123",
          hintStyle: TextStyle(
            color: Color.fromARGB(186, 255, 255, 255),
          ),
        ),
        style: TextStyle(fontWeight: FontWeight.w700),
        cursorColor: Colors.white,
      ),
      SizedBox(
        height: 10.0,
      ),
      Text(
        "Nhập lại Mật khẩu",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
      ),
      TextField(
        controller: _repassword,
        obscureText: _obscure,
        decoration: InputDecoration(
          suffixIcon: IconButton(
              onPressed: () {
                _obscure = !_obscure;
                setState(() {});
              },
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off)),
          fillColor: Colors.blue[100],
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
          border:
              OutlineInputBorder(borderSide: BorderSide.none, gapPadding: 0),
          hintText: "abc123",
          hintStyle: TextStyle(
            color: Color.fromARGB(186, 255, 255, 255),
          ),
        ),
        style: TextStyle(fontWeight: FontWeight.w700),
        cursorColor: Colors.white,
      )
    ];
  }
}
