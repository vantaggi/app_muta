import 'package:flutter/material.dart';
import 'package:app_muta/screens/home_screen.dart';
import 'package:app_muta/screens/map_screen.dart';
import 'package:app_muta/screens/create_muta_screen.dart';
import 'package:app_muta/screens/archive_screen.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  // Lista delle pagine principali della nostra app
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    MapScreen(),
    CreateMutaScreen(),
    ArchiveScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Il body cambia in base alla selezione nel menu
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // Il menu di navigazione
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mappa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Crea',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: 'Archivio',
          ),
        ],
        currentIndex: _selectedIndex,
        // Usiamo i colori del tema corrente per la navigazione
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Mantiene lo stile fisso
      ),
    );
  }
}