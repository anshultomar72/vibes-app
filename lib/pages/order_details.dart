import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/orders.dart';
import '../models/menu_items.dart';
import 'package:intl/intl.dart';

import '../provider/cart_provider.dart';
import 'cart_page.dart'; // For formatting date and time

class OrderDetailsPage extends StatefulWidget {
  final OrderItem order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  Map<MenuItem, int> _fetchedItems = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final QuerySnapshot menuItemsSnapshot = await FirebaseFirestore.instance
          .collection('menu_items')
          .where(FieldPath.documentId, whereIn: widget.order.menuItems.keys.toList())
          .get();

      Map<MenuItem, int> fetchedItems = {};
      for (var doc in menuItemsSnapshot.docs) {
        final menuItemData = doc.data() as Map<String, dynamic>;
        MenuItem menuItem = MenuItem.fromMap(menuItemData..['id'] = doc.id);
        fetchedItems[menuItem] = widget.order.menuItems[doc.id] ?? 0;
      }

      setState(() {
        _fetchedItems = fetchedItems;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching menu items: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleOrderAgain(OrderItem order) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    List<String> unavailableItems = [];
    bool hasError = false;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );


      // Clear existing cart
      cartProvider.clearCart();

      // Fetch menu items and check availability
      final QuerySnapshot menuItemsSnapshot = await FirebaseFirestore.instance
          .collection('menu_items')
          .where(FieldPath.documentId, whereIn: order.menuItems.keys.toList())
          .get();

      // Create a map of available menu items
      Map<String, MenuItem> availableMenuItems = {};
      for (var doc in menuItemsSnapshot.docs) {
        final menuItemData = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);

        final enrichedMenuItemData = {
          ...menuItemData,
          'id': doc.id,
        };
        MenuItem menuItem = MenuItem.fromMap(enrichedMenuItemData,);

        if (menuItem.isAvailable) {
          availableMenuItems[menuItem.id] = menuItem;
        } else {
          unavailableItems.add(menuItem.name);
        }
      }

      // Close loading indicator
      Navigator.pop(context);

      // If there are unavailable items, show alert
      if (unavailableItems.isNotEmpty) {
        hasError = true;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Some items are unavailable'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('The following items are currently unavailable:'),
                SizedBox(height: 8),
                ...unavailableItems.map((name) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          size: 16,
                          color: Colors.red[400]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(name,
                            style: TextStyle(color: Colors.grey[800])),
                      ),
                    ],
                  ),
                )),
                SizedBox(height: 12),
                Text(
                  'Available items will be added to your cart.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }

      // Add available items to cart
      Map<String, int> itemsToAdd = {};
      order.menuItems.forEach((itemId, quantity) {
        if (availableMenuItems.containsKey(itemId)) {
          itemsToAdd[itemId] = quantity;
        }
      });

      if (itemsToAdd.isNotEmpty) {
        await cartProvider.addMultipleItems(itemsToAdd);
      }

      // Navigate to cart page only if there are items added
      if (itemsToAdd.isNotEmpty) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=> CartPage()));
      }

    } catch (e) {
      // Close loading indicator if it's showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to process your order. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Address Section
                Text(
                  'Delivery Address',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.order.address,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),

                // Order ID and Timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ID: ${widget.order.id}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(widget.order.timestamp),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(thickness: 1, color: Colors.grey),

                // Items List
                const SizedBox(height: 10),
                ..._fetchedItems.entries.map((entry) {
                  final menuItem = entry.key;
                  final quantity = entry.value;
                  final itemTotal = menuItem.price * quantity;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                menuItem.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${menuItem.price.toStringAsFixed(2)} x $quantity',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${itemTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 12),
                const Divider(thickness: 1, color: Colors.grey),

                // Total Amount Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${widget.order.totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status and Order Again Button Row
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Order Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.order.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getStatusColor(widget.order.status),
                        ),
                      ),
                      child: Text(
                        widget.order.status,
                        style: TextStyle(
                          color: _getStatusColor(widget.order.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Order Again Button
                    ElevatedButton(
                      onPressed: () {
                        _handleOrderAgain(widget.order);

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, // Softer color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Order Again'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to format the timestamp into a readable date and time
  String _formatDateTime(DateTime timestamp) {
    final DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');
    return formatter.format(timestamp);
  }

  // Helper method to get the color based on the order status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'preparing':
        return Colors.orange;
      case 'out for delivery':
        return Colors.blue;
      case 'confirmed':
        return Colors.grey;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
