import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/graphql_service.dart';
import '../widgets/menu_item_card.dart';
import '../models/menu_item.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final String restaurantId;
  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Query(
        options: QueryOptions(
          document: gql(GraphQLService.restaurantQuery),
          variables: {'id': restaurantId},
        ),
        builder: (result, {refetch, fetchMore}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(child: Text(result.exception.toString()));
          }

          final restaurant = result.data?['restaurant'];
          if (restaurant == null) {
            return const Center(child: Text('Restaurant introuvable'));
          }

          // Sécurisation du menu
          final menuItems = (restaurant['menu'] as List<dynamic>?)
                  ?.map((item) => MenuItem.fromJson(item))
                  .toList() ??
              [];

          final bool isOpen = restaurant['isOpen'] ?? true;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(restaurant['name'] ?? ''),
                  background: Image.network(
                    restaurant['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey[300]),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Cuisine: ${restaurant['cuisine'] ?? ''}"),
                      Text(
                          "Rating: ${(restaurant['rating'] ?? 0).toStringAsFixed(1)}"),
                      Text("Adresse: ${restaurant['address'] ?? ''}"),
                      Text(
                          "Commande minimale: ${restaurant['minOrder']?.toStringAsFixed(2) ?? '0'}TND"),
                      Text(
                          "Temps de livraison: ${restaurant['deliveryTime'] ?? 0} min"),
                      const SizedBox(height: 16),
                      Text(
                        isOpen ? 'Menu disponible' : 'Restaurant fermé',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isOpen ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (menuItems.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      isOpen ? 'Aucun plat disponible pour le moment' : '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              if (menuItems.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final menuItem = menuItems[index];
                      return MenuItemCard(
                        menuItem: menuItem,
                        initialQuantity: 0,
                        isRestaurantOpen:
                            true, // ou récupéré depuis restaurant['isOpen']
                        onQuantityChanged: (qty) {
                          print('${menuItem.name} x $qty');
                        },
                      );
                    },
                    childCount: menuItems.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
