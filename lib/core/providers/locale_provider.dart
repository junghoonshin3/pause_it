import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [LocaleNotifier] - 언어 설정 상태 관리
///
/// 주요 기능:
/// - 현재 선택된 언어 상태 관리
/// - 언어 변경
/// - 언어 초기화 (시스템 언어로 복귀)
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null);

  /// [setLocale] - 언어 설정
  void setLocale(Locale locale) => state = locale;

  /// [clearLocale] - 언어 초기화 (시스템 언어 사용)
  void clearLocale() => state = null;
}

/// [localeProvider] - 언어 설정 Provider
///
/// null이면 시스템 언어 사용
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) => LocaleNotifier(),
);

/// [supportedLocales] - 지원하는 언어 목록
///
/// - ko_KR: 한국어
/// - en_US: 영어
/// - ja_JP: 일본어
const supportedLocales = [
  Locale('ko', 'KR'),
  Locale('en', 'US'),
  Locale('ja', 'JP'),
];
