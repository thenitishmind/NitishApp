import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portfolio_project.dart';

class ProjectDetailScreen extends StatelessWidget {
  final PortfolioProject project;

  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.image,
                size: 80,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              project.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              project.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Technologies Used',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.technologies
                  .map((tech) => Chip(label: Text(tech)))
                  .toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (project.githubUrl != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(project.githubUrl!),
                      icon: const Icon(Icons.code),
                      label: const Text('View Code'),
                    ),
                  ),
                if (project.githubUrl != null && project.liveUrl != null)
                  const SizedBox(width: 16),
                if (project.liveUrl != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(project.liveUrl!),
                      icon: const Icon(Icons.launch),
                      label: const Text('Live Demo'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}