import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

/// [NotificationService] - 로컬 알림 관리 서비스
///
/// 주요 기능:
/// - 로컬 알림 초기화 및 권한 요청
/// - 영상 알림 스케줄 (3시간 후)
/// - Android 그룹 알림 관리 (groupKey + group summary)
/// - 알림 취소 (그룹 summary 자동 정리)
/// - 알림 클릭 시 YouTube 앱 실행
///
/// 사용 예시:
/// ```dart
/// // 초기화
/// await NotificationService.instance.initialize();
/// await NotificationService.instance.requestPermission();
///
/// // 알림 스케줄
/// await NotificationService.instance.scheduleVideoReminder(
///   videoId: 1,
///   videoTitle: '영상 제목',
///   youtubeVideoId: 'dQw4w9WgXcQ',
///   timestampSeconds: 120,
/// );
///
/// // 알림 취소
/// await NotificationService.instance.cancelNotification(1);
/// ```
class NotificationService {
  /// 싱글톤 인스턴스
  static final NotificationService instance = NotificationService._internal();

  /// Flutter Local Notifications Plugin 인스턴스
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// private 생성자 (싱글톤 패턴)
  NotificationService._internal();

  /// Android 그룹 알림 summary의 고정 ID (Video ID는 AUTOINCREMENT 1부터이므로 충돌 없음)
  static const int _groupSummaryId = 0;

  /// Android 그룹 알림을 묶는 키
  static const String _groupKey = 'pause_it_video_reminders';

  /// 영상 리마인더 알림 지연 시간
  static const Duration _reminderDelay = Duration(hours: 3);

