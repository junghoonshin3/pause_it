import 'package:equatable/equatable.dart';

/// [Video] - 유튜브 타임스탬프 도메인 엔티티
///
/// 주요 특징:
/// - 유튜브 영상의 특정 시점을 저장하는 핵심 엔티티
/// - Immutable 객체로 안전한 상태 관리
/// - Equatable을 통한 객체 비교
///
/// 사용 예시:
/// ```dart
/// final video = Video(
///   id: 1,
///   categoryId: 1,
///   youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
///   youtubeVideoId: 'dQw4w9WgXcQ',
///   title: 'Never Gonna Give You Up',
///   timestampSeconds: 120,
///   createdAt: DateTime.now(),
///   updatedAt: DateTime.now(),
/// );
/// ```
class Video extends Equatable {
  /// 비디오 ID (Primary Key, Auto Increment)
  final int? id;

  /// 소속 카테고리 ID (Foreign Key)
  final int categoryId;

  /// 원본 유튜브 URL
  /// - 예: https://www.youtube.com/watch?v=dQw4w9WgXcQ
  /// - 예: https://youtu.be/dQw4w9WgXcQ?t=120
  final String youtubeUrl;

  /// 유튜브 비디오 ID (URL에서 추출)
  /// - 예: dQw4w9WgXcQ
  /// - Step 2에서 자동 추출 로직 구현 예정
  final String youtubeVideoId;

  /// 비디오 제목 (YouTube API에서 가져오거나 사용자 입력)
  final String title;

  /// 비디오 설명 (선택 사항)
  /// - YouTube API에서 가져온 영상 설명
  /// - null인 경우 설명 없음
  final String? description;

  /// 썸네일 URL (선택 사항)
  /// - 예: https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg
  /// - null인 경우 기본 썸네일 표시
  final String? thumbnailUrl;

  /// 채널명
  /// - YouTube API에서 가져온 채널 이름
  /// - 필수 값
  final String channelName;

  /// 영상 길이 (초 단위)
  /// - 예: 125초 = 2분 5초
  /// - 필수 값
  final int durationSeconds;

  /// 중단 시점 (초 단위)
  /// - 0: 처음부터 시청
  /// - 120: 2분 지점에서 중단
  final int timestampSeconds;

  /// 사용자 메모 (선택 사항)
  /// - 예: "리액트 훅 설명 부분", "레시피 재료 목록"
  final String? memo;

  /// 생성 일시
  final DateTime createdAt;

  /// 마지막 수정 일시
  final DateTime updatedAt;

  const Video({
    this.id,
    required this.categoryId,
    required this.youtubeUrl,
    required this.youtubeVideoId,
    required this.title,
    this.description,
    this.thumbnailUrl,
    required this.channelName,
    required this.durationSeconds,
    required this.timestampSeconds,
    this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// [formattedTimestamp] - 타임스탬프를 읽기 쉬운 형식으로 변환
  ///
  /// Returns:
  /// - 0초: "0:00"
  /// - 65초: "1:05"
  /// - 3665초: "1:01:05"
  String get formattedTimestamp {
    final hours = timestampSeconds ~/ 3600;
    final minutes = (timestampSeconds % 3600) ~/ 60;
    final seconds = timestampSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// [formattedDuration] - 영상 길이를 읽기 쉬운 형식으로 변환
  ///
  /// Returns:
  /// - 0초: "0:00"
  /// - 65초: "1:05"
  /// - 3665초: "1:01:05"
  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// [playbackUrl] - 타임스탬프 포함된 재생 URL 생성
  ///
  /// Returns: 타임스탬프 쿼리 파라미터가 추가된 URL
  /// - 예: https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=120s
  String get playbackUrl {
    if (timestampSeconds > 0) {
      return 'https://www.youtube.com/watch?v=$youtubeVideoId&t=${timestampSeconds}s';
    }
    return 'https://www.youtube.com/watch?v=$youtubeVideoId';
  }

  /// [defaultThumbnailUrl] - 썸네일 URL 또는 기본값 반환
  ///
  /// Returns:
  /// - thumbnailUrl이 있으면 그대로 반환
  /// - null이면 YouTube 기본 썸네일 URL 생성
  String get defaultThumbnailUrl {
    return thumbnailUrl ?? 'https://i.ytimg.com/vi/$youtubeVideoId/hqdefault.jpg';
  }

  /// [copyWith] - 일부 속성만 변경한 새 객체 생성
  ///
  /// Parameters: 변경하고 싶은 필드만 전달
  /// Returns: 변경된 새 Video 객체
  Video copyWith({
    int? id,
    int? categoryId,
    String? youtubeUrl,
    String? youtubeVideoId,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? channelName,
    int? durationSeconds,
    int? timestampSeconds,
    String? memo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Video(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      channelName: channelName ?? this.channelName,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      timestampSeconds: timestampSeconds ?? this.timestampSeconds,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// [props] - Equatable 동등성 비교에 사용할 속성 목록
  @override
  List<Object?> get props => [
        id,
        categoryId,
        youtubeUrl,
        youtubeVideoId,
        title,
        description,
        thumbnailUrl,
        channelName,
        durationSeconds,
        timestampSeconds,
        memo,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Video(id: $id, categoryId: $categoryId, title: $title, channelName: $channelName, youtubeVideoId: $youtubeVideoId, timestamp: $formattedTimestamp, duration: $formattedDuration)';
  }
}
