import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/navigation_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return Drawer(
          backgroundColor: AppTheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.surface,
                  AppTheme.backgroundSecondary,
                ],
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        // Profile Image
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.textInverse.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.textInverse.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppTheme.textInverse,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Name and Title
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nitish Singh',
                                style: TextStyle(
                                  color: AppTheme.textInverse,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Full Stack Developer',
                                style: TextStyle(
                                  color: AppTheme.textInverse,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: navProvider.navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = navProvider.navigationItems[index];
                      final isActive = navProvider.currentIndex == index;
                      
                      return _buildDrawerItem(
                        context,
                        item.label,
                        item.icon,
                        item.activeIcon,
                        item.route,
                        isActive,
                        () {
                          navProvider.setCurrentIndex(index);
                          context.go(item.route);
                          Navigator.of(context).pop(); // Close drawer
                        },
                      );
                    },
                  ),
                ),
                
                // Footer
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Social Links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSocialButton(
                            context,
                            Icons.code,
                            'GitHub',
                            () {
                              // Open GitHub
                            },
                          ),
                          _buildSocialButton(
                            context,
                            Icons.work,
                            'LinkedIn',
                            () {
                              // Open LinkedIn
                            },
                          ),
                          _buildSocialButton(
                            context,
                            Icons.email,
                            'Email',
                            () {
                              context.go('/contact');
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Copyright
                      const Text(
                        '© 2024 Nitish Singh',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    IconData activeIcon,
    String route,
    bool isActive,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            isActive ? activeIcon : icon,
            key: ValueKey(isActive),
            color: isActive ? AppTheme.primary : AppTheme.textMuted,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppTheme.primary : AppTheme.textPrimary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 16,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tileColor: isActive
            ? AppTheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        onTap: onTap,
        trailing: isActive
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.border.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: AppTheme.textMuted,
            size: 20,
          ),
        ),
      ),
    );
  }
}