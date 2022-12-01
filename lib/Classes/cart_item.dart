class CartItem {
  late String id;
  late int count;
  CartItem({required this.id, required this.count});
  void increase() {
    count++;
  }

  void decrease() {
    count--;
  }
}
