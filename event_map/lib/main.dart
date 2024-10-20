import 'package:flutter/material.dart';
import 'AppNavigator.dart'; // Updated the import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Map App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AppNavigator(), // Use AppNavigator as the main navigator
    );
  }
}
