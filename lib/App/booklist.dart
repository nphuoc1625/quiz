import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

import '../Classes/Book.dart';
import 'bookdetail.dart';

class BookList extends StatefulWidget {
  const BookList({super.key});
  static const routename = "booklist";

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  late List<Book> booklist = [];

  bool byalpha = false;

  Widget makeItem(BuildContext context, int index) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(6)),
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, BookDetail.routeName,
                arguments: booklist[index].id!);
          },
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: booklist[index].image!,
                    ),
                  ),
                  Text(
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    booklist[index].title!,
                  ),
                  Text(
                    "đ ${booklist[index].price!}",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              if (booklist[index].isSale!)
                Container(
                  alignment: Alignment.topRight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("- ${booklist[index].discount!}%",
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
            ],
          )),
    );
  }

  void makeList(DataSnapshot ds) async {
    booklist = [];
    for (DataSnapshot i in ds.children) {
      Book book = Book.lite(i);
      await Book.getimage(book.imageLinks!).then((v) {
        book.image = v;
        booklist.add(book);
      }).whenComplete(() {
        setState(() {});
      });
    }
  }

  void getSaleBook() async {
    DataSnapshot ds = await FirebaseDatabase.instance
        .ref()
        .child("books")
        .orderByChild("isSale")
        .equalTo(true)
        .get();
    makeList(ds);
  }

  void getBookByCategory(String s) async {
    DataSnapshot ds = await FirebaseDatabase.instance
        .ref()
        .child("books")
        .orderByChild("categories")
        .equalTo(s)
        .get();
    makeList(ds);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    var arg =
        ModalRoute.of(context)!.settings.arguments! as Map<String, dynamic>;

    if (arg['type'] == "cate") {
      getBookByCategory(arg['value']);
    } else if (arg['type'] == "sale") {
      getSaleBook();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.lightBlue[300],
            scrolledUnderElevation: 0,
            pinned: true,
            actions: [
              IconButton(
                  onPressed: () {
                    byalpha = !byalpha;
                    booklist = booklist.reversed.toList();
                    setState(() {});
                  },
                  icon: byalpha
                      ? Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white)),
                          child: const Text("Z-a"),
                        )
                      : const Text("a-Z")),
            ],
          ),
          SliverGrid(
              delegate: SliverChildBuilderDelegate(childCount: booklist.length,
                  (context, index) {
                if (booklist.isEmpty) return const Text("Loading");
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6)),
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, BookDetail.routeName,
                            arguments: booklist[index].id!);
                      },
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.bottomCenter,
                                  child: booklist[index].image!,
                                ),
                              ),
                              Text(
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                booklist[index].title!,
                              ),
                              Text(
                                "đ ${booklist[index].price!}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                          if (booklist[index].isSale!)
                            Container(
                              alignment: Alignment.topRight,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text("- ${booklist[index].discount!}%",
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ),
                              ),
                            ),
                        ],
                      )),
                );
              }),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 8,
                  childAspectRatio: 1 / 1.4,
                  crossAxisCount: 2))
          // Slivergrid(delegate: SliverChildListDelegate(booklist))
        ],
      ),
    );
  }
}
