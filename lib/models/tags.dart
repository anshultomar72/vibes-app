import 'package:flutter/cupertino.dart';

class Tags {
  final String id;
  final String name;
  final String imageUrl;

  Tags({
    required this.id,
    required this.name,
    required this.imageUrl
  });

  // Convert a Tag instance into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl':imageUrl
    };
  }

  // Create a Category instance from a Map
  factory Tags.fromMap(Map<String, dynamic> map) {
    return Tags(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl :map['imageUrl'] ?? '',
    );
  }
}