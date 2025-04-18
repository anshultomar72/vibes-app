import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibes_app/models/menu_items.dart';
import 'package:vibes_app/provider/cart_provider.dart';

class SpecialItems extends StatefulWidget {
  const SpecialItems({Key? key}) : super(key: key);

  @override
  State<SpecialItems> createState() => _SpecialItemsState();
}

class _SpecialItemsState extends State<SpecialItems> {
  Map<String, bool> expandedSections = {};
  Map<String, int> cartItems = {};

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    final gridAspectRatio = (screenWidth / 2) / 240; // Adjust dynamically

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("special").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Center(
            child: SizedBox(
              height: 24, // Smaller size
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2, // Thinner stroke for elegance
                color: Colors.blueAccent, // Custom color
              ),
            ),
          );
        }

        final specials = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: specials.length,
          itemBuilder: (context, specialIndex) {
            final special = specials[specialIndex].data() as Map<String,
                dynamic>;
            final title = special['title'] as String;
            final menuList = List<String>.from(special['menu_list'] ?? []);
            final isExpanded = expandedSections[title] ?? false;
            final displayCount = isExpanded ? menuList.length : min(
                4, menuList.length);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================ Title for Special Item =========================
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (menuList.length > 4)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              expandedSections[title] = !isExpanded;
                            });
                          },
                          child: Text(
                            isExpanded ? "Show less" : "See all",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ========================= Cards for Special Menu Items =========================
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: gridAspectRatio, // Dynamic aspect ratio
                    crossAxisSpacing: screenWidth * 0.04,
                    mainAxisSpacing: screenHeight * 0.06,
                  ),
                  itemCount: displayCount,
                  itemBuilder: (context, menuIndex) {
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('menu_items')
                          .doc(menuList[menuIndex])
                          .get(),
                      builder: (context, menuItemSnapshot) {
                        if (!menuItemSnapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final menuItemData = menuItemSnapshot.data!
                            .data() as Map<String, dynamic>;

                        // Inject the ID field from the document reference
                        final enrichedMenuItemData = {
                          ...menuItemData,
                          'id': menuList[menuIndex],
                        };

                        MenuItem menuItem = MenuItem.fromMap(
                            enrichedMenuItemData);

                        return _buildMenuItem(menuItem);
                      },
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            );
          },
        );
      },
    );
  }

  // ====================== Build Individual Menu Item Card =========================
  Widget _buildMenuItem(MenuItem menuItem) {
    return Consumer<CartProvider>(builder: (context, cartProvider, child) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.none,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                const SizedBox(height: 25),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 45), // Space below the image
                        Text(
                          menuItem.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return Icon(
                              index < menuItem.rating ? Icons.star : Icons
                                  .star_border,
                              color: Colors.orange,
                              size: 16,
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                cartProvider.removeItem(menuItem);
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                              color: Colors.orange,
                              iconSize: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${cartProvider.getItemQuantity(menuItem)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                debugPrint(menuItem.id);
                                cartProvider.addItem(menuItem);
                              },
                              icon: const Icon(Icons.add_circle_outline),
                              color: Colors.orange,
                              iconSize: 24,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: -40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: menuItem.imageUrl,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                      placeholder: (context, url) =>
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      errorWidget: (context, url, error) =>
                      const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}