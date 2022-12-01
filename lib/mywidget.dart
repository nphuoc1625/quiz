import 'package:flutter/material.dart';

import 'Classes/order.dart';

class MyWidget {
  static String textOfState(int state) {
    switch (state) {
      case Order.UNCONFIRMED:
        {
          return "Chưa xác nhận";
        }
      case Order.DELIVERING:
        {
          return "Đang giao";
        }
      case Order.DELIVERED:
        {
          return "Đã giao";
        }
      case Order.CANCELED:
        {
          return "Đã hủy";
        }

      default:
        return "";
    }
  }

  static Widget buttonByState(int state) {
    String title = "";
    switch (state) {
      case Order.UNCONFIRMED:
        {
          title = "Xác nhận đơn";
          break;
        }
      case Order.DELIVERING:
        {
          title = "Xác nhận";
          break;
        }
      case Order.CANCELED:
        {
          title = "Hủy";
          break;
        }
      default:
    }

    return Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(color: Colors.red),
        child: Text(
          title,
          style: const TextStyle(color: Colors.yellow),
        ));
  }
}
