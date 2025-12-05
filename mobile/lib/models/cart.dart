import 'package:flutter/foundation.dart';
import 'menu_item.dart';

class CartItem {
  final MenuItem item;
  int quantity;
  final DateTime addedAt;
  final String? specialInstructions;

  CartItem({
    required this.item,
    required this.quantity,
    this.specialInstructions,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  double get totalPrice => item.price * quantity;

  CartItem copyWith({
    MenuItem? item,
    int? quantity,
    String? specialInstructions,
    DateTime? addedAt,
  }) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item.toJson(),
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      item: MenuItem.fromJson(json['item']),
      quantity: json['quantity'] as int,
      specialInstructions: json['specialInstructions'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.item.id == item.id &&
        other.specialInstructions == specialInstructions;
  }

  @override
  int get hashCode => Object.hash(item.id, specialInstructions);
}

class CartModel extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => Map.from(_items);
  
  int get itemCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }
  
  double get totalPrice {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get subtotalPrice {
    return totalPrice;
  }

  double get deliveryFee {
    // Frais de livraison fixes ou calculés
    return totalPrice >= 20.0 ? 0.0 : 2.50;
  }

  double get totalWithFees {
    return subtotalPrice + deliveryFee;
  }

  // Ajouter un item au panier
  void addItem(MenuItem item, int quantity, {String? specialInstructions}) {
    final key = _generateKey(item.id, specialInstructions);
    
    if (_items.containsKey(key)) {
      _items[key] = _items[key]!.copyWith(
        quantity: _items[key]!.quantity + quantity,
      );
    } else {
      _items[key] = CartItem(
        item: item,
        quantity: quantity,
        specialInstructions: specialInstructions,
      );
    }
    notifyListeners();
  }

  // Retirer un item du panier
  void removeItem(String itemId, {String? specialInstructions}) {
    final key = _generateKey(itemId, specialInstructions);
    _items.remove(key);
    notifyListeners();
  }

  // Mettre à jour la quantité
  void updateQuantity(String itemId, int quantity, {String? specialInstructions}) {
    final key = _generateKey(itemId, specialInstructions);
    
    if (_items.containsKey(key)) {
      if (quantity <= 0) {
        _items.remove(key);
      } else {
        _items[key] = _items[key]!.copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  // Mettre à jour les instructions spéciales
  void updateSpecialInstructions(String itemId, String? oldInstructions, String? newInstructions) {
    final oldKey = _generateKey(itemId, oldInstructions);
    final newKey = _generateKey(itemId, newInstructions);
    
    if (_items.containsKey(oldKey)) {
      final cartItem = _items[oldKey]!;
      _items.remove(oldKey);
      
      if (newKey != oldKey) {
        _items[newKey] = cartItem.copyWith(specialInstructions: newInstructions);
      } else {
        _items[oldKey] = cartItem.copyWith(specialInstructions: newInstructions);
      }
      notifyListeners();
    }
  }

  // Vider le panier
  void clear() {
    _items.clear();
    notifyListeners();
  }

  // Vérifier si un item est dans le panier
  bool containsItem(String itemId, {String? specialInstructions}) {
    final key = _generateKey(itemId, specialInstructions);
    return _items.containsKey(key);
  }

  // Obtenir la quantité d'un item
  int getItemQuantity(String itemId, {String? specialInstructions}) {
    final key = _generateKey(itemId, specialInstructions);
    return _items[key]?.quantity ?? 0;
  }

  // Obtenir les items groupés par restaurant
  Map<String, List<CartItem>> getItemsByRestaurant() {
    final Map<String, List<CartItem>> grouped = {};
    
    for (final cartItem in _items.values) {
      final restaurantId = cartItem.item.restaurantId;
      if (restaurantId != null) {
        grouped.putIfAbsent(restaurantId, () => []);
        grouped[restaurantId]!.add(cartItem);
      }
    }
    
    return grouped;
  }

  // Vérifier si le panier contient des items d'un seul restaurant
  bool get isSingleRestaurant {
    final restaurants = _items.values.map((item) => item.item.restaurantId).toSet();
    return restaurants.length <= 1;
  }

  // Obtenir l'ID du restaurant principal
  String? get mainRestaurantId {
    if (_items.isEmpty) return null;
    
    final restaurants = <String, int>{};
    for (final cartItem in _items.values) {
      final restaurantId = cartItem.item.restaurantId;
      if (restaurantId != null) {
        restaurants[restaurantId] = (restaurants[restaurantId] ?? 0) + 1;
      }
    }
    
    if (restaurants.isEmpty) return null;
    
    return restaurants.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Sauvegarder le panier
  Map<String, dynamic> toJson() {
    return {
      'items': _items.values.map((item) => item.toJson()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Restaurer le panier
  void fromJson(Map<String, dynamic> json) {
    _items.clear();
    
    final itemsData = json['items'] as List?;
    if (itemsData != null) {
      for (final itemData in itemsData) {
        final cartItem = CartItem.fromJson(itemData);
        final key = _generateKey(cartItem.item.id, cartItem.specialInstructions);
        _items[key] = cartItem;
      }
    }
    
    notifyListeners();
  }

  // Générer une clé unique pour un item
  String _generateKey(String itemId, String? specialInstructions) {
    final instructions = specialInstructions?.trim() ?? '';
    return '$itemId${instructions.isNotEmpty ? '_$instructions' : ''}';
  }

  // Récapitulatif du panier
  Map<String, dynamic> get summary {
    return {
      'itemCount': itemCount,
      'subtotal': subtotalPrice,
      'deliveryFee': deliveryFee,
      'total': totalWithFees,
      'restaurantCount': getItemsByRestaurant().length,
      'isSingleRestaurant': isSingleRestaurant,
    };
  }

  // Appliquer une promotion
  void applyPromoCode(String code) {
    // TODO: Implémenter la logique des codes promo
    notifyListeners();
  }
}