import 'package:flutter/material.dart';
import '../models/testimonial.dart';
import '../core/services/testimonials_service.dart';

class TestimonialsProvider with ChangeNotifier {
  final TestimonialsService _testimonialsService = TestimonialsService();
  
  List<Testimonial> _testimonials = [];
  List<Testimonial> _featuredTestimonials = [];
  bool _isLoading = false;
  String? _error;

  List<Testimonial> get testimonials => _testimonials;
  List<Testimonial> get featuredTestimonials => _featuredTestimonials;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTestimonials() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _testimonials = await _testimonialsService.getTestimonials();
      _featuredTestimonials = await _testimonialsService.getFeaturedTestimonials();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading testimonials: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFeaturedTestimonials() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _featuredTestimonials = await _testimonialsService.getFeaturedTestimonials();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading featured testimonials: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
