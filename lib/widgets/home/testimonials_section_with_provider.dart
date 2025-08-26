import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/testimonials_provider.dart';

class TestimonialsSectionWithProvider extends StatefulWidget {
  const TestimonialsSectionWithProvider({super.key});

  @override
  State<TestimonialsSectionWithProvider> createState() => _TestimonialsSectionWithProviderState();
}

class _TestimonialsSectionWithProviderState extends State<TestimonialsSectionWithProvider> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TestimonialsProvider>().loadFeaturedTestimonials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Testimonials',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Consumer<TestimonialsProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (provider.error != null) {
                return Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load testimonials',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => provider.loadFeaturedTestimonials(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (provider.featuredTestimonials.isEmpty) {
                return const Center(
                  child: Text('No testimonials available'),
                );
              }

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.featuredTestimonials.length,
                  itemBuilder: (context, index) {
                    final testimonial = provider.featuredTestimonials[index];
                    return Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 16),
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  '"${testimonial.testimonial}"',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[300],
                                    child: testimonial.avatar != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child: Image.network(
                                              testimonial.avatar!,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Icon(Icons.person, color: Colors.grey);
                                              },
                                            ),
                                          )
                                        : const Icon(Icons.person, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          testimonial.name,
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${testimonial.role} at ${testimonial.company}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (testimonial.rating != null)
                                          Row(
                                            children: List.generate(5, (starIndex) {
                                              return Icon(
                                                starIndex < (testimonial.rating! - 0.5)
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                size: 12,
                                                color: Colors.amber,
                                              );
                                            }),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
