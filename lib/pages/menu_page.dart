import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tags.dart';
import '../provider/menu_provider.dart';

class MenuPage extends StatefulWidget {
  final String category;

  const MenuPage({super.key, required this.category});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool isVeg = false;
  bool isExpanded = false;
  Set<Tags> filters = <Tags>{};
  int count = 0;

  @override
  void initState() {
    super.initState();

    print(widget.category);
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
    await menuProvider.fetchAllMenuItems();
    await menuProvider.fetchAllCategories();
    await menuProvider.fetchAllTags();
    filters.clear();
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
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,

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
          IconButton(
            icon: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
            ),
            onPressed: () {
              // Cart action
            },
          ),
        ],
      ),

      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, child) {
          if (menuProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: Column(
              children: [
      // ===================== SEARCH BAR ===========================
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

    // ============================  Sorting and Filtering Bar ====================================
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
               // ===========================Sort Button ================
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  backgroundColor: Colors.white// Adjust padding
                                ),
                                onPressed: () {
                                  // Handle sorting functionality
                                },
                                child: Row(

                                  children: [
                                    Icon(
                                      Icons.sort_outlined,
                                      color: Colors.black,
                                    ),
                                    Text(
                                      "Sort",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Icon(
                                        Icons.arrow_drop_down_outlined,
                                        color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 4),
              // ========================Filter Chips===========================
                              Row(
                                children: menuProvider.tags.map((tag) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: FilterChip(

                                      label: Text(
                                        tag.name,
                                        style: TextStyle(
                                          color: Colors.black, // Change text color
                                        ),
                                      ),
                                      selected: filters.contains(tag), // Manage selection state here
                                      onSelected: (bool selected) {
                                        print('Selected: ${tag.name}');
                                        setState(() {
                                          if(selected){
                                            filters.add(tag);
                                          }
                                          else{
                                            filters.remove(tag);
                                          }
                                        });
                                        // Handle selection logic
                                      },
                                      selectedColor: Colors.green, // Color when selected
                                      backgroundColor: Colors.white, // Color when not selected
                                      checkmarkColor: Colors.white,
                                      elevation: 0,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Selected Items: ${filters.map((Tags e) => e.name).join(', ')}',
                  style: TextStyle(color: Colors.white),
                ),

       // ============================== Display Categories and Menu Items ===============
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.category == "all"
                        ? menuProvider.categories.length
                        : 1,
                    itemBuilder: (context, categoryIndex) {
                      final category = widget.category == "all"
                          ? menuProvider.categories[categoryIndex]
                          : menuProvider.categories.firstWhere((cat) => cat.id == widget.category);
                      final categoryItems = menuProvider.menuItems
                          .where((item) => item.category == category.id)
                          .toList();

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
                                                  isExpanded = !isExpanded;
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
                                              crossFadeState: isExpanded
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
                                                    isExpanded = !isExpanded;
                                                  });
                                                },
                                                child: Text(
                                                  isExpanded ? "View Less" : "View More",
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
                                            child: Image.network(
                                              menuItem.imageUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 8),

               // ========================================== Add/Remove Buttons============================
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.white),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,

                                            children: [

                                              count == 0
                                                  ? InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    count++;
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.green),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min, // Make the row wrap tightly around its content
                                                    children: const [
                                                      Icon(Icons.add, size: 16, color: Colors.green),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Add',
                                                        style: TextStyle(color: Colors.green),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                                  : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Decrement button
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (count > 0) count--;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      child: const Icon(Icons.remove, size: 16, color: Colors.red),
                                                    ),
                                                  ),

                                                  // Display count
                                                  Container(
                                                    width: 40,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    color: Colors.green,
                                                    child: Center(
                                                      child: Text(
                                                        "$count", // Display the actual count
                                                        style: const TextStyle(color: Colors.white),
                                                      ),
                                                    ),
                                                  ),

                                                  // Increment button
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        count++;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      child: const Icon(Icons.add, size: 16, color: Colors.green),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
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
            ),
          );
        },
      ),
    );
  }
}
