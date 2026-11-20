import 'package:material_ui/material_ui.dart';

/// Tokens from docs/ui-guidelines.md.
abstract final class TranixColors {
  static const seed = Color(0xFF1F4E79);
  static const amber = Color(0xFFF2A900);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFED6C02);
  static const error = Color(0xFFC62828);
  static const info = Color(0xFF0277BD);
  static const neutral = Color(0xFF616161);
}

/// Status colours as a theme extension so dark mode can supply its own later.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.neutral,
  });

  static const light = StatusColors(
    success: TranixColors.success,
    warning: TranixColors.warning,
    error: TranixColors.error,
    info: TranixColors.info,
    neutral: TranixColors.neutral,
  );

  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color neutral;

  @override
  StatusColors copyWith({Color? success, Color? warning, Color? error, Color? info, Color? neutral}) {
    return StatusColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      neutral: neutral ?? this.neutral,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
    );
  }
}

abstract final class AppTheme {
  /// Light theme at launch (ui-guidelines). Body text ≥ 16 sp; buttons ≥ 48 dp tall.
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: TranixColors.seed,
      secondary: TranixColors.amber,
      error: TranixColors.error,
    );
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    return base.copyWith(
      extensions: const [StatusColors.light],
      textTheme: base.textTheme.copyWith(
        bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 16),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      appBarTheme: AppBarTheme(backgroundColor: scheme.surface, centerTitle: false),
    );
  }
}

extension StatusColorsX on BuildContext {
  Color get successColor => statusColors.success;

  StatusColors get statusColors => Theme.of(this).extension<StatusColors>() ?? StatusColors.light;
}
