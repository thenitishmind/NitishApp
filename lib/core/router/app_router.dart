import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/home_screen.dart';
import '../../screens/about_screen.dart';
import '../../screens/projects_screen.dart';
import '../../screens/contact_screen.dart';
import '../../screens/project_detail_screen.dart';
import '../../widgets/common/main_layout.dart';
import '../../models/portfolio_project.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/about',
            name: 'about',
            builder: (context, state) => const AboutScreen(),
          ),
          GoRoute(
            path: '/projects',
            name: 'projects',
            builder: (context, state) => const ProjectsScreen(),
          ),
          GoRoute(
            path: '/projects/:id',
            name: 'project-detail',
            builder: (context, state) {
              final projectId = state.pathParameters['id']!;
              // Create a sample project for the detail view
              final project = PortfolioProject(
                id: projectId,
                title: 'Project Details',
                description: 'This is a detailed view of the selected project.',
                imageUrl: 'https://via.placeholder.com/600x400',
                technologies: ['Flutter', 'Dart', 'Firebase'],
                githubUrl: 'https://github.com/example/project',
                liveUrl: 'https://example.com',
              );
              return ProjectDetailScreen(project: project);
            },
          ),
          GoRoute(
            path: '/contact',
            name: 'contact',
            builder: (context, state) => const ContactScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text(
          'Page not found',
          style: TextStyle(fontSize: 24),
        ),
      ),
    ),
  );
}