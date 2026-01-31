import 'package:flutter/material.dart';
import '../../domain/entities/video.dart';

/// [VideoCard] - 영상 카드 위젯
///
/// 주요 기능:
/// - 영상 정보 표시 (썸네일, 제목, 채널명, 타임스탬프)
/// - 탭 시 YouTube 영상 재생
/// - 길게 누르면 편집/삭제 옵션 표시
///
/// Parameters:
/// - [video]: 표시할 영상
/// - [onTap]: 카드 탭 시 콜백 (영상 재생)
/// - [onEdit]: 편집 버튼 탭 시 콜백
/// - [onDelete]: 삭제 버튼 탭 시 콜백
/// - [onUpdateTimestamp]: 타임스탬프 업데이트 콜백
class VideoCard extends StatelessWidget {
  final Video video;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(int seconds)? onUpdateTimestamp;

  const VideoCard({
    super.key,
    required this.video,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onUpdateTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showOptionsBottomSheet(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일
            _buildThumbnail(context),

            // 영상 정보
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    video.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // 채널명
                  Text(
                    video.channelName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // 타임스탬프 & 영상 길이
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(video.timestampSeconds),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ ${_formatDuration(video.durationSeconds)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [_buildThumbnail] - 썸네일 이미지 생성
  Widget _buildThumbnail(BuildContext context) {
    return Stack(
      children: [
        // 썸네일 이미지
        AspectRatio(
          aspectRatio: 16 / 9,
          child: (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty)
              ? Image.network(
                  video.thumbnailUrl!,
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

        // 재생 아이콘 오버레이
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),

        // 영상 길이 배지
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _formatDuration(video.durationSeconds),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// [_buildThumbnailPlaceholder] - 썸네일 로딩/에러 플레이스홀더
  Widget _buildThumbnailPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.video_library,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  /// [_showOptionsBottomSheet] - 편집/삭제 옵션 표시
  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 영상 정보 표시
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: video.thumbnailUrl != null
                        ? Image.network(
                            video.thumbnailUrl!,
                            width: 80,
                            height: 45,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 45,
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: const Icon(Icons.video_library),
                              );
                            },
                          )
                        : Container(
                            width: 80,
                            height: 45,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Icon(Icons.video_library),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          video.channelName,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // 타임스탬프 업데이트
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('타임스탬프 업데이트'),
              onTap: () {
                Navigator.pop(context);
                _showTimestampUpdateDialog(context);
              },
            ),

            // 편집
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('편집'),
              onTap: () {
                Navigator.pop(context);
                if (onEdit != null) {
                  onEdit!();
                }
              },
            ),

            // 삭제
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                if (onDelete != null) {
                  _showDeleteConfirmation(context);
                }
              },
            ),

            // 취소
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('취소'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  /// [_showTimestampUpdateDialog] - 타임스탬프 업데이트 다이얼로그
  void _showTimestampUpdateDialog(BuildContext context) {
    final controller = TextEditingController(
      text: _formatDuration(video.timestampSeconds),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('타임스탬프 업데이트'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '새로운 타임스탬프를 입력하세요\n(형식: MM:SS 또는 HH:MM:SS)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '타임스탬프',
                hintText: '1:23 또는 1:23:45',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
              keyboardType: TextInputType.text,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              final seconds = _parseDuration(controller.text);
              if (seconds != null && onUpdateTimestamp != null) {
                onUpdateTimestamp!(seconds);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('올바른 형식으로 입력해주세요 (예: 1:23)'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('업데이트'),
          ),
        ],
      ),
    );
  }

  /// [_showDeleteConfirmation] - 삭제 확인 다이얼로그
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('영상 삭제'),
        content: Text('\'${video.title}\' 영상을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (onDelete != null) {
                onDelete!();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  /// [_formatDuration] - 초를 시간 형식으로 변환 (MM:SS 또는 HH:MM:SS)
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
  }

  /// [_parseDuration] - 시간 문자열을 초로 변환
  ///
  /// 지원 형식:
  /// - "1:23" -> 83초
  /// - "1:23:45" -> 5025초
  int? _parseDuration(String input) {
    try {
      final parts = input.trim().split(':');
      if (parts.length == 2) {
        // MM:SS
        final minutes = int.parse(parts[0]);
        final seconds = int.parse(parts[1]);
        return minutes * 60 + seconds;
      } else if (parts.length == 3) {
        // HH:MM:SS
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        return hours * 3600 + minutes * 60 + seconds;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
