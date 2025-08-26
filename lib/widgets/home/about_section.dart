import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Me',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'I am a passionate Flutter developer with experience in creating beautiful and functional mobile applications. '
            'I love working with the latest technologies and creating user-friendly interfaces.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Flutter',
              'Dart',
              'Firebase',
              'REST APIs',
              'Git',
              'UI/UX Design'
            ].map((skill) => Chip(
              label: Text(skill),
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            )).toList(),
          ),
        ],
      ),
    );
  }
}