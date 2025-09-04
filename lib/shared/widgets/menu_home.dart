import 'package:flutter/material.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/stations/screens/stations_screen.dart';
import '../../features/loans/screens/loans_screen.dart';
import '../../features/statistics/screens/statistics_screen.dart';

class MenuHome extends StatefulWidget {
  final int initialIndex; // Add this parameter

  const MenuHome({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MenuHome> createState() => _MenuHomeState();
}

class _MenuHomeState extends State<MenuHome> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    const HomeTab(),
    const StationsScreen(),
    const LoansScreen(),
    const StatisticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Initialize with the passed index
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent duplication of MenuHome on back navigation
        if (_selectedIndex == 0) {
          return true; // Allow default back behavior
        } else {
          setState(() => _selectedIndex = 0); // Navigate to HomeTab
          return false; // Prevent default back behavior
        }
      },
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Estaciones',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Préstamos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Estadísticas',
            ),
          ],
        ),
      ),
    );
  }
}
