import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;

    return Container(
      height: size.height * 0.9,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
      ),
      child: Stack(
        children: [
          // Animated background elements
          _buildBackgroundElements(),
          
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: isDesktop
                  ? _buildDesktopLayout(size)
                  : _buildMobileLayout(size),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(Size size) {
    return Row(
      children: [
        // Left side - Text content
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(right: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextContent(),
                const SizedBox(height: 48),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
        
        // Right side - Visual element
        Expanded(
          flex: 2,
          child: _buildHeroVisual(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Visual element
        SizedBox(
          height: size.height * 0.3,
          child: _buildHeroVisual(),
        ),
        
        const SizedBox(height: 48),
        
        // Text content
        _buildTextContent(),
        
        const SizedBox(height: 32),
        
        // Action buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting
        Text(
          'Hi, I\'m',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, curve: Curves.easeOut)
            .slideY(begin: 0.2, end: 0),
        
        const SizedBox(height: 8),
        
        // Name with gradient
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            'Nitish',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 600.ms, curve: Curves.easeOut)
            .slideY(begin: 0.2, end: 0)
            .then()
            .shimmer(duration: 2000.ms, color: AppTheme.primary.withValues(alpha: 0.3)),
        
        const SizedBox(height: 24),
        
        // Description
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.border.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            'A passionate developer building modern web applications and digital experiences that solve real-world problems.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        )
            .animate(delay: 400.ms)
            .fadeIn(duration: 600.ms, curve: Curves.easeOut)
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Primary CTA
        ElevatedButton.icon(
          onPressed: () => context.push('/projects'),
          icon: const Icon(Icons.work_outline),
          label: const Text('View Projects'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.textInverse,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: AppTheme.primary.withValues(alpha: 0.3),
          ),
        )
            .animate(delay: 600.ms)
            .fadeIn(duration: 600.ms, curve: Curves.easeOut)
            .slideY(begin: 0.2, end: 0)
            .then()
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.05, 1.05),
              duration: 2000.ms,
              curve: Curves.easeInOut,
            ),
        
        const SizedBox(width: 16),
        
        // Secondary CTA
        OutlinedButton.icon(
          onPressed: () {
            // Open GitHub profile
          },
          icon: const Icon(Icons.code),
          label: const Text('GitHub'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.textPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: BorderSide(
              color: AppTheme.border.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        )
            .animate(delay: 800.ms)
            .fadeIn(duration: 600.ms, curve: Curves.easeOut)
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildHeroVisual() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 32,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppTheme.surface.withValues(alpha: 0.1),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 120,
                      color: AppTheme.textPrimary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '👨‍💻',
                      style: TextStyle(fontSize: 48),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    )
        .animate(delay: 1000.ms)
        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }

  Widget _buildBackgroundElements() {
    return Stack(
      children: [
        // Floating circles
        Positioned(
          top: 100,
          left: 50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.1, 1.1),
                duration: 4000.ms,
                curve: Curves.easeInOut,
              ),
        ),
        
        Positioned(
          bottom: 100,
          right: 50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.2, 1.2),
                duration: 3000.ms,
                curve: Curves.easeInOut,
              ),
        ),
        
        Positioned(
          top: 200,
          right: 100,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.3, 1.3),
                duration: 5000.ms,
                curve: Curves.easeInOut,
              ),
        ),
      ],
    );
  }
}