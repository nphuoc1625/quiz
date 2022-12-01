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

import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FToast fToast = FToast();
  late TextEditingController _email, _password;
  bool? saved = false;
  bool _obscure = true;
  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    checkIfSaved();
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  Future<File> getFile() async {
    Directory dir = await getApplicationDocumentsDirectory();
    return File(dir.path + "/logincred.txt");
  }

  void saveinfo() async {
    File file = await getFile();
    file.create();
    IOSink write = file.openWrite();
    write.writeln(_email.text);
    write.writeln(_password.text);
  }

  void checkIfSaved() async {
    File file = await getFile();
    if (await file.exists()) {
      List<String> read = await file.readAsLines();
      saved = true;
      _email.text = read.elementAt(0);
      _password.text = read.elementAt(1);
      setState(() {});
    }
  }

  void deleteInfo() async {
    File file = await getFile();
    if (await file.exists()) file.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
          height: double.infinity,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: 80, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  "Đăng nhập",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.blue[900]),
                ),
                SizedBox(height: 50),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: emailAndPassword(),
                ),
                Container(
                    width: double.infinity,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: saved,
                              onChanged: (value) {
                                setState(() {
                                  saved = !saved!;
                                });
                              },
                              activeColor: Colors.blue,
                              checkColor: Colors.white,
                            ),
                            Text(
                              "Lưu thông tin",
                            )
                          ],
                        ),
                        TextButton(
                            onPressed: () {},
                            style: ButtonStyle(shadowColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.blue;
                                }
                                return Colors.red;
                              },
                            )),
                            child: Text(
                              "Quên mật khẩu ?",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.right,
                            )),
                      ],
                    )),
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
                        showtoast("Tài khoản hoặc mật khẩu trống! ");
                      } else {
                        UserCredential credential = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: _email.text, password: _password.text);
                        if (credential.user != null) {
                          DataSnapshot ds = await FirebaseDatabase.instance
                              .ref()
                              .child("users")
                              .child(credential.user!.uid)
                              .get();
                          if (ds.exists) {
                            // ignore: use_build_context_synchronously
                            Navigator.popAndPushNamed(context, App.routename);
                          } else {
                            // ignore: use_build_context_synchronously
                            Navigator.popAndPushNamed(context, 'setinfo');
                          }
                        }
                        deleteInfo();
                        saveinfo();
                      }
                      //
                    },
                    child: Text(
                      "Đăng nhập ",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Chưa có tài khoản ? "),
                    TextButton(
                        onPressed: () async {
                          pushSignUp(context);
                        },
                        child: Text("Đăng ký",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )))
                  ],
                )
              ],
            ),
          )),
    );
  }

  Future<void> pushSignUp(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    if (await Navigator.pushNamed(context, SignUpScreen.routename) != null) {
      var result = await Navigator.pushNamed(context, SignUpScreen.routename)
          as List<String>;

      if (!mounted) return;

      // After the Selection Screen returns a result, hide any previous snackbars
      // and show the new result.
      _email.text = result.elementAt(0);
      _password.text = result.elementAt(1);
      setState(() {});
    }

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
  }

  void showtoast(String text) {
    Fluttertoast.showToast(msg: text, toastLength: Toast.LENGTH_SHORT);
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
        height: 20.0,
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
      )
    ];
  }
}
