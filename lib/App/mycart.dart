import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quiz/App/bookdetail.dart';
import 'package:quiz/App/checkout.dart';
import 'package:quiz/Classes/cart_item.dart';

import '../Classes/Book.dart';
import '../Classes/Cart.dart';
import '../Classes/myuser.dart';

class MyCart extends StatefulWidget {
  const MyCart({super.key});
  static const String routename = "cart";

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  bool _all = false;

  Cart cart = Cart.instance;
  late List<Book> books = [];
  late List<bool> checkedindex = [];
  int total = 0;

  Future<void> getUserCart() async {
    //check if user have cartItem
    if (Cart.instance.items.isNotEmpty) {
      DataSnapshot ds = await FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(MyUser.instance.id!)
          .child("cart")
          .get();

      for (int i = 0; i < ds.children.length; i++) {
        DataSnapshot data = await FirebaseDatabase.instance
            .ref()
            .child("books")
            .child(ds.children.elementAt(i).key!)
            .get();
        Book book = Book.lite(data);
        book.image = await Book.getimage(book.imageLinks!);
        books.add(book);
        if (mounted) setState(() {});
      }
    }
  }

  void decreaseItem(int i) {
    cart.items[i].count--;
    FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(MyUser.instance.id!)
        .child("cart")
        .child(cart.items.elementAt(i).id)
        .set(cart.items.elementAt(i).count);
    setState(() {});
    calculateTotal();
  }

  void increaseitem(int i) {
    cart.items[i].count++;
    FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(MyUser.instance.id!)
        .child("cart")
        .child(cart.items.elementAt(i).id)
        .set(cart.items.elementAt(i).count);
    setState(() {});
    calculateTotal();
  }

  void calculateTotal() {
    total = 0;
    for (int i = 0; i < checkedindex.length; i++) {
      if (checkedindex[i]) {
        total += books[i].price! * cart.items[i].count;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    getUserCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (books.isNotEmpty)
            TextButton(
                onPressed: () {
                  setState(() {
                    for (int i = 0; i < checkedindex.length; i++) {
                      if (checkedindex[i]) {
                        FirebaseDatabase.instance
                            .ref()
                            .child("users")
                            .child(MyUser.instance.id!)
                            .child("cart")
                            .child(cart.items[i].id)
                            .remove();

                        books.removeAt(i);
                        cart.remove(i);
                      }
                    }
                    checkedindex.removeWhere((i) => i = true);
                  });
                },
                child: const Text(
                  "Xóa",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ))
        ],
      ),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          return makeItem(context, index);
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 16),
        height: 80,
        color: Colors.tealAccent,
        child: Row(
          children: [
            TextButton.icon(
              style: const ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll(Colors.black),
                  overlayColor: MaterialStatePropertyAll(Colors.black12),
                  shape: MaterialStatePropertyAll(ContinuousRectangleBorder())),
              onPressed: () {
                _all = !_all;
                for (int i = 0; i < checkedindex.length; i++) {
                  checkedindex[i] = _all;
                }
                calculateTotal();
                setState(() {});
              },
              icon: Icon(_all
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank),
              label: const Text("Tất cả"),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Tổng:"),
                  Text(
                    "$total",
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
            SizedBox(
              width: 150,
              height: 80,
              child: ElevatedButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.blue;
                      }
                    }),
                    foregroundColor:
                        const MaterialStatePropertyAll(Colors.white),
                    shape: const MaterialStatePropertyAll(
                        ContinuousRectangleBorder()),
                    backgroundColor:
                        const MaterialStatePropertyAll(Colors.blue),
                  ),
                  onPressed: () {
                    if (checkedindex.contains(true)) {
                      List<Book> checkoutbook = [];
                      List<int> counts = [];
                      for (int i = 0; i < checkedindex.length; i++) {
                        if (checkedindex[i]) {
                          checkoutbook.add(books.elementAt(i));
                          counts.add(cart.items[i].count);
                        }
                      }
                      Map<String, dynamic> arg = {
                        "books": checkoutbook,
                        "counts": counts,
                        "total": total
                      };
                      Navigator.pushNamed(context, CheckOut.routename,
                              arguments: arg)
                          .then((value) {
                        if (value == 'SUCCESS') Navigator.pop(context);
                      });
                    } else {
                      Fluttertoast.showToast(
                          msg: "Chọn ít nhất 1 món hàng",
                          toastLength: Toast.LENGTH_SHORT);
                    }
                  },
                  child: const Text("Thanh toán")),
            ),
          ],
        ),
      ),
    );
  }

  Container makeItem(BuildContext context, int index) {
    checkedindex.add(false);

    return Container(
      height: 140,
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.only(top: 10),
      child: Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Checkbox(
              value: checkedindex[index],
              onChanged: ((value) {
                checkedindex[index] = !checkedindex[index];
                calculateTotal();
                setState(() {});
              })),

          /// Item Image
          SizedBox(
            width: 80,
            child: books[index].image!,
          ),
          const VerticalDivider(
            thickness: 4,
            color: Colors.transparent,
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, BookDetail.routeName,
                                arguments: books[index].id)
                            .then((value) => setState(() {}));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            books[index].title!,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "đ ${books[index].price}",
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      style: const ButtonStyle(
                          shape: MaterialStatePropertyAll(CircleBorder())),
                      onPressed: () {
                        if (cart.items[index].count > 1) {
                          setState(() {
                            decreaseItem(index);
                          });
                        }
                      },
                      child: const Icon(Icons.horizontal_rule),
                    ),
                    Text(
                      "${cart.items[index].count}",
                      style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      style: const ButtonStyle(
                          shape: MaterialStatePropertyAll(CircleBorder())),
                      onPressed: () {
                        if (cart.items[index].count < 100) {
                          increaseitem(index);
                        }
                      },
                      child: const Icon(Icons.add),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
