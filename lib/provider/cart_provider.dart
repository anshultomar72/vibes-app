import 'dart:collection';
import 'package:flutter/cupertino.dart';
import '../models/menu_items.dart';

class CartProvider extends ChangeNotifier {
  final Map<MenuItem, int> _items = {};

  UnmodifiableMapView<MenuItem, int> get items => UnmodifiableMapView(_items);

  double get totalPrice => _items.entries
      .fold(0, (sum, entry) => sum + entry.key.price * entry.value);

  int getItemQuantity(MenuItem item) => _items[item] ?? 0;

  void add(MenuItem item) {
    if (_items.containsKey(item)) {
      _items[item] = _items[item]! + 1;
    } else {
      _items[item] = 1;
    }
    notifyListeners();
  }

  void removeItem(MenuItem item) {
    if (_items.containsKey(item) && _items[item]! > 1) {
      _items[item] = _items[item]! - 1;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  void removeAll() {
    _items.clear();
    notifyListeners();
  }
}
