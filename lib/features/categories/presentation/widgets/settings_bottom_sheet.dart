import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// [SettingsBottomSheet] - Neo-Brutalist 디자인의 앱 설정 BottomSheet
///
/// 구성:
/// - 알림 전체 ON/OFF (Switch)
/// - 리마인더 알림 ON/OFF (Switch)
/// - 리마인더 시간 선택 (DropdownButton, 분 단위)
///
/// 알림 전체가 OFF이면 아래 항목은 시각적으로 비활성화됨
class SettingsBottomSheet extends ConsumerWidget {
  const SettingsBottomSheet({super.key});

  /// Dropdown 옵션 목록 (분 단위): 15분, 30분, 1시간, 3시간, 6시간, 24시간
  static const List<int> _delayOptions = [15, 30, 60, 180, 360, 1440];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context);
    final isDelayEnabled = settings.alarmEnabled && settings.reminderEnabled;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        border: Border(
          top: BorderSide(color: AppTheme.accentElectric, width: 3),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Text(
              l10n.settingsTitle.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),

            // 구분선
            Container(
              height: 2,
              color: AppTheme.accentElectric,
            ),
            const SizedBox(height: 20),

            // 알림 전체 ON/OFF
            _buildSwitchRow(
              context,
              label: l10n.settingsAlarmEnabled,
              value: settings.alarmEnabled,
              enabled: true,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setAlarmEnabled(value);
              },
            ),
            const SizedBox(height: 16),

            // 리마인더 알림 ON/OFF (알림 전체 OFF이면 disabled)
            _buildSwitchRow(
              context,
              label: l10n.settingsReminderEnabled,
              value: settings.reminderEnabled,
              enabled: settings.alarmEnabled,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setReminderEnabled(value);
              },
            ),
            const SizedBox(height: 16),

            // 리마인더 시간 Dropdown 선택
            _buildDelayRow(context, ref, l10n, settings, isDelayEnabled),
          ],
        ),
      ),
    );
  }

  /// [_buildSwitchRow] - Switch 항목 행 생성
  Widget _buildSwitchRow(
    BuildContext context, {
    required String label,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: enabled ? AppTheme.textPrimary : AppTheme.textTertiary,
          ),
        ),
        Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeThumbColor: AppTheme.accentElectric,
          activeTrackColor: AppTheme.accentElectric.withValues(alpha: 0.4),
          inactiveTrackColor: AppTheme.textTertiary.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  /// [_buildDelayRow] - 리마인더 시간 Dropdown 선택 행 생성
  ///
  /// 옵션 표시 규칙: 60분 미만 → settingsReminderMinute, 60분 이상 → settingsReminderHour
  Widget _buildDelayRow(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AppSettings settings,
    bool isEnabled,
  ) {
    final borderColor = isEnabled
        ? AppTheme.accentElectric
        : AppTheme.textTertiary.withValues(alpha: 0.3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.settingsReminderDelay,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isEnabled ? AppTheme.textPrimary : AppTheme.textTertiary,
          ),
        ),

        // DropdownButton (Neo-Brutalist 스타일)
        Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryDark,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: DropdownButton<int>(
            value: settings.reminderDelayMinutes,
            onChanged: isEnabled
                ? (value) {
                    if (value != null) {
                      ref
                          .read(settingsProvider.notifier)
                          .setReminderDelayMinutes(value);
                    }
                  }
                : null,
            items: _delayOptions.map((minutes) {
              // 60분 미만이면 분 단위, 60분 이상이면 시간 단위로 표시
              final label = minutes < 60
                  ? l10n.settingsReminderMinute(minutes)
                  : l10n.settingsReminderHour(minutes ~/ 60);
              return DropdownMenuItem<int>(
                value: minutes,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontFamily: AppTheme.fontFamilyMono,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }).toList(),
            dropdownColor: AppTheme.primaryDark,
            underline: const SizedBox.shrink(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            icon: Icon(
              Icons.arrow_drop_down,
              color: isEnabled ? AppTheme.accentElectric : AppTheme.textTertiary,
            ),
            iconSize: 20,
          ),
        ),
      ],
    );
  }
}
