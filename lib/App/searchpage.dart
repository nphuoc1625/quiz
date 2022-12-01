import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Classes/Book.dart';
import 'bookdetail.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  static final String routeName = "search";
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchvalue = TextEditingController();
  List<Book> books = [];

  @override
  void initState() {
    super.initState();
  }

  void search() async {
    books = [];
    DataSnapshot ds = await FirebaseDatabase.instance
        .ref()
        .child("books")
        .orderByChild("title")
        .startAt(_searchvalue.text)
        .get();
    if (ds.exists || ds.children.isNotEmpty) {
      for (var element in ds.children) {
        Book book = Book.lite(element);
        book.image = await Book.getimage(book.imageLinks!);
        books.add(book);
        setState(() {});
      }
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            body: CustomScrollView(slivers: [
          SliverAppBar(
            title: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: TextField(
                onEditingComplete: () {
                  search();
                },
                onChanged: (value) {
                  if (value.isEmpty) {
                    books = [];
                    setState(() {});
                  }
                },
                controller: _searchvalue,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 10),
                    hintText: "Bạn tìm kiếm sản phẩm gì ?"),
                autofocus: true,
              ),
            ),
            titleSpacing: 0,
            leadingWidth: 50,
            actions: [
              IconButton(
                  onPressed: () {
                    search();
                  },
                  icon: const Icon(Icons.search))
            ],
          ),
          SliverGrid(
              delegate: SliverChildBuilderDelegate(childCount: books.length,
                  (context, index) {
                if (books.isEmpty) return const Text("Nhập gì đó");
                return Container(
                    height: 150,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6)),
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.all(8),
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, BookDetail.routeName,
                              arguments: books[index].id!);
                        },
                        child: Stack(children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                        alignment: Alignment.bottomCenter,
                                        child: books[index].image!)),
                                Text(
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    books[index].title!),
                                Text("đ ${books[index].price!}",
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ))
                              ]),
                          if (books[index].isSale!)
                            Container(
                                alignment: Alignment.topRight,
                                child: DecoratedBox(
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                          "- ${books[index].discount!}%",
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    )))
                        ])));
              }),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 8,
                  childAspectRatio: 1 / 1.4,
                  crossAxisCount: 2))
        ])));
  }
}
