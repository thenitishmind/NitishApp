import 'package:flutter/material.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final experiences = [
      {
        'title': 'Flutter Developer',
        'company': 'Tech Company',
        'duration': '2022 - Present',
        'description': 'Developing cross-platform mobile applications using Flutter and Dart.',
      },
      {
        'title': 'Mobile App Developer',
        'company': 'Startup Inc.',
        'duration': '2021 - 2022',
        'description': 'Built and maintained mobile applications for iOS and Android platforms.',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Experience',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          ...experiences.map((exp) => Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp['title'] as String,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${exp['company']} • ${exp['duration']}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exp['description'] as String,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}