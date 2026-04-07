import 'package:flutter/material.dart';

class AppTheme {
  static const _lightSeed = Color(0xFF0F766E);
  static const _darkSeed = Color(0xFF34D399);
  static const _lightBackground = Color(0xFFF4F7F5);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightSurfaceAlt = Color(0xFFE8EFEC);
  static const _darkBackground = Color(0xFF0F1720);
  static const _darkSurface = Color(0xFF16212C);
  static const _darkSurfaceAlt = Color(0xFF1B2A36);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _lightSeed,
      brightness: Brightness.light,
      primary: _lightSeed,
      surface: _lightSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _lightBackground,
      canvasColor: _lightBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: _lightBackground,
        foregroundColor: Color(0xFF102A26),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _lightSurface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        hintStyle: const TextStyle(color: Color(0xFF6E7E79)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _lightSeed, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _lightSurface,
        selectedColor: const Color(0xFFD7F2EC),
        disabledColor: _lightSurfaceAlt,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF23403A),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _lightSeed,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: _lightSeed,
          foregroundColor: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: _lightSurface,
        selectedItemColor: _lightSeed,
        unselectedItemColor: const Color(0xFF6A7B76),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      dividerColor: _lightSurfaceAlt,
      iconTheme: const IconThemeData(color: Color(0xFF244A43)),
      listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.zero),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _lightSeed,
        linearTrackColor: _lightSurfaceAlt,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: _lightSeed,
        thumbColor: _lightSeed,
        inactiveTrackColor: _lightSurfaceAlt,
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _darkSeed,
      brightness: Brightness.dark,
      primary: _darkSeed,
      surface: _darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _darkBackground,
      canvasColor: _darkBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: _darkBackground,
        foregroundColor: Color(0xFFE6FFF9),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _darkSurface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        hintStyle: const TextStyle(color: Color(0xFF89A29A)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _darkSeed, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _darkSurface,
        selectedColor: const Color(0xFF143C37),
        disabledColor: _darkSurfaceAlt,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFFD2FFF5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _darkSeed,
          foregroundColor: const Color(0xFF09221E),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: _darkSeed,
          foregroundColor: const Color(0xFF09221E),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: _darkSurface,
        selectedItemColor: _darkSeed,
        unselectedItemColor: const Color(0xFF7E9A92),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      dividerColor: _darkSurfaceAlt,
      iconTheme: const IconThemeData(color: Color(0xFFC4FBEF)),
      listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.zero),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _darkSeed,
        linearTrackColor: _darkSurfaceAlt,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: _darkSeed,
        thumbColor: _darkSeed,
        inactiveTrackColor: _darkSurfaceAlt,
      ),
    );
  }
}
