import '../../../../core/services/youtube_metadata_service.dart';

/// [SharedUrlResult] - 공유 URL 처리 결과
///
/// 공유받은 YouTube URL을 파싱하고 메타데이터를 가져온 후의 결과를 담는 엔티티
class SharedUrlResult {
  /// YouTube 영상 ID (예: "dQw4w9WgXcQ")
  final String videoId;

  /// 전체 YouTube URL (타임스탬프 포함 가능)
  final String url;

  /// 타임스탬프 (초 단위, 없으면 0)
  final int timestampSeconds;

  /// 영상 메타데이터 (제목, 채널, 썸네일 등)
  final YouTubeMetadata metadata;

  const SharedUrlResult({
    required this.videoId,
    required this.url,
    required this.timestampSeconds,
    required this.metadata,
  });
}
