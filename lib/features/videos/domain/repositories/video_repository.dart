import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/video.dart';

/// [VideoRepository] - 비디오 타임스탬프 저장소 추상 인터페이스
///
/// 주요 특징:
/// - Domain Layer와 Data Layer 간 경계 정의
/// - Either<Failure, T> 패턴으로 에러 핸들링
/// - 구현체는 Data Layer에서 제공
///
/// 구현체: lib/features/videos/data/repositories/video_repository_impl.dart
abstract class VideoRepository {
  /// [getAllVideos] - 모든 비디오 조회
  ///
  /// Returns:
  /// - Left(Failure): 조회 실패
  /// - Right(List<Video>): 성공 (빈 리스트 가능)
  ///
  /// 정렬: 생성일시 내림차순 (최근 추가 순)
  Future<Either<Failure, List<Video>>> getAllVideos();

  /// [getVideosByCategory] - 특정 카테고리의 비디오 목록 조회
  ///
  /// Parameters:
  /// - [categoryId]: 조회할 카테고리 ID
  ///
  /// Returns:
  /// - Left(Failure): 조회 실패
  /// - Right(List<Video>): 해당 카테고리의 비디오 목록
  ///
  /// 정렬: 생성일시 내림차순
  Future<Either<Failure, List<Video>>> getVideosByCategory(int categoryId);

  /// [getVideoById] - ID로 특정 비디오 조회
  ///
  /// Parameters:
  /// - [id]: 조회할 비디오 ID
  ///
  /// Returns:
  /// - Left(CacheFailure): ID에 해당하는 비디오 없음
  /// - Left(DatabaseFailure): DB 오류
  /// - Right(Video): 조회 성공
  Future<Either<Failure, Video>> getVideoById(int id);

  /// [createVideo] - 새 비디오 타임스탬프 생성
  ///
  /// Parameters:
  /// - [video]: 생성할 비디오 (id는 무시되고 자동 생성됨)
  ///
  /// Returns:
  /// - Left(ValidationFailure): 필수 필드 누락 또는 유효하지 않은 값
  /// - Left(DatabaseFailure): 생성 실패 (Foreign Key 위반 등)
  /// - Right(Video): 생성된 비디오 (id 포함)
  ///
  /// 검증 사항:
  /// - categoryId가 실제 존재하는지 확인
  /// - youtubeVideoId 형식 검증 (Step 2)
  Future<Either<Failure, Video>> createVideo(Video video);

  /// [updateVideo] - 기존 비디오 수정
  ///
  /// Parameters:
  /// - [video]: 수정할 비디오 (id 필수)
  ///
  /// Returns:
  /// - Left(ValidationFailure): id가 null이거나 필수 필드 누락
  /// - Left(CacheFailure): 해당 ID의 비디오 없음
  /// - Left(DatabaseFailure): 수정 실패
  /// - Right(Video): 수정된 비디오
  ///
  /// 동작:
  /// - updatedAt은 자동으로 현재 시각으로 갱신
  Future<Either<Failure, Video>> updateVideo(Video video);

  /// [deleteVideo] - 비디오 삭제
  ///
  /// Parameters:
  /// - [id]: 삭제할 비디오 ID
  ///
  /// Returns:
  /// - Left(CacheFailure): 해당 ID의 비디오 없음
  /// - Left(DatabaseFailure): 삭제 실패
  /// - Right(Unit): 삭제 성공
  Future<Either<Failure, Unit>> deleteVideo(int id);

  /// [getVideoCountByCategory] - 특정 카테고리의 비디오 개수 조회
  ///
  /// Parameters:
  /// - [categoryId]: 카테고리 ID
  ///
  /// Returns:
  /// - Left(DatabaseFailure): 조회 실패
  /// - Right(int): 비디오 개수
  ///
  /// 사용 예시: 카테고리 목록에서 각 카테고리의 비디오 개수 표시
  Future<Either<Failure, int>> getVideoCountByCategory(int categoryId);

  /// [updateVideoTimestamp] - 비디오 타임스탬프만 빠르게 업데이트
  ///
  /// Parameters:
  /// - [videoId]: 수정할 비디오 ID
  /// - [timestampSeconds]: 새로운 타임스탬프 (초 단위)
  ///
  /// Returns:
  /// - Left(CacheFailure): 해당 ID의 비디오 없음
  /// - Left(DatabaseFailure): 수정 실패
  /// - Right(Video): 수정된 비디오
  ///
  /// 동작:
  /// - timestampSeconds와 updatedAt만 갱신
  /// - 전체 updateVideo()보다 경량화된 버전
  Future<Either<Failure, Video>> updateVideoTimestamp(
    int videoId,
    int timestampSeconds,
  );

  /// [searchVideos] - 제목/메모로 비디오 검색 (Step 3 이후 구현 예정)
  ///
  /// Parameters:
  /// - [query]: 검색어
  ///
  /// Returns:
  /// - Left(Failure): 검색 실패
  /// - Right(List<Video>): 검색 결과 (빈 리스트 가능)
  ///
  /// 검색 대상: title, memo 필드 (LIKE 쿼리)
  Future<Either<Failure, List<Video>>> searchVideos(String query);
}
