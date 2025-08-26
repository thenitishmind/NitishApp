import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/navigation_provider.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.95),
            border: Border(
              top: BorderSide(
                color: AppTheme.border.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: const ColorFilter.mode(
                Colors.transparent,
                BlendMode.overlay,
              ),
              child: BottomNavigationBar(
                currentIndex: navProvider.currentIndex,
                onTap: (index) {
                  navProvider.setCurrentIndex(index);
                  context.go(navProvider.navigationItems[index].route);
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: AppTheme.primary,
                unselectedItemColor: AppTheme.textMuted,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                items: navProvider.navigationItems
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isActive = navProvider.currentIndex == index;
                  
                  return BottomNavigationBarItem(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: Container(
                        key: ValueKey(isActive),
                        padding: const EdgeInsets.all(8),
                        decoration: isActive
                            ? BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primary.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              )
                            : null,
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          size: 24,
                        ),
                      ),
                    ),
                    label: item.label,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}