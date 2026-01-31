import '../../domain/entities/video.dart';

/// [VideoModel] - Video 엔티티의 Data Layer 모델
///
/// 주요 기능:
/// - SQLite Map <-> Video Entity 변환
/// - JSON 직렬화/역직렬화 (향후 API 연동 시 사용)
/// - Domain Layer와 Data Layer 간 데이터 변환 담당
///
/// 사용 예시:
/// ```dart
/// // DB에서 읽기
/// final map = await db.query('videos', where: 'id = ?', whereArgs: [1]);
/// final video = VideoModel.fromMap(map.first);
///
/// // DB에 쓰기
/// final model = VideoModel.fromEntity(video);
/// await db.insert('videos', model.toMap());
/// ```
class VideoModel extends Video {
  const VideoModel({
    super.id,
    required super.categoryId,
    required super.youtubeUrl,
    required super.youtubeVideoId,
    required super.title,
    super.description,
    super.thumbnailUrl,
    required super.channelName,
    required super.durationSeconds,
    required super.timestampSeconds,
    super.memo,
    required super.createdAt,
    required super.updatedAt,
  });

  /// [fromEntity] - Domain Entity를 Model로 변환
  ///
  /// Parameters:
  /// - [video]: 변환할 Video 엔티티
  ///
  /// Returns: VideoModel 객체
  factory VideoModel.fromEntity(Video video) {
    return VideoModel(
      id: video.id,
      categoryId: video.categoryId,
      youtubeUrl: video.youtubeUrl,
      youtubeVideoId: video.youtubeVideoId,
      title: video.title,
      description: video.description,
      thumbnailUrl: video.thumbnailUrl,
      channelName: video.channelName,
      durationSeconds: video.durationSeconds,
      timestampSeconds: video.timestampSeconds,
      memo: video.memo,
      createdAt: video.createdAt,
      updatedAt: video.updatedAt,
    );
  }

  /// [fromMap] - SQLite Map을 VideoModel로 변환
  ///
  /// Parameters:
  /// - [map]: SQLite 쿼리 결과 맵
  ///
  /// Returns: VideoModel 객체
  ///
  /// Map 구조:
  /// ```dart
  /// {
  ///   'id': 1,
  ///   'category_id': 1,
  ///   'youtube_url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  ///   'youtube_video_id': 'dQw4w9WgXcQ',
  ///   'title': 'Never Gonna Give You Up',
  ///   'description': 'Official music video',
  ///   'thumbnail_url': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
  ///   'channel_name': 'Rick Astley',
  ///   'duration_seconds': 212,
  ///   'timestamp_seconds': 120,
  ///   'memo': 'chorus part',
  ///   'created_at': 1704067200000,
  ///   'updated_at': 1704067200000,
  /// }
  /// ```
  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      youtubeUrl: map['youtube_url'] as String,
      youtubeVideoId: map['youtube_video_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      thumbnailUrl: map['thumbnail_url'] as String?,
      channelName: map['channel_name'] as String,
      durationSeconds: map['duration_seconds'] as int,
      timestampSeconds: map['timestamp_seconds'] as int,
      memo: map['memo'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// [toMap] - VideoModel을 SQLite Map으로 변환
  ///
  /// Returns: SQLite INSERT/UPDATE용 맵
  ///
  /// 주의사항:
  /// - id가 null인 경우 맵에 포함하지 않음 (Auto Increment)
  /// - DateTime은 millisecondsSinceEpoch로 변환 (Unix timestamp)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'category_id': categoryId,
      'youtube_url': youtubeUrl,
      'youtube_video_id': youtubeVideoId,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'channel_name': channelName,
      'duration_seconds': durationSeconds,
      'timestamp_seconds': timestampSeconds,
      'memo': memo,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };

    // id가 있는 경우에만 추가 (UPDATE 시)
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  /// [toEntity] - Model을 Domain Entity로 변환
  ///
  /// Returns: Video 엔티티
  ///
  /// 사용 시기:
  /// - Data Layer에서 조회한 데이터를 Domain Layer로 전달 시
  Video toEntity() {
    return Video(
      id: id,
      categoryId: categoryId,
      youtubeUrl: youtubeUrl,
      youtubeVideoId: youtubeVideoId,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      channelName: channelName,
      durationSeconds: durationSeconds,
      timestampSeconds: timestampSeconds,
      memo: memo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// [copyWith] - 일부 속성만 변경한 새 모델 생성
  @override
  VideoModel copyWith({
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
    return VideoModel(
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

  @override
  String toString() {
    return 'VideoModel(id: $id, categoryId: $categoryId, title: $title, channelName: $channelName, youtubeVideoId: $youtubeVideoId, timestamp: $formattedTimestamp, duration: $formattedDuration)';
  }
}
