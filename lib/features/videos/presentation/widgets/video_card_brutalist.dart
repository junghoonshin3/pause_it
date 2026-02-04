import 'package:flutter/material.dart';
import '../../domain/entities/video.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/timestamp_utils.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// [VideoCardBrutalist] - Neo-Brutalist 스타일 영상 카드
///
/// 디자인 특징:
/// - 날카로운 직각 모서리와 두꺼운 보더
/// - 대담한 타이포그래피와 기하학적 형태
/// - 강한 드롭섀도우와 레이어 효과
/// - 타임스탬프 강조 표시
///
/// Parameters:
/// - [video]: 표시할 영상
/// - [onTap]: 카드 탭 시 콜백 (영상 재생)
/// - [onEdit]: 편집 버튼 탭 시 콜백
/// - [onDelete]: 삭제 버튼 탭 시 콜백
class VideoCardBrutalist extends StatefulWidget {
  final Video video;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VideoCardBrutalist({
    super.key,
    required this.video,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<VideoCardBrutalist> createState() => _VideoCardBrutalistState();
}

class _VideoCardBrutalistState extends State<VideoCardBrutalist>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.animationDurationFast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.animationCurve),
    );

    _shadowAnimation = Tween<Offset>(
      begin: const Offset(6, 6),
      end: const Offset(2, 2),
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.animationCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            onLongPress: () => _showOptionsBottomSheet(context),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                border: Border.all(
                  color: AppTheme.textTertiary.withValues(alpha: 0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: _shadowAnimation.value,
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 썸네일
                  _buildThumbnail(context),

                  // 영상 정보
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목
                        Text(
                          widget.video.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                    height: 1.3,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // 채널명
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 14,
                              color: AppTheme.accentPurple,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.video.channelName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                      letterSpacing: 0.3,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 타임스탬프 & 영상 길이
                        Row(
                          children: [
                            // 현재 타임스탬프 (강조)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryDark,
                                border: Border.all(
                                  color: AppTheme.accentElectric,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.play_arrow,
                                    size: 16,
                                    color: AppTheme.accentElectric,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    TimestampUtils.formatDuration(widget.video.timestampSeconds),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: AppTheme.accentElectric,
                                          fontFamily: AppTheme.fontFamilyMono,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // 전체 길이
                            Text(
                              '/ ${TimestampUtils.formatDuration(widget.video.durationSeconds)}',
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textTertiary,
                                        fontFamily: AppTheme.fontFamilyMono,
                                      ),
                            ),

                            const Spacer(),

                            // 진행률 표시
                            _buildProgressIndicator(context),
                          ],
                        ),

                        // 메모가 있는 경우 표시
                        if (widget.video.memo != null &&
                            widget.video.memo!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryDark,
                              border: const Border(
                                left: BorderSide(
                                  color: AppTheme.accentYellow,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Text(
                              widget.video.memo!,
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// [_buildThumbnail] - 썸네일 이미지 생성
  Widget _buildThumbnail(BuildContext context) {
    return Stack(
      children: [
        // 썸네일 이미지
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.textTertiary.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
            ),
            child:
                (widget.video.thumbnailUrl != null && widget.video.thumbnailUrl!.isNotEmpty)
                    ? Image.network(
                        widget.video.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildThumbnailPlaceholder(context);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildThumbnailPlaceholder(context);
                        },
                      )
                    : _buildThumbnailPlaceholder(context),
          ),
        ),

        // 재생 아이콘 오버레이
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark.withValues(alpha: 0.9),
                  border: Border.all(
                    color: AppTheme.accentElectric,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: AppTheme.accentElectric,
                  size: 36,
                ),
              ),
            ),
          ),
        ),

        // 영상 길이 배지 (좌하단)
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              border: Border.all(
                color: AppTheme.textPrimary,
                width: 2,
              ),
            ),
            child: Text(
              TimestampUtils.formatDuration(widget.video.durationSeconds),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontFamily: AppTheme.fontFamilyMono,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),

        // 저장된 위치 표시 (우하단)
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentElectric,
              border: Border.all(
                color: AppTheme.primaryDark,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bookmark,
                  size: 14,
                  color: AppTheme.primaryDark,
                ),
                const SizedBox(width: 4),
                Text(
                  TimestampUtils.formatDuration(widget.video.timestampSeconds),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.primaryDark,
                        fontFamily: AppTheme.fontFamilyMono,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// [_buildThumbnailPlaceholder] - 썸네일 로딩/에러 플레이스홀더
  Widget _buildThumbnailPlaceholder(BuildContext context) {
    return Container(
      color: AppTheme.primaryDark,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                border: Border.all(
                  color: AppTheme.textTertiary,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.video_library,
                size: 32,
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [_buildProgressIndicator] - 진행률 표시
  Widget _buildProgressIndicator(BuildContext context) {
    final progress = widget.video.durationSeconds > 0
        ? widget.video.timestampSeconds / widget.video.durationSeconds
        : 0.0;
    final progressPercent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        border: Border.all(
          color: AppTheme.textTertiary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        '$progressPercent%',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textSecondary,
              fontFamily: AppTheme.fontFamilyMono,
            ),
      ),
    );
  }

  /// [_showOptionsBottomSheet] - 편집/삭제 옵션 표시
  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.secondaryDark,
          border: Border(
            top: BorderSide(color: AppTheme.accentElectric, width: 4),
            left: BorderSide(color: AppTheme.accentElectric, width: 4),
            right: BorderSide(color: AppTheme.accentElectric, width: 4),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더: 영상 정보
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.textTertiary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // 썸네일 미니
                    Container(
                      width: 80,
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.textTertiary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: widget.video.thumbnailUrl != null
                          ? Image.network(
                              widget.video.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppTheme.primaryDark,
                                  child: const Icon(
                                    Icons.video_library,
                                    color: AppTheme.textTertiary,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: AppTheme.primaryDark,
                              child: const Icon(
                                Icons.video_library,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.video.title,
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.video.channelName,
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 옵션들
              _buildBrutalistOption(
                context: context,
                icon: Icons.edit,
                label: 'EDIT',
                color: AppTheme.accentPurple,
                onTap: () {
                  Navigator.pop(context);
                  if (widget.onEdit != null) widget.onEdit!();
                },
              ),

              _buildBrutalistOption(
                context: context,
                icon: Icons.delete,
                label: 'DELETE',
                color: AppTheme.accentNeon,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),

              _buildBrutalistOption(
                context: context,
                icon: Icons.close,
                label: 'CANCEL',
                color: AppTheme.textSecondary,
                onTap: () => Navigator.pop(context),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrutalistOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.textTertiary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
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
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    letterSpacing: 1,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// [_showDeleteConfirmation] - 삭제 확인 다이얼로그
  void _showDeleteConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.secondaryDark,
            border: Border.all(
              color: AppTheme.accentNeon,
              width: 4,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 타이틀
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    color: AppTheme.accentNeon,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.brutalistConfirmDelete,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accentNeon,
                          letterSpacing: 1,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 메시지
              Text(
                l10n.videoDeleteConfirmMessage,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
              ),

              const SizedBox(height: 12),

              // 영상 정보
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  border: Border.all(
                    color: AppTheme.textTertiary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 34,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.textTertiary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: widget.video.thumbnailUrl != null
                          ? Image.network(
                              widget.video.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppTheme.secondaryDark,
                                  child: const Icon(
                                    Icons.video_library,
                                    color: AppTheme.textTertiary,
                                    size: 16,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: AppTheme.secondaryDark,
                              child: const Icon(
                                Icons.video_library,
                                color: AppTheme.textTertiary,
                                size: 16,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.video.title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 버튼들
              Row(
                children: [
                  Expanded(
                    child: _buildDialogButton(
                      context: context,
                      label: l10n.commonButtonCancel.toUpperCase(),
                      color: AppTheme.textSecondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDialogButton(
                      context: context,
                      label: l10n.commonButtonDelete.toUpperCase(),
                      color: AppTheme.accentNeon,
                      onPressed: () {
                        Navigator.pop(context);
                        if (widget.onDelete != null) widget.onDelete!();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton({
    required BuildContext context,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.primaryDark,
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  letterSpacing: 1,
                ),
          ),
        ),
      ),
    );
  }

}
