import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibes_app/pages/menu_page.dart';
import 'package:vibes_app/pages/special_item_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../provider/cart_provider.dart';
import '../provider/menu_provider.dart';
import '../provider/user_provider.dart';
import 'BottomNavigationBar.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<String> promotionBanners = [];
  late MenuProvider _menuProvider;

  @override
  void initState() {
    super.initState();
    fetchPromotionBanners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserDetails();
      // Fetch the categories after the build is complete
      _menuProvider = Provider.of<MenuProvider>(context , listen: false);
      _menuProvider.fetchAllCategories();
    });

  }

  Future<void> _refreshPage() async {
    // Refetch the promotion banners
    fetchPromotionBanners();
    // Refetch the categories
    _menuProvider.fetchAllCategories();
    // You can add any other refresh logic here (e.g., fetching special items)
  }

  void fetchPromotionBanners() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint(prefs.getKeys().toString());
    final promotionsSnapshot = await FirebaseFirestore.instance.collection('promotions').get();
    setState(() {
      promotionBanners = promotionsSnapshot.docs.map((doc) => doc['image_url'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Access the BottomNavigationBarPage's state to open the drawer
    final parentState = context.findAncestorStateOfType<BottomNavigationBarPageState >();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder:(context){
            return
              GestureDetector(
                onTap: () {
                  parentState?.openDrawer(); // Call the drawer open function
                },
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                        userProvider.profileImageUrl,
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
          }
        ),
        title: SizedBox(
          width: screenWidth * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, ${userProvider.userName}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "Ready to feast?",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
            onPressed: () {},
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CartPage()));
                },
              ),
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  // Only show the count badge if itemCount > 0
                  return cartProvider.itemCount > 0
                      ? Positioned(
                    top: -2,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "${cartProvider.itemCount}",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  )
                      : const SizedBox.shrink(); // Return empty widget when count is 0
                },
              ),
            ],
          ),
        ],
        backgroundColor: Colors.black,
        elevation: 4.0,
        shadowColor: Colors.grey[800],
      ),



      body: RefreshIndicator(
        onRefresh: _refreshPage,
        color: Colors.deepOrange,
        child: Container(
          color: Colors.black,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
       // ====================Special Offers =============
                    Padding(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.02, 10, 0, 10),
                      child: Text(
                        "Special Offers",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

    // ====================================Promotions Carousel ===========================
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: screenHeight * 0.23,
                          viewportFraction: 0.9,
                          enlargeCenterPage: true,
                          autoPlay: true,
                        ),
              items: promotionBanners.map((bannerUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: screenWidth * 0.9,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),  // Ensure images are clipped by the border radius
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              bannerUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  // Image is loaded, show the image
                                  return child;
                                } else {
                                  // Image is still loading, show a progress indicator
                                  return Center(
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
                              },
                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                // Show error icon if the image fails to load
                                return const Center(
                                  child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),

    // ======================================= Menu categories ===============================
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          screenWidth * 0.02,
                          screenWidth * 0.06,
                          screenWidth * 0.04,
                          screenWidth * 0.00
                      ),
                      child: Container(
                        height: screenHeight * 0.25,
                        child: Consumer<MenuProvider>(
                          builder: (context, menuProvider, child) {
                            if (menuProvider.isLoading) {
                              return Center(
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
                            return GridView.count(
                              crossAxisCount: 2,
                              scrollDirection: Axis.horizontal,
                              children: menuProvider.categories
                                  .map((category) => _buildCategoryItem(category.imageUrl, category.name , category.id))
                                  .toList(),
                            );
                          },
                        ),
                      ),
                    ),

      // =================================== Weekly Special===================================
                    SpecialItems(),

                    SizedBox(height: screenHeight*0.25,)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

//==============================Widget for Category items ========================
  Widget _buildCategoryItem(String icon, String label, String id) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MenuPage(category: id),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon/Image Section
          SizedBox(
            width: 60,
            height: 60,
            child: CachedNetworkImage(
              imageUrl: icon,
              placeholder: (context, url) => _buildSkeletonLoader(), // Skeleton loader as placeholder
              errorWidget: (context, url, error) => const Icon(
                Icons.error,
                color: Colors.red,
                size: 50,
              ),
              fadeInDuration: const Duration(milliseconds: 300), // Smooth transition
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 5),

          // Text Section
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

// Helper function to create the skeleton loader using Shimmer
  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}



