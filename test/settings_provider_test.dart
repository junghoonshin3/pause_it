import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pause_it/core/providers/settings_provider.dart';

void main() {
  /// 각 테스트 전 SharedPreferences를 빈 상태로 초기화
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppSettings 기본값·copyWith', () {
    test('기본값이 올바르게 설정된다', () {
      const settings = AppSettings();

      expect(settings.alarmEnabled, true);
      expect(settings.reminderEnabled, true);
      expect(settings.reminderDelayMinutes, 180);
    });

    test('copyWith 부분 업데이트 시 미변경 필드는 유지된다', () {
      const settings = AppSettings();
      final updated = settings.copyWith(reminderDelayMinutes: 30);

      expect(updated.reminderDelayMinutes, 30);
      expect(updated.alarmEnabled, true);
      expect(updated.reminderEnabled, true);
    });

    test('copyWith 모든 필드를 동시에 변경할 수 있다', () {
      const settings = AppSettings();
      final updated = settings.copyWith(
        alarmEnabled: false,
        reminderEnabled: false,
        reminderDelayMinutes: 1440,
      );

      expect(updated.alarmEnabled, false);
      expect(updated.reminderEnabled, false);
      expect(updated.reminderDelayMinutes, 1440);
    });
  });

  group('SettingsNotifier - 초기 상태', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Provider 초기 상태가 기본값과 동일한다', () {
      final state = container.read(settingsProvider);

      expect(state.alarmEnabled, true);
      expect(state.reminderEnabled, true);
      expect(state.reminderDelayMinutes, 180);
    });
  });

  group('SettingsNotifier - alarmEnabled', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('setAlarmEnabled(false)로 상태가 변경된다', () async {
      await container.read(settingsProvider.notifier).setAlarmEnabled(false);

      expect(container.read(settingsProvider).alarmEnabled, false);
    });

    test('setAlarmEnabled 값이 SharedPreferences에 저장된다', () async {
      await container.read(settingsProvider.notifier).setAlarmEnabled(false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('alarm_enabled'), false);
    });
  });

  group('SettingsNotifier - reminderEnabled', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('setReminderEnabled(false)로 상태가 변경된다', () async {
      await container.read(settingsProvider.notifier).setReminderEnabled(false);

      expect(container.read(settingsProvider).reminderEnabled, false);
    });

    test('setReminderEnabled 값이 SharedPreferences에 저장된다', () async {
      await container.read(settingsProvider.notifier).setReminderEnabled(false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('reminder_enabled'), false);
    });
  });

  group('SettingsNotifier - reminderDelayMinutes', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('setReminderDelayMinutes로 상태가 변경된다', () async {
      await container
          .read(settingsProvider.notifier)
          .setReminderDelayMinutes(30);

      expect(container.read(settingsProvider).reminderDelayMinutes, 30);
    });

    test('setReminderDelayMinutes 값이 SharedPreferences에 저장된다', () async {
      await container
          .read(settingsProvider.notifier)
          .setReminderDelayMinutes(360);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('reminder_delay_minutes'), 360);
    });

    /// Dropdown 옵션 6개 전부를 순회하며 저장·복원 검증
    test('6개 옵션 [15, 30, 60, 180, 360, 1440] 모두 저장·복원 가능', () async {
      final options = [15, 30, 60, 180, 360, 1440];

      for (final option in options) {
        // 현재 container에 저장
        await container
            .read(settingsProvider.notifier)
            .setReminderDelayMinutes(option);
        expect(container.read(settingsProvider).reminderDelayMinutes, option);

        // 별도 container로 loadSettings 복원 검증
        final tempContainer = ProviderContainer();
        await tempContainer.read(settingsProvider.notifier).loadSettings();
        expect(
          tempContainer.read(settingsProvider).reminderDelayMinutes,
          option,
          reason: 'loadSettings 복원 실패: option=$option',
        );
        tempContainer.dispose();
      }
    });
  });

  group('SettingsNotifier - loadSettings 복원', () {
    test('저장된 값이 있으면 loadSettings로 복원된다', () async {
      // 먼저 값 저장
      final container1 = ProviderContainer();
      await container1
          .read(settingsProvider.notifier)
          .setAlarmEnabled(false);
      await container1
          .read(settingsProvider.notifier)
          .setReminderEnabled(false);
      await container1
          .read(settingsProvider.notifier)
          .setReminderDelayMinutes(1440);
      container1.dispose();

      // 새 container에서 loadSettings
      final container2 = ProviderContainer();
      await container2.read(settingsProvider.notifier).loadSettings();

      final state = container2.read(settingsProvider);
      expect(state.alarmEnabled, false);
      expect(state.reminderEnabled, false);
      expect(state.reminderDelayMinutes, 1440);
      container2.dispose();
    });

    test('저장된 값이 없으면 loadSettings 후 기본값을 유지한다', () async {
      // SharedPreferences가 빈 상태에서 loadSettings
      final container = ProviderContainer();
      await container.read(settingsProvider.notifier).loadSettings();

      final state = container.read(settingsProvider);
      expect(state.alarmEnabled, true);
      expect(state.reminderEnabled, true);
      expect(state.reminderDelayMinutes, 180);
      container.dispose();
    });

    test('일부 키만 저장된 경우 나머지는 기본값을 사용한다', () async {
      // reminderDelayMinutes만 저장
      SharedPreferences.setMockInitialValues({
        'reminder_delay_minutes': 15,
      });

      final container = ProviderContainer();
      await container.read(settingsProvider.notifier).loadSettings();

      final state = container.read(settingsProvider);
      expect(state.alarmEnabled, true); // 기본값
      expect(state.reminderEnabled, true); // 기본값
      expect(state.reminderDelayMinutes, 15); // 저장된 값
      container.dispose();
    });
  });
}
