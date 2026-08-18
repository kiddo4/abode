import 'package:flutter/material.dart';

/// The single source of design truth.
///
/// Editorial/architectural: a near-white paper canvas, hairline rules instead
/// of shadows, one restrained accent, and typography doing the heavy lifting.
/// Deliberately no gradients anywhere — depth comes from whitespace, rules, and
/// the liquid-glass chrome floating above the 3D.
abstract final class AbodeColors {
  static const canvas = Color(0xFFFBFAF8);
  static const surface = Color(0xFFFFFFFF);
  static const hairline = Color(0xFFE4E2DC);

  static const ink = Color(0xFF14140F);
  static const inkSecondary = Color(0xFF6B6B63);
  static const inkTertiary = Color(0xFF9A9A90);

  /// Exactly one accent. Change this token, change the whole app.
  static const accent = Color(0xFFB4543A);

  /// The backdrop the 3D viewport clears to. Matches the card [surface] it
  /// sits on, so the model reads as printed on the card rather than framed in
  /// a video window.
  static const viewport = surface;
}

abstract final class AbodeSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 40.0;
  static const xxl = 64.0;

  /// Horizontal page margin. Generous, so content reads as a printed page.
  static const gutter = 24.0;
}

abstract final class AbodeType {
  static const display = 'Fraunces';
  static const body = 'Inter';

  /// Prices and headline numerals — the typographic hero.
  static const price = TextStyle(
    fontFamily: display,
    fontSize: 34,
    height: 1.05,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.8,
    color: AbodeColors.ink,
  );

  static const headline = TextStyle(
    fontFamily: display,
    fontSize: 26,
    height: 1.15,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.4,
    color: AbodeColors.ink,
  );

  /// Listing names on cards — display serif, so a card reads as a catalogue
  /// entry rather than a list row.
  static const cardTitle = TextStyle(
    fontFamily: display,
    fontSize: 23,
    height: 1.1,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.3,
    color: AbodeColors.ink,
  );

  /// The index numeral on each card ("01").
  static const index = TextStyle(
    fontFamily: display,
    fontSize: 15,
    height: 1,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AbodeColors.inkTertiary,
  );

  static const title = TextStyle(
    fontFamily: body,
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AbodeColors.ink,
  );

  static const bodyText = TextStyle(
    fontFamily: body,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AbodeColors.inkSecondary,
  );

  static const label = TextStyle(
    fontFamily: body,
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: AbodeColors.inkSecondary,
  );

  /// Small caps-ish eyebrow used for section headers and metadata.
  static const eyebrow = TextStyle(
    fontFamily: body,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.1,
    color: AbodeColors.inkTertiary,
  );
}

abstract final class AbodeRadius {
  /// Sharp and architectural. Capsules are reserved for glass chrome.
  static const card = 4.0;
  static const chip = 999.0;
}

ThemeData buildAbodeTheme() {
  const scheme = ColorScheme.light(
    primary: AbodeColors.accent,
    onPrimary: Colors.white,
    surface: AbodeColors.surface,
    onSurface: AbodeColors.ink,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AbodeColors.canvas,
    fontFamily: AbodeType.body,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    dividerTheme: const DividerThemeData(
      color: AbodeColors.hairline,
      thickness: 1,
      space: 1,
    ),
  );
}
