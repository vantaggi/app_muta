import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_muta/screens/home_screen.dart';
import 'package:app_muta/screens/map_screen.dart';
import 'package:app_muta/screens/create_muta_screen.dart';
import 'package:app_muta/screens/archive_screen.dart';
import 'package:app_muta/theme/theme_provider.dart';

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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          // Il body cambia in base alla selezione nel menu
          body: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          // Il menu di navigazione
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: 'Home',
                activeIcon: Icon(
                  Icons.home,
                  color: themeProvider.currentPrimaryColor,
                ),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.map),
                label: 'Mappa',
                activeIcon: Icon(
                  Icons.map,
                  color: themeProvider.currentPrimaryColor,
                ),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.add_circle_outline),
                label: 'Crea',
                activeIcon: Icon(
                  Icons.add_circle,
                  color: themeProvider.currentPrimaryColor,
                ),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.archive),
                label: 'Archivio',
                activeIcon: Icon(
                  Icons.archive,
                  color: themeProvider.currentPrimaryColor,
                ),
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: themeProvider.currentPrimaryColor,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          ),
        );
      },
    );
  }
}