import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibes_app/pages/BottomNavigationBar.dart';
import 'package:vibes_app/pages/cart_page.dart';
import 'package:vibes_app/pages/homePage.dart';
import '../models/tags.dart';
import '../provider/cart_provider.dart';
import '../provider/menu_provider.dart';

class MenuPage extends StatefulWidget {
  final String category;

  const MenuPage({super.key, required this.category});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool isVeg = false;

  Set<Tags> filters = <Tags>{};
  TextEditingController searchController = TextEditingController();
  bool isFilterChipsVisible = true;
  ScrollController scrollController = ScrollController();
  double lastScrollPosition = 0;
  String sortBy = 'none'; // Options: 'none', 'price_high', 'price_low', 'rating'
  Set<String> selectedCategories = {};
  Map<String, bool> expandedItems = {};

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        // This empty setState will trigger a rebuild with the new search text
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menuProvider = Provider.of<MenuProvider>(context, listen: false); // Initialize selection state

      if (menuProvider.menuItems.isEmpty) {
        menuProvider.fetchAllMenuItems();
      }
      if (menuProvider.categories.isEmpty) {
        menuProvider.fetchAllCategories();
      }
      if (menuProvider.tags.isEmpty) {
        menuProvider.fetchAllTags();
      }
      menuProvider.setupRealtimeUpdates();
    });
  }



  Future<void> _refreshData() async {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    await menuProvider.fetchAllMenuItems();
    await menuProvider.fetchAllCategories();
    await menuProvider.fetchAllTags();
    await cartProvider.loadCartData();
    filters.clear();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final menuProvider = Provider.of<MenuProvider>(context, listen: false);
          return WillPopScope(
            onWillPop: () async{
              this.setState(() {});
              return true;
            },
            child: DraggableScrollableSheet(
              // Dynamically set initial size based on content
              initialChildSize: widget.category != "all" ? 0.5 : 0.7,
              // Adjust max and min sizes
              maxChildSize: 0.9,
              minChildSize: widget.category != "all" ? 0.3 : 0.4,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 18.0,
                      right: 18.0,
                      top: 18.0,
                      // Add bottom padding to account for keyboard
                      bottom: MediaQuery.of(context).viewInsets.bottom + 18.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Sort options
                        const Text(
                          'Sort By',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildSortChip('Price: High to Low', 'price_high', setState),
                            _buildSortChip('Price: Low to High', 'price_low', setState),
                            _buildSortChip('Rating', 'rating', setState),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Tags
                        const Text(
                          'Tags',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: menuProvider.tags.map((tag) {
                            return FilterChip(
                              selected: filters.contains(tag),
                              label: Text(
                                tag.name,
                                style: TextStyle(
                                  color: filters.contains(tag) ? Colors.white : Colors.black,
                                ),
                              ),
                              backgroundColor: Colors.white,
                              selectedColor: Colors.red,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    filters.add(tag);
                                  } else {
                                    filters.remove(tag);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        if(widget.category == "all") ...[
                          const Text(
                            'Categories',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: menuProvider.categories.map((category) {
                              return FilterChip(
                                selected: selectedCategories.contains(category.id),
                                label: Text(
                                  category.name,
                                  style: TextStyle(
                                    color: selectedCategories.contains(category.id)
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                backgroundColor: Colors.white,
                                selectedColor: Colors.red,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedCategories.add(category.id);
                                    } else {
                                      selectedCategories.remove(category.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                        // Categories


                        SizedBox(height: 24,),

                        // Apply and Reset buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  this.setState(() {}); // Update state in parent widget
                                  Navigator.pop(context);
                                },
                                child: const Text('Apply Filters'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white),
                                ),
                                onPressed: () {
                                  setState(() {
                                    sortBy = 'none';
                                    selectedCategories.clear();
                                    filters.clear();
                                  });
                                  this.setState(() {}); // Update state in parent widget
                                },
                                child: const Text('Reset'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortChip(String label, String value, StateSetter setState) {
    return ChoiceChip(
      selected: sortBy == value,
      label: Text(
        label,
        style: TextStyle(
          color: sortBy == value ? Colors.white : Colors.black,
        ),
      ),
      backgroundColor: Colors.white,
      selectedColor: Colors.red,
      onSelected: (selected) {
        setState(() {
          sortBy = selected ? value : 'none';
        });
      },
    );
  }

  List<dynamic> _getFilteredAndSortedItems(List<dynamic> items) {
    // First filter by search text
    var filteredItems = items.where((item) {
      bool matchesSearch = searchController.text.isEmpty ||
          item.name.toLowerCase().contains(searchController.text.toLowerCase());

      // Check if item matches selected tags
      bool matchesTags = filters.isEmpty ||
          filters.every((tag) => item.tags.contains(tag.name));


      // Check if item matches selected categories
      bool matchesCategories = selectedCategories.isEmpty ||
          selectedCategories.contains(item.category);

      return matchesSearch && matchesTags && matchesCategories;
    }).toList();

    // Then apply sorting
    switch (sortBy) {
      case 'price_high':
        filteredItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'price_low':
        filteredItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'rating':
        filteredItems.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
    }

    return filteredItems;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            if(widget.category == "all"){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => BottomNavigationBarPage()));
            }
            else Navigator.pop(context);
          },
          child: Container(
            height: screenHeight*0.1,
            width: screenWidth*0.1,
            // color: Colors.red,
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,

            ),
          ),
        ),
        title: const Text(
          "Menu",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
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



              ]
          ),
        ],
      ),

      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, child) {
          if (menuProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<dynamic> allFilteredItems = _getFilteredAndSortedItems(menuProvider.menuItems);

          // Group filtered items by category
          Map<String, List<dynamic>> itemsByCategory = {};
          for (var item in allFilteredItems) {
            if (!itemsByCategory.containsKey(item.category)) {
              itemsByCategory[item.category] = [];
            }
            itemsByCategory[item.category]!.add(item);
          }

          // Get categories that have items after filtering
          List<dynamic> categoriesWithItems = menuProvider.categories
              .where((category) =>
          itemsByCategory.containsKey(category.id) &&
              itemsByCategory[category.id]!.isNotEmpty)
              .toList();
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return Column(
                  children: [
    // =====================-========= SEARCH BAR ===========================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
                      children: [
      // =========================== Search bar ===========================================
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                              vertical: screenHeight * 0.01,
                            ),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Search your interesting foods...',
                                prefixIcon: Icon(Icons.search, color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 0), // Align text better
                              ),
                            ),
                          ),
                        ),

    // ================================= Sorting button ==================================
                        GestureDetector(
                          onTap: _showFilterBottomSheet,
                          child: Container(
                            height: screenHeight * 0.06,
                            width: screenHeight * 0.06, // Ensure a square container for alignment

                            child: Icon(
                              Icons.tune_sharp, // Use a suitable icon for filtering
                              size: screenHeight * 0.035, // Adjust size relative to screen height
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),


     // ======================== Filter Chips ===========================
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: menuProvider.tags.map((tag) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0), // Adjust space between chips
                            child: FilterChip(
                              showCheckmark: false,
                              label: Row(
                                mainAxisSize: MainAxisSize.min, // Compact row layout
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      tag.imageUrl,
                                      width: 35, // Adjust icon size
                                      height: 25,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        // Default icon if image fails
                                        return Icon(Icons.image, size: 20);
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8), // Space between icon and text
                                  Text(
                                    tag.name,
                                    style: const TextStyle(
                                      color: Color(0xFF2C2C2C), // Dark text color
                                      fontWeight: FontWeight.w500, // Bold text
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (filters.contains(tag)) ...[
                                    SizedBox(width: 8), // Space before close icon
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          filters.remove(tag); // Remove tag on tap
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.black45, // Close icon color
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), // Rounded edges
                                side: filters.contains(tag)
                                    ? BorderSide(color: Colors.red.shade300) // Red border if selected
                                    : BorderSide(color: Colors.grey.shade300),
                              ),
                              backgroundColor: filters.contains(tag)
                                  ? Colors.red.shade50 // Light red background if selected
                                  : Colors.white,
                              selectedColor: Colors.red.shade50,
                              selected: filters.contains(tag),
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    filters.add(tag);
                                  } else {
                                    filters.remove(tag);
                                  }
                                });
                              },
                              visualDensity: VisualDensity.compact, // Compact chip
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              elevation: 0, // Flat chip
                            ),
                          );
                        }).toList(),
                      ),
                    ),

     // ===================================== Display Categories and Menu Items ===============
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: widget.category == "all"
                            ? categoriesWithItems.length + 1
                            : 1,
                        itemBuilder: (context, categoryIndex) {
                          if (categoryIndex == categoriesWithItems.length) {
                            return SizedBox(height: screenHeight * 0.25); // Adjust height as needed
                          }
                          final category = widget.category == "all"
                              ? categoriesWithItems[categoryIndex]
                              : menuProvider.categories.firstWhere((cat) => cat.id == widget.category);

                          final categoryItems = itemsByCategory[category.id] ?? [];
                          // Skip if no items in category
                          if (categoryItems.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  category.name,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: categoryItems.length,
                                itemBuilder: (context, itemIndex) {
                                  final menuItem = categoryItems[itemIndex];

                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(8.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                          // ==================================== Left Section: Item Details ==============================
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Veg/Non-Veg Icon
                                              Icon(
                                                isVeg ? Icons.circle : Icons.circle,
                                                size: 20,
                                                color: isVeg ? Colors.green : Colors.red,
                                              ),
                                              const SizedBox(height: 4),
                                              // Item Name
                                              Text(
                                                menuItem.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                         // ========== =============Rating and Number of Ratings ================================
                                              Row(
                                                children: [
                                                  ...List.generate(5, (index) => Icon(
                                                    index < (menuItem.rating ?? 0).floor()
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    size: 16,
                                                    color: Colors.amber,
                                                  )),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${menuItem.totalRating} ratings',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              // Price
                                              Text(
                                                '₹${menuItem.price}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              GestureDetector(
                                                onTap: () {
                                                  if (menuItem.description.length > 100) {
                                                    setState(() {
                                                      expandedItems[menuItem.id] = !(expandedItems[menuItem.id] ?? false);
                                                    });
                                                  }
                                                },
                                                child: AnimatedCrossFade(
                                                  firstChild: Text(
                                                    menuItem.description,
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                  secondChild: Text(
                                                    menuItem.description,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                  crossFadeState: (expandedItems[menuItem.id] ?? false)
                                                      ? CrossFadeState.showSecond
                                                      : CrossFadeState.showFirst,
                                                  duration: const Duration(milliseconds: 300),
                                                ),
                                              ),
                                              if (menuItem.description.length > 100)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        expandedItems[menuItem.id] = !(expandedItems[menuItem.id] ?? false);
                                                      });
                                                    },
                                                    child: Text(
                                                      (expandedItems[menuItem.id] ?? false) ? "View Less" : "View More",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.blue[700],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                 // -============================== Right Section: Image and Add/Remove Buttons===============================
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                    // =========================== Product Image with Border ==========================
                                            Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.grey[300]!, width: 1),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(7),
                                                child: CachedNetworkImage(
                                                  imageUrl: menuItem.imageUrl,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => Shimmer.fromColors(
                                                    baseColor: Colors.grey[300]!,
                                                    highlightColor: Colors.grey[100]!,
                                                    child: Container(
                                                      color: Colors.grey,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                    ),
                                                  ),
                                                  errorWidget: (context, url, error) => const Icon(
                                                    Icons.error,
                                                    color: Colors.red,
                                                    size: 50,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 8),

                   // ========================================== Add/Remove Buttons============================
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8)
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  cartProvider.getItemQuantity(menuItem) == 0
                                                  ? Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: (){
                                                        cartProvider.addItem(menuItem);
                                                      },
                                                      borderRadius: BorderRadius.circular(8),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 24,
                                                          vertical: 12,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.green, width: 1.5),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children:  [
                                                            Icon(Icons.add, size: 20, color: Colors.green),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              'ADD',
                                                              style: TextStyle(
                                                                color: Colors.green,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                      :
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.green, width: 1.5),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        // Decrement button
                                                        Material(
                                                          color: Colors.transparent,
                                                          child: InkWell(
                                                            onTap: () {
                                                              cartProvider.removeItem(menuItem);
                                                            },
                                                            borderRadius: const BorderRadius.only(
                                                              topLeft: Radius.circular(8),
                                                              bottomLeft: Radius.circular(8),
                                                            ),
                                                            child: Container(
                                                              padding: const EdgeInsets.all(12),
                                                              child: const Icon(
                                                                Icons.remove,
                                                                size: 20,
                                                                color: Colors.red,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        // Count display
                                                        Container(
                                                          width: 40,
                                                          height: 44,
                                                          color: Colors.green,
                                                          child: Center(
                                                            child: Text(
                                                              "${cartProvider.getItemQuantity(menuItem)}",
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        // Increment button
                                                        Material(
                                                          color: Colors.transparent,
                                                          child: InkWell(
                                                            onTap: () {
                                                              cartProvider.addItem(menuItem);
                                                            },
                                                            borderRadius: const BorderRadius.only(
                                                              topRight: Radius.circular(8),
                                                              bottomRight: Radius.circular(8),
                                                            ),
                                                            child: Container(
                                                              padding: const EdgeInsets.all(12),
                                                              child: const Icon(
                                                                Icons.add,
                                                                size: 20,
                                                                color: Colors.green,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            ),
          );
        },
      ),
    );
  }
  @override
  void dispose() {
    searchController.removeListener(() { setState(() {}); });
    searchController.dispose();
    super.dispose();
  }
}
