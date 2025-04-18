import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibes_app/pages/favourite_page.dart';
import 'package:vibes_app/pages/homePage.dart';
import 'package:vibes_app/pages/login.dart';
import 'package:vibes_app/pages/order_history.dart';
import 'package:vibes_app/pages/saved_addresses.dart';
import '../pages/BottomNavigationBar.dart';
import '../pages/profile_page.dart';
import '../provider/cart_provider.dart';
import '../provider/user_provider.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Drawer(
      child: Container(
        color: Colors.black87,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.deepOrange, Colors.orange],
                ),
              ),
              accountName: Text(
                userProvider.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(
                userProvider.email,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(userProvider.profileImageUrl),
                onBackgroundImageError: (_, __) {
                  // Update to placeholder if image load fails
                  userProvider.updateUserDetails(
                    userProvider.userName,
                    userProvider.phone,
                    "https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png",
                  );
                },
              ),
            ),
            _buildDrawerItem(
              icon: Icons.person_outline,
              text: 'Profile',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              ),
            ),
            // _buildDrawerItem(
            //   icon: Icons.favorite_border_outlined,
            //   text: 'Favorites',
            //   onTap: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => FavouritePage()),
            //   ),
            // ),
            _buildDrawerItem(
              icon: Icons.receipt_long_outlined,
              text: 'My Orders',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderHistoryPage()),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.location_on_outlined,
              text: 'Saved Addresses',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedAddressesPage()),
              ),
            ),
            const Divider(color: Colors.grey),
            _buildDrawerItem(
              icon: Icons.help_outline,
              text: 'FAQs',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BottomNavigationBarPage()),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.help_outline,
              text: 'Help & Support',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BottomNavigationBarPage()),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.policy_outlined,
              text: 'Privacy Policy',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BottomNavigationBarPage()),
              ),
            ),
            const Divider(color: Colors.grey),
            _buildDrawerItem(
              icon: Icons.logout,
              text: 'Logout',
              onTap: () async {
                Provider.of<CartProvider>(context, listen: false).clearCart();
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Clear user data
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'App Version 1.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      onTap: onTap,
      dense: true,
      horizontalTitleGap: 0,
    );
  }
}
