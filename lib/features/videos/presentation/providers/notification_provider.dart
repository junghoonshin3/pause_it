import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';

/// [notificationServiceProvider] - NotificationService Provider
///
/// 싱글톤 NotificationService 인스턴스를 제공하는 Provider
///
/// 사용 예시:
/// ```dart
/// final notificationService = ref.read(notificationServiceProvider);
/// await notificationService.scheduleVideoReminder(...);
/// ```
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});
