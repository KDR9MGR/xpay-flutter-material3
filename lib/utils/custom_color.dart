import 'package:flutter/material.dart';

class CustomColor {
  // Material 3 Dark Theme with Neon Blue
  static const Color primaryColor = Color(0xFF00E5FF); // Neon Cyan/Blue
  static const Color primaryVariant = Color(0xFF0091EA); // Deeper neon blue
  static const Color secondaryColor = Color(0xFF03DAC6); // Neon teal accent
  static const Color secondaryVariant = Color(0xFF018786); // Darker teal
  
  // Background colors for dark theme
  static const Color backgroundColor = Color(0xFF000000); // Pure black
  static const Color surfaceColor = Color(0xFF121212); // Dark surface
  static const Color screenBGColor = Color(0xFF0A0A0A); // Slightly lighter black
  
  // Text colors
  static const Color primaryTextColor = Color(0xFFFFFFFF); // White text
  static const Color secondaryTextColor = Color(0xFFB3B3B3); // Gray text
  static const Color onPrimaryTextColor = Color(0xFF000000); // Black text on neon
  
  // Additional colors
  static const Color errorColor = Color(0xFFFF6B6B); // Neon red for errors
  static const Color successColor = Color(0xFF4ECDC4); // Neon green for success
  static const Color warningColor = Color(0xFFFFE66D); // Neon yellow for warnings
  
  // Legacy colors (maintained for compatibility)
  static const Color splashScreenColor = Color(0xFF0A0A0A);
  static const Color sliderColor = Color(0xFF00E5FF); // Same as primary
  
  // Material 3 specific colors
  static const Color outlineColor = Color(0xFF2D2D2D); // For borders
  static const Color onSurfaceVariant = Color(0xFF9E9E9E); // Text on surface variant
}
