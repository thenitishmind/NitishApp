import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/navigation_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;

  const CustomAppBar({
    super.key,
    this.onMenuPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;

    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return AppBar(
          backgroundColor: AppTheme.surface.withValues(alpha: 0.95),
          elevation: 0,
          scrolledUnderElevation: 8,
          surfaceTintColor: AppTheme.primary.withValues(alpha: 0.1),
          
          // Leading widget
          leading: isDesktop
              ? null
              : IconButton(
                  onPressed: onMenuPressed,
                  icon: const Icon(Icons.menu),
                  color: AppTheme.textPrimary,
                ),
          
          // Title
          title: Row(
            children: [
              // Logo/Brand
              GestureDetector(
                onTap: () => context.go('/'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Nitish',
                    style: TextStyle(
                      color: AppTheme.textInverse,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              
              // Desktop Navigation
              if (isDesktop) ...[
                const SizedBox(width: 32),
                Expanded(
                  child: Row(
                    children: navProvider.navigationItems
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isActive = navProvider.currentIndex == index;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildNavItem(
                          context,
                          item.label,
                          item.route,
                          isActive,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
          
          // Actions
          actions: isDesktop
              ? [
                  // GitHub Button
                  IconButton(
                    onPressed: () {
                      // Open GitHub profile
                    },
                    icon: const Icon(Icons.code),
                    tooltip: 'GitHub Profile',
                    color: AppTheme.textPrimary,
                  ),
                  const SizedBox(width: 16),
                ]
              : null,
          
          // Backdrop blur effect
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.surface.withValues(alpha: 0.95),
                  AppTheme.surface.withValues(alpha: 0.85),
                ],
              ),
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String label,
    String route,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive
              ? AppTheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          border: isActive
              ? Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.primary : AppTheme.textPrimary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 16,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}