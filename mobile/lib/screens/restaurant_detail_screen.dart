// lib/screens/restaurant_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import '../services/graphql_service.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  String selectedCategory = 'Tous';
  Map<String, int> cartQuantities = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Query(
        options: QueryOptions(
          document: gql(GraphQLService.restaurantQuery),
          variables: {'id': widget.restaurantId},
        ),
        builder: (QueryResult result, {fetchMore, refetch}) {
          if (result.isLoading) {
            return _buildLoadingScreen();
          }

          if (result.hasException) {
            return _buildErrorScreen(result.exception.toString(), refetch);
          }

          final restaurant = result.data?['restaurant'];
          final menu = restaurant?['menu'] ?? [];

          // Extraire les catégories uniques
          final categories = <String>['Tous'];
          final Set<String> uniqueCategories = {};

          for (final item in menu) {
            final category = item['category'] as String?;
            if (category != null && !uniqueCategories.contains(category)) {
              uniqueCategories.add(category);
              categories.add(category);
            }
          }
          // Filtrer les items par catégorie
          final filteredMenu = selectedCategory == 'Tous'
              ? menu
              : menu
                  .where((item) => item['category'] == selectedCategory)
                  .toList();

          return CustomScrollView(
            slivers: [
              // AppBar avec image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF8B0000).withOpacity(0.8),
                          Color(0xFF8B0000).withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getCuisineIcon(restaurant?['cuisine'] ?? ''),
                        size: 100,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                  title: Text(
                    restaurant?['name'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Informations du restaurant
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Note
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFD700),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 16, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  (restaurant?['rating'] ?? 0)
                                      .toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Temps de livraison
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(0xFF8B0000),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 16, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  '${restaurant?['deliveryTime'] ?? 0} min',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Favori
                          IconButton(
                            onPressed: () {
                              // Toggle favorite
                            },
                            icon: Icon(
                              restaurant?['isFavorite'] ?? false
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Color(0xFF8B0000),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Cuisine
                      Row(
                        children: [
                          Icon(Icons.restaurant_menu,
                              size: 20, color: Color(0xFF8B0000)),
                          const SizedBox(width: 8),
                          Text(
                            restaurant?['cuisine'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Adresse
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on,
                              size: 20, color: Color(0xFF8B0000)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              restaurant?['address'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Commande minimale
                      Row(
                        children: [
                          Icon(Icons.euro_symbol,
                              size: 20, color: Color(0xFF8B0000)),
                          const SizedBox(width: 8),
                          Text(
                            'Commande minimale: ${restaurant?['minOrder'].toStringAsFixed(2)}€',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Filtres de catégorie
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.grey[50],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((category) {
                        final isSelected = category == selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            selectedColor: Color(0xFF8B0000),
                            labelStyle: TextStyle(
                              color:
                                  isSelected ? Colors.white : Color(0xFF8B0000),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: isSelected
                                    ? Color(0xFF8B0000)
                                    : Colors.grey[300]!,
                              ),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              // Menu items
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filteredMenu[index];
                    final quantity = cartQuantities[item['id']] ?? 0;

                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['name'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (item['available'] == false)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Indisponible',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (item['description'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        item['description'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF8B0000)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item['category'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF8B0000),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${item['price'].toStringAsFixed(2)}€',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF8B0000),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: filteredMenu.length,
                ),
              ),
            ],
          );
        },
      ),
      // Bouton d'action flottant
      floatingActionButton: Mutation(
        options: MutationOptions(
          document: gql(GraphQLService.addToCartMutation),
        ),
        builder: (runMutation, mutationResult) {
          return FloatingActionButton.extended(
            onPressed: () {
              // Logique pour ajouter plusieurs items
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Color(0xFF8B0000),
                  content: const Text('Fonctionnalité à implémenter'),
                ),
              );
            },
            backgroundColor: Color(0xFF8B0000),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Voir le panier'),
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8B0000),
        title: const Text('Chargement...'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF8B0000)),
            const SizedBox(height: 20),
            const Text('Chargement du restaurant...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error, Function? refetch) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8B0000),
        title: const Text('Erreur'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFF8B0000),
              ),
              const SizedBox(height: 20),
              const Text(
                'Impossible de charger le restaurant',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              if (refetch != null)
                ElevatedButton(
                  onPressed: () => refetch(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B0000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Réessayer'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCuisineIcon(String cuisine) {
    switch (cuisine.toLowerCase()) {
      case 'italien':
        return Icons.local_pizza;
      case 'japonais':
        return Icons.set_meal;
      case 'américain':
        return Icons.fastfood;
      case 'français':
        return Icons.breakfast_dining;
      default:
        return Icons.restaurant_menu;
    }
  }
}
