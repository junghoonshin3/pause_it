import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart' as app_exceptions;
import '../../../../core/error/failures.dart';
import '../../../../core/services/youtube_metadata_service.dart';
import '../../../../core/usecases/usecase.dart';

/// [GetVideoMetadataParams] - GetVideoMetadata Use Case 파라미터
class GetVideoMetadataParams {
  /// YouTube video ID (11자리)
  final String videoId;

  const GetVideoMetadataParams({required this.videoId});
}

/// [GetVideoMetadata] - YouTube 영상 메타데이터 조회 Use Case
///
/// 주요 기능:
/// - YouTube API를 통한 영상 정보 가져오기
/// - 제목, 썸네일, 길이, 채널 정보 등 추출
/// - 네트워크 에러 핸들링
///
/// 사용 예시:
/// ```dart
/// final service = YouTubeMetadataService();
/// final useCase = GetVideoMetadata(service);
///
/// final params = GetVideoMetadataParams(videoId: 'dQw4w9WgXcQ');
/// final result = await useCase(params);
///
/// result.fold(
///   (failure) => print('오류: ${failure.message}'),
///   (metadata) => print('제목: ${metadata.title}'),
/// );
/// ```
class GetVideoMetadata extends UseCase<YouTubeMetadata, GetVideoMetadataParams> {
  final YouTubeMetadataService _metadataService;

  GetVideoMetadata(this._metadataService);

  @override
  Future<Either<Failure, YouTubeMetadata>> call(
    GetVideoMetadataParams params,
  ) async {
    try {
      // 1. 유효성 검사
      if (params.videoId.trim().isEmpty) {
        return const Left(
          ValidationFailure('YouTube video ID가 필요합니다.'),
        );
      }

      if (params.videoId.length != 11) {
        return Left(
          ValidationFailure(
            'YouTube video ID는 11자리여야 합니다.',
            {'videoId': '잘못된 길이: ${params.videoId.length}'},
          ),
        );
      }

      // 2. 메타데이터 가져오기
      final metadata = await _metadataService.getMetadata(params.videoId);

      return Right(metadata);
    } on app_exceptions.ValidationException catch (e) {
      // 유효성 검증 실패 (잘못된 video ID, 영상 없음 등)
      return Left(ValidationFailure(e.message, e.fieldErrors));
    } catch (e) {
      // 네트워크 오류 또는 기타 예외
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('연결')) {
        return Left(
          NetworkFailure('인터넷 연결을 확인해주세요.'),
        );
      }

      return Left(
        NetworkFailure('메타데이터를 가져오는 중 오류가 발생했습니다: $e'),
      );
    }
  }

  /// [dispose] - 리소스 해제
  ///
  /// YouTubeMetadataService의 dispose 호출
  /// Use Case 사용 완료 후 호출 권장
  void dispose() {
    _metadataService.dispose();
  }
}
