import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../providers/category_provider.dart';
import '../../../videos/domain/entities/shared_url_result.dart';
import '../../../videos/domain/entities/video.dart';
import '../../../videos/presentation/providers/notification_provider.dart';
import '../../../videos/presentation/providers/video_provider.dart';
import '../../../../core/services/youtube_metadata_service.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// [CategorySelectionDialog] - 공유 영상 카테고리 선택 다이얼로그
///
/// YouTube 공유로 받은 영상을 어떤 카테고리에 저장할지 선택하는 UI
/// 타임스탬프 입력 필드를 포함하여 저장 시간 지점을 사용자가 수정할 수 있음
class CategorySelectionDialog extends ConsumerStatefulWidget {
  final SharedUrlResult sharedUrlResult;
  final VoidCallback onCancel;

  const CategorySelectionDialog({
    super.key,
    required this.sharedUrlResult,
    required this.onCancel,
  });

  @override
  ConsumerState<CategorySelectionDialog> createState() =>
      _CategorySelectionDialogState();
}

class _CategorySelectionDialogState
    extends ConsumerState<CategorySelectionDialog> {
  late final TextEditingController _timestampController;

  @override
  void initState() {
    super.initState();
    // URL에 타임스탬프가 포함된 경우 포맷된 값으로 초기화, 아니면 기본값 0:00
    final initialSeconds = widget.sharedUrlResult.timestampSeconds;
    _timestampController = TextEditingController(
      text: initialSeconds > 0 ? _formatDuration(initialSeconds) : '0:00',
    );
  }

  @override
  void dispose() {
    _timestampController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.categorySelectionTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 영상 미리보기
            _VideoPreview(metadata: widget.sharedUrlResult.metadata),
            const SizedBox(height: 16),

            // 타임스탬프 입력 필드
            TextField(
              controller: _timestampController,
              decoration: InputDecoration(
                labelText: l10n.videoTimestampLabel,
                hintText: l10n.videoTimestampHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.access_time),
                helperText: l10n.videoTimestampHelperDefault,
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              l10n.categorySelectionPrompt,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),

            // 카테고리 목록
            categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(l10n.categorySelectionLoadError),
              data: (categories) {
                if (categories.isEmpty) {
                  return _EmptyCategories(onCancel: widget.onCancel);
                }
                return _CategoryList(
                  categories: categories,
                  onSelect: (category) => _addToCategory(category),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text(l10n.commonButtonCancel),
        ),
      ],
    );
  }

  /// [_addToCategory] - 선택한 카테고리에 영상 추가
  Future<void> _addToCategory(Category category) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    // 사용자가 입력한 타임스탬프 파싱
    final timestampSeconds = _parseDuration(_timestampController.text) ?? 0;

    final newVideo = Video(
      id: null, // DB에서 자동 생성
      categoryId: category.id!,
      youtubeUrl: widget.sharedUrlResult.url,
      youtubeVideoId: widget.sharedUrlResult.videoId,
      title: widget.sharedUrlResult.metadata.title,
      description: widget.sharedUrlResult.metadata.description,
      thumbnailUrl: widget.sharedUrlResult.metadata.thumbnailUrl,
      channelName: widget.sharedUrlResult.metadata.channelName,
      durationSeconds: widget.sharedUrlResult.metadata.durationSeconds,
      timestampSeconds: timestampSeconds,
      memo: null,
      createdAt: now,
      updatedAt: now,
    );

    final savedVideo = await ref
        .read(videoListProvider(category.id!).notifier)
        .addVideo(newVideo);

    if (!context.mounted) return;

    // 영상 개수 카운트 갱신
    ref.invalidate(videoCountProvider(category.id!));

    // sharedUrlStateProvider 초기화
    ref.read(sharedUrlStateProvider.notifier).state = null;
    Navigator.pop(context);

    if (savedVideo != null) {
      // 저장된 영상에 대해 리마인더 알림 스케줄
      if (savedVideo.id != null) {
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.scheduleVideoReminder(
          videoId: savedVideo.id!,
          videoTitle: savedVideo.title,
          youtubeVideoId: savedVideo.youtubeVideoId,
          timestampSeconds: savedVideo.timestampSeconds,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categorySelectionAddSuccess(category.name)),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categorySelectionAddFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// [_parseDuration] - 시간 문자열을 초로 변환
  ///
  /// 지원 형식:
  /// - MM:SS (예: 1:23 → 83초)
  /// - HH:MM:SS (예: 1:23:45 → 5025초)
  /// - YouTube 스타일: t=70s, t=1m10s, 70s, 1m10s, 1h2m30s 등
  int? _parseDuration(String input) {
    try {
      // 앞뒤 공백 제거 및 앞의 "t=" 제거
      var text = input.trim();
      if (text.startsWith('t=')) {
        text = text.substring(2);
      }

      // YouTube 스타일 형식: Xh, Xm, Xs 조합
      final youtubePattern = RegExp(r'^(?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s)?$');
      final youtubeMatch = youtubePattern.firstMatch(text);
      if (youtubeMatch != null && youtubeMatch[0]!.isNotEmpty) {
        final hours = int.parse(youtubeMatch[1] ?? '0');
        final minutes = int.parse(youtubeMatch[2] ?? '0');
        final seconds = int.parse(youtubeMatch[3] ?? '0');
        return hours * 3600 + minutes * 60 + seconds;
      }

      // 기존 형식: MM:SS / HH:MM:SS
      final parts = text.split(':');
      if (parts.length == 2) {
        final minutes = int.parse(parts[0]);
        final seconds = int.parse(parts[1]);
        return minutes * 60 + seconds;
      } else if (parts.length == 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        return hours * 3600 + minutes * 60 + seconds;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// [_formatDuration] - 초 단위를 "M:SS" 또는 "H:MM:SS" 형식으로 변환
  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// [_VideoPreview] - 영상 미리보기 위젯
class _VideoPreview extends StatelessWidget {
  final YouTubeMetadata metadata;

  const _VideoPreview({required this.metadata});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 썸네일
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            metadata.thumbnailUrl,
            width: 120,
            height: 68,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 120,
              height: 68,
              color: Colors.grey[300],
              child: const Icon(Icons.video_library),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 제목 및 채널
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metadata.title,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                metadata.channelName,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// [_CategoryList] - 카테고리 목록 위젯
class _CategoryList extends StatelessWidget {
  final List<Category> categories;
  final Function(Category) onSelect;

  const _CategoryList({required this.categories, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: categories.map((category) {
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.folder,
              color: _getContrastColor(category.color),
            ),
          ),
          title: Text(category.name),
          onTap: () => onSelect(category),
        );
      }).toList(),
    );
  }

  /// [_getContrastColor] - 배경색에 대비되는 텍스트 색상 계산
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

/// [_EmptyCategories] - 카테고리 없음 안내 위젯
class _EmptyCategories extends StatelessWidget {
  final VoidCallback onCancel;

  const _EmptyCategories({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        const Icon(Icons.folder_off, size: 48, color: Colors.grey),
        const SizedBox(height: 8),
        Text(l10n.categorySelectionEmpty),
        const SizedBox(height: 4),
        Text(
          l10n.categorySelectionEmptyDesc,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onCancel,
          child: Text(l10n.commonButtonConfirm),
        ),
      ],
    );
  }
}
