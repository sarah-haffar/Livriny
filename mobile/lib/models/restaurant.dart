// lib/models/restaurant.dart
class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final double rating;
  final int deliveryTime;
  final bool isOpen;
  final String address;
  final String? imageUrl;
  final double minOrder;
  final bool isFavorite;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.deliveryTime,
    required this.isOpen,
    required this.address,
    this.imageUrl,
    required this.minOrder,
    required this.isFavorite,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      cuisine: json['cuisine'] as String,
      rating: (json['rating'] as num).toDouble(),
      deliveryTime: json['deliveryTime'] as int,
      isOpen: json['isOpen'] as bool,
      address: json['address'] as String,
      imageUrl: json['imageUrl'] as String?,
      minOrder: (json['minOrder'] as num).toDouble(),
      isFavorite: json['isFavorite'] as bool,
    );
  }

  @override
  String toString() {
    return 'Restaurant{id: $id, name: $name, cuisine: $cuisine}';
  }
}