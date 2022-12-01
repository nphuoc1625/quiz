import 'package:badges/badges.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quiz/Classes/cart_item.dart';

class Cart {
  static final Cart instance = Cart._();
  Cart._();

  List<CartItem> items = List.empty(growable: true);
  bool showbadge = false;
  Widget cartcount = const Text("");
  Badge badge = Badge();

  void create(DataSnapshot ds) {
    showbadge = true;
    cartcount = Text("${ds.children.length}");
    items = List.empty(growable: true);
    if (ds.children.isNotEmpty) {
      for (DataSnapshot i in ds.children) {
        items.add(CartItem(id: i.key!, count: i.value as int));
      }
    }
  }

  void add(CartItem item) {
    var has = false;
    for (CartItem i in items) {
      if (i.id == (item.id)) {
        i.count += item.count;
        has = true;
        break;
      }
    }
    if (!has) items.add(item);
    showbadge = true;
    cartcount = Text("${items.length}");
  }

  void remove(int index) {
    items.removeAt(index);
    if (items.isEmpty) {
      showbadge = false;
    }
    cartcount = Text("${items.length}");
  }

  void removeWhere(String id) {
    items.removeWhere((element) => element.id == id);
    if (items.isEmpty) {
      showbadge = false;
    }
    cartcount = Text("${items.length}");
  }
}
