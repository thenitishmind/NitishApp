import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import '../models/project.dart';
import '../models/github_user.dart';
import '../core/config/github_config.dart';

/// GitHub API Provider for fetching user and repository data
/// 
/// Configuration is now centralized in GitHubConfig class.
/// See lib/core/config/github_config.dart for setup instructions.
class GithubProvider extends ChangeNotifier {
  List<Project> _projects = [];
  List<Project> _featuredProjects = [];
  List<Project> _recentProjects = [];
  GithubUser? _user;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetch;
  Timer? _periodicTimer;
  
  // Rate limiting
  int _rateLimitRemaining = 60;
  DateTime? _rateLimitReset;
  
  // Cache duration (configurable)
  static const Duration _cacheDuration = Duration(minutes: GitHubConfig.cacheMinutes);

  // Getters
  List<Project> get projects => _projects;
  List<Project> get featuredProjects => _featuredProjects;
  List<Project> get recentProjects => _recentProjects;
  GithubUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get rateLimitRemaining => _rateLimitRemaining;
  DateTime? get rateLimitReset => _rateLimitReset;
  bool get hasData => _projects.isNotEmpty || _user != null;
  
  // Check if cache is still valid
  bool get isCacheValid {
    if (_lastFetch == null) return false;
    return DateTime.now().difference(_lastFetch!) < _cacheDuration;
  }

