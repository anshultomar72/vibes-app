import 'package:flutter/cupertino.dart';

class Tags {
  final String id;
  final String name;

  Tags({
    required this.id,
    required this.name,
  });

  // Convert a Category instance into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Create a Category instance from a Map
  factory Tags.fromMap(Map<String, dynamic> map) {
    return Tags(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
    );
  }
}