  /// [initialize] - 알림 서비스 초기화
  ///
  /// 앱 시작 시 한 번만 호출
  /// Android/iOS 플랫폼별 설정 및 알림 채널 생성
  Future<void> initialize() async {
    // Android 초기화 설정
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 초기화 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 통합 초기화 설정
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 알림 플러그인 초기화 (알림 클릭 콜백 포함)
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android 알림 채널 생성
    const androidChannel = AndroidNotificationChannel(
      'video_reminder', // 채널 ID
      '영상 알림', // 채널 이름
      description: '나중에 보려던 영상을 알려드립니다', // 채널 설명
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    print('✅ NotificationService 초기화 완료');
  }

  /// [scheduleVideoReminder] - 3시간 후 영상 알림 스케줄
  ///
  /// 개별 영상 알림 스케줄 후 Android에서는 그룹 summary도 갱신
  ///
  /// Parameters:
  /// - [videoId]: 영상 ID (알림 ID로 사용)
  /// - [videoTitle]: 영상 제목
  /// - [youtubeVideoId]: YouTube 영상 ID
  /// - [timestampSeconds]: 재생 시작 위치 (초)
  Future<void> scheduleVideoReminder({
    required int videoId,
    required String videoTitle,
    required String youtubeVideoId,
    required int timestampSeconds,
  }) async {
    try {
      // 3시간 후 시간 계산
      final scheduledDate = tz.TZDateTime.now(tz.local).add(_reminderDelay);

      // YouTube URL 생성 (타임스탬프 포함)
      final youtubeUrl =
          'https://www.youtube.com/watch?v=$youtubeVideoId&t=${timestampSeconds}s';

      // 개별 영상 알림 스케줄
      await _notifications.zonedSchedule(
        videoId, // 알림 ID = 영상 ID
        '나중에 보려던 영상이 있어요! 🎬',
        '$videoTitle - 다시 이어서 보기',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'video_reminder',
            '영상 알림',
            channelDescription: '나중에 보려던 영상을 알려드립니다',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            groupKey: _groupKey,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: youtubeUrl, // 알림 클릭 시 전달될 URL
      );

      print('✅ 알림 스케줄: ID=$videoId, 제목=$videoTitle, 발송시간=$scheduledDate');

      // Android에서만 그룹 summary 스케줄/갱신
      if (Platform.isAndroid) {
        await _scheduleOrUpdateGroupSummary(scheduledDate);
      }
    } catch (e) {
      print('❌ 알림 스케줄 실패: $e');
    }
  }

  /// [_scheduleOrUpdateGroupSummary] - Android 그룹 알림 summary 스케줄 또는 갱신
  ///
  /// 영상이 추가될 때마다 기존 summary를 취소하고 새로운 시간으로 재스케줄
  /// payload=null이므로 탭하면 앱만 열림 (YouTube 실행 안 됨)
  Future<void> _scheduleOrUpdateGroupSummary(tz.TZDateTime scheduledDate) async {
    // 기존 group summary 취소 (같은 ID 중복 방지)
    await _notifications.cancel(_groupSummaryId);

    // group summary 스케줄
    await _notifications.zonedSchedule(
      _groupSummaryId,
      '나중에 보려던 영상이 있어요! 🎬',
      '저장한 영상을 이어서 보기',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'video_reminder',
          '영상 알림',
          channelDescription: '나중에 보려던 영상을 알려드립니다',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          groupKey: _groupKey,
          setAsGroupSummary: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: null, // 탭 시 앱만 열림
    );

    print('✅ 그룹 summary 갱신: 발송시간=$scheduledDate');
  }

  /// [cancelNotification] - 알림 취소
  ///
  /// 영상 삭제 시 예약된 알림도 함께 취소
  /// Android에서 남은 영상 알림이 없으면 group summary도 함께 취소
  ///
  /// Parameters:
  /// - [videoId]: 취소할 알림의 영상 ID
  Future<void> cancelNotification(int videoId) async {
    try {
      await _notifications.cancel(videoId);
      print('🗑️ 알림 취소: ID=$videoId');

      // Android에서 남은 영상 알림이 없으면 group summary도 취소
      if (Platform.isAndroid) {
        final pending = await _notifications.pendingNotificationRequests();
        // _groupSummaryId(0)을 제외한 예약 알림이 남아있지 않으면 summary 취소
        final hasRemainingVideoAlarms =
            pending.any((n) => n.id != _groupSummaryId);
        if (!hasRemainingVideoAlarms) {
          await _notifications.cancel(_groupSummaryId);
          print('🗑️ 그룹 summary 취소 (남은 영상 알림 없음)');
        }
      }
    } catch (e) {
      print('❌ 알림 취소 실패: $e');
    }
  }

  /// [cancelAllNotifications] - 모든 알림 취소
  ///
  /// 앱 설정 리셋 시 사용
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('🗑️ 모든 알림 취소 완료');
    } catch (e) {
      print('❌ 모든 알림 취소 실패: $e');
    }
  }

  /// [_onNotificationTapped] - 알림 클릭 시 콜백
  ///
  /// 알림 클릭 시 YouTube 앱/브라우저로 영상 재생
  ///
  /// Parameters:
  /// - [response]: 알림 응답 객체 (payload 포함)
  void _onNotificationTapped(NotificationResponse response) async {
    final payload = response.payload;

    if (payload != null && payload.isNotEmpty) {
      try {
        final url = Uri.parse(payload);

        if (await canLaunchUrl(url)) {
          // YouTube 앱 우선 실행 (iOS/Android)
          await launchUrl(url, mode: LaunchMode.externalApplication);
          print('✅ 알림 클릭 → YouTube 실행: $payload');
        } else {
          print('❌ URL 실행 불가: $payload');
        }
      } catch (e) {
        print('❌ 알림 클릭 처리 실패: $e');
      }
    }
  }

  /// [requestPermission] - 알림 권한 요청
  ///
  /// iOS 및 Android 13+ 에서 필수
  ///
  /// Returns: 권한 허용 여부
  Future<bool> requestPermission() async {
    try {
      // Android 플러그인 인스턴스
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // iOS 플러그인 인스턴스
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      // Android 알림 권한 요청 (Android 13+)
      bool? androidGranted =
          await androidPlugin?.requestNotificationsPermission();

      // iOS 알림 권한 요청
      bool? iosGranted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      final granted = (androidGranted ?? true) && (iosGranted ?? true);

      if (granted) {
        print('✅ 알림 권한 허용됨');
      } else {
        print('⚠️ 알림 권한 거부됨');
      }

      return granted;
    } catch (e) {
      print('❌ 알림 권한 요청 실패: $e');
      return false;
    }
  }

  /// [getPendingNotifications] - 예약된 알림 목록 조회
  ///
  /// 디버깅 및 테스트용
  ///
  /// Returns: 예약된 알림 목록
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
