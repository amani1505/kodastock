class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://stocklens.benethemmanuel.site/api';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String isOnboardingCompleted = 'is_onboarding_completed';
  static const String themeMode = 'theme_mode';
  static const String watchlistKey = 'user_watchlist';
  static const String lastSyncKey = 'last_sync_time';


    // Auth Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

  // App Info
  static const String appName = 'KodaStock';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int itemsPerPage = 20;
  
  // Cache Duration
  static const Duration cacheValidDuration = Duration(minutes: 5);
}

class ApiEndpoints {
  // Auth Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/profile';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  


  static const String dashboard = '/dashboard';
  static const String stocksList = '/stocks';
  static String stockDetails(String symbol) => '/stocks/$symbol';
  static const String compare = '/stocks/compare';
  static String analysis(String symbol) => '/analysis/$symbol';
  static const String marketSummary = '/market/summary';
}

class AppStrings {

  // Auth Messages
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String loginSuccess = 'Login successful!';
  static const String signupSuccess = 'Account created successfully!';
  static const String logoutSuccess = 'Logged out successfully';


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
  static const String errorInvalidCredentials = 'Invalid email or password.';
  static const String errorEmailRequired = 'Email is required';
  static const String errorEmailInvalid = 'Please enter a valid email';
  static const String errorPasswordRequired = 'Password is required';
  static const String errorPasswordTooShort = 'Password must be at least 6 characters';
  static const String errorPasswordMismatch = 'Passwords do not match';
  static const String errorNameRequired = 'Name is required';
  static const String errorUnauthorized = 'Session expired. Please login again.';
}

class AppColors {
  static const int primaryColor = 0xFF1E88E5;
  static const int successColor = 0xFF4CAF50;
  static const int errorColor = 0xFFE53935;
  static const int warningColor = 0xFFFFA726;
  static const int infoColor = 0xFF29B6F6;
}
