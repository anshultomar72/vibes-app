import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/menu_items.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, int> _items = {};
  final Map<String, MenuItem> _menuItemsById = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CartProvider() {
    loadCartData(); // Load cart data when the provider is instantiated
  }

  UnmodifiableMapView<String, int> get items => UnmodifiableMapView(_items);
  UnmodifiableMapView<String, MenuItem> get menuItemsById => UnmodifiableMapView(_menuItemsById);


  double get totalPrice => _items.entries.fold(0, (sum, entry) {
    MenuItem? menuItem = _menuItemsById[entry.key]; // Get the MenuItem by ID
    if (menuItem != null) {
      return sum + menuItem.price * entry.value; // Calculate total price
    }
    return sum;
  });
  int get count => _items.length;
  int get itemCount => _items.values.fold(0, (sum, quantity) => sum + quantity);

  int getItemQuantity(MenuItem item) => _items[item.id] ?? 0;

  void addItem(MenuItem item) {
    _menuItemsById[item.id] = item; // Store the MenuItem by its ID
    if (_items.containsKey(item.id)) {
      _items[item.id] = _items[item.id]! + 1;
    } else {
      _items[item.id] = 1;
    }
    saveCartData();
    notifyListeners();
  }

  void removeItem(MenuItem item) {
    if (_items.containsKey(item.id) && _items[item.id]! > 1) {
      _items[item.id] = _items[item.id]! - 1;
    } else {
      _items.remove(item.id);
      _menuItemsById.remove(item.id); // Remove MenuItem reference if quantity is zero
    }
    saveCartData();
    notifyListeners();
  }

  void removeAll() {
    _items.clear();
    _menuItemsById.clear(); // Clear both the items and the menu item references
    saveCartData();
    notifyListeners();
  }

  Future<void> saveCartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert _items and _menuItemsById to Maps
    Map<String, dynamic> cartData = _items.map((key, value) =>
        MapEntry(key, {'quantity': value, 'item': _menuItemsById[key]?.toMap()})
    );

    prefs.setString('cart', jsonEncode(cartData));
  }

  Future<void> loadCartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cartData = prefs.getString('cart');
    if (cartData != null) {
      Map<String, dynamic> decoded = jsonDecode(cartData);
      _items.clear();
      _menuItemsById.clear();

      decoded.forEach((id, itemData) {
        MenuItem menuItem = MenuItem.fromMap(itemData['item']);
        _items[id] = itemData['quantity'];
        _menuItemsById[id] = menuItem;
      });

      notifyListeners();
    }
  }
  void clearCart() {
    _items.clear();
    _menuItemsById.clear();
    saveCartData();
    notifyListeners();  // Notify listeners that the cart is cleared
  }
  Future<void> addItemById(String itemId, int quantity) async {
    if (quantity <= 0) return; // Don't add if quantity is 0 or negative

    try {
      // Fetch the menu item from Firebase
      DocumentSnapshot menuItemDoc = await _firestore
          .collection('menu_items')
          .doc(itemId)
          .get();

      if (!menuItemDoc.exists) {
        print('Menu item not found: $itemId');
        return;
      }

      // Convert the document data to a MenuItem object
      MenuItem menuItem = MenuItem.fromMap(
          Map<String, dynamic>.from(menuItemDoc.data() as Map<String, dynamic>)
      );

      // Check if the item is available
      if (!menuItem.isAvailable) {
        print('Menu item is not available: $itemId');
        return;
      }

      // Store the MenuItem by its ID
      _menuItemsById[itemId] = menuItem;

      // Update quantity
      if (_items.containsKey(itemId)) {
        _items[itemId] = _items[itemId]! + quantity;
      } else {
        _items[itemId] = quantity;
      }

      await saveCartData();
      notifyListeners();
    } catch (e) {
      print('Error adding item to cart: $e');
      // You might want to rethrow the error or handle it differently
      throw Exception('Failed to add item to cart: $e');
    }
  }

  // Modify addMultipleItems to fetch from Firebase as well
  Future<void> addMultipleItems(Map<String, int> items) async {
    try {
      // Clear existing cart first
      clearCart();

      // Fetch all menu items at once for better performance
      List<String> itemIds = items.keys.toList();
      QuerySnapshot menuItemsSnapshot = await _firestore
          .collection('menu_items')
          .where(FieldPath.documentId, whereIn: itemIds)
          .get();

      // Convert documents to MenuItem objects and store them
      for (var doc in menuItemsSnapshot.docs) {
        final menuItemData = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);

        final enrichedMenuItemData = {
          ...menuItemData,
          'id': doc.id,
        };
        MenuItem menuItem = MenuItem.fromMap(enrichedMenuItemData,);

        // Only add if the item is available
        if (menuItem.isAvailable) {
          _menuItemsById[menuItem.id] = menuItem;
          _items[menuItem.id] = items[menuItem.id] ?? 0;
        }
      }

      await saveCartData();
      notifyListeners();
    } catch (e) {
      print('Error adding multiple items to cart: $e');
      throw Exception('Failed to add items to cart: $e');
    }
  }
}
