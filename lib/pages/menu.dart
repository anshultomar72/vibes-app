// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:vibes_app/pages/cart_page.dart';
// import '../models/tags.dart';
// import '../provider/cart_provider.dart';
// import '../provider/menu_provider.dart';
//
// class MenuPage extends StatefulWidget {
//   final String category;
//
//   const MenuPage({super.key, required this.category});
//
//   @override
//   State<MenuPage> createState() => _MenuPageState();
// }
//
// class _MenuPageState extends State<MenuPage> {
//   bool isVeg = false;
//   bool isExpanded = false;
//   Set<Tags> filters = <Tags>{};
//   TextEditingController searchController = TextEditingController();
//   bool isFilterChipsVisible = true;
//   ScrollController scrollController = ScrollController();
//   double lastScrollPosition = 0;
//   String sortBy = 'none'; // Options: 'none', 'price_high', 'price_low', 'rating'
//   Set<String> selectedCategories = {};
//
//   @override
//   void initState() {
//     super.initState();
//     scrollController.addListener(_scrollListener);
//     print(widget.category);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final menuProvider = Provider.of<MenuProvider>(context, listen: false);
//
//       if (menuProvider.menuItems.isEmpty) {
//         menuProvider.fetchAllMenuItems();
//       }
//       if (menuProvider.categories.isEmpty) {
//         menuProvider.fetchAllCategories();
//       }
//       if (menuProvider.tags.isEmpty) {
//         menuProvider.fetchAllTags();
//       }
//       menuProvider.setupRealtimeUpdates();
//     });
//   }
//
//   void _scrollListener() {
//     if ((scrollController.position.pixels > lastScrollPosition) && isFilterChipsVisible) {
//       // Scrolling down
//       setState(() {
//         isFilterChipsVisible = false;
//       });
//     } else if ((scrollController.position.pixels < lastScrollPosition) && !isFilterChipsVisible) {
//       // Scrolling up
//       setState(() {
//         isFilterChipsVisible = true;
//       });
//     }
//     lastScrollPosition = scrollController.position.pixels;
//   }
//
//   void _showFilterBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.black,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) {
//           final menuProvider = Provider.of<MenuProvider>(context, listen: false);
//           return DraggableScrollableSheet(
//             initialChildSize: 0.7,
//             maxChildSize: 0.9,
//             minChildSize: 0.5,
//             expand: false,
//             builder: (context, scrollController) {
//               return Container(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Handle bar
//                     Center(
//                       child: Container(
//                         width: 40,
//                         height: 4,
//                         margin: const EdgeInsets.only(bottom: 20),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[600],
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                       ),
//                     ),
//
//                     // Sort options
//                     const Text(
//                       'Sort By',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Wrap(
//                       spacing: 8,
//                       children: [
//                         _buildSortChip('Price: High to Low', 'price_high', setState),
//                         _buildSortChip('Price: Low to High', 'price_low', setState),
//                         _buildSortChip('Rating', 'rating', setState),
//                       ],
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // Categories
//                     const Text(
//                       'Categories',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Wrap(
//                       spacing: 8,
//                       children: menuProvider.categories.map((category) {
//                         return FilterChip(
//                           selected: selectedCategories.contains(category.id),
//                           label: Text(
//                             category.name,
//                             style: TextStyle(
//                               color: selectedCategories.contains(category.id)
//                                   ? Colors.white
//                                   : Colors.black,
//                             ),
//                           ),
//                           backgroundColor: Colors.white,
//                           selectedColor: Colors.red,
//                           onSelected: (selected) {
//                             setState(() {
//                               if (selected) {
//                                 selectedCategories.add(category.id);
//                               } else {
//                                 selectedCategories.remove(category.id);
//                               }
//                             });
//                           },
//                         );
//                       }).toList(),
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // Tags
//                     const Text(
//                       'Tags',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Wrap(
//                       spacing: 8,
//                       children: menuProvider.tags.map((tag) {
//                         return FilterChip(
//                           selected: filters.contains(tag),
//                           label: Text(
//                             tag.name,
//                             style: TextStyle(
//                               color: filters.contains(tag) ? Colors.white : Colors.black,
//                             ),
//                           ),
//                           backgroundColor: Colors.white,
//                           selectedColor: Colors.red,
//                           onSelected: (selected) {
//                             setState(() {
//                               if (selected) {
//                                 filters.add(tag);
//                               } else {
//                                 filters.remove(tag);
//                               }
//                             });
//                           },
//                         );
//                       }).toList(),
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // Apply and Reset buttons
//                     Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red,
//                               foregroundColor: Colors.white,
//                             ),
//                             onPressed: () {
//                               this.setState(() {});
//                               Navigator.pop(context);
//                             },
//                             child: const Text('Apply Filters'),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: OutlinedButton(
//                             style: OutlinedButton.styleFrom(
//                               foregroundColor: Colors.white,
//                               side: const BorderSide(color: Colors.white),
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 sortBy = 'none';
//                                 selectedCategories.clear();
//                                 filters.clear();
//                               });
//                               this.setState(() {});
//                             },
//                             child: const Text('Reset'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildSortChip(String label, String value, StateSetter setState) {
//     return ChoiceChip(
//       selected: sortBy == value,
//       label: Text(
//         label,
//         style: TextStyle(
//           color: sortBy == value ? Colors.white : Colors.black,
//         ),
//       ),
//       backgroundColor: Colors.white,
//       selectedColor: Colors.red,
//       onSelected: (selected) {
//         setState(() {
//           sortBy = selected ? value : 'none';
//         });
//       },
//     );
//   }
//
//   List<dynamic> _getFilteredAndSortedItems(List<dynamic> items) {
//     var filteredItems = items.where((item) {
//       bool matchesTags = filters.isEmpty ||
//           filters.any((tag) => item.tags.contains(tag.id));
//       bool matchesCategories = selectedCategories.isEmpty ||
//           selectedCategories.contains(item.category);
//       return matchesTags && matchesCategories;
//     }).toList();
//
//     switch (sortBy) {
//       case 'price_high':
//         filteredItems.sort((a, b) => b.price.compareTo(a.price));
//         break;
//       case 'price_low':
//         filteredItems.sort((a, b) => a.price.compareTo(b.price));
//         break;
//       case 'rating':
//         filteredItems.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
//         break;
//     }
//
//     return filteredItems;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // ... (keep your existing build method header)
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         // ... (keep your existing AppBar code)
//       ),
//       body: Consumer<MenuProvider>(
//         builder: (context, menuProvider, child) {
//           if (menuProvider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           return RefreshIndicator(
//             onRefresh: _refreshData,
//             child: Consumer<CartProvider>(
//               builder: (context, cartProvider, child) {
//                 return Column(
//                   children: [
//                     // Search bar and filter button
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Expanded(
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: MediaQuery.of(context).size.width * 0.02,
//                               vertical: MediaQuery.of(context).size.height * 0.01,
//                             ),
//                             child: TextField(
//                               controller: searchController,
//                               decoration: InputDecoration(
//                                 hintText: 'Search your interesting foods...',
//                                 prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(30),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(vertical: 0),
//                               ),
//                             ),
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: _showFilterBottomSheet,
//                           child: Container(
//                             height: MediaQuery.of(context).size.height * 0.06,
//                             width: MediaQuery.of(context).size.height * 0.06,
//                             child: Icon(
//                               Icons.filter_list_rounded,
//                               size: MediaQuery.of(context).size.height * 0.035,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     // Filter chips with animation
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 300),
//                       height: isFilterChipsVisible ? 60 : 0,
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           children: menuProvider.tags.map((tag) {
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 6.0),
//                               child: FilterChip(
//                                 // ... (keep your existing FilterChip code)
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ),
//
//                     // Menu items list
//                     Expanded(
//                       child: ListView.builder(
//                         controller: scrollController,
//                         itemCount: widget.category == "all"
//                             ? menuProvider.categories.length
//                             : 1,
//                         itemBuilder: (context, categoryIndex) {
//                           final category = widget.category == "all"
//                               ? menuProvider.categories[categoryIndex]
//                               : menuProvider.categories.firstWhere((cat) => cat.id == widget.category);
//
//                           final categoryItems = _getFilteredAndSortedItems(
//                               menuProvider.menuItems.where((item) => item.category == category.id).toList()
//                           );
//
//                           // Skip empty categories
//                           if (categoryItems.isEmpty) {
//                             return const SizedBox.shrink();
//                           }
//
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               // ... (keep your existing category header)
//                               ListView.builder(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemCount: categoryItems.length,
//                                 itemBuilder: (context, itemIndex) {
//                                   final menuItem = categoryItems[itemIndex];
//                                   // ... (keep your existing menu item widget)
//                                 },
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     scrollController.removeListener(_scrollListener);
//     scrollController.dispose();
//     super.dispose();
//   }
// }