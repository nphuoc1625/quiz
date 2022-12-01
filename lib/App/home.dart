import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz/App/booklist.dart';
import 'package:quiz/App/mycart.dart';
import 'package:quiz/App/searchpage.dart';
import 'package:quiz/Classes/myuser.dart';

import '../Classes/Book.dart';
import '../Classes/Cart.dart';
import 'bookdetail.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin<Home> {
  bool _showbadge = false;
  late Text _textCartcount = const Text("");
  late List<Widget> books_trend;
  late List<Widget> books_new;
  bool loading = true;
  bool selected = true;

  Route createSearchRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SearchPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  Widget makeItem(Book book) {
    return Container(
      width: 160,
      height: 250,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(6)),
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, BookDetail.routeName,
                    arguments: book.id!)
                .then((value) {
              setState(() {});
            });
          },
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: book.image!,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      book.title!,
                    ),
                  ),
                  Text(
                    "đ ${book.price!}",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              if (book.isSale!)
                Container(
                  alignment: Alignment.topRight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("- ${book.discount!}%",
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
            ],
          )),
    );
  }

  void getData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();

    //get trending
    DataSnapshot ds = await ref.child("books").limitToFirst(6).get();
    if (ds.exists) {
      loading = false;
      books_trend = List.empty(growable: true);

      for (DataSnapshot i in ds.children) {
        Book book = Book.lite(i);
        book.image = await Book.getimage(book.imageLinks!);
        books_trend.add(makeItem(book));
        setState(() {});
      }
    }
    //get trending
    ds = await ref
        .child("books")
        .orderByChild("publishedDate")
        .limitToFirst(6)
        .get();
    if (ds.exists) {
      books_new = List.empty(growable: true);
      for (DataSnapshot i in ds.children) {
        Book book = Book.lite(i);
        book.image = await Book.getimage(book.imageLinks!);
        books_new.add(makeItem(book));
        setState(() {});
      }
      // books_new = books_new.reversed.toList();
    }
  }

  void getuser() async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);
    DataSnapshot ds = await ref.get();
    MyUser.instance.refresh(ds);
  }

  void getCart() async {
    DataSnapshot ds = await FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("cart")
        .get();
    if (ds.exists) {
      Cart.instance.create(ds);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    //Listener for cart change
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    books_trend = List.generate(3, (index) {
      return AnimatedContainer(
        width: 170,
        height: 220,
        margin: const EdgeInsets.only(left: 10),
        duration: const Duration(seconds: 2),
        color: selected ? Colors.grey[100] : Colors.blue[300],
        curve: Curves.linear,
      );
    });
    books_new = books_trend;

    setState(() {
      createSearchRoute();
      getuser();
      getData();
      getCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(slivers: [
      SliverAppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark,
              statusBarColor: Colors.white),
          snap: true,
          floating: true,
          title: TextButton.icon(
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.grey[100]),
                  overlayColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.grey[300]!;
                    }
                    return null;
                  }),
                  alignment: Alignment.centerLeft,
                  minimumSize:
                      const MaterialStatePropertyAll(Size.fromHeight(30)),
                  shape: const MaterialStatePropertyAll(
                      ContinuousRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20))))),
              onPressed: () =>
                  Navigator.pushNamed(context, SearchPage.routeName)
                      .then((value) {
                    setState(() {});
                  }),
              icon: const Icon(Icons.search, color: Colors.black),
              label: const Text("Bạn muốn tìm gì ?",
                  style: TextStyle(color: Colors.black))),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: Badge(
                position: BadgePosition.topEnd(end: 0, top: 0),
                animationType: BadgeAnimationType.slide,
                badgeContent: Cart.instance.cartcount,
                showBadge: Cart.instance.showbadge,
                child: IconButton(
                    onPressed: () async {
                      Navigator.pushNamed(context, MyCart.routename)
                          .then((value) => setState(() {}));
                    },
                    icon: const Icon(Icons.shopping_cart)),
              ),
            )
          ]),
      SliverToBoxAdapter(
          child: Column(children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                  offset: Offset(0, 4), color: Colors.blue, blurRadius: 5),
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, BookList.routename,
                    arguments: {"type": "sale"}).then((value) {
                  setState(() {});
                });
              },
              child: Image.network(
                  "https://static.vecteezy.com/system/resources/previews/002/661/111/original/super-sale-banner-in-pop-blue-background-sales-promotion-background-illustration-vector.jpg"),
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
                style: ButtonStyle(
                    padding: const MaterialStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                    overlayColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.grey[300]!;
                      }
                      return null;
                    }),
                    minimumSize:
                        const MaterialStatePropertyAll(Size.fromHeight(30)),
                    shape: const MaterialStatePropertyAll(
                        ContinuousRectangleBorder())),
                onPressed: () {},
                icon: SizedBox(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                      Text("Thịnh hành",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Icon(
                        Icons.more_horiz,
                        size: 30,
                      )
                    ])))),

        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: books_trend,
            )),
        //Moi nhat
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
                style: ButtonStyle(
                    padding: const MaterialStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                    overlayColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.grey[300]!;
                      }
                      return null;
                    }),
                    minimumSize:
                        const MaterialStatePropertyAll(Size.fromHeight(30)),
                    shape: const MaterialStatePropertyAll(
                        ContinuousRectangleBorder())),
                onPressed: () {},
                icon: SizedBox(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                      Text("Mới ra",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Icon(
                        Icons.more_horiz,
                        size: 30,
                      )
                    ])))),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: books_new,
            ))
      ]))
    ]);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}
