import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static String activeTheme = 'cyberpunk'; // State variable (non-const)

  static const Color background = Color(0xFF090A0F);
  static const Color surface = Color(0xFF131622);
  static const Color surfaceLight = Color(0xFF1E2235);
  
  static const Color primary = Color(0xFF7C3AED); // Cyberpunk Violet
  static const Color secondary = Color(0xFF06B6D4); // Cyberpunk Cyan
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentYellow = Color(0xFFF59E0B);
  
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);
  
  static const Color border = Color(0xFF262B44);
  static const Color borderLight = Color(0xFF374151);

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
    Color primaryColor = const Color(0xFF7C3AED);
    Color secondaryColor = const Color(0xFF06B6D4);
    Color scaffoldBg = const Color(0xFF090A0F);
    Color surfaceColor = const Color(0xFF131622);
    Color borderCol = const Color(0xFF262B44);
    
    if (activeTheme == 'emerald') {
      primaryColor = const Color(0xFF10B981);
      secondaryColor = const Color(0xFF34D399);
      scaffoldBg = const Color(0xFF070908);
      surfaceColor = const Color(0xFF0F1512);
      borderCol = const Color(0xFF1C2D24);
    } else if (activeTheme == 'sunset') {
      primaryColor = const Color(0xFFEC4899);
      secondaryColor = const Color(0xFFF97316);
      scaffoldBg = const Color(0xFF0F0712);
      surfaceColor = const Color(0xFF1B0F22);
      borderCol = const Color(0xFF331B40);
    } else if (activeTheme == 'glacier') {
      primaryColor = const Color(0xFF0EA5E9);
      secondaryColor = const Color(0xFF22D3EE);
      scaffoldBg = const Color(0xFF070C14);
      surfaceColor = const Color(0xFF0E1624);
      borderCol = const Color(0xFF192A40);
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        onSurface: const Color(0xFFF3F4F6),
        error: const Color(0xFFEC4899),
      ),
      dividerTheme: DividerThemeData(
        color: borderCol,
        thickness: 1,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF3F4F6),
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF3F4F6),
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: const Color(0xFFF3F4F6),
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: const Color(0xFF9CA3AF),
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
        unselectedItemColor: const Color(0xFF6B7280),
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
    Color surfaceColor = AppColors.surface;
    Color borderColor = AppColors.border;
    
    if (activeTheme == 'emerald') {
      surfaceColor = const Color(0xFF0F1512);
      borderColor = const Color(0xFF1C2D24);
    } else if (activeTheme == 'sunset') {
      surfaceColor = const Color(0xFF1B0F22);
      borderColor = const Color(0xFF331B40);
    } else if (activeTheme == 'glacier') {
      surfaceColor = const Color(0xFF0E1624);
      borderColor = const Color(0xFF192A40);
    }

    return BoxDecoration(
      color: color ?? surfaceColor.withOpacity(0.8),
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: border ?? Border.all(color: borderColor, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
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
