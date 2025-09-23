import 'package:flutter/material.dart';

/// Application-wide constants and configuration
class AppConstants {
  // App Information
  static const String appName = 'Todo Pro';
  static const String appVersion = '1.0.0';

  // Spacing and Sizing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  static const double iconSizeSmall = 18.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Form Validation
  static const int minTitleLength = 1;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;

  // UI Text
  static const String emptyTodosMessage = 'No todos yet.\nTap + to add your first todo!';
  static const String emptySearchMessage = 'No todos match your search.';
  static const String emptyCompletedMessage = 'No completed todos yet.';
  static const String emptyPendingMessage = 'No pending todos.';

  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection.';
  static const String validationErrorTitle = 'Please enter a title';
  static const String validationErrorTitleTooLong = 'Title is too long (max $maxTitleLength characters)';
  static const String validationErrorDescriptionTooLong = 'Description is too long (max $maxDescriptionLength characters)';

  // Success Messages
  static const String todoAddedMessage = 'Todo added successfully!';
  static const String todoUpdatedMessage = 'Todo updated successfully!';
  static const String todoDeletedMessage = 'Todo deleted successfully!';
  static const String todoCompletedMessage = 'Todo marked as completed!';
  static const String todoUncompletedMessage = 'Todo marked as pending!';

  // Bottom Navigation
  static const List<BottomNavigationBarItem> bottomNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.analytics_outlined),
      activeIcon: Icon(Icons.analytics),
      label: 'Statistics',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  // Search
  static const String searchHintText = 'Search todos...';
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);

  // Statistics
  static const List<String> statisticsLabels = [
    'Total Tasks',
    'Completed',
    'Pending',
  ];

  // Settings Options
  static const List<String> themeOptions = [
    'Light Theme',
    'Dark Theme',
    'System Theme',
  ];

  static const List<IconData> themeIcons = [
    Icons.light_mode,
    Icons.dark_mode,
    Icons.brightness_auto,
  ];

  // Category Display Names and Colors (for reference)
  static const Map<String, Color> categoryColors = {
    'Work': Color(0xFF1976D2),      // Blue
    'Personal': Color(0xFF388E3C),  // Green
    'Shopping': Color(0xFFFF7043),  // Orange
  };

  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  // Asset paths (if you add assets later)
  static const String assetsPath = 'assets/';
  static const String imagesPath = '${assetsPath}images/';
  static const String iconsPath = '${assetsPath}icons/';

  // Local storage keys
  static const String todosStorageKey = 'todos_key';
  static const String themeStorageKey = 'theme_mode';
  static const String firstLaunchKey = 'first_launch';

  // Default values
  static const int defaultAnimationDurationMs = 300;
  static const double defaultElevation = 2.0;
  static const double defaultBorderRadius = 12.0;

  // Validation regex patterns
  static final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp urlRegex = RegExp(r'^https?://[\w-]+(\.[\w-]+)+([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?$');

  // Date formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';

  // Accessibility
  static const Duration accessibilityTimeout = Duration(seconds: 5);
  static const double minimumTapSize = 48.0;
}

/// Extension methods for common UI patterns
extension ContextExtensions on BuildContext {
  /// Returns the current theme data
  ThemeData get theme => Theme.of(this);

  /// Returns the current color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Returns the current text theme
  TextTheme get textTheme => theme.textTheme;

  /// Returns the media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Returns the screen size
  Size get screenSize => mediaQuery.size;

  /// Returns true if the screen width is considered mobile
  bool get isMobile => screenSize.width < AppConstants.mobileBreakpoint;

  /// Returns true if the screen width is considered tablet
  bool get isTablet => screenSize.width >= AppConstants.mobileBreakpoint &&
                       screenSize.width < AppConstants.tabletBreakpoint;

  /// Returns true if the screen width is considered desktop
  bool get isDesktop => screenSize.width >= AppConstants.tabletBreakpoint;
}