/// GitHub Configuration
/// 
/// This file contains configuration settings for the GitHub API integration.
/// Update these values to customize your portfolio.

class GitHubConfig {
  /// Your GitHub username
  /// This should match your GitHub profile username exactly
  static const String username = 'thenitishmind';
  
  /// Optional: GitHub Personal Access Token
  /// 
  /// Adding a token increases your rate limit from 60 to 5000 requests/hour.
  /// 
  /// To generate a token:
  /// 1. Go to https://github.com/settings/tokens
  /// 2. Click "Generate new token" -> "Generate new token (classic)"
  /// 3. Give it a name like "Portfolio App"
  /// 4. Select scopes: 
  ///    - public_repo (for public repositories)
  ///    - read:user (for user profile information)
  /// 5. Click "Generate token"
  /// 6. Copy the token and paste it below (keep the quotes)
  /// 
  /// Example: static const String? token = 'ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
  static const String? token = null;
  
  /// GitHub API Base URL (do not change unless using GitHub Enterprise)
  static const String baseUrl = 'https://api.github.com';
  
  /// User Agent for API requests (can be customized)
  static const String userAgent = 'Flutter-Portfolio-App/1.0';
  
  /// Cache duration for API responses (in minutes)
  /// Reduce this for more frequent updates, increase to reduce API calls
  static const int cacheMinutes = 2;
  
  /// Maximum repositories to fetch per API call
  /// GitHub API maximum is 100
  static const int maxPerPage = 100;
  
  /// Retry configuration
  static const int maxRetries = 3;
  static const int baseTimeoutSeconds = 10;
  static const int retryDelaySeconds = 1;
}
