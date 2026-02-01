import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../providers/category_provider.dart';
import '../../../videos/domain/entities/shared_url_result.dart';
import '../../../videos/domain/entities/video.dart';
import '../../../videos/presentation/providers/video_provider.dart';
import '../../../../core/services/youtube_metadata_service.dart';

/// [CategorySelectionDialog] - 공유 영상 카테고리 선택 다이얼로그
///
/// YouTube 공유로 받은 영상을 어떤 카테고리에 저장할지 선택하는 UI
class CategorySelectionDialog extends ConsumerWidget {
  final SharedUrlResult sharedUrlResult;
  final VoidCallback onCancel;

  const CategorySelectionDialog({
    super.key,
    required this.sharedUrlResult,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return AlertDialog(
      title: const Text('카테고리 선택'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 영상 미리보기
            _VideoPreview(metadata: sharedUrlResult.metadata),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              '어느 카테고리에 추가할까요?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),

            // 카테고리 목록
            categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const Text('카테고리를 불러올 수 없습니다'),
              data: (categories) {
                if (categories.isEmpty) {
                  return _EmptyCategories(onCancel: onCancel);
                }
                return _CategoryList(
                  categories: categories,
                  onSelect: (category) =>
                      _addToCategory(context, ref, category),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('취소'),
        ),
      ],
    );
  }

  /// [_addToCategory] - 선택한 카테고리에 영상 추가
  Future<void> _addToCategory(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final now = DateTime.now();
    final newVideo = Video(
      id: null, // DB에서 자동 생성
      categoryId: category.id!,
      youtubeUrl: sharedUrlResult.url,
      youtubeVideoId: sharedUrlResult.videoId,
      title: sharedUrlResult.metadata.title,
      description: sharedUrlResult.metadata.description,
      thumbnailUrl: sharedUrlResult.metadata.thumbnailUrl,
      channelName: sharedUrlResult.metadata.channelName,
      durationSeconds: sharedUrlResult.metadata.durationSeconds,
      timestampSeconds: sharedUrlResult.timestampSeconds,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${category.name}에 영상이 추가되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('영상 추가에 실패했습니다'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    return Column(
      children: [
        const Icon(Icons.folder_off, size: 48, color: Colors.grey),
        const SizedBox(height: 8),
        const Text('카테고리가 없습니다'),
        const SizedBox(height: 4),
        const Text(
          '먼저 카테고리를 생성해주세요',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onCancel,
          child: const Text('확인'),
        ),
      ],
    );
  }
}
