import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// [AppTheme] - Pause it의 Neo-Brutalist 테마 시스템
///
/// 디자인 철학:
/// - 대담한 기하학적 형태와 고대비 타이포그래피
/// - 의도적인 거칠함과 날카로운 모서리
/// - 비대칭 레이아웃과 겹치는 요소들
/// - 프리미엄 미디어 관리 도구의 느낌
class AppTheme {
  // ============ 색상 시스템 ============

  // Base Colors - 깊은 차콜 베이스
  static const Color primaryDark = Color(0xFF1A1A1D);
  static const Color secondaryDark = Color(0xFF2D2D30);
  static const Color surfaceDark = Color(0xFF25252A);

  // Accent Colors - 전기적인 강조색
  static const Color accentElectric = Color(0xFF00F0FF); // 시안
  static const Color accentNeon = Color(0xFFFF006E); // 네온 핑크
  static const Color accentYellow = Color(0xFFFBFF00); // 경고 노랑
  static const Color accentPurple = Color(0xFF8B5CF6); // 보라

  // Functional Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4B4B8);
  static const Color textTertiary = Color(0xFF6E6E73);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // ============ 타이포그래피 ============

  static const String fontFamilyMono = 'RobotoMono'; // 타임스탬프용 모노스페이스

  static TextTheme get textTheme {
    // Space Grotesk for display (영문), Noto Sans KR for 한글
    return GoogleFonts.spaceGroteskTextTheme().copyWith(
      // Display - 대형 타이틀
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 57,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 45,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),

      // Headline - 섹션 헤더
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),

      // Title - 카드 타이틀
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleMedium: GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.1,
      ),

      // Body - 본문
      bodyLarge: GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.4,
      ),

      // Label - 버튼/라벨
      labelLarge: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.5,
      ),
    );
  }

  // ============ 다크 테마 ============

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // 색상 스킴
    colorScheme: ColorScheme.dark(
      primary: accentElectric,
      secondary: accentNeon,
      tertiary: accentYellow,
      surface: surfaceDark,
      surfaceContainerHighest: secondaryDark,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      error: error,
    ),

    scaffoldBackgroundColor: primaryDark,

    // 타이포그래피
    textTheme: textTheme,

    // AppBar 테마
    appBarTheme: AppBarTheme(
      backgroundColor: primaryDark,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: textTheme.headlineMedium?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w800,
      ),
    ),

    // Card 테마 - Brutalist 스타일
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0), // 날카로운 직각
        side: BorderSide(
          color: textTertiary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      margin: EdgeInsets.zero,
    ),

    // FloatingActionButton 테마
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentElectric,
      foregroundColor: primaryDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: const BorderSide(
          color: accentElectric,
          width: 3,
        ),
      ),
    ),

    // 다이얼로그 테마
    dialogTheme: DialogThemeData(
      backgroundColor: secondaryDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: const BorderSide(
          color: accentElectric,
          width: 3,
        ),
      ),
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w800,
      ),
    ),

    // BottomSheet 테마
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: secondaryDark,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
        side: BorderSide(
          color: accentElectric,
          width: 3,
        ),
      ),
    ),

    // Input 테마
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: primaryDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: BorderSide(
          color: textTertiary,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: BorderSide(
          color: textTertiary,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: const BorderSide(
          color: accentElectric,
          width: 3,
        ),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: textSecondary,
      ),
    ),

    // 스낵바 테마
    snackBarTheme: SnackBarThemeData(
      backgroundColor: secondaryDark,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: textPrimary,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: const BorderSide(
          color: accentElectric,
          width: 2,
        ),
      ),
    ),

    // 아이콘 테마
    iconTheme: const IconThemeData(
      color: textPrimary,
      size: 24,
    ),
  );

  // ============ 애니메이션 설정 ============

  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  static const Curve animationCurve = Curves.easeOutCubic;
  static const Curve animationCurveSharp = Curves.easeOutExpo;

  // ============ 그림자 (Brutalist - 강한 드롭섀도우) ============

  static List<BoxShadow> brutalistShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      offset: const Offset(6, 6),
      blurRadius: 0,
    ),
  ];

  static List<BoxShadow> brutalistShadowHeavy = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.6),
      offset: const Offset(8, 8),
      blurRadius: 0,
    ),
  ];
}
