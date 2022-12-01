// ignore_for_file: prefer_final_fields

import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:quiz/App/mycart.dart';
import 'package:quiz/Classes/cart_item.dart';
import 'package:quiz/Classes/comment.dart';
import 'package:quiz/Classes/myuser.dart';
import '../Classes/book.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../Classes/Cart.dart';

class BookDetail extends StatefulWidget {
  const BookDetail({super.key});
  static const String routeName = "bookdetail";

  @override
  State<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  var book = Book();
  late Widget image;

  String? title, author, language, cate, des;
  int? pageCount, price;
  double? averageRating;
  //comment
  List<Widget> listComment = [];
  List<Comment> comments = [];
  //Bagde
  //User
  bool _favorite = false;

  var _count = 1;
  TextEditingController _comment = TextEditingController();
  bool _visible = true;

  void getdata(String id) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child("books").child(id);
    DataSnapshot ds = await ref.get();

    if (ds.exists) {
      book = Book.full(ds);
      String url = await FirebaseStorage.instance
          .ref("books")
          .child(book.imageLinks!)
          .getDownloadURL();

      image = CarouselSlider.builder(
          itemCount: 3,
          itemBuilder: ((context, index, realIndex) {
            return Image.network(url);
          }),
          options: CarouselOptions());

      //Check if liked
      FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(MyUser.instance.id!)
          .child("favorites")
          .child(book.id!)
          .get()
          .then((value) {
        if (value.exists) _favorite = true;
        setState(() {});
      });

      price = book.price;
      title = book.title;
      author = book.authors;
      averageRating = book.averageRating;
      language = book.language;
      cate = book.categories;
      des = book.description;

      setState(() {});
    }
  }

  void getcomment(id) {
    FirebaseDatabase.instance
        .ref()
        .child("rates")
        .child(id)
        .get()
        .then((value) {
      for (DataSnapshot i in value.children) {
        if (i.key == MyUser.instance.id) {
          _visible = false;
        }
        comments.add(Comment.fromDS(i));
      }
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    image = const SizedBox(
      width: 100,
      height: 100,
    );
    price = 0;
    title = "Tựa đề";
    averageRating = 5.0;
    language = "vi";
    cate = "Thể loại";
    des = "Mô tả";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var id = ModalRoute.of(context)!.settings.arguments! as String;
    getdata(id);
    getcomment(id);
  }

  @override
  Widget build(BuildContext context) {
    Scaffold scaffold = Scaffold(
      backgroundColor: Colors.blue[300],
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: CustomScrollView(slivers: [
          SliverAppBar.large(
              pinned: false,
              expandedHeight: 300,
              stretch: true,
              backgroundColor: Colors.blue[300],
              flexibleSpace: Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Center(
                  child: image,
                ),
              ),
              systemOverlayStyle:
                  const SystemUiOverlayStyle(statusBarColor: Colors.white),
              scrolledUnderElevation: 0,
              title: const Text("Chi tiết"),
              centerTitle: true,
              actions: [
                Badge(
                  position: BadgePosition.topEnd(end: 0, top: 0),
                  animationType: BadgeAnimationType.slide,
                  badgeContent: Cart.instance.cartcount,
                  showBadge: Cart.instance.showbadge,
                  child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, MyCart.routename)
                            .then((value) {
                          setState(() {});
                        });
                      },
                      icon: const Icon(Icons.shopping_cart)),
                ),
              ]),
          SliverToBoxAdapter(
              child: Center(
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                      alignment: Alignment.center,
                      child:
                          Container(width: 80, height: 4, color: Colors.grey)),

                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "đ: ",
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 16),
                                  ),
                                  Text(
                                    "$price",
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(
                                child: Text(
                                  "$title",
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                "$author",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              _favorite = !_favorite;
                              if (_favorite) {
                                FirebaseDatabase.instance
                                    .ref("users")
                                    .child(
                                        FirebaseAuth.instance.currentUser!.uid)
                                    .child("favorites")
                                    .child(book.id!)
                                    .set("liked");
                              } else {
                                FirebaseDatabase.instance
                                    .ref("users")
                                    .child(
                                        FirebaseAuth.instance.currentUser!.uid)
                                    .child("favorites")
                                    .child(book.id!)
                                    .remove();
                              }

                              setState(() {});
                            },
                            icon: Icon(
                              color: Colors.pink,
                              _favorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border,
                              size: 35,
                            )),
                      ]),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(4)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text("Đánh giá"),
                              Text(
                                "$averageRating",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          Container(
                            color: Colors.grey,
                            width: 1,
                            height: 20,
                          ),
                          Column(
                            children: [
                              const Text("Ngôn ngữ"),
                              Text(
                                "$language",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            color: Colors.grey,
                            width: 1,
                            height: 20,
                          ),
                          Column(
                            children: [
                              const Text("Thể loại"),
                              Text(
                                "$cate",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "$des",
                    style: const TextStyle(
                        fontSize: 16, color: Color.fromARGB(255, 95, 95, 95)),
                  ),
                  //
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0, bottom: 16),
                    child: Text(
                      "Đánh giá",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Visibility(
                      visible: _visible,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 7,
                                child: TextField(
                                  controller: _comment,
                                )),
                            const VerticalDivider(
                              color: Colors.transparent,
                              thickness: 8,
                            ),
                            Expanded(
                                flex: 3,
                                child: TextButton(
                                    style: ButtonStyle(
                                        shape: const MaterialStatePropertyAll(
                                            ContinuousRectangleBorder()),
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.grey[200])),
                                    onPressed: () {
                                      Comment cmt = Comment(
                                          name: MyUser.instance.name,
                                          rate: 3.3,
                                          comment: _comment.text);
                                      FirebaseDatabase.instance
                                          .ref()
                                          .child("rates")
                                          .child(book.id!)
                                          .child(MyUser.instance.id!)
                                          .set(cmt.toMap());
                                      _visible = false;
                                      comments.add(cmt);
                                      setState(() {});
                                    },
                                    child: const Text("Thêm")))
                          ],
                        ),
                      )),
                  Column(
                    children: List<Widget>.generate(comments.length, (index) {
                      return Column(children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${comments[index].name}",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text("${comments[index].comment}")
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        const Divider(
                          thickness: 1,
                        )
                      ]);
                    }),
                  )
                ],
              ),
            ),
          ))
        ]),
      ),
      bottomNavigationBar: Container(
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(blurRadius: 6, offset: Offset(0, 4), color: Colors.grey),
          ]),
          height: 80,
          width: 500,
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "SL",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              if (_count > 1) _count--;
                            });
                          },
                          icon: const CircleAvatar(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.black,
                            child: Icon(Icons.horizontal_rule),
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "$_count",
                          style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              if (_count < 100) _count++;
                            });
                          },
                          icon: const CircleAvatar(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.black,
                            child: Icon(Icons.add),
                          ))
                    ],
                  ),
                ),
              ),
              const VerticalDivider(
                color: Colors.white,
                thickness: 8,
              ),
              Expanded(
                flex: 3,
                child: TextButton(
                  style: ButtonStyle(
                      minimumSize:
                          const MaterialStatePropertyAll(Size(150, 50)),
                      shape: MaterialStatePropertyAll(ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                      backgroundColor:
                          const MaterialStatePropertyAll(Colors.amber)),
                  child: const Text(
                    "Add to Cart",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    addToCart();
                    setState(() {});
                  },
                ),
              ),
            ],
          )),
    );

    //
    return scaffold;
  }

  void addToCart() {
    Cart.instance.add(CartItem(id: book.id!, count: _count));

    FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("cart")
        .child(book.id!)
        .set(Cart.instance.items
            .where((element) {
              if (element.id == book.id!) {
                return true;
              }
              return false;
            })
            .first
            .count);
    _count = 1;
    setState(() {});
  }
}
