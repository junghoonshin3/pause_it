import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../categories/domain/entities/category.dart';
import '../../domain/entities/video.dart';
import '../providers/video_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/video_card_brutalist.dart';
import '../widgets/add_video_dialog.dart';
import '../widgets/edit_video_dialog.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// [VideoListScreenBrutalist] - Neo-Brutalist 디자인의 영상 목록 화면
///
/// 주요 기능:
/// - 특정 카테고리의 영상 목록 표시
/// - 영상 추가 FAB
/// - 영상 재생 (YouTube 앱/웹 열기)
/// - 영상 편집/삭제
/// - 타임스탬프 업데이트
///
/// 디자인 특징:
/// - 대담한 타이포그래피와 비대칭 레이아웃
/// - 날카로운 기하학적 형태
/// - 강렬한 색상 대비
/// - 레이어드 UI와 강한 그림자
///
/// Parameters:
/// - [category]: 표시할 카테고리
class VideoListScreenBrutalist extends ConsumerWidget {
  final Category category;

  const VideoListScreenBrutalist({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 영상 목록 상태 구독
    final videosAsync = ref.watch(videoListProvider(category.id!));

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 커스텀 헤더
            _buildBrutalistHeader(context, ref, videosAsync),

            // 메인 콘텐츠
            Expanded(
              child: videosAsync.when(
                loading: () => _buildLoadingView(context),
                error: (error, stackTrace) =>
                    _buildErrorView(context, error.toString()),
                data: (videos) {
                  if (videos.isEmpty) {
                    return _buildEmptyView(context, ref);
                  }
                  return _buildVideoList(context, ref, videos);
                },
              ),
            ),
          ],
        ),
      ),

      // Brutalist FAB
      floatingActionButton: _buildBrutalistFAB(context, ref),
    );
  }

  /// [_buildBrutalistHeader] - Neo-Brutalist 스타일 헤더
  Widget _buildBrutalistHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue videosAsync,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.textTertiary.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 네비게이션
          Row(
            children: [
              // 뒤로가기 버튼
              _buildIconButton(
                context: context,
                icon: Icons.arrow_back,
                color: AppTheme.textPrimary,
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(width: 16),

              // 카테고리 아이콘
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: category.color,
                  border: Border.all(
                    color: AppTheme.primaryDark,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.folder,
                  size: 24,
                  color: _getContrastColor(category.color),
                ),
              ),

              const SizedBox(width: 12),

              // 카테고리 이름
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name.toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.5,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      AppLocalizations.of(context).brutalistVideos,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: category.color,
                            letterSpacing: 2,
                          ),
                    ),
                  ],
                ),
              ),

              // 새로고침 버튼
              _buildIconButton(
                context: context,
                icon: Icons.refresh,
                color: AppTheme.accentElectric,
                onPressed: () {
                  ref.read(videoListProvider(category.id!).notifier).loadVideos();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 통계 스트립
          videosAsync.when(
            data: (videos) => _buildStatsStrip(context, videos),
            loading: () => _buildStatsStrip(context, []),
            error: (e, _) => _buildStatsStrip(context, []),
          ),
        ],
      ),
    );
  }

  /// [_buildStatsStrip] - 통계 정보 스트립
  Widget _buildStatsStrip(BuildContext context, List<Video> videos) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        _buildStatBox(
          context: context,
          label: l10n.brutalistVideos,
          value: '${videos.length}',
          color: AppTheme.accentElectric,
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontFamily: AppTheme.fontFamilyMono,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textSecondary,
                  letterSpacing: 1,
                ),
          ),
        ],
      ),
    );
  }

  /// [_buildIconButton] - Brutalist 아이콘 버튼
  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: 22),
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
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(
            milliseconds: 200 + (index * 50),
          ),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: VideoCardBrutalist(
              video: video,
              onTap: () => _playVideo(context, video),
              onEdit: () => _showEditVideoDialog(context, ref, video),
              onDelete: () => _deleteVideo(context, ref, video),
            ),
          ),
        );
      },
    );
  }

  /// [_buildEmptyView] - 빈 화면 상태
  Widget _buildEmptyView(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 큰 아이콘 박스
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                border: Border.all(
                  color: category.color,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: const Offset(8, 8),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                Icons.video_library_outlined,
                size: 70,
                color: category.color,
              ),
            ),

            const SizedBox(height: 32),

            Text(
              l10n.brutalistNoVideos,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: 2,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                border: Border.all(
                  color: AppTheme.textTertiary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Text(
                l10n.brutalistNoVideosDesc,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [_buildLoadingView] - 로딩 화면
  Widget _buildLoadingView(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.accentElectric,
                width: 4,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppTheme.accentElectric,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.commonLoading,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.accentElectric,
                  letterSpacing: 2,
                ),
          ),
        ],
      ),
    );
  }

  /// [_buildErrorView] - 에러 화면
  Widget _buildErrorView(BuildContext context, String errorMessage) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                border: Border.all(
                  color: AppTheme.error,
                  width: 4,
                ),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.commonError,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.error,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                border: Border.all(
                  color: AppTheme.error.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Text(
                errorMessage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [_buildBrutalistFAB] - Brutalist FAB
  Widget _buildBrutalistFAB(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: () => _showAddVideoDialog(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.accentElectric,
          border: Border.all(
            color: AppTheme.primaryDark,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: AppTheme.primaryDark, size: 24),
            const SizedBox(width: 8),
            Text(
              l10n.brutalistAdd,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ 액션 메서드들 ============

  /// [_showAddVideoDialog] - 영상 추가 다이얼로그 표시
  void _showAddVideoDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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

            if (!context.mounted) return;
            _showBrutalistSnackbar(
              context,
              l10n.brutalistVideoAdded,
              AppTheme.success,
              Icons.check_circle,
            );
          } else {
            _showBrutalistSnackbar(
              context,
              l10n.brutalistFailedToAdd,
              AppTheme.error,
              Icons.error,
            );
          }
        },
      ),
    );
  }

  /// [_showEditVideoDialog] - 영상 편집 다이얼로그 표시
  void _showEditVideoDialog(
    BuildContext context,
    WidgetRef ref,
    Video video,
  ) {
    final l10n = AppLocalizations.of(context);
    // 🔒 LAYER 1 VALIDATION: Check if category.id exists
    if (category.id == null) {
      _showBrutalistSnackbar(
        context,
        l10n.commonError,
        AppTheme.error,
        Icons.error,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => EditVideoDialog(
        video: video,
        currentCategoryId: category.id!, // Safe after null check
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
              // 두 카테고리의 영상 개수 갱신
              ref.invalidate(videoCountProvider(category.id!));
              ref.invalidate(videoCountProvider(updatedVideo.categoryId));
              _showBrutalistSnackbar(
                context,
                l10n.brutalistVideoMoved,
                AppTheme.success,
                Icons.check_circle,
              );
            } else {
              _showBrutalistSnackbar(
                context,
                l10n.brutalistFailedToUpdate,
                AppTheme.error,
                Icons.error,
              );
            }
          } else {
            // 카테고리 변경 없이 정보만 수정
            final success = await ref
                .read(videoListProvider(category.id!).notifier)
                .updateVideo(updatedVideo);

            if (!context.mounted) return;

            if (success) {
              _showBrutalistSnackbar(
                context,
                l10n.brutalistVideoUpdated,
                AppTheme.success,
                Icons.check_circle,
              );
            } else {
              _showBrutalistSnackbar(
                context,
                l10n.brutalistFailedToUpdate,
                AppTheme.error,
                Icons.error,
              );
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
    final l10n = AppLocalizations.of(context);
    // 알림 취소
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.cancelNotification(video.id!);

    // 영상 삭제
    final success = await ref
        .read(videoListProvider(category.id!).notifier)
        .deleteVideo(video.id!);

    if (!context.mounted) return;

    if (success) {
      _showBrutalistSnackbar(
        context,
        l10n.brutalistVideoDeleted,
        AppTheme.success,
        Icons.check_circle,
      );
    } else {
      _showBrutalistSnackbar(
        context,
        l10n.brutalistFailedToDelete,
        AppTheme.error,
        Icons.error,
      );
    }
  }

  /// [_playVideo] - YouTube 영상 재생
  Future<void> _playVideo(BuildContext context, Video video) async {
    final l10n = AppLocalizations.of(context);
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

        if (!context.mounted) return;
        if (!browserLaunched) {
          _showBrutalistSnackbar(
            context,
            l10n.commonError,
            AppTheme.error,
            Icons.error,
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      _showBrutalistSnackbar(
        context,
        l10n.commonError,
        AppTheme.error,
        Icons.error,
      );
    }
  }

  /// [_getContrastColor] - 배경색에 대비되는 색상 반환
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? AppTheme.primaryDark : AppTheme.textPrimary;
  }

  void _showBrutalistSnackbar(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: AppTheme.secondaryDark,
        behavior: SnackBarBehavior.floating,
        shape: Border.all(color: color, width: 2),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
