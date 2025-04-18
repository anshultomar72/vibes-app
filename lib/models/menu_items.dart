class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final int totalRating;
  final List<String> tags;
  final String category;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.tags,
    required this.rating,
    required this.totalRating,
    required this.category,
    required this.isAvailable,
  });

  // Convert a MenuItem instance into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'rating': rating,
      'totalRating': totalRating,
      'tags': tags,
      'category': category,
      'isAvailable': isAvailable,
    };
  }

  // Create a MenuItem instance from a Map
  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['image_url'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalRating: map['totalRating'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      category: map['category'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}

class Category {
  final String id;
  final String name;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  // Convert a Category instance into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  // Create a Category instance from a Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}