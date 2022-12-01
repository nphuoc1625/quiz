import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../App/app.dart';

class SetInfo extends StatefulWidget {
  const SetInfo({super.key});
  static const routename = "setinfo";
  @override
  State<SetInfo> createState() => _SetInfoState();
}

class _SetInfoState extends State<SetInfo> {
  late TextEditingController _name, _address, _mobile;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _name = TextEditingController();
    _address = TextEditingController();
    _mobile = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Đặt thông tin cơ bản",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Text(
              "Họ và tên",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            TextField(
              controller: _name,
              decoration: InputDecoration(
                fillColor: Colors.blue[100],
                filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                border: const OutlineInputBorder(
                    borderSide: BorderSide.none, gapPadding: 0),
                hintText: "Nguyễn Văn A",
                hintStyle: const TextStyle(
                  color: Color.fromARGB(186, 255, 255, 255),
                ),
              ),
              style: const TextStyle(fontWeight: FontWeight.w700),
              cursorColor: Colors.white,
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              "Địa chỉ",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            TextField(
              controller: _address,
              decoration: InputDecoration(
                fillColor: Colors.blue[100],
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                border: const OutlineInputBorder(
                    borderSide: BorderSide.none, gapPadding: 0),
                hintText: "abc123",
                hintStyle: const TextStyle(
                  color: Color.fromARGB(186, 255, 255, 255),
                ),
              ),
              style: const TextStyle(fontWeight: FontWeight.w700),
              cursorColor: Colors.white,
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              "Số điện thoại",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: _mobile,
              decoration: InputDecoration(
                fillColor: Colors.blue[100],
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                border: const OutlineInputBorder(
                    borderSide: BorderSide.none, gapPadding: 0),
                hintText: "abc123",
                hintStyle: const TextStyle(
                  color: Color.fromARGB(186, 255, 255, 255),
                ),
              ),
              style: const TextStyle(fontWeight: FontWeight.w700),
              cursorColor: Colors.white,
            ),
            const SizedBox(
              height: 10.0,
            ),
            Center(
              child: ElevatedButton(
                  style: ButtonStyle(
                      foregroundColor:
                          const MaterialStatePropertyAll(Colors.white),
                      minimumSize:
                          const MaterialStatePropertyAll(Size(100, 40)),
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.lightBlue[300])),
                  onPressed: () {
                    if (!(_name.text.isEmpty ||
                        _address.text.isEmpty ||
                        _mobile.text.isEmpty)) {
                      FirebaseDatabase.instance
                          .ref("users")
                          .child(FirebaseAuth.instance.currentUser!.uid)
                          .set({
                        "name": _name.text,
                        "isadmin": false,
                        "address": _address.text,
                        "mobile": _mobile.text
                      }).whenComplete(() => {
                                Navigator.popAndPushNamed(
                                    context, App.routename)
                              });
                    } else {
                      Fluttertoast.showToast(msg: "Xin điền đầy đủ thông tin");
                    }
                  },
                  child: const Text("Lưu")),
            )
          ],
        ),
      ),
    );
  }
}
