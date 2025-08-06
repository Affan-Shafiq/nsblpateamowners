import 'package:flutter/material.dart';

class AppColors {
  // NSBLPA Brand Colors
  static const Color primary = Color(0xFF1E3A8A); // Deep Blue
  static const Color secondary = Color(0xFF3B82F6); // Blue
  static const Color accent = Color(0xFFF59E0B); // Amber
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color background = Color(0xFFF8FAFC); // Light Gray
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color textPrimary = Color(0xFF1F2937); // Dark Gray
  static const Color textSecondary = Color(0xFF6B7280); // Medium Gray
}

class AppConstants {
  // API Endpoints
  static const String baseUrl = 'https://nsblpa.com/ownership/';
  static const String teamsEndpoint = 'teams';
  static const String contractsEndpoint = 'contracts';
  static const String financeEndpoint = 'finance';
  static const String documentsEndpoint = 'documents';
  
  // App Configuration
  static const String appName = 'NSBLPA Team Owners';
  static const String appVersion = '1.0.0';
  
  // Navigation
  static const int animationDuration = 300;
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String selectedTeamKey = 'selected_team';
  static const String userProfileKey = 'user_profile';
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
} 