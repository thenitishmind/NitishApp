import '../../models/testimonial.dart';

class TestimonialsService {
  static final TestimonialsService _instance = TestimonialsService._internal();
  factory TestimonialsService() => _instance;
  TestimonialsService._internal();

  // Real testimonials data - replace with actual client testimonials
  static const List<Map<String, dynamic>> _testimonialsData = [
    {
      'name': 'Saraswat Mukherjee',
      'role': 'Senior AI Engineer',
      'company': 'Microsoft',
      'testimonial': 'Working with Nitish was a great experience. His technical skills and attention to detail are truly impressive.',
      'avatar': null,
      'rating': 5.0,
    },
    {
      'name': 'Pankaj Kumar',
      'role': 'Cyber Security Specialist',
      'company': 'HCL',
      'testimonial': 'Nitish is a dedicated developer who consistently delivers high-quality code and innovative solutions.',
      'avatar': null,
      'rating': 5.0,
    },
    {
      'name': 'Aditi Sharma',
      'role': 'Student',
      'company': 'DPG College Haryana',
      'testimonial': 'Collaborating with Nitish resulted in an exceptional product that exceeded client expectations.',
      'avatar': null,
      'rating': 5.0,
    },
  ];

  Future<List<Testimonial>> getTestimonials() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _testimonialsData
        .map((data) => Testimonial.fromJson(data))
        .toList();
  }

  Future<List<Testimonial>> getFeaturedTestimonials({int limit = 3}) async {
    final testimonials = await getTestimonials();
    return testimonials.take(limit).toList();
  }
}
