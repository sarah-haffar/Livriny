import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/icon_data.dart';

class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final double rating;
  final String deliveryTime; // Gardez-le en String
  final bool isOpen;
  final String address;
  final String imageUrl;
  final double minOrder;
  final bool isFavorite;
  final double distance;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.deliveryTime,
    required this.isOpen,
    required this.address,
    required this.imageUrl,
    required this.minOrder,
    required this.isFavorite,
    required this.distance,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'].toString(),
      name: json['name'].toString(),
      cuisine: json['cuisine'].toString(),
      rating: _parseDouble(json['rating']),
      deliveryTime: _parseDeliveryTime(json['deliveryTime']),
      isOpen: json['isOpen'] ?? false,
      address: json['address'].toString(),
      imageUrl: json['imageUrl']?.toString() ?? '',
      minOrder: _parseDouble(json['minOrder']),
      isFavorite: json['isFavorite'] ?? false,
      distance: _parseDouble(json['distance']) ?? 0.0,
    );
  }

  IconData get cuisineIcon {
    switch (cuisine.toLowerCase()) {
      case 'pizza':
      case 'italien':
        return Icons.local_pizza;
      case 'burger':
      case 'américain':
        return Icons.fastfood;
      case 'sushi':
      case 'japonais':
        return Icons.set_meal;
      case 'mexicain':
        return Icons.restaurant;
      case 'asiatique':
        return Icons.ramen_dining;
      case 'indien':
        return Icons.rice_bowl;
      case 'salade':
      case 'healthy':
        return Icons.eco;
      case 'dessert':
      case 'glaces':
        return Icons.icecream;
      case 'café':
      case 'petit-déjeuner':
        return Icons.coffee;
      default:
        return Icons.restaurant_menu;
    }
  }


  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String _parseDeliveryTime(dynamic value) {
    if (value == null) return '30-45 min';
    
    if (value is String) {
      return value;
    } 
    else if (value is int) {
      // Si c'est un int, formatez-le en String
      return '$value-${value + 10} min';
    }
    else {
      return value.toString();
    }
  }
}