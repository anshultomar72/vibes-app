import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vibes_app/models/menu_items.dart';
import '../models/tags.dart';

class MenuProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MenuItem> _menuItems = [];
  List<Category> _categories = [];
  List<Tags> _tags = [];

  bool _isLoading = false;
  bool _isListeningToUpdates = false;

  List<MenuItem> get menuItems => _menuItems;
  List<Category> get categories => _categories;
  List<Tags> get tags => _tags;

  bool get isLoading => _isLoading;

  // Fetch all menu items from Firebase
  Future<void> fetchAllMenuItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear existing menu items before fetching
      clearMenuItems();

      // Fetch from Firestore
      final snapshot = await _firestore.collection('menu_items').get();
      _menuItems = snapshot.docs.map((doc) {
        return MenuItem(
            id: doc.id,
            name: doc['name'],
            description: doc['description'],
            price: doc['price'].toDouble(),
            imageUrl: doc['image_url'],
            rating: doc['rating'].toDouble(),
            totalRating: doc['num_ratings'].toInt(),
            tags: List<String>.from(doc['tags'] ?? []),
            category: doc['category'],
            isAvailable: doc['isAvailable'] as bool? ?? true
        );
      }).toList();
    } catch (e) {
      print('Error fetching menu items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all categories from Firebase
  Future<void> fetchAllCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Fetch from Firestore
      final snapshot = await _firestore.collection('categories').get();
      _categories = snapshot.docs.map((doc) {
        return Category(
          id: doc.id,
          name: doc['name'],
          imageUrl: doc['image_url'],
        );
      }).toList();
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all tags from Firebase
  Future<void> fetchAllTags() async {
    notifyListeners();
    try {
      // Fetch from Firestore
      final snapshot = await _firestore.collection('tags').get();
      _tags = snapshot.docs.map((doc) {
        return Tags(
          id: doc.id,
          name: doc['name'],
          imageUrl : doc['imageUrl']
        );
      }).toList();
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch menu items by category
  Future<void> fetchMenuItemsByCategory(String category) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('menu_items')
          .where('category', isEqualTo: category)
          .get();

      _menuItems = snapshot.docs.map((doc) {
        return MenuItem(
            id: doc.id,
            name: doc['name'],
            description: doc['description'],
            price: doc['price'].toDouble(),
            imageUrl: doc['image_url'],
            rating: doc['rating'].toDouble(),
            totalRating: doc['num_ratings'].toInt(),
            tags: List<String>.from(doc['tags'] ?? []),
            category: doc['category'],
            isAvailable: doc['isAvailable'] as bool? ?? true
        );
      }).toList();
    } catch (e) {
      print('Error fetching menu items by category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set up real-time updates for menu items
  void setupRealtimeUpdates() {
    if (_isListeningToUpdates) return;
    _isListeningToUpdates = true;
    _firestore.collection('menu_items').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            _handleAddedItem(change.doc);
            break;
          case DocumentChangeType.modified:
            _handleModifiedItem(change.doc);
            break;
          case DocumentChangeType.removed:
            _handleRemovedItem(change.doc);
            break;
        }
      }
      notifyListeners();
    });
  }

  void _handleAddedItem(DocumentSnapshot doc) {
    final newItem = MenuItem(
      id: doc.id,
      name: doc['name'],
      description: doc['description'],
      price: doc['price'].toDouble(),
      imageUrl: doc['image_url'],
      rating: doc['rating'].toDouble(),
      totalRating: doc['num_ratings'].toInt(),
      tags: List<String>.from(doc['tags'] ?? []),
      category: doc['category'],
      isAvailable: doc['isAvailable'] as bool? ?? true,
    );

    _menuItems.add(newItem);
    notifyListeners();
  }

  void _handleModifiedItem(DocumentSnapshot doc) {
    final index = _menuItems.indexWhere((item) => item.id == doc.id);
    if (index != -1) {
      _menuItems[index] = MenuItem(
        id: doc.id,
        name: doc['name'],
        description: doc['description'],
        price: doc['price'].toDouble(),
        imageUrl: doc['image_url'],
        rating: doc['rating'].toDouble(),
        totalRating: doc['num_ratings'].toInt(),
        tags: List<String>.from(doc['tags'] ?? []),
        category: doc['category'],
        isAvailable: doc['isAvailable'] as bool? ?? true,
      );
    }
    notifyListeners();
  }

  void _handleRemovedItem(DocumentSnapshot doc) {
    _menuItems.removeWhere((item) => item.id == doc.id);
    notifyListeners();
  }

  // Clear menu items
  void clearMenuItems() {
    _menuItems.clear();
    notifyListeners();
  }
}