/// Centralized constants for consistent spacing, sizing, and styling across the app.
class AppSpacing {
  // Base spacing unit - all other spacing should be multiples of this
  static const double unit = 4.0;

  // Common spacing values
  static const double xs = unit; // 4
  static const double sm = unit * 2; // 8
  static const double md = unit * 3; // 12
  static const double lg = unit * 4; // 16
  static const double xl = unit * 5; // 20
  static const double xxl = unit * 6; // 24
  static const double xxxl = unit * 8; // 32

  // Page padding
  static const double pagePadding = lg; // 16

  // Card spacing
  static const double cardPadding = md; // 12
  static const double cardMargin = sm; // 8

  // List item spacing
  static const double listItemPadding = lg; // 16
  static const double listItemSpacing = sm; // 8
}

class AppSizes {
  // Button sizes
  static const double buttonHeight = 48.0;
  static const double buttonMinWidth = 88.0;

  // Icon sizes
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;

  // Elevation levels
  static const double elevationLow = 2.0;
  static const double elevationMed = 4.0;
  static const double elevationHigh = 8.0;
}

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

class AppStrings {
  // Common error messages
  static const String signInRequired = 'Please sign in to continue.';
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Check your internet connection and try again.';
  static const String errorSaving = 'Failed to save. Please try again.';
  static const String errorLoading = 'Failed to load data. Please try again.';

  // Common success messages
  static const String savedSuccessfully = 'Saved successfully';
  static const String deletedSuccessfully = 'Deleted successfully';

  // Empty state messages
  static const String noDataYet = 'No data yet';
  static const String noItemsFound = 'No items found';
}