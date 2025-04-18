import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vibes_app/pages/cart_page.dart';
import 'package:vibes_app/pages/order_details.dart';
import 'package:vibes_app/provider/cart_provider.dart';
import 'package:vibes_app/provider/user_provider.dart';

import '../models/menu_items.dart';
import '../models/orders.dart';
import '../provider/order_provider.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUserDetails();
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      print(userProvider.user_uuid);
      orderProvider.fetchOrders(userProvider.user_uuid);
    });
  }

  Widget _buildOrderCard(OrderItem order) {
    Color statusColor;
    switch (order.status.toLowerCase()) {
      case 'preparing':
        statusColor = Colors.orange;
        break;
      case 'out for delivery':
        statusColor = Colors.blue;
        break;
      case 'confirmed':
        statusColor = Colors.grey;
        break;
      case 'delivered':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    Future<void> _handleOrderAgain() async {
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

    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => OrderDetailsPage(order: order,)));
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('dd').format(order.timestamp),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(order.timestamp),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order id: ${order.id.substring(0, 8)}',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${order.menuItems.values.reduce((a, b) => a + b)} items',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${order.totalCost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey[300]),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.toLowerCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _handleOrderAgain,
                    icon: Icon(
                      Icons.replay,
                      color: Colors.deepOrange,
                      size: 20,
                    ),
                    label: Text(
                      'Order Again',
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (orderProvider.orders.isEmpty) {
            return Center(child: Text('No orders found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (orderProvider.currentOrders.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Orders in process',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  ...orderProvider.currentOrders.map(_buildOrderCard),
                ],
                if (orderProvider.pastOrders.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'Past Orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  ...orderProvider.pastOrders.map(_buildOrderCard),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}