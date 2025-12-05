// lib/main.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'screens/home_screen.dart';
import 'services/graphql_service.dart';

void main() async {
  // Initialiser GraphQL
  await initHiveForFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: GraphQLService.clientNotifier,
      child: CacheProvider(
        child: MaterialApp(
          title: 'FoodExpress',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            scaffoldBackgroundColor: Colors.white,
          ),
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}