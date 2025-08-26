import 'package:flutter/material.dart';

class Project {
  final int id;
  final String name;
  final String fullName;
  final String? description;
  final String htmlUrl;
  final String? homepage;
  final String? language;
  final int stargazersCount;
  final int forksCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> topics;
  final bool archived;
  final String? license;

  Project({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    required this.htmlUrl,
    this.homepage,
    this.language,
    required this.stargazersCount,
    required this.forksCount,
    required this.createdAt,
    required this.updatedAt,
    required this.topics,
    required this.archived,
    this.license,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      fullName: json['full_name'],
      description: json['description'],
      htmlUrl: json['html_url'],
      homepage: json['homepage'],
      language: json['language'],
      stargazersCount: json['stargazers_count'] ?? 0,
      forksCount: json['forks_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      topics: List<String>.from(json['topics'] ?? []),
      archived: json['archived'] ?? false,
      license: json['license']?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'description': description,
      'html_url': htmlUrl,
      'homepage': homepage,
      'language': language,
      'stargazers_count': stargazersCount,
      'forks_count': forksCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'topics': topics,
      'archived': archived,
      'license': license,
    };
  }

  // Helper methods
  String get displayName => name.replaceAll('-', ' ').replaceAll('_', ' ');
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Portfolio-specific properties for display
  String get title => displayName;
  String? get imageUrl {
    // Generate a GitHub social preview image if available
    if (htmlUrl.isNotEmpty) {
      final parts = htmlUrl.split('/');
      if (parts.length >= 5) {
        final owner = parts[3];
        final repo = parts[4];
        return 'https://opengraph.githubassets.com/1/$owner/$repo';
      }
    }
    return null;
  }
  List<String> get technologies => [language ?? 'Unknown'];
  String? get githubUrl => htmlUrl;
  String? get liveUrl => homepage;

  Color get languageColor {
    switch (language?.toLowerCase()) {
      case 'javascript':
        return const Color(0xFFFACC15); // Yellow-400
      case 'typescript':
        return const Color(0xFF3B82F6); // Blue-500
      case 'python':
        return const Color(0xFF22C55E); // Green-500
      case 'java':
        return const Color(0xFFEF4444); // Red-500
      case 'dart':
        return const Color(0xFF06B6D4); // Cyan-500
      case 'swift':
        return const Color(0xFFF97316); // Orange-500
      case 'kotlin':
        return const Color(0xFF8B5CF6); // Purple-500
      case 'go':
        return const Color(0xFF06B6D4); // Cyan-500
      case 'rust':
        return const Color(0xFFF97316); // Orange-500
      case 'c++':
        return const Color(0xFF8B5CF6); // Purple-500
      case 'c#':
        return const Color(0xFF10B981); // Green-500
      case 'php':
        return const Color(0xFF6366F1); // Indigo-500
      case 'ruby':
        return const Color(0xFFEF4444); // Red-500
      case 'html':
        return const Color(0xFFF97316); // Orange-500
      case 'css':
        return const Color(0xFF3B82F6); // Blue-500
      case 'vue':
        return const Color(0xFF10B981); // Green-500
      case 'react':
        return const Color(0xFF06B6D4); // Cyan-500
      default:
        return const Color(0xFF6B7280); // Gray-500
    }
  }
}