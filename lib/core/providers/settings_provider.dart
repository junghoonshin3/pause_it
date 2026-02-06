import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [AppSettings] - 앱 설정 데이터 클래스
///
/// SharedPreferences로 백킹되는 설정 상태
class AppSettings {
  /// 알림 전체 ON/OFF
  final bool alarmEnabled;

  /// 리마인더 알림 ON/OFF
  final bool reminderEnabled;

  /// 리마인더 지연 시간 (분 단위, 선택지: 15, 30, 60, 180, 360, 1440)
  final int reminderDelayMinutes;

  const AppSettings({
    this.alarmEnabled = true,
    this.reminderEnabled = true,
    this.reminderDelayMinutes = 180,
  });

  AppSettings copyWith({
    bool? alarmEnabled,
    bool? reminderEnabled,
    int? reminderDelayMinutes,
  }) {
    return AppSettings(
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDelayMinutes: reminderDelayMinutes ?? this.reminderDelayMinutes,
    );
  }
}

/// SharedPreferences 키 상수
const String _keyAlarmEnabled = 'alarm_enabled';
const String _keyReminderEnabled = 'reminder_enabled';
const String _keyReminderDelayMinutes = 'reminder_delay_minutes';

/// [SettingsNotifier] - 앱 설정 상태 관리 (StateNotifier 패턴)
///
/// SharedPreferences에서 설정값을 복원하고, 변경 시 자동 저장
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  /// [loadSettings] - SharedPreferences에서 저장된 설정 복원
  ///
  /// 앱 시작 시 한 번만 호출
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = AppSettings(
        alarmEnabled: prefs.getBool(_keyAlarmEnabled) ?? true,
        reminderEnabled: prefs.getBool(_keyReminderEnabled) ?? true,
        reminderDelayMinutes: prefs.getInt(_keyReminderDelayMinutes) ?? 180,
      );
    } catch (e) {
      // 복원 실패 시 기본값 유지
      debugPrint('❌ 설정 복원 실패: $e');
    }
  }

  /// [setAlarmEnabled] - 알림 전체 ON/OFF 변경
  Future<void> setAlarmEnabled(bool value) async {
    state = state.copyWith(alarmEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAlarmEnabled, value);
  }

  /// [setReminderEnabled] - 리마인더 알림 ON/OFF 변경
  Future<void> setReminderEnabled(bool value) async {
    state = state.copyWith(reminderEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReminderEnabled, value);
  }

  /// [setReminderDelayMinutes] - 리마인더 지연 시간 변경 (15, 30, 60, 180, 360, 1440)
  Future<void> setReminderDelayMinutes(int value) async {
    state = state.copyWith(reminderDelayMinutes: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyReminderDelayMinutes, value);
  }
}

/// [settingsProvider] - 앱 설정 Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);
