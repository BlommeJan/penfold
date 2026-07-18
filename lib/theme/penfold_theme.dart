import 'package:flutter/material.dart';

import 'penfold_colors.dart';

/// Penfold light and dark [ThemeData] definitions.
abstract final class PenfoldTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: PenfoldColors.blue,
      brightness: brightness,
      primary: PenfoldColors.blue,
      onPrimary: Colors.white,
      secondary: PenfoldColors.blueLight,
      onSecondary: Colors.white,
      tertiary: PenfoldColors.accent,
      surface: isLight ? PenfoldColors.lightSurface : PenfoldColors.darkSurface,
      onSurface:
          isLight ? PenfoldColors.lightOnSurface : PenfoldColors.darkOnSurface,
      surfaceContainerHighest: isLight
          ? const Color(0xFFEDF0F4)
          : PenfoldColors.darkSurfaceVariant,
      outline: isLight ? PenfoldColors.lightChipBorder : PenfoldColors.darkChipBorder,
    );

    final scaffoldBackground =
        isLight ? PenfoldColors.lightScaffold : PenfoldColors.darkScaffold;

    final dividerColor =
        isLight ? PenfoldColors.lightDivider : PenfoldColors.darkDivider;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: isLight ? PenfoldColors.lightSurface : PenfoldColors.darkSurface,
        foregroundColor:
            isLight ? PenfoldColors.lightOnSurface : PenfoldColors.darkOnSurface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: isLight
              ? PenfoldColors.lightOnSurface
              : PenfoldColors.darkOnSurface,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor:
            isLight ? PenfoldColors.lightSurface : PenfoldColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isLight
              ? PenfoldColors.lightOnSurface
              : PenfoldColors.darkOnSurface,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:
            isLight ? PenfoldColors.lightSurface : PenfoldColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: isLight
            ? PenfoldColors.lightChipBorder
            : PenfoldColors.darkChipBorder,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.primary,
        textColor: colorScheme.onSurface,
        subtitleTextStyle: TextStyle(
          color: isLight
              ? const Color(0xFF5D6D7E)
              : PenfoldColors.darkOnSurfaceMuted,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PenfoldColors.blue;
          }
          return isLight ? Colors.white : PenfoldColors.darkSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PenfoldColors.blue.withValues(alpha: 0.45);
          }
          return isLight
              ? const Color(0xFFBDC3C7)
              : PenfoldColors.darkChipBorder;
        }),
      ),
      chipTheme: ChipThemeData(
        selectedColor: PenfoldColors.blue.withValues(alpha: isLight ? 0.14 : 0.28),
        checkmarkColor: isLight ? PenfoldColors.blue : PenfoldColors.blueLight,
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
        side: BorderSide(color: dividerColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      segmentedButtonTheme: const SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? const Color(0xFFF4F6F9)
            : PenfoldColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: PenfoldColors.blue, width: 2),
        ),
        labelStyle: TextStyle(
          color: isLight
              ? const Color(0xFF5D6D7E)
              : PenfoldColors.darkOnSurfaceMuted,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PenfoldColors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PenfoldColors.blue,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: PenfoldColors.blue,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isLight ? PenfoldColors.lightOnSurface : PenfoldColors.darkSurfaceVariant,
        contentTextStyle: TextStyle(
          color: isLight ? Colors.white : PenfoldColors.darkOnSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: isLight ? PenfoldColors.lightSurface : PenfoldColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(colorScheme.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            isLight ? PenfoldColors.lightSurface : PenfoldColors.darkSurface,
          ),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      cardTheme: CardThemeData(
        color: isLight ? PenfoldColors.lightSurface : PenfoldColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: isLight ? 1 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isLight
                ? PenfoldColors.lightChipBorder
                : PenfoldColors.darkChipBorder,
          ),
        ),
      ),
    );
  }
}
