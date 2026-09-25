import 'package:flutter/material.dart';

import '../features/profile/presentation/profile_screen.dart';
import '../features/stylist/presentation/stylist_screen.dart';
import '../features/try_on/domain/try_on_repository.dart';
import '../features/try_on/presentation/studio_screen.dart';
import '../features/wardrobe/presentation/wardrobe_screen.dart';

class MainShell extends StatefulWidget {
  final TryOnRepository repository;
  final bool isDarkMode;
  final ValueChanged<bool> onToggleTheme;

  const MainShell({
    super.key,
    required this.repository,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      StudioScreen(repository: widget.repository),
      const WardrobeScreen(),
      StylistScreen(repository: widget.repository),
      ProfileScreen(
        repository: widget.repository,
        isDarkMode: widget.isDarkMode,
        onToggleTheme: widget.onToggleTheme,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'Studio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom_outlined),
            activeIcon: Icon(Icons.checkroom),
            label: 'Wardrobe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style_outlined),
            activeIcon: Icon(Icons.style),
            label: 'Stylist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
