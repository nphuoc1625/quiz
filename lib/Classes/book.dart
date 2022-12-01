import 'dart:collection';

import "package:firebase_database/firebase_database.dart";
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';

class Book {
  late String? publishedDate,
      description,
      language,
      publisher,
      categories,
      authors,
      id,
      title,
      imageLinks;
  late double? averageRating;
  late int? price, sale, pageCount, discount;
  late bool? isSale;
  late Image? image;
  Book(
      {this.id,
      this.title,
      this.publishedDate,
      this.description,
      this.language,
      this.publisher,
      this.pageCount,
      this.averageRating,
      this.price,
      this.authors,
      this.isSale,
      this.sale,
      this.discount,
      this.imageLinks,
      this.categories,
      this.image});

  factory Book.lite(DataSnapshot ds) {
    int sale = 0;
    int price = ds.child("price").value as int;
    int discount = 0;
    if ((ds.child("isSale").value as bool)) {
      sale = ds.child("sale").value as int;
      discount = 100 - ((sale / price) * 100).toInt();
      price = sale;
    }

    return Book(
        id: ds.key as String,
        imageLinks: ds.child("imageLinks").value as String,
        title: ds.child("title").value as String,
        averageRating: ds.child("averageRating").value as double,
        isSale: ds.child("isSale").value as bool,
        price: price,
        discount: discount);
  }
  static Future<Image> getimage(String imagename) async {
    String url = await FirebaseStorage.instance
        .ref("books")
        .child(imagename)
        .getDownloadURL();
    return Image.network(
      url,
      fit: BoxFit.fitHeight,
    );
  }

  factory Book.full(DataSnapshot ds) {
    int sale = 0;
    int price = ds.child("price").value as int;
    int discount = 0;
    if ((ds.child("isSale").value as bool)) {
      sale = ds.child("sale").value as int;
      discount = sale ~/ price;
      price = sale;
    }
    return Book(
        id: ds.key as String,
        title: ds.child("title").value as String,
        averageRating: double.parse(ds.child("averageRating").value.toString()),
        price: price,
        authors: ds.child("authors").value as String,
        categories: ds.child("categories").value as String,
        description: ds.child("description").value as String,
        language: ds.child("language").value as String,
        pageCount: ds.child("pageCount").value as int,
        publishedDate: ds.child("publishedDate").value as String,
        publisher: ds.child("publisher").value as String,
        sale: sale,
        discount: discount,
        imageLinks: ds.child("imageLinks").value as String,
        isSale: ds.child("isSale").value as bool);
  }
}
