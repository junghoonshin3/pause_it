import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/shared_url_result.dart';
import 'parse_youtube_url.dart';
import 'get_video_metadata.dart';

/// [HandleSharedUrl] - 공유된 URL 처리 Use Case
///
/// 공유받은 텍스트(URL)를 파싱하고 메타데이터를 가져와서
/// [SharedUrlResult]로 변환하는 비즈니스 로직
///
/// 처리 흐름:
/// 1. URL 파싱 (videoId, timestamp 추출)
/// 2. YouTube API로 메타데이터 가져오기
/// 3. 결과 통합하여 반환
class HandleSharedUrl extends UseCase<SharedUrlResult, String> {
  final ParseYouTubeUrl _parseYoutubeUrl;
  final GetVideoMetadata _getVideoMetadata;

  HandleSharedUrl(this._parseYoutubeUrl, this._getVideoMetadata);

  @override
  Future<Either<Failure, SharedUrlResult>> call(String sharedUrl) async {
    // 1. URL 파싱
    final parseResult = await _parseYoutubeUrl(sharedUrl);

    // URL 파싱 실패 시 에러 반환
    if (parseResult.isLeft()) {
      return Left(parseResult.fold((l) => l, (r) => const ValidationFailure('Unknown error')));
    }

    final parsedUrl = parseResult.fold(
      (l) => throw Exception('Parse failed'),
      (r) => r,
    );

    // 2. 메타데이터 가져오기
    final metadataResult = await _getVideoMetadata(
      GetVideoMetadataParams(videoId: parsedUrl.videoId),
    );

    return metadataResult.fold(
      (failure) => Left(failure),
      (metadata) => Right(SharedUrlResult(
        videoId: parsedUrl.videoId,
        url: sharedUrl,
        timestampSeconds: parsedUrl.timestampSeconds ?? 0,
        metadata: metadata,
      )),
    );
  }
}
