import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../models/orders.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderItem> _orders = [];
  bool _isLoading = false;
  String _userId = ''; // You'll need to set this from your auth system

  List<OrderItem> get orders => _orders;
  bool get isLoading => _isLoading;

  // Separate getters for current and past orders
  List<OrderItem> get currentOrders => _orders
      .where((order) => order.status != 'delivered')
      .toList();

  List<OrderItem> get pastOrders => _orders
      .where((order) => order.status == 'delivered')
      .toList();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchOrders(String userId) async {

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('orders')
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      _orders = snapshot.docs.map((doc) {
        Map<String, int> menuItems = Map<String, int>.from(doc.data()['menu_items']);

        print("Yessssssssssssssssssss22222222222222222222");
        debugPrint(doc.data().toString());
        return OrderItem(
          id: doc.id,
          userId: doc.data()['user_id'],
          totalCost: doc.data()['total_cost'].toDouble(),
          menuItems: menuItems,
          status: doc.data()['status'],
          timestamp: (doc.data()['timestamp'] as Timestamp).toDate(),
          address: doc.data()['address'],
          phoneNumber: doc.data()['phone_number'],
            additionalNote: doc.data()['additional_note']
        );
      }).toList();


      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error fetching orders: $e');
    }
  }

  void setUserId(String userId) {
    _userId = userId;

  }
}
