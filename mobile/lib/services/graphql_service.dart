// lib/services/graphql_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';


class GraphQLService {
  // URL du backend - ADAPTE SELON TON ÉMULATEUR
  //static const String graphqlUrl = 'http://10.0.2.2:4001/graphql'; // Android
  static const String graphqlUrl = 'http://localhost:4001/graphql'; // iOS/Web

  static final HttpLink httpLink = HttpLink(graphqlUrl);

  static final GraphQLClient client = GraphQLClient(
    cache: GraphQLCache(),
    link: httpLink,
  );

  static final ValueNotifier<GraphQLClient> clientNotifier = ValueNotifier(client);

  // ============ QUERIES ============
  

  static String restaurantQuery = '''
  query GetRestaurant(\$id: ID!) {
    restaurant(id: \$id) {
      id
      name
      cuisine
      rating
      deliveryTime
      address
      imageUrl
      minOrder
      isOpen
      menu {
        id
        name
        description
        price
        category
        available
      }
    }
  }
''';



  static String get dashboardQuery => '''
    query GetDashboard {
      dashboard {
        activeOrders {
          id
          status
          total
          estimatedDelivery
          restaurant {
            name
          }
        }
        favoriteRestaurants {
          id
          name
          cuisine
          rating
        }
        cart {
          items {
            itemId
            name
            quantity
            price
          }
          total
        }
      }
    }
  ''';

  static String get cartQuery => '''
    query GetCart {
      myCart {
        items {
          itemId
          name
          quantity
          price
        }
        subtotal
        deliveryFee
        tax
        total
        restaurant {
          id
          name
        }
      }
    }
  ''';

  // ============ MUTATIONS ============
  
  static String get addToCartMutation => '''
    mutation AddToCart(\$itemId: ID!, \$quantity: Int!) {
      addToCart(itemId: \$itemId, quantity: \$quantity) {
        items {
          itemId
          name
          quantity
          price
        }
        total
      }
    }
  ''';

  static String get updateCartItemMutation => '''
    mutation UpdateCartItem(\$itemId: ID!, \$quantity: Int!) {
      updateCartItem(itemId: \$itemId, quantity: \$quantity) {
        items {
          itemId
          name
          quantity
          price
        }
        total
      }
    }
  ''';

  static String get removeFromCartMutation => '''
    mutation RemoveFromCart(\$itemId: ID!) {
      removeFromCart(itemId: \$itemId) {
        items {
          itemId
          name
          quantity
        }
        total
      }
    }
  ''';

  static String get clearCartMutation => '''
    mutation ClearCart {
      clearCart {
        items {
          name
        }
        total
      }
    }
  ''';

  static String get placeOrderMutation => '''
  mutation PlaceOrder(\$input: OrderInput!) {
    placeOrder(input: \$input) {
      order {
        id
        status
        total
        deliveryAddress
        estimatedDelivery
        items {
          name
          quantity
          price
        }
        restaurant {
          id
          name
        }
        driver {
          id
          name
          phone
        }
        createdAt
      }
      paymentIntent {
        id
        clientSecret
        amount
        currency
      }
    }
  }
''';
  static const String toggleFavoriteMutation = '''
  mutation ToggleFavorite(\$restaurantId: ID!) {
    toggleFavorite(restaurantId: \$restaurantId) {
      id
      favorites {
        id
        name
        isFavorite
      }
    }
  }
''';



  // ============ MÉTHODES UTILES ============
  
  static GraphQLClient getClient() {
    return client;
  }
}

// Provider pour GraphQL
class GraphQLProviderWidget extends StatelessWidget {
  final Widget child;

  const GraphQLProviderWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: GraphQLService.clientNotifier,
      child: CacheProvider(
        child: child,
      ),
    );
  }
}