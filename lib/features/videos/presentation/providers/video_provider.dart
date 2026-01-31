import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/video_local_datasource.dart';
import '../../data/repositories/video_repository_impl.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/video_repository.dart';
import '../../domain/usecases/get_video_metadata.dart';
import '../../domain/usecases/parse_youtube_url.dart';
import '../../domain/usecases/handle_shared_url.dart';
import '../../domain/entities/shared_url_result.dart';
import '../../../../core/services/youtube_metadata_service.dart';
import '../../../../core/services/share_intent_service.dart';

/// [videoLocalDataSourceProvider] - 영상 로컬 데이터소스 Provider
final videoLocalDataSourceProvider = Provider<VideoLocalDataSource>((ref) {
  return VideoLocalDataSource();
});

/// [videoRepositoryProvider] - 영상 저장소 Provider
final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  final dataSource = ref.watch(videoLocalDataSourceProvider);
  return VideoRepositoryImpl(localDataSource: dataSource);
});

/// [youtubeMetadataServiceProvider] - YouTube 메타데이터 서비스 Provider
final youtubeMetadataServiceProvider = Provider<YouTubeMetadataService>((ref) {
  return YouTubeMetadataService();
});

/// [parseYoutubeUrlProvider] - YouTube URL 파싱 Use Case Provider
final parseYoutubeUrlProvider = Provider<ParseYouTubeUrl>((ref) {
  return ParseYouTubeUrl();
});

/// [getVideoMetadataProvider] - 영상 메타데이터 가져오기 Use Case Provider
final getVideoMetadataProvider = Provider<GetVideoMetadata>((ref) {
  final service = ref.watch(youtubeMetadataServiceProvider);
  return GetVideoMetadata(service);
});

/// [videoListProvider] - 특정 카테고리의 영상 목록 Provider
///
/// Parameters:
/// - categoryId: 조회할 카테고리 ID
///
/// 사용 예시:
/// ```dart
/// final videos = ref.watch(videoListProvider(categoryId));
/// ```
final videoListProvider = StateNotifierProvider.family<
    VideoListNotifier,
    AsyncValue<List<Video>>,
    int>(
  (ref, categoryId) {
    final repository = ref.watch(videoRepositoryProvider);
    return VideoListNotifier(repository, categoryId);
  },
);

/// [VideoListNotifier] - 영상 목록 상태 관리 클래스
///
/// 특정 카테고리의 영상 목록을 관리
class VideoListNotifier extends StateNotifier<AsyncValue<List<Video>>> {
  final VideoRepository _repository;
  final int _categoryId;

  VideoListNotifier(this._repository, this._categoryId)
      : super(const AsyncValue.loading()) {
    loadVideos();
  }

  /// [loadVideos] - 카테고리별 영상 목록 불러오기
  Future<void> loadVideos() async {
    state = const AsyncValue.loading();

    final result = await _repository.getVideosByCategory(_categoryId);

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (videos) {
        state = AsyncValue.data(videos);
      },
    );
  }

  /// [addVideo] - 영상 추가
  ///
  /// Parameters:
  /// - [video]: 추가할 영상 (categoryId는 이미 설정되어 있어야 함)
  ///
  /// Returns: 추가된 영상 (ID 포함), 실패 시 null
  Future<Video?> addVideo(Video video) async {
    try {
      final result = await _repository.createVideo(video);

      return result.fold(
        (failure) {
          // 에러 로그 출력 (디버깅용)
          print('❌ 영상 추가 실패: ${failure.message}');
          return null;
        },
        (insertedVideo) {
          print('✅ 영상 추가 성공: ${insertedVideo.title} (ID: ${insertedVideo.id})');
          loadVideos();
          return insertedVideo;
        },
      );
    } catch (e) {
      print('❌ 영상 추가 중 예외 발생: $e');
      return null;
    }
  }

  /// [updateVideo] - 영상 정보 수정
  Future<bool> updateVideo(Video video) async {
    try {
      // updatedAt 업데이트
      final updatedVideo = Video(
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
        updatedAt: DateTime.now(),
      );

      final result = await _repository.updateVideo(updatedVideo);

      return result.fold(
        (failure) => false,
        (updatedVideo) {
          loadVideos();
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  /// [deleteVideo] - 영상 삭제
  Future<bool> deleteVideo(int videoId) async {
    try {
      final result = await _repository.deleteVideo(videoId);

      return result.fold(
        (failure) => false,
        (_) {
          loadVideos();
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  /// [updateTimestamp] - 영상 타임스탬프만 업데이트
  ///
  /// 빠른 타임스탬프 변경을 위한 헬퍼 메서드
  Future<bool> updateTimestamp(int videoId, int timestampSeconds) async {
    try {
      final result =
          await _repository.updateVideoTimestamp(videoId, timestampSeconds);

      return result.fold(
        (failure) => false,
        (updatedVideo) {
          loadVideos();
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }
}

// ===== Share Intent 관련 Providers =====

/// [shareIntentServiceProvider] - Share Intent 서비스 Provider
final shareIntentServiceProvider = Provider<ShareIntentService>((ref) {
  return ShareIntentService();
});

/// [handleSharedUrlProvider] - 공유 URL 처리 Use Case Provider
final handleSharedUrlProvider = Provider<HandleSharedUrl>((ref) {
  final parseUrl = ref.watch(parseYoutubeUrlProvider);
  final getMetadata = ref.watch(getVideoMetadataProvider);
  return HandleSharedUrl(parseUrl, getMetadata);
});

/// [sharedUrlStateProvider] - 공유 URL 상태 Provider
/// null: 공유 없음, SharedUrlResult: 처리 대기 중
final sharedUrlStateProvider = StateProvider<SharedUrlResult?>((ref) => null);

/// [videoCountProvider] - 카테고리별 영상 개수 Provider
///
/// 특정 카테고리의 영상 개수를 조회하는 FutureProvider
///
/// Parameters:
/// - categoryId: 영상 개수를 조회할 카테고리 ID
///
/// Returns: 해당 카테고리의 영상 개수 (에러 시 0 반환)
///
/// 사용 예시:
/// ```dart
/// final count = ref.watch(videoCountProvider(categoryId));
/// count.when(
///   data: (count) => Text('영상 $count개'),
///   loading: () => Text('로딩 중...'),
///   error: (_, __) => Text('영상 0개'),
/// );
/// ```
final videoCountProvider = FutureProvider.family<int, int>((ref, categoryId) async {
  final repository = ref.watch(videoRepositoryProvider);
  final result = await repository.getVideoCountByCategory(categoryId);

  return result.fold(
    (failure) {
      // 에러 발생 시 0 반환
      print('❌ 영상 개수 조회 실패: ${failure.message}');
      return 0;
    },
    (count) => count,
  );
});
