import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/project.dart';
import '../providers/github_provider.dart';
import '../core/theme/app_theme.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Web', 'Mobile', 'Backend'];

  // Helper function for responsive text sizes
  double _getResponsiveTextSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AppTheme.getResponsiveFontSize(screenWidth, baseSize);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<GithubProvider>(context, listen: false);
      provider.refreshData();
      provider.startPeriodicRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GithubProvider>(
      builder: (context, githubProvider, child) {
        final projects = githubProvider.getFilteredProjects(_selectedFilter);

        return Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.heroGradient,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppTheme.isMobile(MediaQuery.of(context).size.width) ? 40 : 60,
            ).add(AppTheme.getResponsivePadding(MediaQuery.of(context).size.width)),
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
                    '🚀 MY PROJECTS',
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
                  'Featured Projects',
                  style: TextStyle(
                    fontSize: _getResponsiveTextSize(context, 28),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: githubProvider.error != null 
                            ? AppTheme.warning.withValues(alpha: 0.1)
                            : AppTheme.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: githubProvider.error != null 
                              ? AppTheme.warning.withValues(alpha: 0.3)
                              : AppTheme.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: githubProvider.error != null 
                                  ? AppTheme.warning 
                                  : AppTheme.success,
                              shape: BoxShape.circle,
                            ),
                          ).animate(onPlay: (controller) => controller.repeat()).fadeIn().then().fadeOut(),
                          const SizedBox(width: 8),
                          Text(
                            githubProvider.error != null 
                                ? 'Connection Issues' 
                                : 'Live GitHub Data',
                            style: TextStyle(
                              fontSize: _getResponsiveTextSize(context, 13),
                              color: githubProvider.error != null 
                                  ? AppTheme.warning 
                                  : AppTheme.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Stack(
                      children: [
                        IconButton(
                          onPressed: githubProvider.isLoading 
                              ? null 
                              : () => githubProvider.forceRefresh(),
                          icon: githubProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          tooltip: githubProvider.isLoading ? 'Loading...' : 'Refresh Projects',
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.accent.withValues(alpha: 0.1),
                            foregroundColor: AppTheme.accent,
                          ),
                        ),
                        if (githubProvider.error != null)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${projects.length} Projects from GitHub',
                    style: TextStyle(
                      fontSize: _getResponsiveTextSize(context, 13),
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Filter Chips
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedFilter == filter;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          backgroundColor: AppTheme.surface.withValues(alpha: 0.5),
                          selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                          checkmarkColor: AppTheme.primary,
                          side: BorderSide(
                            color: isSelected 
                                ? AppTheme.primary 
                                : AppTheme.border.withValues(alpha: 0.3),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected 
                                ? AppTheme.primary 
                                : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          elevation: isSelected ? 2 : 0,
                          shadowColor: AppTheme.primary.withValues(alpha: 0.3),
                        ).animate(delay: (index * 100).ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Projects Grid
                Expanded(
                  child: githubProvider.isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                'Fetching latest projects from GitHub...',
                                style: TextStyle(
                                  fontSize: _getResponsiveTextSize(context, 14),
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(),
                        )
                      : githubProvider.error != null
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.error.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: AppTheme.error,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Failed to load projects',
                                      style: TextStyle(
                                        fontSize: _getResponsiveTextSize(context, 18),
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      githubProvider.error!,
                                      style: TextStyle(
                                        fontSize: _getResponsiveTextSize(context, 14),
                                        color: AppTheme.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () => githubProvider.forceRefresh(),
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Retry'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().scale(begin: const Offset(0.8, 0.8)),
                            )
                          : projects.isEmpty
                              ? Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surface.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppTheme.border.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.folder_open,
                                          size: 48,
                                          color: AppTheme.accent,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No projects found for $_selectedFilter',
                                          style: TextStyle(
                                            fontSize: _getResponsiveTextSize(context, 16),
                                            color: AppTheme.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).animate().scale(begin: const Offset(0.8, 0.8)),
                                )
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    final crossAxisCount = AppTheme.getGridColumns(constraints.maxWidth);
                                    final spacing = AppTheme.isMobile(constraints.maxWidth) ? 16.0 : 20.0;
                                    final aspectRatio = AppTheme.isMobile(constraints.maxWidth) ? 0.9 : 0.85;
                                    
                                    return GridView.builder(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio: aspectRatio,
                                        crossAxisSpacing: spacing,
                                        mainAxisSpacing: spacing,
                                      ),
                                      itemCount: projects.length,
                                      itemBuilder: (context, index) {
                                        final project = projects[index];
                                        return GitHubProjectCard(
                                          project: project,
                                        ).animate(delay: (index * 100).ms).scale(
                                          begin: const Offset(0.8, 0.8), 
                                          end: const Offset(1.0, 1.0),
                                          curve: AppTheme.smoothCurve,
                                        );
                                      },
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GitHubProjectCard extends StatelessWidget {
  final Project project;

  const GitHubProjectCard({
    super.key,
    required this.project,
  });

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
    final daysSinceUpdate = DateTime.now().difference(project.updatedAt).inDays;
    final isRecentlyUpdated = daysSinceUpdate < 30;
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.background.withValues(alpha: 0.95),
              AppTheme.backgroundSecondary.withValues(alpha: 0.9),
            ],
          ),
          border: Border.all(
            color: AppTheme.surface.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.15),
              blurRadius: 40,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _launchUrl(project.htmlUrl),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with status and stats
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      project.languageColor.withValues(alpha: 0.2),
                      project.languageColor.withValues(alpha: 0.1),
                      project.languageColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: project.languageColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badges
                    Row(
                      children: [
                        if (isRecentlyUpdated)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.success,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: _getResponsiveTextSize(context, 12),
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        if (project.language != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: project.languageColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: project.languageColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: project.languageColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  project.language!,
                                  style: TextStyle(
                                    fontSize: _getResponsiveTextSize(context, 11),
                                    color: project.languageColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Project icon and title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: project.languageColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: project.languageColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getLanguageIcon(project.language),
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                style: TextStyle(
                                  fontSize: _getResponsiveTextSize(context, 16),
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: 0.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Updated ${_getTimeAgo(daysSinceUpdate)}',
                                style: TextStyle(
                                  fontSize: _getResponsiveTextSize(context, 11),
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Content section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      if (project.description != null && project.description!.isNotEmpty)
                        Expanded(
                          child: Text(
                            project.description!,
                            style: TextStyle(
                              fontSize: _getResponsiveTextSize(context, 14),
                              color: AppTheme.textSecondary,
                              height: 1.5,
                              letterSpacing: 0.1,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        Expanded(
                          child: Text(
                            'A ${project.language ?? 'software'} project showcasing modern development practices.',
                            style: TextStyle(
                              fontSize: _getResponsiveTextSize(context, 14),
                              color: AppTheme.textMuted,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Stats row
                      Row(
                        children: [
                          _buildStatItem(
                            Icons.star_border_rounded,
                            project.stargazersCount.toString(),
                            AppTheme.warning,
                          ),
                          const SizedBox(width: 16),
                          _buildStatItem(
                            Icons.fork_right_rounded,
                            project.forksCount.toString(),
                            AppTheme.info,
                          ),
                          if (project.topics.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            _buildStatItem(
                              Icons.label_outline_rounded,
                              project.topics.length.toString(),
                              AppTheme.accent,
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _launchUrl(project.htmlUrl),
                              icon: const Icon(Icons.code_rounded, size: 16),
                              label: const Text('Source'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                side: BorderSide(color: project.languageColor.withValues(alpha: 0.5)),
                                foregroundColor: project.languageColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          if (project.homepage != null && project.homepage!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _launchUrl(project.homepage!),
                                icon: const Icon(Icons.launch_rounded, size: 16),
                                label: const Text('Live'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  backgroundColor: project.languageColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(int days) {
    if (days == 0) return 'today';
    if (days == 1) return 'yesterday';
    if (days < 7) return '$days days ago';
    if (days < 30) return '${(days / 7).floor()} weeks ago';
    if (days < 365) return '${(days / 30).floor()} months ago';
    return '${(days / 365).floor()} years ago';
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  IconData _getLanguageIcon(String? language) {
    switch (language?.toLowerCase()) {
      case 'javascript':
      case 'typescript':
        return Icons.code;
      case 'python':
        return Icons.data_object;
      case 'java':
        return Icons.coffee;
      case 'dart':
        return Icons.flutter_dash;
      case 'swift':
        return Icons.phone_iphone;
      case 'kotlin':
        return Icons.android;
      case 'go':
        return Icons.speed;
      case 'rust':
        return Icons.security;
      case 'html':
      case 'css':
        return Icons.web;
      case 'react':
      case 'vue':
        return Icons.web_asset;
      default:
        return Icons.code;
    }
  }
}
