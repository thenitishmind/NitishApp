import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isDrawerOpen = false;

  int get currentIndex => _currentIndex;
  bool get isDrawerOpen => _isDrawerOpen;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: '/',
    ),
    NavigationItem(
      label: 'About',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: '/about',
    ),
    NavigationItem(
      label: 'Projects',
      icon: Icons.work_outline,
      activeIcon: Icons.work,
      route: '/projects',
    ),
    NavigationItem(
      label: 'Contact',
      icon: Icons.contact_mail_outlined,
      activeIcon: Icons.contact_mail,
      route: '/contact',
    ),
  ];

  List<NavigationItem> get navigationItems => _navigationItems;

  void setCurrentIndex(int index) {
    if (index != _currentIndex && index >= 0 && index < _navigationItems.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void setCurrentRoute(String route) {
    final index = _navigationItems.indexWhere((item) => item.route == route);
    if (index != -1) {
      setCurrentIndex(index);
    }
  }

  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }

  void closeDrawer() {
    if (_isDrawerOpen) {
      _isDrawerOpen = false;
      notifyListeners();
    }
  }

  void openDrawer() {
    if (!_isDrawerOpen) {
      _isDrawerOpen = true;
      notifyListeners();
    }
  }
}

class NavigationItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  NavigationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}