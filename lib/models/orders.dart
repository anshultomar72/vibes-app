import 'package:vibes_app/models/menu_items.dart';

class OrderItem {
  final String id;
  final String userId;
  final double totalCost;
  final Map<String,int> menuItems;
  final String status;
  final DateTime timestamp;
  final String address;
  final String phoneNumber;
  final String additionalNote;

  OrderItem({
    required this.id,
    required this.totalCost,
    required this.menuItems,
    required this.status,
    required this.userId,
    required this.timestamp,
    required this.address,
    required this.phoneNumber,
    required this.additionalNote,
  });
  }