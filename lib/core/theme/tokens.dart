import 'package:material_ui/material_ui.dart';

/// Design tokens. Palette is derived from the CHI logo (amber sun disc, charcoal wave)
/// per section 10 of the requirements. Text colours are checked for WCAG AA on [AppColors.bg].
abstract final class AppColors {
  static const bg = Color(0xFFFBF6EE); // warm paper
  static const surface = Color(0xFFFFFFFF);
  static const sunken = Color(0xFFF4EDE1);
  static const ink = Color(0xFF1D1A16); // charcoal, primary text
  static const inkSoft = Color(0xFF4A443C);
  static const muted = Color(0xFF756C60); // secondary text, 4.7:1 on bg
  static const line = Color(0xFFE9E0D2);
  static const amber = Color(
    0xFFE9A23B,
  ); // logo sun: fills and accents only, not body text
  static const amberSoft = Color(0xFFFBEACB);
  static const amberLine = Color(0xFFF1D39C);
  static const amberDeep = Color(0xFF9A5B07); // amber that passes AA as text
  static const night = Color(0xFF211D18); // hero cards
  static const nightRaised = Color(0xFF2B261F);
  static const nightLine = Color(0xFF3A342C);
  static const onNight = Color(0xFFF7F1E7);
  static const onNightMuted = Color(0xFFB9AE9E);
  static const success = Color(0xFF2E7D4F);
  static const successSoft = Color(0xFFE2F1E7);
  static const successLine = Color(0xFFBFDDC9);
  static const danger = Color(0xFFB23B2A);
  static const dangerSoft = Color(0xFFF8E1DC);
  static const dangerLine = Color(0xFFEDBDB4);
  static const info = Color(0xFF2F5F8A);
  static const infoSoft = Color(0xFFE1ECF5);
  // Accents for patterned art on dark banners only.
  static const sage = Color(0xFF7FB89A);
  static const sky = Color(0xFF8FB3D6);
  static const amberLight = Color(0xFFF0B55E);
}

abstract final class Space {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class Radii {
  static const sm = 6.0;
  static const md = 10.0;
  static const lg = 12.0;
  static const pill = 999.0;
}

abstract final class Motion {
  static const press = Duration(milliseconds: 100);
  static const short = Duration(milliseconds: 200);
  static const page = Duration(milliseconds: 280);
  static const stagger = Duration(milliseconds: 30);
  static const enter = Curves.easeOutCubic;
  static const move = Curves.easeInOutCubic;
  static const exit = Curves.easeInCubic;
}

abstract final class Fonts {
  static const display = 'Fraunces';
  static const ui = 'Inter';
  static const arabic = 'Amiri';
}

const _tabular = [FontFeature.tabularFigures()];

abstract final class AppText {
  static const hero = TextStyle(
    fontFamily: Fonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 34,
    height: 40 / 34,
    letterSpacing: -0.6,
    color: AppColors.ink,
  );
  static const title = TextStyle(
    fontFamily: Fonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 28,
    height: 34 / 28,
    letterSpacing: -0.4,
    color: AppColors.ink,
  );
  static const heading = TextStyle(
    fontFamily: Fonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 26 / 20,
    letterSpacing: -0.2,
    color: AppColors.ink,
  );
  static const body = TextStyle(
    fontFamily: Fonts.ui,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 22 / 15,
    color: AppColors.ink,
  );

  /// List-row titles: a step lighter than [bodyStrong] so dense lists stay calm.
  static const bodyMedium = TextStyle(
    fontFamily: Fonts.ui,
    fontWeight: FontWeight.w500,
    fontSize: 15,
    height: 22 / 15,
    color: AppColors.ink,
  );
  static const bodyStrong = TextStyle(
    fontFamily: Fonts.ui,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 22 / 15,
    color: AppColors.ink,
  );
  static const label = TextStyle(
    fontFamily: Fonts.ui,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 18 / 13,
    color: AppColors.ink,
  );
  static const caption = TextStyle(
    fontFamily: Fonts.ui,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 16 / 12,
    color: AppColors.ink,
  );
  static const overline = TextStyle(
    fontFamily: Fonts.ui,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 18 / 13,
    color: AppColors.muted,
  );

  /// Times, amounts, countdowns: anything that lines up or ticks uses tabular figures.
  static const number = TextStyle(
    fontFamily: Fonts.ui,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 22 / 15,
    color: AppColors.ink,
    fontFeatures: _tabular,
  );
  static const arabic = TextStyle(
    fontFamily: Fonts.arabic,
    fontSize: 26,
    height: 50 / 26,
    color: AppColors.ink,
  );
}

extension TabularNums on TextStyle {
  TextStyle get tabular => copyWith(fontFeatures: _tabular);
}
