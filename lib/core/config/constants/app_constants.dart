class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://api.kodastock.com/v1';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String isOnboardingCompleted = 'is_onboarding_completed';
  static const String themeMode = 'theme_mode';
  static const String watchlistKey = 'user_watchlist';
  static const String lastSyncKey = 'last_sync_time';

  // App Info
  static const String appName = 'KodaStock';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int itemsPerPage = 20;
  
  // Cache Duration
  static const Duration cacheValidDuration = Duration(minutes: 5);
}

class ApiEndpoints {
  static const String dashboard = '/dashboard';
  static const String stocksList = '/stocks/list';
  static String stockDetails(String symbol) => '/stocks/$symbol';
  static const String compare = '/stocks/compare';
  static String analysis(String symbol) => '/analysis/$symbol';
  static const String marketSummary = '/market/summary';
}

class AppStrings {
  // Welcome Messages
  static const String welcomeBack = 'Welcome back';
  static const String investmentMessage = "Here's what's happening with your investments today.";

  // Navigation
  static const String dashboard = 'Dashboard';
  static const String stocks = 'Stocks';
  static const String compare = 'Compare';
  static const String analysis = 'Analysis';

  // Actions
  static const String viewDetails = 'View Details';
  static const String compareStocks = 'Compare Stocks';
  static const String analyze = 'Analyze';
  static const String addToWatchlist = 'Add to Watchlist';

  // Errors
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorLoadingData = 'Failed to load data.';
}

class AppColors {
  static const int primaryColor = 0xFF1E88E5;
  static const int successColor = 0xFF4CAF50;
  static const int errorColor = 0xFFE53935;
  static const int warningColor = 0xFFFFA726;
  static const int infoColor = 0xFF29B6F6;
}
