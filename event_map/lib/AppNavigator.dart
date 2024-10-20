import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'MapPage.dart';
import 'ChatPage.dart';
import 'ProfilePage.dart';
import 'Widgets/NavBar.dart';

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  _AppNavigatorState createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int _selectedIndex = 1; // Start with the Map Page by default

  // Define your pages
  final List<Widget> _pages = [
    const HomePage(),
    const MapPage(),
    const ChatPage(),
    const ProfilePage(),
  ];

  // Handle bottom navigation tap
  void _onBarIconTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages, // Display the selected page
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onBarIconTapped: _onBarIconTapped, // Change page on tap
      ),
    );
  }
}
