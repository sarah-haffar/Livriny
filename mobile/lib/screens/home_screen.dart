import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'restaurant_detail_screen.dart';
import 'checkout_screen.dart'; // Assure-toi d'importer ton écran de panier
import '/widgets/cart_badge.dart'; // Assure-toi que CartBadge est défini
import '/widgets/cart_bottom_sheet.dart'; // Assure-toi que CartBottomSheet est défini

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";

  static String get restaurantsQuery => '''
  query GetRestaurants {
    restaurants {
      id
      name
      cuisine
      rating
      deliveryTime
      isOpen
      address
      imageUrl
      minOrder
    }
  }
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Livriny"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                builder: (_) => const CartBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Champ de recherche
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un restaurant ou cuisine...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Liste des restaurants
          Expanded(
            child: Query(
              options: QueryOptions(document: gql(restaurantsQuery)),
              builder: (result, {refetch, fetchMore}) {
                if (result.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (result.hasException) {
                  return Center(child: Text(result.exception.toString()));
                }

                List restaurants = result.data?['restaurants'] ?? [];

                // Filtrer par nom ou cuisine
                if (searchQuery.isNotEmpty) {
                  restaurants = restaurants.where((r) {
                    final name = (r['name'] ?? '').toLowerCase();
                    final cuisine = (r['cuisine'] ?? '').toLowerCase();
                    return name.contains(searchQuery) || cuisine.contains(searchQuery);
                  }).toList();
                }

                if (restaurants.isEmpty) {
                  return const Center(child: Text("Aucun restaurant trouvé"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final r = restaurants[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            r['imageUrl'] ?? '',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.restaurant),
                            ),
                          ),
                        ),
                        title: Text(
                          r['name'] ?? 'Nom inconnu',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text("${r['cuisine'] ?? 'Cuisine inconnue'} • ⭐ ${(r['rating'] ?? 0).toStringAsFixed(1)}"),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RestaurantDetailScreen(restaurantId: r['id']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
