import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muta_manager/screens/home_screen.dart';
import 'package:muta_manager/screens/map_screen.dart';
import 'package:muta_manager/screens/create_muta_screen.dart';
import 'package:muta_manager/screens/archive_screen.dart';
import 'package:muta_manager/theme/theme_provider.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Lista delle pagine principali della nostra app
        final List<Widget> _widgetOptions = <Widget>[
          const HomeScreen(),
          const MapScreen(),
          const CreateMutaScreen(),
          const ArchiveScreen(),
        ];

        return Scaffold(
          // Il body cambia in base alla selezione nel menu
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(child: child, opacity: animation);
            },
            child: Center(
              key: ValueKey<int>(_selectedIndex),
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ),
          // Il menu di navigazione
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                label: 'Home',
                activeIcon: Icon(
                  Icons.home,
                  color: themeProvider.currentPrimaryColor,
                ),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.map_outlined),
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
                icon: const Icon(Icons.archive_outlined),
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