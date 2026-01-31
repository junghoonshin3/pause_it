import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../error/exceptions.dart' as app_exceptions;

/// [YouTubeMetadata] - YouTube 영상 메타데이터
///
/// 주요 정보:
/// - 영상 제목, 설명
/// - 썸네일 URL
/// - 영상 길이
/// - 채널 정보
class YouTubeMetadata {
  /// 영상 ID (11자리)
  final String videoId;

  /// 영상 제목
  final String title;

  /// 영상 설명 (전체)
  final String description;

  /// 썸네일 URL (고품질)
  final String thumbnailUrl;

  /// 영상 길이 (초 단위)
  final int durationSeconds;

  /// 채널 이름
  final String channelName;

  /// 조회수
  final int viewCount;

  /// 업로드 일시
  final DateTime? uploadDate;

  const YouTubeMetadata({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.channelName,
    required this.viewCount,
    this.uploadDate,
  });

  /// [formattedDuration] - 영상 길이를 읽기 쉬운 형식으로 변환
  ///
  /// Returns:
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

  @override
  String toString() {
    return 'YouTubeMetadata(videoId: $videoId, title: $title, duration: $formattedDuration, channel: $channelName)';
  }
}

/// [YouTubeMetadataService] - YouTube 영상 메타데이터 추출 서비스
///
/// 주요 기능:
/// - youtube_explode_dart를 사용한 영상 정보 가져오기
/// - 네트워크 에러 핸들링
/// - 리소스 관리 (YoutubeExplode 인스턴스)
///
/// 사용 예시:
/// ```dart
/// final service = YouTubeMetadataService();
/// try {
///   final metadata = await service.getMetadata('dQw4w9WgXcQ');
///   print(metadata.title);
/// } finally {
///   service.dispose();
/// }
/// ```
class YouTubeMetadataService {
  final YoutubeExplode _youtubeExplode;

  YouTubeMetadataService({YoutubeExplode? youtubeExplode})
      : _youtubeExplode = youtubeExplode ?? YoutubeExplode();

  /// [getMetadata] - YouTube 영상 메타데이터 가져오기
  ///
  /// Parameters:
  /// - [videoId]: YouTube video ID (11자리)
  ///
  /// Returns: YouTubeMetadata 객체
  /// Throws:
  /// - ValidationException: 잘못된 video ID
  /// - NetworkFailure: 네트워크 오류 또는 영상을 찾을 수 없음
  ///
  /// 사용 예시:
  /// ```dart
  /// final metadata = await service.getMetadata('dQw4w9WgXcQ');
  /// print('제목: ${metadata.title}');
  /// print('길이: ${metadata.formattedDuration}');
  /// ```
  Future<YouTubeMetadata> getMetadata(String videoId) async {
    try {
      // 유효성 검증
      if (videoId.trim().isEmpty || videoId.length != 11) {
        throw app_exceptions.ValidationException(
          'YouTube video ID는 11자리여야 합니다.',
          {'videoId': '잘못된 형식: $videoId'},
        );
      }

      // 영상 정보 가져오기
      final video = await _youtubeExplode.videos.get(videoId);

      // 썸네일 URL 추출 (가장 높은 품질)
      final thumbnailUrl = video.thumbnails.highResUrl;

      // 메타데이터 생성
      return YouTubeMetadata(
        videoId: videoId,
        title: video.title,
        description: video.description,
        thumbnailUrl: thumbnailUrl,
        durationSeconds: video.duration?.inSeconds ?? 0,
        channelName: video.author,
        viewCount: video.engagement.viewCount,
        uploadDate: video.uploadDate,
      );
    } on VideoUnplayableException catch (e) {
      // 영상을 재생할 수 없음 (비공개, 삭제됨, 지역 제한 등)
      throw app_exceptions.ValidationException(
        '영상을 찾을 수 없거나 재생할 수 없습니다: $e',
        {'videoId': videoId},
      );
    } catch (e) {
      // 네트워크 오류 또는 기타 예외
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('HTTP')) {
        throw app_exceptions.ValidationException(
          '네트워크 오류: 인터넷 연결을 확인해주세요.',
          {'videoId': videoId, 'error': e.toString()},
        );
      }

      // 알 수 없는 오류
      throw app_exceptions.ValidationException(
        'YouTube 메타데이터 가져오기 실패: $e',
        {'videoId': videoId},
      );
    }
  }

  /// [getMetadataByUrl] - YouTube URL로 메타데이터 가져오기
  ///
  /// Parameters:
  /// - [url]: YouTube URL
  ///
  /// Returns: YouTubeMetadata 객체
  /// Throws: ValidationException, NetworkFailure
  ///
  /// 내부적으로 YouTubeUrlParser를 사용하여 video ID 추출 후
  /// getMetadata() 호출
  Future<YouTubeMetadata> getMetadataByUrl(String url) async {
    // URL에서 video ID 추출은 Use Case에서 처리하도록 분리
    // 여기서는 직접 youtube_explode_dart의 URL 파싱 사용
    try {
      final videoId = VideoId(url);
      return await getMetadata(videoId.value);
    } catch (e) {
      throw app_exceptions.ValidationException(
        '유효하지 않은 YouTube URL입니다.',
        {'url': url, 'error': e.toString()},
      );
    }
  }

  /// [dispose] - 리소스 해제
  ///
  /// YoutubeExplode 인스턴스의 HTTP 클라이언트 종료
  /// 서비스 사용 완료 후 반드시 호출 권장
  void dispose() {
    _youtubeExplode.close();
  }
}
