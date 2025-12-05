import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'models/cart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // GraphQL client simple pour Web/Desktop
  final HttpLink httpLink = HttpLink('http://localhost:4001/graphql');

  final GraphQLClient client = GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(),
  );

  runApp(
    GraphQLProvider(
      client: ValueNotifier(client),
      child: ChangeNotifierProvider(
        create: (_) => CartModel(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livriny',
      theme: ThemeData(primaryColor: const Color(0xFF8B0000)),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
