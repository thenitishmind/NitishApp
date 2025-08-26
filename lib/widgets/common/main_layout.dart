import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/navigation_provider.dart';
import 'custom_app_bar.dart';
import 'custom_bottom_nav.dart';
import 'custom_drawer.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Update navigation provider based on current route
    final String location = GoRouterState.of(context).uri.toString();
    context.read<NavigationProvider>().setCurrentRoute(location);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppTheme.background,
          
          // Custom App Bar
          appBar: CustomAppBar(
            onMenuPressed: () {
              if (MediaQuery.of(context).size.width < 768) {
                _scaffoldKey.currentState?.openDrawer();
              }
            },
          ),
          
          // Custom Drawer for mobile
          drawer: MediaQuery.of(context).size.width < 768
              ? const CustomDrawer()
              : null,
          
          // Body with animated container
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.background,
                  AppTheme.backgroundSecondary,
                ],
                stops: [0.0, 1.0],
              ),
            ),
            child: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                child: widget.child,
              ),
            ),
          ),
          
          // Bottom Navigation for mobile
          bottomNavigationBar: MediaQuery.of(context).size.width < 768
              ? const CustomBottomNav()
              : null,
          
          // Floating Action Button for larger screens
          floatingActionButton: MediaQuery.of(context).size.width >= 768
              ? FloatingActionButton.extended(
                  onPressed: () {
                    context.push('/contact');
                  },
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.textInverse,
                  icon: const Icon(Icons.contact_mail),
                  label: const Text('Contact Me'),
                  elevation: 8,
                  extendedPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                )
              : null,
        );
      },
    );
  }
}