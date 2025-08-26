import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/github_provider.dart';
import '../widgets/home/hero_section.dart';
import '../widgets/home/work_section.dart';
import '../widgets/home/projects_section.dart';
import '../widgets/home/testimonials_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GithubProvider>().refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // Hero Section
            const HeroSection(),
            
            // Work Section
            const WorkSection()
                .animate(delay: 200.ms)
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .slideY(begin: 0.1, end: 0),
            
            // Projects Section
            const ProjectsSection()
                .animate(delay: 400.ms)
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .slideY(begin: 0.1, end: 0),
            
            // Testimonials Section
            const TestimonialsSection()
                .animate(delay: 600.ms)
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .slideY(begin: 0.1, end: 0),
            
            // Footer spacing
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}