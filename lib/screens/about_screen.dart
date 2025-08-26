import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/github_provider.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackbar('Could not open the link. Please try again later.');
      }
    } catch (e) {
      _showErrorSnackbar('An error occurred while opening the link.');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = AppTheme.isMobile(size.width);
    final isTablet = AppTheme.isTablet(size.width);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: isMobile 
          ? _buildMobileLayout() 
          : isTablet
            ? _buildTabletLayout()
            : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(),
          _buildTabNavigation(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(),
          _buildTabNavigation(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildProfileSidebar(),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildTabNavigation(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Consumer<GithubProvider>(
      builder: (context, githubProvider, child) {
        final user = githubProvider.user;
        
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: user?.avatarUrl ?? 'https://github.com/thenitishmind.png',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ).animate().scale(delay: 200.ms, duration: 600.ms),
              const SizedBox(height: 20),
              Text(
                user?.name ?? 'Nitish Singh',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 8),
              Text(
                user?.bio ?? 'Full Stack Developer',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 600.ms),
              if (user?.location != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user!.location!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 800.ms),
              ],
              if (user?.publicRepos != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      'Repositories',
                      user!.publicRepos.toString(),
                      Icons.folder,
                    ),
                    _buildStatCard(
                      'Followers',
                      user.followers.toString(),
                      Icons.people,
                    ),
                    _buildStatCard(
                      'Following',
                      user.following.toString(),
                      Icons.person_add,
                    ),
                  ],
                ).animate().fadeIn(delay: 1000.ms),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileSidebar() {
    return Consumer<GithubProvider>(
      builder: (context, githubProvider, child) {
        final user = githubProvider.user;
        
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: user?.avatarUrl ?? 'https://github.com/thenitishmind.png',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ).animate().scale(delay: 200.ms, duration: 600.ms),
              const SizedBox(height: 16),
              Text(
                user?.name ?? 'Nitish Singh',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 8),
              Text(
                user?.bio ?? 'Full Stack Developer',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 600.ms),
              if (user?.location != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        user!.location!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 800.ms),
              ],
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _launchURL(user?.htmlUrl ?? 'https://github.com/thenitishmind'),
                icon: const Icon(Icons.code),
                label: const Text('GitHub Profile'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
              if (user?.publicRepos != null) ...[
                const SizedBox(height: 20),
                _buildStatCard('Repositories', user!.publicRepos.toString(), Icons.code),
                const SizedBox(height: 12),
                _buildStatCard('Followers', user.followers.toString(), Icons.people),
                const SizedBox(height: 12),
                _buildStatCard('Following', user.following.toString(), Icons.star),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(25),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(25),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'About'),
            Tab(text: 'Skills'),
            Tab(text: 'Experience'),
            Tab(text: 'Education'),
            Tab(text: 'Contact'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildAboutTab(),
        _buildSkillsTab(),
        _buildExperienceTab(),
        _buildEducationTab(),
        _buildContactTab(),
      ],
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'About Me',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            'I\'m a passionate Full Stack Developer with expertise in mobile and web development. I love creating beautiful, functional applications that solve real-world problems. With a strong background in Flutter, React, Node.js, and various other technologies, I\'m always eager to take on new challenges and learn cutting-edge technologies.',
            style: Theme.of(context).textTheme.bodyLarge,
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 24),
          Text(
            'What I Do',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 16),
          _buildFeatureCard(
            'Mobile Development',
            'Creating cross-platform mobile applications using Flutter with beautiful UI/UX and optimal performance.',
            Icons.phone_android,
          ).animate().fadeIn(delay: 800.ms),
          const SizedBox(height: 16),
          _buildFeatureCard(
            'Web Development',
            'Building responsive web applications using React, Next.js, and modern web technologies.',
            Icons.web,
          ).animate().fadeIn(delay: 1000.ms),
          const SizedBox(height: 16),
          _buildFeatureCard(
            'Backend Development',
            'Developing robust APIs and backend services using Node.js, Express, and various databases.',
            Icons.storage,
          ).animate().fadeIn(delay: 1200.ms),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Technical Skills',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 20),
          _buildSkillCategory('Mobile Development', [
            'Flutter', 'Dart', 'Android', 'iOS', 'Firebase'
          ]).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 16),
          _buildSkillCategory('Web Development', [
            'React', 'Next.js', 'JavaScript', 'TypeScript', 'HTML/CSS'
          ]).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 16),
          _buildSkillCategory('Backend Development', [
            'Node.js', 'Express', 'MongoDB', 'PostgreSQL', 'REST APIs'
          ]).animate().fadeIn(delay: 800.ms),
          const SizedBox(height: 16),
          _buildSkillCategory('Tools & Technologies', [
            'Git', 'Docker', 'AWS', 'VS Code', 'Figma'
          ]).animate().fadeIn(delay: 1000.ms),
        ],
      ),
    );
  }

  Widget _buildSkillCategory(String title, List<String> skills) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((skill) => _buildSkillChip(skill)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        skill,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildExperienceTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Professional Experience',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 20),
          _buildExperienceCard(
            'Senior Full Stack Developer',
            'Tech Solutions Inc.',
            '2022 - Present',
            'Leading development of mobile and web applications using Flutter and React. Mentoring junior developers and architecting scalable solutions.',
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 16),
          _buildExperienceCard(
            'Mobile App Developer',
            'Digital Innovations Ltd.',
            '2020 - 2022',
            'Developed multiple successful mobile applications using Flutter. Collaborated with design teams to create beautiful and intuitive user interfaces.',
          ).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 16),
          _buildExperienceCard(
            'Frontend Developer',
            'Web Masters Agency',
            '2019 - 2020',
            'Built responsive web applications using React and modern JavaScript. Worked closely with clients to deliver high-quality web solutions.',
          ).animate().fadeIn(delay: 800.ms),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(String position, String company, String duration, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            position,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.business,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                company,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                duration,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEducationTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Education',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 20),
          _buildEducationCard(
            'Bachelor of Technology',
            'Computer Science & Engineering',
            'XYZ University',
            '2018 - 2022',
            'Graduated with honors. Specialized in software development and algorithms.',
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 16),
          _buildEducationCard(
            'Certifications',
            'Google Flutter Developer',
            'Google',
            '2021',
            'Certified Flutter developer with expertise in cross-platform mobile development.',
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildEducationCard(String degree, String field, String institution, String duration, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            degree,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            field,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.school,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                institution,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                duration,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Get In Touch',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            'I\'m always interested in new opportunities and exciting projects. Feel free to reach out!',
            style: Theme.of(context).textTheme.bodyLarge,
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 24),
          _buildContactCard(
            'Email',
            'nitish@example.com',
            Icons.email,
            'mailto:nitish@example.com',
          ).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 16),
          _buildContactCard(
            'GitHub',
            'github.com/thenitishmind',
            Icons.code,
            'https://github.com/thenitishmind',
          ).animate().fadeIn(delay: 800.ms),
          const SizedBox(height: 16),
          _buildContactCard(
            'LinkedIn',
            'linkedin.com/in/nitishsingh',
            Icons.business,
            'https://linkedin.com/in/nitishsingh',
          ).animate().fadeIn(delay: 1000.ms),
          const SizedBox(height: 16),
          _buildContactCard(
            'Phone',
            '+1 (555) 123-4567',
            Icons.phone,
            'tel:+15551234567',
          ).animate().fadeIn(delay: 1200.ms),
        ],
      ),
    );
  }

  Widget _buildContactCard(String title, String value, IconData icon, String url) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _launchURL(url),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
