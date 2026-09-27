import 'package:flutter/material.dart';

import 'app_theme.dart';

class AppColor {
  static bool isLight(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(context, light: true, dark: false, listen: listen);
  }

  static Color primaryColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xff0066FF),
      dark: const Color(0xFF3B82F6),
      listen: listen,
    );
  }

  static Color secondAppColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFFFFFFFF),
      dark: const Color(0xFF1E1E24), // Luxury Carbon Card / Surface
      listen: listen,
    );
  }

  static Color borderColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFFCBD5E1),
      dark: const Color(0xFF2C2D35), // Subtle Carbon Border
      listen: listen,
    );
  }

  static Color scaffoldColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFFF1F5F9),
      dark: const Color(0xFF121214), // Deep Carbon / AMOLED Background
      listen: listen,
    );
  }

  static Color textFormFillColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFFF8FAFC),
      dark: const Color(0xFF18181D), // Inset Form Field
      listen: listen,
    );
  }

  static Color hintColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFF94A3B8),
      dark: const Color(0xFF71717A),
      listen: listen,
    );
  }

  static Color darkTextColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFF1E293B),
      dark: const Color(0xFFF4F4F5),
      listen: listen,
    );
  }

  static Color greyColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFF64748B),
      dark: const Color(0xFFA1A1AA),
      listen: listen,
    );
  }

  static Color titleFormFiledColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFF1E293B),
      dark: const Color(0xFFF4F4F5),
      listen: listen,
    );
  }

  static Color blackTextColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFF0F172A),
      dark: const Color(0xFFFFFFFF),
      listen: listen,
    );
  }

  static Color whiteColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xffffffff),
      dark: const Color(0xffffffff),
      listen: listen,
    );
  }

  static Color textFormBorderColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFFCBD5E1),
      dark: const Color(0xFF2C2D35),
      listen: listen,
    );
  }

  static Color textFormColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFF0F172A),
      dark: const Color(0xFFFFFFFF),
      listen: listen,
    );
  }

  static Color appBarTextColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFF0F172A),
      dark: const Color(0xFFFFFFFF),
      listen: listen,
    );
  }

  static Color appBarColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFFFFFFFF),
      dark: const Color(0xFF121214), // Seamless Carbon AppBar
      listen: listen,
    );
  }

  static Color blackColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(context, light: Colors.black, dark: Colors.black, listen: listen);
  }

  static Color buttonTextColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xffffffff),
      dark: const Color(0xffffffff),
      listen: listen,
    );
  }

  /// Card surface color — slightly elevated from scaffold
  static Color cardColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFFFFFFFF),
      dark: const Color(0xFF1E1E24), // Luxury Carbon Card
      listen: listen,
    );
  }

  static Color gradientSecondaryColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFFF8FAFC),
      dark: const Color(0xFF18181D),
      listen: listen,
    );
  }

  static Color redColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFFFF3B3B),
      dark: const Color(0xFFF87171),
      listen: listen,
    );
  }

  static Color greenColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFF00C06B),
      dark: const Color(0xFF34D399),
      listen: listen,
    );
  }

  static Color orangeColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFFFF8C00),
      dark: const Color(0xFFFBBF24),
      listen: listen,
    );
  }

  static Color blueColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFF0066FF),
      dark: const Color(0xFF3B82F6),
      listen: listen,
    );
  }

  static Color goldColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFFF5A623),
      dark: const Color(0xFFFCD34D),
      listen: listen,
    );
  }

  /// Divider / subtle separator color
  static Color dividerColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(
      context,
      light: const Color(0xFFE2E8F0),
      dark: const Color(0xFF27272A),
      listen: listen,
    );
  }

  /// Icon color
  static Color iconColoramber(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(context, light: Colors.amber, dark: Colors.amber, listen: listen);
  }

  static Color iconColor(BuildContext context, {bool listen = true}) {
    return AppTheme.getByTheme(context, light: Colors.orange, dark: Colors.orange, listen: listen);
  }
}
