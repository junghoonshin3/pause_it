import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// [AnalyticsService] - Firebase Analytics 이벤트 로깅 싱글톤 서비스
///
/// 앱 내 사용자 액션을 타입안전한 메서드로 Firebase Analytics에 전송
/// kDebugMode에서는 console에 이벤트 정보를 출력
/// 모든 이벤트는 try-catch로 감싸어 로깅 실패 시 앱 충돌 방지
class AnalyticsService {
  /// 싱글톤 인스턴스
  static final AnalyticsService instance = AnalyticsService._internal();

  /// private 생성자 (싱글톤 패턴)
  AnalyticsService._internal();

  // ============ 내부 공통 메서드 ============

  /// [_log] - 내부 공통 이벤트 로깅 메서드
  ///
  /// kDebugMode에서 console 출력 후 FirebaseAnalytics에 전송
  Future<void> _log(String name, Map<String, Object>? params) async {
    try {
      if (kDebugMode) {
        debugPrint('[Analytics] $name: ${params ?? {}}');
      }
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: params,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Analytics] ❌ 로깅 실패 ($name): $e');
      }
    }
  }

  // ============ 앱 라이프사이클 이벤트 ============

  /// [logAppStarted] - 앱 시작 이벤트
  Future<void> logAppStarted() async {
    await _log('app_started', null);
  }

  /// [logAppResumed] - 앱 백그라운드에서 복귀 이벤트
  Future<void> logAppResumed() async {
    await _log('app_resumed', null);
  }

  /// [logAppPaused] - 앱 백그라운드로 이동 이벤트
  Future<void> logAppPaused() async {
    await _log('app_paused', null);
  }

  /// [logAppDetached] - 앱 종료 이벤트
  Future<void> logAppDetached() async {
    await _log('app_detached', null);
  }

  // ============ 카테고리 이벤트 ============

  /// [logCategoryCreated] - 카테고리 생성 이벤트
  Future<void> logCategoryCreated({required String name}) async {
    await _log('category_created', {'name': name});
  }

  /// [logCategoryUpdated] - 카테고리 수정 이벤트
  Future<void> logCategoryUpdated({required int id, required String name}) async {
    await _log('category_updated', {'id': id, 'name': name});
  }

  /// [logCategoryDeleted] - 카테고리 삭제 이벤트
  Future<void> logCategoryDeleted({required int id, required String name}) async {
    await _log('category_deleted', {'id': id, 'name': name});
  }

  /// [logCategoryOpened] - 카테고리 열기 (영상 목록 전이) 이벤트
  Future<void> logCategoryOpened({
    required int id,
    required String name,
    required int videoCount,
  }) async {
    await _log('category_opened', {
      'id': id,
      'name': name,
      'video_count': videoCount,
    });
  }

  // ============ 영상 이벤트 ============

  /// [logVideoAdded] - 영상 추가 이벤트
  ///
  /// source: 'manual' (수동 추가) 또는 'share_intent' (공유 URL)
  Future<void> logVideoAdded({
    required int videoId,
    required int categoryId,
    required bool hasTimestamp,
    required String source,
  }) async {
    await _log('video_added', {
      'video_id': videoId,
      'category_id': categoryId,
      'has_timestamp': hasTimestamp,
      'source': source,
    });
  }

  /// [logVideoUpdated] - 영상 수정 이벤트 (카테고리 변경 제외)
  Future<void> logVideoUpdated({
    required int videoId,
    required bool timestampChanged,
    required bool memoChanged,
  }) async {
    await _log('video_updated', {
      'video_id': videoId,
      'timestamp_changed': timestampChanged,
      'memo_changed': memoChanged,
    });
  }

  /// [logVideoMoved] - 영상 카테고리 변경 이벤트
  Future<void> logVideoMoved({
    required int videoId,
    required int fromCategoryId,
    required int toCategoryId,
  }) async {
    await _log('video_moved', {
      'video_id': videoId,
      'from_category_id': fromCategoryId,
      'to_category_id': toCategoryId,
    });
  }

  /// [logVideoDeleted] - 영상 삭제 이벤트
  Future<void> logVideoDeleted({
    required int videoId,
    required int categoryId,
  }) async {
    await _log('video_deleted', {
      'video_id': videoId,
      'category_id': categoryId,
    });
  }

  /// [logVideoPlayed] - 영상 재생 (YouTube 실행) 이벤트
  Future<void> logVideoPlayed({
    required int videoId,
    required int categoryId,
    required int timestampSeconds,
  }) async {
    await _log('video_played', {
      'video_id': videoId,
      'category_id': categoryId,
      'timestamp_seconds': timestampSeconds,
    });
  }

  // ============ 공유 Intent 이벤트 ============

  /// [logShareIntentReceived] - 공유 URL 수신 및 파싱 성공 이벤트
  Future<void> logShareIntentReceived({required bool hasTimestamp}) async {
    await _log('share_intent_received', {'has_timestamp': hasTimestamp});
  }

  /// [logShareIntentCancelled] - 공유 URL 카테고리 선택 취소 이벤트
  Future<void> logShareIntentCancelled() async {
    await _log('share_intent_cancelled', null);
  }

  // ============ 알림 이벤트 ============

  /// [logNotificationTapped] - 알림 클릭 → YouTube 실행 이벤트
  Future<void> logNotificationTapped({required int videoId}) async {
    await _log('notification_tapped', {'video_id': videoId});
  }
}
