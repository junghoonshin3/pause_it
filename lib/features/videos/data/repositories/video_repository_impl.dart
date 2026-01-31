import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/video_local_datasource.dart';
import '../models/video_model.dart';

/// [VideoRepositoryImpl] - VideoRepository의 구현체
///
/// 주요 기능:
/// - DataSource의 Exception을 Domain Layer의 Failure로 변환
/// - Either<Failure, T> 패턴으로 에러 핸들링
/// - Entity <-> Model 변환
///
/// 사용 예시:
/// ```dart
/// final repository = VideoRepositoryImpl(datasource);
/// final result = await repository.getVideosByCategory(1);
/// result.fold(
///   (failure) => print('에러: ${failure.message}'),
///   (videos) => print('성공: ${videos.length}개'),
/// );
/// ```
class VideoRepositoryImpl implements VideoRepository {
  final VideoLocalDataSource _localDataSource;

  VideoRepositoryImpl({
    required VideoLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<Video>>> getAllVideos() async {
    try {
      final videoModels = await _localDataSource.getAllVideos();
      // Model -> Entity 변환
      final videos = videoModels.map((model) => model.toEntity()).toList();
      return Right(videos);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('알 수 없는 오류 발생: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByCategory(int categoryId) async {
    try {
      final videoModels = await _localDataSource.getVideosByCategory(categoryId);
      final videos = videoModels.map((model) => model.toEntity()).toList();
      return Right(videos);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('알 수 없는 오류 발생: $e'));
    }
  }

  @override
  Future<Either<Failure, Video>> getVideoById(int id) async {
    try {
      final videoModel = await _localDataSource.getVideoById(id);
      return Right(videoModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('알 수 없는 오류 발생: $e'));
    }
  }

  @override
  Future<Either<Failure, Video>> createVideo(Video video) async {
    try {
      // Entity -> Model 변환
      final videoModel = VideoModel.fromEntity(video);

      // 생성 실행
      final createdModel = await _localDataSource.insertVideo(videoModel);

      return Right(createdModel.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('알 수 없는 오류 발생: $e'));
    }
  }

  @override
  Future<Either<Failure, Video>> updateVideo(Video video) async {
    try {
      // Entity -> Model 변환
      final videoModel = VideoModel.fromEntity(video);

      // 수정 실행
      final updatedModel = await _localDataSource.updateVideo(videoModel);

      return Right(updatedModel.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('알 수 없는 오류 발생: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVideo(int id) async {
    try {
      await _localDataSource.deleteVideo(id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('알 수 없는 오류 발생: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getVideoCountByCategory(int categoryId) async {
    try {
      final count = await _localDataSource.getVideoCountByCategory(categoryId);
      return Right(count);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('알 수 없는 오류 발생: $e'));
    }
  }

  @override
  Future<Either<Failure, Video>> updateVideoTimestamp(
    int videoId,
    int timestampSeconds,
  ) async {
    try {
      final videoModel = await _localDataSource.getVideoById(videoId);
      final updatedModel = videoModel.copyWith(
        timestampSeconds: timestampSeconds,
        updatedAt: DateTime.now(),
      );
      final result = await _localDataSource.updateVideo(updatedModel);
      return Right(result.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('타임스탬프 업데이트 실패: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> searchVideos(String query) async {
    try {
      final videoModels = await _localDataSource.searchVideos(query);
      final videos = videoModels.map((model) => model.toEntity()).toList();
      return Right(videos);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('알 수 없는 오류 발생: $e'));
    }
  }
}
