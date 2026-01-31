import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/youtube_url_parser.dart';
import '../../../../core/usecases/usecase.dart';

/// [ParsedYouTubeUrl] - 파싱된 YouTube URL 데이터
///
/// 주요 정보:
/// - 원본 URL
/// - 추출된 video ID
/// - 타임스탬프
/// - 정규화된 URL
class ParsedYouTubeUrl {
  /// 원본 URL
  final String originalUrl;

  /// 추출된 YouTube video ID (11자리)
  final String videoId;

  /// 타임스탬프 (초 단위, 0이면 처음부터)
  final int timestampSeconds;

  /// 정규화된 표준 YouTube URL
  final String normalizedUrl;

  /// 썸네일 URL (고품질)
  final String thumbnailUrl;

  const ParsedYouTubeUrl({
    required this.originalUrl,
    required this.videoId,
    required this.timestampSeconds,
    required this.normalizedUrl,
    required this.thumbnailUrl,
  });

  @override
  String toString() {
    return 'ParsedYouTubeUrl(videoId: $videoId, timestamp: $timestampSeconds, url: $normalizedUrl)';
  }
}

/// [ParseYouTubeUrl] - YouTube URL 파싱 Use Case
///
/// 주요 기능:
/// - YouTube URL 유효성 검사
/// - video ID 추출
/// - 타임스탬프 추출
/// - URL 정규화
///
/// 사용 예시:
/// ```dart
/// final useCase = ParseYouTubeUrl();
/// final result = await useCase('https://youtu.be/dQw4w9WgXcQ?t=120');
/// result.fold(
///   (failure) => print('오류: ${failure.message}'),
///   (parsed) => print('Video ID: ${parsed.videoId}'),
/// );
/// ```
class ParseYouTubeUrl extends UseCase<ParsedYouTubeUrl, String> {
  @override
  Future<Either<Failure, ParsedYouTubeUrl>> call(String url) async {
    try {
      // 1. URL 유효성 검사
      if (url.trim().isEmpty) {
        return const Left(
          ValidationFailure('YouTube URL을 입력해주세요.'),
        );
      }

      // 2. video ID 추출
      final videoId = YouTubeUrlParser.parseVideoId(url);
      if (videoId == null) {
        return Left(
          ValidationFailure(
            '유효하지 않은 YouTube URL입니다.',
            {'url': '형식이 올바르지 않습니다: $url'},
          ),
        );
      }

      // 3. 타임스탬프 추출
      final timestamp = YouTubeUrlParser.parseTimestamp(url);

      // 4. URL 정규화
      final normalizedUrl = YouTubeUrlParser.buildYouTubeUrl(
        videoId,
        timestamp: timestamp,
      );

      // 5. 썸네일 URL 생성
      final thumbnailUrl = YouTubeUrlParser.buildThumbnailUrl(videoId);

      // 6. 파싱 결과 생성
      final parsed = ParsedYouTubeUrl(
        originalUrl: url,
        videoId: videoId,
        timestampSeconds: timestamp,
        normalizedUrl: normalizedUrl,
        thumbnailUrl: thumbnailUrl,
      );

      return Right(parsed);
    } catch (e) {
      return Left(
        ValidationFailure('URL 파싱 중 오류 발생: $e'),
      );
    }
  }
}
