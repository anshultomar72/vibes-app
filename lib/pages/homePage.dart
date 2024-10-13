import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0, // Removes shadow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 20),

            // Menu Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMenuTab('Menu'),
                _buildMenuTab('Burger'),
                _buildMenuTab('Pizza'),
                _buildMenuTab('Dessert'),
              ],
            ),
            const SizedBox(height: 20),

            // Promotions Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Today's Offer",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Free box of Fries',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'on all orders above ₹150',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Popular Items Section
            const Text(
              'Popular',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPopularItem('Burger', '₹ 120', 'images/burger.png'),
                _buildPopularItem(
                    'Pizza Fries', '₹ 120', 'images/pizza_fries.png'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
Widget _buildMenuTab(String title) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

Widget _buildPopularItem(String title, String price, String imagePath) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(price),
    ],
  );
}
