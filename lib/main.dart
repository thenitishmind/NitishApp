import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/github_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/testimonials_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F0F17),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const NitishPortfolioApp());
}

class NitishPortfolioApp extends StatelessWidget {
  const NitishPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final provider = GithubProvider();
          // Initialize with connection testing and automatic retry
          provider.initialize();
          return provider;
        }),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => TestimonialsProvider()),
      ],
      child: MaterialApp.router(
        title: 'Nitish Portfolio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}