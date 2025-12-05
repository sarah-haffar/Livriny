// lib/models/order.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'menu_item.dart';
import 'cart.dart';

class OrderItem {
  final String id;
  final MenuItem item;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.item,
    required this.quantity,
    required this.price,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item': item.toJson(),
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      item: MenuItem.fromJson(json['item']),
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }
}

enum OrderStatus {
  pending('En attente',Colors.orange),
  confirmed('Confirmée', Colors.blue),
  preparing('En préparation', Colors.purple),
  ready('Prête', Colors.green),
  delivered('Livrée', Colors.green),
  cancelled('Annulée', Colors.red);

  final String displayName;
  final Color color;

  const OrderStatus(this.displayName, this.color);
}

class Order {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String deliveryAddress;
  final String? specialInstructions;
  final String paymentMethod;
  final String? paymentId;

  Order({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
    this.estimatedDelivery,
    required this.deliveryAddress,
    this.specialInstructions,
    required this.paymentMethod,
    this.paymentId,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'total': total,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'specialInstructions': specialInstructions,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      restaurantName: json['restaurantName'] as String,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'] as String)
          : null,
      deliveryAddress: json['deliveryAddress'] as String,
      specialInstructions: json['specialInstructions'] as String?,
      paymentMethod: json['paymentMethod'] as String,
      paymentId: json['paymentId'] as String?,
    );
  }

  Order copyWith({
    String? id,
    String? restaurantId,
    String? restaurantName,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? tax,
    double? total,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? estimatedDelivery,
    String? deliveryAddress,
    String? specialInstructions,
    String? paymentMethod,
    String? paymentId,
  }) {
    return Order(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
    );
  }
}

class OrderModel extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => List.from(_orders);
  List<Order> get activeOrders => _orders
      .where((order) => order.status != OrderStatus.delivered &&
          order.status != OrderStatus.cancelled)
      .toList();
  
  List<Order> get pastOrders => _orders
      .where((order) => order.status == OrderStatus.delivered ||
          order.status == OrderStatus.cancelled)
      .toList();

  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  Order? getOrder(String orderId) {
    return _orders.firstWhere((order) => order.id == orderId);
  }

  void clear() {
    _orders.clear();
    notifyListeners();
  }
}