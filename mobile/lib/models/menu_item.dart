// code a completer // lib/models/menu_item.dart
class MenuItem {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String category;
  final bool available;
  final String? restaurantId; // Optionnel

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    required this.available,
    this.restaurantId,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
  // Créer une copie sans __typename
  final Map<String, dynamic> filteredJson = Map<String, dynamic>.from(json);
  filteredJson.remove('__typename'); // Enlever le champ GraphQL
  
  return MenuItem(
    id: filteredJson['id']?.toString() ?? '',
    name: filteredJson['name']?.toString() ?? '',
    description: filteredJson['description']?.toString(),
    price: (filteredJson['price'] as num?)?.toDouble() ?? 0.0,
    category: filteredJson['category']?.toString() ?? 'Autre',
    available: filteredJson['available'] as bool? ?? true,
    restaurantId: filteredJson['restaurantId']?.toString(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'available': available,
      if (restaurantId != null) 'restaurantId': restaurantId,
    };
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    bool? available,
    String? restaurantId,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      available: available ?? this.available,
      restaurantId: restaurantId ?? this.restaurantId,
    );
  }

  @override
  String toString() {
    return 'MenuItem(id: $id, name: $name, price: $price, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}