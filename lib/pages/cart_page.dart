import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';
import '../models/menu_items.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final double deliveryFee = 85.00;
  final double platformFee = 6.00;
  final double gstCharges = 11.08;
  final double extraDiscount = 25.00;
  String selectedAddress = "Home";

  // Theme colors
  final Color backgroundColor = const Color(0xFF2C2C2C);
  final Color cardColor = const Color(0xFF3D3D3D);
  final Color textColor = const Color(0xFFE0E0E0);
  final Color secondaryTextColor = const Color(0xFFB0B0B0);
  final Color accentColor = const Color(0xFF4CAF50);
  final Color dividerColor = const Color(0xFF505050);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_rounded, color: textColor),
        ),
        title: Text(
          "Cart",
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.count == 0) {
            return Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(color: textColor),
              ),
            );
          }

          double itemTotal = cartProvider.totalPrice;
          double finalTotal = itemTotal + deliveryFee + platformFee + gstCharges - extraDiscount;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.25,
                  ),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: cartProvider.items.length + 1,
                        itemBuilder: (context, index) {
                          if (index == cartProvider.items.length) {
                            return _buildAddMoreItems();
                          }
                          String itemId = cartProvider.items.keys.elementAt(index);
                          MenuItem item = cartProvider.menuItemsById[itemId]!;
                          int quantity = cartProvider.items[itemId]!;
                          return _buildCartItem(item, quantity, cartProvider);
                        },
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: cardColor,
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bill Details",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: 12),
                            _buildBillRow("Item Total", "₹${itemTotal.toStringAsFixed(2)}"),
                            _buildBillRow("Delivery Fee ", "₹$deliveryFee"),
                            Padding(
                              padding: EdgeInsets.only(left: 24),
                              child: Text(
                                "Enjoy Discounted Delivery!",
                                style: TextStyle(color: secondaryTextColor, fontSize: 12),
                              ),
                            ),
                            _buildBillRow(
                              "Extra discount for you",
                              "-₹$extraDiscount",
                              valueColor: accentColor,
                            ),
                            _buildBillRow("Platform fee", "₹$platformFee"),
                            _buildBillRow("GST and Restaurant Charges", "₹$gstCharges"),
                            Divider(color: dividerColor),
                            _buildBillRow(
                              "To Pay",
                              "₹${finalTotal.toStringAsFixed(2)}",
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildAddressAndPayment(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(MenuItem item, int quantity, CartProvider cartProvider) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(color: accentColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.circle, color: accentColor, size: 12),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
                ),
                Text(
                  "₹${item.price}",
                  style: TextStyle(fontSize: 14, color: secondaryTextColor),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: dividerColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, size: 18, color: textColor),
                  onPressed: () => cartProvider.removeItem(item),
                ),
                Text('$quantity', style: TextStyle(color: textColor)),
                IconButton(
                  icon: Icon(Icons.add, size: 18, color: textColor),
                  onPressed: () => cartProvider.addItem(item),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreItems() {
    return Container(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "Type cooking requests",
              style: TextStyle(color: textColor),
            ),
            trailing: Icon(Icons.chevron_right, color: textColor),
            onTap: () {
              // Show cooking instructions dialog
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: secondaryTextColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? textColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressAndPayment() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // Show address selection dialog
            },
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, color: textColor),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Delivery at $selectedAddress",
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),

                    ],
                  ),
                ),
                Text(
                  "Change",
                  style: TextStyle(color: accentColor),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle order placement
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Place Cash Order | ₹277",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}