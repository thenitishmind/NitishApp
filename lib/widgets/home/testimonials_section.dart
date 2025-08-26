import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/testimonials_service.dart';
import '../../models/testimonial.dart';
import '../../core/theme/app_theme.dart';

class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  final TestimonialsService _testimonialsService = TestimonialsService();
  List<Testimonial> testimonials = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTestimonials();
  }

  Future<void> _loadTestimonials() async {
    try {
      final fetchedTestimonials = await _testimonialsService.getFeaturedTestimonials();
      setState(() {
        testimonials = fetchedTestimonials;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Helper function for responsive text sizes
  double _getResponsiveTextSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return baseSize * 1.0;
    } else if (screenWidth > 800) {
      return baseSize * 0.95;
    } else if (screenWidth > 600) {
      return baseSize * 0.9;
    } else {
      return baseSize * 0.85;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.1),
                    AppTheme.accent.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                '✨ TESTIMONIALS',
                style: TextStyle(
                  fontSize: _getResponsiveTextSize(context, 12),
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
            
            const SizedBox(height: 20),
            
            Text(
              'What People Say',
              style: TextStyle(
                fontSize: _getResponsiveTextSize(context, 28),
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 12),
            
            Text(
              'Hear from professionals who have worked with me',
              style: TextStyle(
                fontSize: _getResponsiveTextSize(context, 16),
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 50),
            
            // Testimonials Content
            if (isLoading)
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        color: AppTheme.primary,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading testimonials...',
                      style: TextStyle(
                        fontSize: _getResponsiveTextSize(context, 14),
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ).animate().fadeIn(),
              )
            else if (testimonials.isEmpty)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.border.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No testimonials available',
                        style: TextStyle(
                          fontSize: _getResponsiveTextSize(context, 14),
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(begin: const Offset(0.8, 0.8)),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  // Determine the layout based on screen size
                  if (constraints.maxWidth > 1200) {
                    // Desktop: 3 columns
                    return _buildGridLayout(testimonials, 3);
                  } else if (constraints.maxWidth > 800) {
                    // Tablet: 2 columns
                    return _buildGridLayout(testimonials, 2);
                  } else if (constraints.maxWidth > 600) {
                    // Large mobile: horizontal scroll
                    return _buildHorizontalScrollLayout(testimonials);
                  } else {
                    // Small mobile: vertical stack
                    return _buildVerticalLayout(testimonials);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridLayout(List<Testimonial> testimonials, int columns) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: testimonials.asMap().entries.map((entry) {
        final index = entry.key;
        final testimonial = entry.value;
        return SizedBox(
          width: columns == 3 ? 350 : 400,
          child: _buildTestimonialCard(testimonial, index),
        );
      }).toList(),
    );
  }

  Widget _buildHorizontalScrollLayout(List<Testimonial> testimonials) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: testimonials.length,
        itemBuilder: (context, index) {
          final testimonial = testimonials[index];
          return Container(
            width: 320,
            margin: const EdgeInsets.only(right: 20),
            child: _buildTestimonialCard(testimonial, index),
          );
        },
      ),
    );
  }

  Widget _buildVerticalLayout(List<Testimonial> testimonials) {
    return Column(
      children: testimonials.asMap().entries.map((entry) {
        final index = entry.key;
        final testimonial = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildTestimonialCard(testimonial, index),
        );
      }).toList(),
    );
  }

  Widget _buildTestimonialCard(Testimonial testimonial, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surface.withValues(alpha: 0.9),
            AppTheme.surfaceElevated.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: AppTheme.elevation2,
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quote icon with better positioning
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.elevation1,
              ),
              child: const Icon(
                Icons.format_quote,
                color: Colors.white,
                size: 24,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Testimonial text with improved readability
            Flexible(
              child: Text(
                testimonial.testimonial,
                style: TextStyle(
                  fontSize: _getResponsiveTextSize(context, 16),
                  color: AppTheme.textSecondary,
                  height: 1.7,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Rating stars with better spacing
            if (testimonial.rating != null) ...[
              Row(
                children: List.generate(5, (starIndex) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      starIndex < (testimonial.rating?.round() ?? 0)
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 20,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
            ],
            
            // Author info with improved layout
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accent.withValues(alpha: 0.15),
                        AppTheme.primary.withValues(alpha: 0.15),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: testimonial.avatar != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(27),
                          child: Image.network(
                            testimonial.avatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person_rounded,
                                color: AppTheme.primary,
                                size: 28,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          color: AppTheme.primary,
                          size: 28,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testimonial.name,
                        style: TextStyle(
                          fontSize: _getResponsiveTextSize(context, 16),
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${testimonial.role} at ${testimonial.company}',
                        style: TextStyle(
                          fontSize: _getResponsiveTextSize(context, 13),
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 150).ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0, duration: 600.ms);
  }
}