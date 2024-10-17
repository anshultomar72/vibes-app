import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String profileImageUrl = 'https://avatars.githubusercontent.com/u/98070776?v=4';
  String userName = 'Hardik';
  List<String> promotionBanners = [];

  @override
  void initState() {
    super.initState();
    fetchPromotionBanners();
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipOval(
            child: Image.network(
              profileImageUrl,
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ),
        title: SizedBox(
          width: screenWidth * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, $userName",
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
          IconButton(
            icon: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.black,
        elevation: 4.0,
        shadowColor: Colors.grey[800],
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.02,
                screenHeight * 0.02,
                screenWidth * 0.02,
                screenHeight * 0.01,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search your interesting foods...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  // Special Offers
                  Padding(
                    padding: EdgeInsets.fromLTRB(screenWidth * 0.02, 10, 0, 10),
                    child: Text(
                      "Special Offers",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Promotions Carousel
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0 , 0,0,5),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: screenHeight * 0.22,
                        viewportFraction: 0.9,
                        enlargeCenterPage: true,
                        autoPlay: true,
                      ),
                      items: promotionBanners.map((bannerUrl) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: screenWidth * 0.9,
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(bannerUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  // Menu categories
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Container(
                      height: screenHeight * 0.18,
                      child: GridView.count(
                        crossAxisCount: 2,
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryItem("assets/images/manchurian.png", "Manchur"),
                          _buildCategoryItem("assets/images/momos.png", "Momo"),
                          _buildCategoryItem("assets/images/naan.png", "Naan"),
                          _buildCategoryItem("assets/images/paratha.png", "Paratha"),
                          _buildCategoryItem("assets/images/pav_bhaji.png", "Pav Bhaji"),
                          _buildCategoryItem("assets/images/salad.png", "Salad"),
                          _buildCategoryItem("assets/images/manchurian.png", "Manchur"),
                          _buildCategoryItem("assets/images/momos.png", "Momo"),
                          _buildCategoryItem("assets/images/naan.png", "Naan"),
                          _buildCategoryItem("assets/images/paratha.png", "Paratha"),
                          _buildCategoryItem("assets/images/pav_bhaji.png", "Pav Bhaji"),
                          _buildCategoryItem("assets/images/salad.png", "Salad"),
                          _buildCategoryItem("assets/images/manchurian.png", "Manchur"),
                          _buildCategoryItem("assets/images/momos.png", "Momo"),
                          _buildCategoryItem("assets/images/naan.png", "Naan"),
                          _buildCategoryItem("assets/images/paratha.png", "Paratha"),
                          _buildCategoryItem("assets/images/pav_bhaji.png", "Pav Bhaji"),
                          _buildCategoryItem("assets/images/salad.png", "Salad"),

                        ],
                      ),
                    ),
                  ),
                  // Weekly Special
                  SpecialItems(),
                  SizedBox(height: screenHeight*0.25,)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 50,  // Set fixed size for the png icon
          height: 50,
          child: GestureDetector(
            onTap: () {},
            child: Image.asset(
              icon,
              width: 50,
              height: 50,
            ),
          ),
        ),
        Text(label, style: TextStyle(color: Colors.white)),
      ],
    );
  }


}

class SpecialItems extends StatelessWidget {
  const SpecialItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("special").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final specials = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: specials.length,
          itemBuilder: (context, specialIndex) {
            final special = specials[specialIndex].data() as Map<String, dynamic>;
            final title = special['title'] as String;
            final menuList = List<String>.from(special['menu_list'] ?? []);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.02, 20, 0, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text("See all", style: TextStyle(color: Colors.green)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: menuList.length,
                    itemBuilder: (context, menuIndex) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('menu_items').doc(menuList[menuIndex]).get(),
                        builder: (context, menuItemSnapshot) {
                          if (!menuItemSnapshot.hasData) {
                            return const SizedBox(width: 150, child: Center(child: CircularProgressIndicator()));
                          }

                          final menuItemData = menuItemSnapshot.data!.data() as Map<String, dynamic>?;
                          final itemName = menuItemData?['name'] as String? ?? 'Unknown Item';
                          final imageUrl = menuItemData?['image_url'] as String? ?? 'assets/images/placeholder.png';

                          return _buildSpecialItem(itemName, imageUrl);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Widget _buildSpecialItem(String name, String imageUrl) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: imageUrl.startsWith('http')
                ? Image.network(imageUrl, height: 100, width: 150, fit: BoxFit.scaleDown)
                : Image.asset(imageUrl, height: 100, width: 150, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}