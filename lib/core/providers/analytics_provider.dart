import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';

/// [analyticsServiceProvider] - AnalyticsService 싱글톤 Provider
///
/// 위젯 컨텍스트에서 사용: ref.read(analyticsServiceProvider)
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService.instance;
});