  Future<void> fetchProjects({int retryCount = 0}) async {
    // Skip if cache is still valid and not force refresh
    if (isCacheValid && _projects.isNotEmpty && retryCount == 0) {
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check rate limiting
      if (_rateLimitRemaining <= 1 && _rateLimitReset != null) {
        final timeUntilReset = _rateLimitReset!.difference(DateTime.now());
        if (timeUntilReset.inSeconds > 0) {
          throw Exception('GitHub API rate limit exceeded. Try again in ${timeUntilReset.inMinutes + 1} minutes.');
        }
      }
      
      // Progressive timeout: configurable base + retries
      final timeoutDuration = Duration(seconds: GitHubConfig.baseTimeoutSeconds + (retryCount * 5));
      
      // Fetch all repositories with pagination - improved to show ALL projects
      List<dynamic> allRepos = [];
      int page = 1;
      const int perPage = GitHubConfig.maxPerPage; // Maximum per page allowed by GitHub API
      
      while (true) {
        // Simple GitHub API call - get all public repositories
        final uri = Uri.parse('${GitHubConfig.baseUrl}/users/${GitHubConfig.username}/repos?sort=updated&per_page=$perPage&page=$page');
        debugPrint('Fetching page $page from: $uri');
        
        final response = await http.get(
          uri,
          headers: {
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': GitHubConfig.userAgent,
            'Cache-Control': 'no-cache',
            'X-GitHub-Api-Version': '2022-11-28',
            if (GitHubConfig.token != null) 'Authorization': 'Bearer ${GitHubConfig.token}',
          },
        ).timeout(timeoutDuration);

        // Update rate limiting info
        _updateRateLimitInfo(response.headers);

        if (response.statusCode == 200) {
          final List<dynamic> pageData = json.decode(response.body);
          
          if (pageData.isEmpty) {
            break; // No more repositories
          }
          
          allRepos.addAll(pageData);
          debugPrint('Fetched ${pageData.length} repositories on page $page (total: ${allRepos.length})');
          page++;
          
          // If we got less than perPage results, this is the last page
          if (pageData.length < perPage) {
            break;
          }
        } else if (response.statusCode == 403) {
          final errorBody = json.decode(response.body);
          final message = errorBody['message'] ?? 'GitHub API rate limit exceeded';
          throw Exception('$message. Please try again later.');
        } else if (response.statusCode == 404) {
          throw Exception('GitHub user "${GitHubConfig.username}" not found. Please check the username.');
        } else {
          final errorBody = response.body.isNotEmpty ? json.decode(response.body) : {};
          final message = errorBody['message'] ?? response.reasonPhrase;
          throw Exception('Failed to load projects (${response.statusCode}): $message');
        }
      }
      
      // Convert ALL repos to Project objects with enhanced filtering
      _projects = allRepos
          .where((repo) => 
            // Filter out repos with null/empty names and forked repositories
            repo['name'] != null && 
            repo['name'].toString().isNotEmpty &&
            !(repo['fork'] ?? false) // Exclude forked repositories
          )
          .map((json) => Project.fromJson(json))
          .toList();
      
      _lastFetch = DateTime.now();
      
      // Sort and organize projects with improved logic
      _organizeProjects();
      
      debugPrint('Successfully fetched ${_projects.length} repositories from GitHub for ${GitHubConfig.username}');
      
    } on SocketException catch (e) {
      if (retryCount < 3) {
        // Exponential backoff: wait 1s, 2s, 4s, 8s
        final delay = Duration(seconds: 1 << retryCount);
        debugPrint('GitHub API: Network error (attempt ${retryCount + 1}/4), retrying in ${delay.inSeconds}s: ${e.message}');
        await Future.delayed(delay);
        return fetchProjects(retryCount: retryCount + 1);
      }
      _error = 'Unable to connect to GitHub. Please check your internet connection and try again.';
      debugPrint('GitHub API: Final network error: ${e.message}');
    } on TimeoutException {
      if (retryCount < 2) {
        // Retry with longer timeout
        final delay = Duration(seconds: 2 + retryCount);
        debugPrint('GitHub API: Request timeout (attempt ${retryCount + 1}/3), retrying in ${delay.inSeconds}s');
        await Future.delayed(delay);
        return fetchProjects(retryCount: retryCount + 1);
      }
      _error = 'GitHub API request timed out. Please try again.';
      debugPrint('GitHub API: Final timeout error');
    } on FormatException catch (e) {
      _error = 'Invalid data received from GitHub API. Please try again later.';
      debugPrint('GitHub API: Format error: ${e.message}');
    } catch (e) {
      // Check for CORS/Web platform issues
      if (kIsWeb && e.toString().contains('Failed to fetch')) {
        debugPrint('GitHub API: CORS error detected on web platform.');
        _error = 'GitHub API not accessible in web demo mode. Please try the mobile app for live data.';
        return;
      }
      
      if (retryCount < 2 && !e.toString().contains('rate limit')) {
        final delay = Duration(seconds: 1 + retryCount);
        debugPrint('GitHub API: Unexpected error (attempt ${retryCount + 1}/3), retrying in ${delay.inSeconds}s: $e');
        await Future.delayed(delay);
        return fetchProjects(retryCount: retryCount + 1);
      }
      _error = e.toString().replaceFirst('Exception: ', '');
      debugPrint('GitHub API: Final error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUser({int retryCount = 0}) async {
    // Skip if cache is still valid and user data exists
    if (isCacheValid && _user != null && retryCount == 0) {
      return;
    }
    
    // On web platform, skip fetching due to CORS
    if (kIsWeb) {
      return;
    }
    
    try {
      // Check rate limiting
      if (_rateLimitRemaining <= 1 && _rateLimitReset != null) {
        final timeUntilReset = _rateLimitReset!.difference(DateTime.now());
        if (timeUntilReset.inSeconds > 0) {
          debugPrint('Skipping user fetch due to rate limit');
          return;
        }
      }
      
      final response = await http.get(
        Uri.parse('${GitHubConfig.baseUrl}/users/${GitHubConfig.username}'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': GitHubConfig.userAgent,
          'Cache-Control': 'no-cache',
          'X-GitHub-Api-Version': '2022-11-28',
          if (GitHubConfig.token != null) 'Authorization': 'Bearer ${GitHubConfig.token}',
        },
      ).timeout(Duration(seconds: 8 + (retryCount * 2)));

      // Update rate limiting info
      _updateRateLimitInfo(response.headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _user = GithubUser.fromJson(data);
        notifyListeners();
      } else if (response.statusCode == 403) {
        debugPrint('GitHub API rate limit exceeded for user fetch');
      } else if (response.statusCode == 404) {
        debugPrint('GitHub user "${GitHubConfig.username}" not found');
      } else {
        debugPrint('Failed to load user (${response.statusCode}): ${response.reasonPhrase}');
      }
    } on SocketException {
      if (retryCount < 2) {
        await Future.delayed(Duration(seconds: 1 << retryCount));
        return fetchUser(retryCount: retryCount + 1);
      }
      debugPrint('No internet connection for user fetch after retries');
    } on TimeoutException {
      if (retryCount < 2) {
        await Future.delayed(Duration(seconds: 1 + retryCount));
        return fetchUser(retryCount: retryCount + 1);
      }
      debugPrint('User fetch request timed out after retries');
    } catch (e) {
      if (retryCount < 1) {
        await Future.delayed(const Duration(seconds: 1));
        return fetchUser(retryCount: retryCount + 1);
      }
      debugPrint('Error fetching user after retries: $e');
    }
  }

  void _organizeProjects() {
    if (_projects.isEmpty) return;

    // Show all non-archived projects
    final displayableProjects = _projects
        .where((project) => !project.archived && project.name.isNotEmpty)
        .toList();

    // Sort all projects by a combination of factors for better representation
    final sortedProjects = List<Project>.from(displayableProjects);
    sortedProjects.sort((a, b) {
      // First, prioritize projects with more engagement (stars + forks)
      final engagementA = a.stargazersCount + a.forksCount;
      final engagementB = b.stargazersCount + b.forksCount;
      
      if (engagementA != engagementB) {
        return engagementB.compareTo(engagementA);
      }
      
      // Then by recent updates
      return b.updatedAt.compareTo(a.updatedAt);
    });

    // Recent projects (updated in the last 6 months for better relevance)
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    final recentProjects = displayableProjects
        .where((project) => project.updatedAt.isAfter(sixMonthsAgo))
        .toList();
    
    recentProjects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _recentProjects = recentProjects.take(12).toList();

    // Featured projects - top projects by score, ensuring no duplicates with recent
    final recentIds = _recentProjects.map((p) => p.id).toSet();
    final featuredCandidates = sortedProjects
        .where((project) => !recentIds.contains(project.id))
        .toList();
    
    _featuredProjects = featuredCandidates.take(20).toList();
    
    // If we don't have enough recent projects, fill from top projects
    if (_recentProjects.length < 8 && sortedProjects.isNotEmpty) {
      _recentProjects = sortedProjects.take(12).toList();
      _featuredProjects = sortedProjects.skip(12).take(20).toList();
    }
    
    debugPrint('Organized projects: ${_recentProjects.length} recent, ${_featuredProjects.length} featured out of ${_projects.length} total (${displayableProjects.length} displayable)');
  }


  List<Project> getFilteredProjects(String filter) {
    // Show all non-archived projects
    final baseProjects = _projects.where((p) => 
      !p.archived && p.name.isNotEmpty
    ).toList();

    // Sort by engagement (stars + forks) first, then by recent updates
    void sortByEngagement(List<Project> projects) {
      projects.sort((a, b) {
        final engagementA = a.stargazersCount + a.forksCount;
        final engagementB = b.stargazersCount + b.forksCount;
        
        if (engagementA != engagementB) {
          return engagementB.compareTo(engagementA);
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });
    }

    switch (filter.toLowerCase()) {
      case 'all':
        final allProjects = List<Project>.from(baseProjects);
        sortByEngagement(allProjects);
        return allProjects;
        
      case 'web':
        final webProjects = baseProjects.where((p) => 
            p.language?.toLowerCase() == 'javascript' || 
            p.language?.toLowerCase() == 'typescript' ||
            p.language?.toLowerCase() == 'html' ||
            p.language?.toLowerCase() == 'css' ||
            p.language?.toLowerCase() == 'vue' ||
            p.language?.toLowerCase() == 'react' ||
            p.language?.toLowerCase() == 'php' ||
            p.language?.toLowerCase() == 'scss' ||
            p.name.toLowerCase().contains('web') ||
            p.name.toLowerCase().contains('site') ||
            p.name.toLowerCase().contains('frontend') ||
            p.name.toLowerCase().contains('backend') ||
            p.name.toLowerCase().contains('portfolio') ||
            (p.description?.toLowerCase().contains('web') ?? false) ||
            (p.description?.toLowerCase().contains('website') ?? false) ||
            (p.description?.toLowerCase().contains('frontend') ?? false) ||
            (p.description?.toLowerCase().contains('backend') ?? false) ||
            p.topics.any((topic) => ['web', 'frontend', 'backend', 'fullstack', 'react', 'vue', 'angular', 'nextjs', 'website', 'html', 'css', 'javascript', 'typescript', 'nodejs', 'express'].contains(topic.toLowerCase()))
        ).toList();
        sortByEngagement(webProjects);
        return webProjects;
        
      case 'mobile':
        final mobileProjects = baseProjects.where((p) => 
            p.language?.toLowerCase() == 'dart' || 
            p.language?.toLowerCase() == 'java' ||
            p.language?.toLowerCase() == 'swift' ||
            p.language?.toLowerCase() == 'kotlin' ||
            p.language?.toLowerCase() == 'objective-c' ||
            p.name.toLowerCase().contains('mobile') ||
            p.name.toLowerCase().contains('app') ||
            p.name.toLowerCase().contains('flutter') ||
            p.name.toLowerCase().contains('android') ||
            p.name.toLowerCase().contains('ios') ||
            (p.description?.toLowerCase().contains('mobile') ?? false) ||
            (p.description?.toLowerCase().contains('app') ?? false) ||
            (p.description?.toLowerCase().contains('flutter') ?? false) ||
            (p.description?.toLowerCase().contains('android') ?? false) ||
            (p.description?.toLowerCase().contains('ios') ?? false) ||
            p.topics.any((topic) => ['flutter', 'android', 'ios', 'mobile', 'react-native', 'app', 'dart', 'xamarin'].contains(topic.toLowerCase()))
        ).toList();
        sortByEngagement(mobileProjects);
        return mobileProjects;
        
      case 'backend':
        final backendProjects = baseProjects.where((p) => 
            p.language?.toLowerCase() == 'python' || 
            p.language?.toLowerCase() == 'go' ||
            p.language?.toLowerCase() == 'rust' ||
            p.language?.toLowerCase() == 'java' ||
            p.language?.toLowerCase() == 'c#' ||
            p.language?.toLowerCase() == 'php' ||
            p.language?.toLowerCase() == 'ruby' ||
            p.language?.toLowerCase() == 'c++' ||
            p.language?.toLowerCase() == 'c' ||
            p.language?.toLowerCase() == 'shell' ||
            p.language?.toLowerCase() == 'dockerfile' ||
            p.name.toLowerCase().contains('api') ||
            p.name.toLowerCase().contains('server') ||
            p.name.toLowerCase().contains('backend') ||
            p.name.toLowerCase().contains('service') ||
            p.name.toLowerCase().contains('database') ||
            (p.description?.toLowerCase().contains('api') ?? false) ||
            (p.description?.toLowerCase().contains('server') ?? false) ||
            (p.description?.toLowerCase().contains('backend') ?? false) ||
            (p.description?.toLowerCase().contains('database') ?? false) ||
            (p.description?.toLowerCase().contains('service') ?? false) ||
            p.topics.any((topic) => ['api', 'backend', 'server', 'database', 'microservices', 'docker', 'kubernetes', 'python', 'java', 'go', 'rust', 'service', 'graphql', 'rest'].contains(topic.toLowerCase()))
        ).toList();
        sortByEngagement(backendProjects);
        return backendProjects;
        
      default:
        final allProjects = List<Project>.from(baseProjects);
        sortByEngagement(allProjects);
        return allProjects;
    }
  }

  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((project) => project.id.toString() == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshData() async {
    await Future.wait([
      fetchProjects(),
      fetchUser(),
    ]);
  }

  // Update rate limiting information from response headers
  void _updateRateLimitInfo(Map<String, String> headers) {
    final remaining = headers['x-ratelimit-remaining'];
    final reset = headers['x-ratelimit-reset'];
    
    if (remaining != null) {
      _rateLimitRemaining = int.tryParse(remaining) ?? 60;
      debugPrint('GitHub API: Rate limit remaining: $_rateLimitRemaining');
    }
    
    if (reset != null) {
      final resetTimestamp = int.tryParse(reset);
      if (resetTimestamp != null) {
        _rateLimitReset = DateTime.fromMillisecondsSinceEpoch(resetTimestamp * 1000);
        debugPrint('GitHub API: Rate limit resets at: $_rateLimitReset');
      }
    }
    
    // Warn when rate limit is getting low
    if (_rateLimitRemaining < 10) {
      debugPrint('GitHub API: WARNING - Rate limit is low ($_rateLimitRemaining remaining). Consider adding a GitHub token.');
    }
  }
  
  // Real-time data refresh using timer with improved logic
  void startPeriodicRefresh() {
    _periodicTimer?.cancel(); // Cancel existing timer
    
    // Don't start periodic refresh if we have persistent network issues
    if (_error != null && (_error!.contains('network') || _error!.contains('connection'))) {
      debugPrint('GitHub API: Skipping periodic refresh due to persistent network issues');
      return;
    }
    
    debugPrint('GitHub API: Starting periodic data refresh (every 90 seconds)');
    
    // Start with immediate refresh if we have good rate limit
    if (_rateLimitRemaining > 15) {
      refreshData();
    }
    
    // Set up periodic refresh every 90 seconds for more real-time updates
    _periodicTimer = Timer.periodic(const Duration(seconds: 90), (timer) {
      // Only refresh if we have sufficient rate limit remaining
      if (_rateLimitRemaining > 10) {
        refreshData();
      } else {
        debugPrint('GitHub API: Skipping periodic refresh due to low rate limit ($_rateLimitRemaining remaining)');
        // If rate limit is low, increase interval temporarily
        if (_rateLimitRemaining < 5) {
          timer.cancel();
          _startLimitedRefresh();
        }
      }
    });
  }

  // Limited refresh mode when rate limit is low
  void _startLimitedRefresh() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      if (_rateLimitRemaining > 15) {
        timer.cancel();
        startPeriodicRefresh(); // Resume normal refresh rate
      } else if (_rateLimitRemaining > 5) {
        refreshData();
      }
    });
    debugPrint('Switched to limited refresh mode due to rate limiting');
  }
  
  // Stop periodic refresh
  void stopPeriodicRefresh() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  // Manual refresh with loading state (ignores cache)
  Future<void> forceRefresh() async {
    _lastFetch = null; // Clear cache to force refresh
    await refreshData();
  }

  // Test GitHub API connectivity
  Future<bool> testConnection() async {
    // Skip connection test on web due to CORS
    if (kIsWeb) {
      return false;
    }
    
    try {
      debugPrint('GitHub API: Testing connection to ${GitHubConfig.username}');
      final response = await http.get(
        Uri.parse('${GitHubConfig.baseUrl}/users/${GitHubConfig.username}'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': GitHubConfig.userAgent,
          'X-GitHub-Api-Version': '2022-11-28',
          if (GitHubConfig.token != null) 'Authorization': 'Bearer ${GitHubConfig.token}',
        },
      ).timeout(const Duration(seconds: 5));
      
      final success = response.statusCode == 200;
      debugPrint('GitHub API: Connection test ${success ? 'successful' : 'failed'} (status: ${response.statusCode})');
      
      if (!success && response.statusCode == 404) {
        debugPrint('GitHub API: User "${GitHubConfig.username}" not found. Please check the username.');
      }
      
      return success;
    } catch (e) {
      debugPrint('GitHub API: Connection test failed: $e');
      return false;
    }
  }

  // Initialize with connection test
  Future<void> initialize() async {
    debugPrint('GitHub API: Initializing provider for ${GitHubConfig.username}');
    
    // On web platform, skip connection test due to CORS
    if (kIsWeb) {
      debugPrint('GitHub API: Web platform detected. Limited functionality due to CORS restrictions.');
      _error = 'GitHub API access limited in web browser due to CORS policy. Try the mobile app for full functionality.';
      notifyListeners();
      return;
    }
    
    final isConnected = await testConnection();
    if (isConnected) {
      debugPrint('GitHub API: Connection successful, fetching data');
      await refreshData();
      startPeriodicRefresh();
    } else {
      debugPrint('GitHub API: No internet connection detected.');
      _error = 'No internet connection. Please check your network and try again.';
      
      notifyListeners();
      
      // Try to reconnect periodically (every 2 minutes)
      _startOfflineMode();
    }
  }
  

  // Offline mode - periodically check for internet connectivity
  void _startOfflineMode() {
    debugPrint('GitHub API: Starting offline mode - will retry connection every 2 minutes');
    
    Timer.periodic(const Duration(minutes: 2), (timer) async {
      debugPrint('GitHub API: Checking connectivity in offline mode...');
      
      if (await testConnection()) {
        debugPrint('GitHub API: Connection restored! Switching to online mode.');
        timer.cancel();
        _error = null;
        await refreshData();
        startPeriodicRefresh();
      } else {
        debugPrint('GitHub API: Still offline, will retry in 2 minutes');
      }
    });
  }
  
  // Get repository statistics
  Map<String, int> get repositoryStats {
    if (_projects.isEmpty) return {};
    
    final stats = <String, int>{};
    final languages = <String>{};
    int totalStars = 0;
    int totalForks = 0;
    
    for (final project in _projects) {
      if (project.language != null) {
        languages.add(project.language!);
      }
      totalStars += project.stargazersCount;
      totalForks += project.forksCount;
    }
    
    stats['repositories'] = _projects.length;
    stats['languages'] = languages.length;
    stats['stars'] = totalStars;
    stats['forks'] = totalForks;
    
    return stats;
  }
  
  // Get most used languages
  Map<String, int> get languageDistribution {
    final distribution = <String, int>{};
    
    for (final project in _projects) {
      if (project.language != null) {
        distribution[project.language!] = (distribution[project.language!] ?? 0) + 1;
      }
    }
    
    // Sort by count
    final sorted = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sorted);
  }
  
  @override
  void dispose() {
    stopPeriodicRefresh();
    super.dispose();
  }
}