import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DynamicColor extends Color {
  final int darkValue;
  final int lightValue;
  const DynamicColor(this.darkValue, this.lightValue) : super(darkValue);

  @override
  int get value => AppColors.isDarkMode ? darkValue : lightValue;
}

class AppColors {
  static String activeTheme = 'cyberpunk'; // State variable (non-const)
  static bool isDarkMode = true; // Global state for dynamic colors

  static const Color background = DynamicColor(0xFF090A0F, 0xFFF9FAFB);
  static const Color surface = DynamicColor(0xFF131622, 0xFFFFFFFF);
  static const Color surfaceLight = DynamicColor(0xFF1E2235, 0xFFF3F4F6);
  
  static const Color primary = Color(0xFF7C3AED); // Cyberpunk Violet
  static const Color secondary = Color(0xFF06B6D4); // Cyberpunk Cyan
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentYellow = Color(0xFFF59E0B);
  
  static const Color textPrimary = DynamicColor(0xFFF3F4F6, 0xFF111827);
  static const Color textSecondary = DynamicColor(0xFF9CA3AF, 0xFF4B5563);
  static const Color textMuted = DynamicColor(0xFF6B7280, 0xFF9CA3AF);
  
  static const Color border = DynamicColor(0xFF262B44, 0xFFE5E7EB);
  static const Color borderLight = DynamicColor(0xFF374151, 0xFFD1D5DB);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [accentOrange, Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [accentPink, Color(0xFFDB2777)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient greenGradient = LinearGradient(
    colors: [accentGreen, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    final activeTheme = AppColors.activeTheme;
    final isDark = AppColors.isDarkMode;

    Color primaryColor = const Color(0xFF7C3AED);
    Color secondaryColor = const Color(0xFF06B6D4);
    Color scaffoldBg = isDark ? const Color(0xFF090A0F) : const Color(0xFFF9FAFB);
    Color surfaceColor = isDark ? const Color(0xFF131622) : const Color(0xFFFFFFFF);
    Color borderCol = isDark ? const Color(0xFF262B44) : const Color(0xFFE5E7EB);
    
    if (activeTheme == 'emerald') {
      primaryColor = const Color(0xFF10B981);
      secondaryColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
      scaffoldBg = isDark ? const Color(0xFF070908) : const Color(0xFFF4FBF7);
      surfaceColor = isDark ? const Color(0xFF0F1512) : const Color(0xFFFFFFFF);
      borderCol = isDark ? const Color(0xFF1C2D24) : const Color(0xFFE6F4EA);
    } else if (activeTheme == 'sunset') {
      primaryColor = const Color(0xFFEC4899);
      secondaryColor = const Color(0xFFF97316);
      scaffoldBg = isDark ? const Color(0xFF0F0712) : const Color(0xFFFDF2F8);
      surfaceColor = isDark ? const Color(0xFF1B0F22) : const Color(0xFFFFFFFF);
      borderCol = isDark ? const Color(0xFF331B40) : const Color(0xFFFCE7F3);
    } else if (activeTheme == 'glacier') {
      primaryColor = const Color(0xFF0EA5E9);
      secondaryColor = isDark ? const Color(0xFF22D3EE) : const Color(0xFF0284C7);
      scaffoldBg = isDark ? const Color(0xFF070C14) : const Color(0xFFF0F9FF);
      surfaceColor = isDark ? const Color(0xFF0E1624) : const Color(0xFFFFFFFF);
      borderCol = isDark ? const Color(0xFF192A40) : const Color(0xFFE0F2FE);
    }

    final textCol = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827);
    final textSecCol = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryColor,
              secondary: secondaryColor,
              surface: surfaceColor,
              onSurface: textCol,
              error: const Color(0xFFEC4899),
            )
          : ColorScheme.light(
              primary: primaryColor,
              secondary: secondaryColor,
              surface: surfaceColor,
              onSurface: textCol,
              error: const Color(0xFFEC4899),
            ),
      dividerTheme: DividerThemeData(
        color: borderCol,
        thickness: 1,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme
      ).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textCol,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textCol,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: textCol,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: textSecCol,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderCol, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: secondaryColor,
        unselectedItemColor: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Dynamic Gradients based on theme
  static LinearGradient get primaryGradient {
    final activeTheme = AppColors.activeTheme;
    if (activeTheme == 'emerald') {
      return const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF047857)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (activeTheme == 'sunset') {
      return const LinearGradient(
        colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (activeTheme == 'glacier') {
      return const LinearGradient(
        colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return AppColors.primaryGradient;
  }

  static LinearGradient get secondaryGradient {
    final activeTheme = AppColors.activeTheme;
    if (activeTheme == 'emerald') {
      return const LinearGradient(
        colors: [Color(0xFF34D399), Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (activeTheme == 'sunset') {
      return const LinearGradient(
        colors: [Color(0xFFF97316), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (activeTheme == 'glacier') {
      return const LinearGradient(
        colors: [Color(0xFF22D3EE), Color(0xFF0891B2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return AppColors.secondaryGradient;
  }

  static LinearGradient get pinkGradient {
    final activeTheme = AppColors.activeTheme;
    if (activeTheme == 'emerald') {
      return const LinearGradient(
        colors: [Color(0xFF059669), Color(0xFF047857)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (activeTheme == 'sunset') {
      return const LinearGradient(
        colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (activeTheme == 'glacier') {
      return const LinearGradient(
        colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return AppColors.pinkGradient;
  }

  static LinearGradient get greenGradient {
    final activeTheme = AppColors.activeTheme;
    if (activeTheme == 'emerald') {
      return const LinearGradient(
        colors: [Color(0xFF34D399), Color(0xFF10B981)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (activeTheme == 'sunset') {
      return const LinearGradient(
        colors: [Color(0xFFF97316), Color(0xFFEA580C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (activeTheme == 'glacier') {
      return const LinearGradient(
        colors: [Color(0xFF22D3EE), Color(0xFF0EA5E9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return AppColors.greenGradient;
  }

  static LinearGradient get orangeGradient {
    final activeTheme = AppColors.activeTheme;
    if (activeTheme == 'emerald') {
      return const LinearGradient(
        colors: [Color(0xFF059669), Color(0xFF047857)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (activeTheme == 'sunset') {
      return const LinearGradient(
        colors: [Color(0xFFF97316), Color(0xFFEA580C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (activeTheme == 'glacier') {
      return const LinearGradient(
        colors: [Color(0xFF06B6D4), Color(0xFF0EA5E9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return AppColors.orangeGradient;
  }

  static LinearGradient get premiumGradient => AppColors.premiumGradient;

  static BoxDecoration glassBox({
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    final activeTheme = AppColors.activeTheme;
    final isDark = AppColors.isDarkMode;
    Color surfaceColor = AppColors.surface;
    Color borderColor = AppColors.border;
    
    if (activeTheme == 'emerald') {
      surfaceColor = isDark ? const Color(0xFF0F1512) : const Color(0xFFFFFFFF);
      borderColor = isDark ? const Color(0xFF1C2D24) : const Color(0xFFE6F4EA);
    } else if (activeTheme == 'sunset') {
      surfaceColor = isDark ? const Color(0xFF1B0F22) : const Color(0xFFFFFFFF);
      borderColor = isDark ? const Color(0xFF331B40) : const Color(0xFFFCE7F3);
    } else if (activeTheme == 'glacier') {
      surfaceColor = isDark ? const Color(0xFF0E1624) : const Color(0xFFFFFFFF);
      borderColor = isDark ? const Color(0xFF192A40) : const Color(0xFFE0F2FE);
    }

    return BoxDecoration(
      color: color ?? surfaceColor.withOpacity(isDark ? 0.8 : 0.95),
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: border ?? Border.all(color: borderColor, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  static BoxDecoration neonGlow({
    required Color color,
    double blurRadius = 15,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.25),
          blurRadius: blurRadius,
          spreadRadius: 2,
        )
      ],
    );
  }
}
