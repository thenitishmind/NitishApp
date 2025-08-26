class Testimonial {
  final String name;
  final String role;
  final String company;
  final String testimonial;
  final String? avatar;
  final double? rating;

  const Testimonial({
    required this.name,
    required this.role,
    required this.company,
    required this.testimonial,
    this.avatar,
    this.rating,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      name: json['name'] as String,
      role: json['role'] as String,
      company: json['company'] as String,
      testimonial: json['testimonial'] as String,
      avatar: json['avatar'] as String?,
      rating: json['rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'company': company,
      'testimonial': testimonial,
      'avatar': avatar,
      'rating': rating,
    };
  }
}
