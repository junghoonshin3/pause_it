/// [YouTubeUrlParser] - YouTube URL 파싱 및 유효성 검사 서비스
///
/// 주요 기능:
/// - 다양한 형식의 YouTube URL에서 video ID 추출
/// - 타임스탬프 파라미터 추출 (t=, start=)
/// - URL 유효성 검사
///
/// 지원 URL 형식:
/// - https://www.youtube.com/watch?v=VIDEO_ID
/// - https://youtu.be/VIDEO_ID
/// - https://www.youtube.com/watch?v=VIDEO_ID&t=120s
/// - https://m.youtube.com/watch?v=VIDEO_ID
/// - https://www.youtube.com/embed/VIDEO_ID
/// - https://www.youtube.com/v/VIDEO_ID
class YouTubeUrlParser {
  /// YouTube URL 정규식 패턴
  static final RegExp _youtubeRegex = RegExp(
    r'^(?:https?:)?(?:\/\/)?(?:www\.)?(?:m\.)?'
    r'(?:youtube\.com|youtu\.be)'
    r'(?:\/(?:[\w\-]+\?v=|embed\/|v\/)?)'
    r'([\w\-]{11})'
    r'(?:\S+)?$',
    caseSensitive: false,
  );

  /// 타임스탬프 파라미터 패턴 (t=, start=)
  static final RegExp _timestampRegex = RegExp(
    r'[?&](?:t|start)=(\d+)',
    caseSensitive: false,
  );

  /// [parseVideoId] - YouTube URL에서 video ID 추출
  ///
  /// Parameters:
  /// - [url]: 파싱할 YouTube URL
  ///
  /// Returns:
  /// - video ID 문자열 (11자리)
  /// - null: 유효하지 않은 URL
  ///
  /// 사용 예시:
  /// ```dart
  /// final videoId = YouTubeUrlParser.parseVideoId('https://youtu.be/dQw4w9WgXcQ');
  /// print(videoId); // 'dQw4w9WgXcQ'
  /// ```
  static String? parseVideoId(String url) {
    if (url.trim().isEmpty) return null;

    final match = _youtubeRegex.firstMatch(url.trim());
    if (match == null || match.groupCount < 1) return null;

    final videoId = match.group(1);
    if (videoId == null || videoId.length != 11) return null;

    return videoId;
  }

  /// [parseTimestamp] - URL에서 타임스탬프 추출
  ///
  /// Parameters:
  /// - [url]: 파싱할 YouTube URL
  ///
  /// Returns:
  /// - 타임스탬프 (초 단위)
  /// - 0: 타임스탬프 파라미터 없음
  ///
  /// 사용 예시:
  /// ```dart
  /// final timestamp = YouTubeUrlParser.parseTimestamp('https://youtu.be/dQw4w9WgXcQ?t=120');
  /// print(timestamp); // 120
  /// ```
  static int parseTimestamp(String url) {
    if (url.trim().isEmpty) return 0;

    final match = _timestampRegex.firstMatch(url.trim());
    if (match == null || match.groupCount < 1) return 0;

    final timestampStr = match.group(1);
    if (timestampStr == null) return 0;

    return int.tryParse(timestampStr) ?? 0;
  }

  /// [isValidYouTubeUrl] - YouTube URL 유효성 검사
  ///
  /// Parameters:
  /// - [url]: 검사할 URL
  ///
  /// Returns:
  /// - true: 유효한 YouTube URL
  /// - false: 유효하지 않은 URL
  static bool isValidYouTubeUrl(String url) {
    return parseVideoId(url) != null;
  }

  /// [buildYouTubeUrl] - video ID와 타임스탬프로 YouTube URL 생성
  ///
  /// Parameters:
  /// - [videoId]: YouTube video ID (11자리)
  /// - [timestamp]: 시작 시점 (초 단위, 선택 사항)
  ///
  /// Returns: 표준 YouTube URL
  ///
  /// 사용 예시:
  /// ```dart
  /// final url = YouTubeUrlParser.buildYouTubeUrl('dQw4w9WgXcQ', timestamp: 120);
  /// print(url); // 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=120s'
  /// ```
  static String buildYouTubeUrl(String videoId, {int timestamp = 0}) {
    if (timestamp > 0) {
      return 'https://www.youtube.com/watch?v=$videoId&t=${timestamp}s';
    }
    return 'https://www.youtube.com/watch?v=$videoId';
  }

  /// [buildThumbnailUrl] - video ID로 썸네일 URL 생성
  ///
  /// Parameters:
  /// - [videoId]: YouTube video ID
  /// - [quality]: 썸네일 품질 (default, mqdefault, hqdefault, sddefault, maxresdefault)
  ///
  /// Returns: YouTube 썸네일 URL
  ///
  /// 품질별 해상도:
  /// - default: 120x90
  /// - mqdefault: 320x180
  /// - hqdefault: 480x360 (권장)
  /// - sddefault: 640x480
  /// - maxresdefault: 1280x720 (모든 영상에 없을 수 있음)
  static String buildThumbnailUrl(
    String videoId, {
    String quality = 'hqdefault',
  }) {
    return 'https://i.ytimg.com/vi/$videoId/$quality.jpg';
  }

  /// [normalizeUrl] - 다양한 형식의 YouTube URL을 표준 형식으로 변환
  ///
  /// Parameters:
  /// - [url]: 변환할 YouTube URL
  ///
  /// Returns:
  /// - 표준 형식 URL (https://www.youtube.com/watch?v=...)
  /// - null: 유효하지 않은 URL
  static String? normalizeUrl(String url) {
    final videoId = parseVideoId(url);
    if (videoId == null) return null;

    final timestamp = parseTimestamp(url);
    return buildYouTubeUrl(videoId, timestamp: timestamp);
  }
}
