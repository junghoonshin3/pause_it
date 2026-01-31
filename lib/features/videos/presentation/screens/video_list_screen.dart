import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../categories/domain/entities/category.dart';
import '../../domain/entities/video.dart';
import '../providers/video_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/video_card.dart';
import '../widgets/add_video_dialog.dart';
import '../widgets/edit_video_dialog.dart';

/// [VideoListScreen] - 카테고리별 영상 목록 화면
///
/// 주요 기능:
/// - 특정 카테고리의 영상 목록 표시
/// - 영상 추가 FAB
/// - 영상 재생 (YouTube 앱/웹 열기)
/// - 영상 편집/삭제
/// - 타임스탬프 업데이트
///
/// Parameters:
/// - [category]: 표시할 카테고리
class VideoListScreen extends ConsumerWidget {
  final Category category;

  const VideoListScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 영상 목록 상태 구독
    final videosAsync = ref.watch(videoListProvider(category.id!));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.folder,
                size: 20,
                color: _getContrastColor(category.color),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 새로고침 버튼
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: () {
              ref.read(videoListProvider(category.id!).notifier).loadVideos();
            },
          ),
        ],
      ),
      body: videosAsync.when(
        // 로딩 상태
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        // 에러 상태
        error: (error, stackTrace) => _buildErrorView(context, error.toString()),

        // 데이터 로드 완료
        data: (videos) {
          if (videos.isEmpty) {
            return _buildEmptyView(context, ref);
          }
          return _buildVideoList(context, ref, videos);
        },
      ),

      // Floating Action Button - 영상 추가
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVideoDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('영상 추가'),
      ),
    );
  }

  /// [_buildVideoList] - 영상 목록 생성
  Widget _buildVideoList(
    BuildContext context,
    WidgetRef ref,
    List<Video> videos,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: VideoCard(
            video: video,
            onTap: () => _playVideo(context, video),
            onEdit: () => _showEditVideoDialog(context, ref, video),
            onDelete: () => _deleteVideo(context, ref, video),
            onUpdateTimestamp: (seconds) =>
                _updateTimestamp(context, ref, video.id!, seconds),
          ),
        );
      },
    );
  }

  /// [_buildEmptyView] - 빈 화면 상태 (영상이 없을 때)
  Widget _buildEmptyView(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 100,
              color: category.color.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '영상이 없습니다',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '아래 버튼을 눌러 YouTube 영상을 추가해보세요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showAddVideoDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('영상 추가'),
              style: FilledButton.styleFrom(
                backgroundColor: category.color,
                foregroundColor: _getContrastColor(category.color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [_buildErrorView] - 에러 화면
  Widget _buildErrorView(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// [_showAddVideoDialog] - 영상 추가 다이얼로그 표시
  void _showAddVideoDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddVideoDialog(
        categoryId: category.id!,
        onVideoAdded: (video) async {
          // 영상 추가 (저장된 영상 객체 반환 - ID 포함)
          final savedVideo = await ref
              .read(videoListProvider(category.id!).notifier)
              .addVideo(video);

          if (!context.mounted) return;

          // 결과 메시지 표시
          if (savedVideo != null && savedVideo.id != null) {
            // 알림 스케줄 (10분 후) - 저장된 영상의 ID 사용
            final notificationService = ref.read(notificationServiceProvider);
            await notificationService.scheduleVideoReminder(
              videoId: savedVideo.id!,
              videoTitle: savedVideo.title,
              youtubeVideoId: savedVideo.youtubeVideoId,
              timestampSeconds: savedVideo.timestampSeconds,
            );

            _showSuccessSnackbar(context, '영상이 추가되었습니다 (10분 후 알림 예정)');
          } else {
            _showErrorSnackbar(context, '영상 추가에 실패했습니다');
          }
        },
      ),
    );
  }

  /// [_showEditVideoDialog] - 영상 편집 다이얼로그 표시
  ///
  /// 영상의 타임스탬프, 메모 수정 및 카테고리 이동 기능 제공
  void _showEditVideoDialog(
    BuildContext context,
    WidgetRef ref,
    Video video,
  ) {
    showDialog(
      context: context,
      builder: (context) => EditVideoDialog(
        video: video,
        currentCategoryId: category.id!,
        onSave: (updatedVideo) async {
          // 카테고리가 변경된 경우
          if (updatedVideo.categoryId != category.id) {
            // 영상 정보 수정 (새 카테고리 ID 포함)
            final success = await ref
                .read(videoListProvider(category.id!).notifier)
                .updateVideo(updatedVideo);

            if (!context.mounted) return;

            if (success) {
              // 현재 목록에서 영상 제거 (다른 카테고리로 이동됨)
              ref.read(videoListProvider(category.id!).notifier).loadVideos();
              _showSuccessSnackbar(context, '영상이 다른 카테고리로 이동되었습니다');
            } else {
              _showErrorSnackbar(context, '영상 이동에 실패했습니다');
            }
          } else {
            // 카테고리 변경 없이 정보만 수정
            final success = await ref
                .read(videoListProvider(category.id!).notifier)
                .updateVideo(updatedVideo);

            if (!context.mounted) return;

            if (success) {
              _showSuccessSnackbar(context, '영상이 수정되었습니다');
            } else {
              _showErrorSnackbar(context, '영상 수정에 실패했습니다');
            }
          }
        },
      ),
    );
  }

  /// [_deleteVideo] - 영상 삭제
  Future<void> _deleteVideo(
    BuildContext context,
    WidgetRef ref,
    Video video,
  ) async {
    // 알림 취소
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.cancelNotification(video.id!);

    // 영상 삭제
    final success = await ref
        .read(videoListProvider(category.id!).notifier)
        .deleteVideo(video.id!);

    if (!context.mounted) return;

    if (success) {
      _showSuccessSnackbar(context, '영상이 삭제되었습니다');
    } else {
      _showErrorSnackbar(context, '영상 삭제에 실패했습니다');
    }
  }

  /// [_updateTimestamp] - 타임스탬프 업데이트
  Future<void> _updateTimestamp(
    BuildContext context,
    WidgetRef ref,
    int videoId,
    int timestampSeconds,
  ) async {
    final success = await ref
        .read(videoListProvider(category.id!).notifier)
        .updateTimestamp(videoId, timestampSeconds);

    if (!context.mounted) return;

    if (success) {
      _showSuccessSnackbar(context, '타임스탬프가 업데이트되었습니다');
    } else {
      _showErrorSnackbar(context, '타임스탬프 업데이트에 실패했습니다');
    }
  }

  /// [_playVideo] - YouTube 영상 재생
  ///
  /// 저장된 타임스탬프 위치에서 영상 재생
  /// url_launcher를 사용하여 YouTube 앱 또는 웹 브라우저 열기
  Future<void> _playVideo(BuildContext context, Video video) async {
    try {
      // YouTube URL 생성 (타임스탬프 포함)
      final url = Uri.parse(
        'https://www.youtube.com/watch?v=${video.youtubeVideoId}&t=${video.timestampSeconds}s',
      );

      // URL 열기 시도
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // YouTube 앱 우선 실행
      );

      // 실패 시 처리
      if (!launched) {
        if (!context.mounted) return;

        // 대안: 브라우저에서 열기
        final browserLaunched = await launchUrl(
          url,
          mode: LaunchMode.platformDefault,
        );

        if (!browserLaunched) {
          _showErrorSnackbar(context, 'YouTube를 열 수 없습니다');
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackbar(context, '영상 재생에 실패했습니다: ${e.toString()}');
    }
  }

  /// [_getContrastColor] - 배경색에 대비되는 색상 반환
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  /// [_showSuccessSnackbar] - 성공 메시지 표시
  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// [_showErrorSnackbar] - 에러 메시지 표시
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// [_showInfoSnackbar] - 정보 메시지 표시
  void _showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
