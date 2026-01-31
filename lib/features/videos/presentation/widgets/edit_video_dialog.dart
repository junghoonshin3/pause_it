import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../domain/entities/video.dart';

/// [EditVideoDialog] - 영상 편집 다이얼로그
///
/// 주요 기능:
/// - 타임스탬프 수정
/// - 메모 수정
/// - 카테고리 이동
///
/// Parameters:
/// - [video]: 편집할 영상 객체
/// - [currentCategoryId]: 현재 영상이 속한 카테고리 ID
/// - [onSave]: 저장 성공 시 콜백 (수정된 Video 객체 반환, 카테고리 변경 포함)
///
/// 사용 예시:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => EditVideoDialog(
///     video: video,
///     currentCategoryId: 1,
///     onSave: (updatedVideo) {
///       // 영상 수정 처리 (카테고리 변경 여부 확인 가능)
///     },
///   ),
/// );
/// ```
class EditVideoDialog extends ConsumerStatefulWidget {
  final Video video;
  final int currentCategoryId;
  final Function(Video)? onSave;

  const EditVideoDialog({
    super.key,
    required this.video,
    required this.currentCategoryId,
    this.onSave,
  });

  @override
  ConsumerState<EditVideoDialog> createState() => _EditVideoDialogState();
}

class _EditVideoDialogState extends ConsumerState<EditVideoDialog> {
  late TextEditingController _timestampController;
  late TextEditingController _memoController;
  int? _selectedCategoryId;
  bool _isCategoryChanged = false;

  @override
  void initState() {
    super.initState();
    // 기존 값으로 초기화
    _timestampController = TextEditingController(
      text: _formatDuration(widget.video.timestampSeconds),
    );
    _memoController = TextEditingController(
      text: widget.video.memo ?? '',
    );
    _selectedCategoryId = widget.currentCategoryId;
  }

  @override
  void dispose() {
    _timestampController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 카테고리 목록 가져오기
    final categoriesAsync = ref.watch(categoryListProvider);

    return AlertDialog(
      title: const Text('영상 편집'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 영상 정보 표시
            _buildVideoInfo(context),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // 타임스탬프 수정
            TextField(
              controller: _timestampController,
              decoration: const InputDecoration(
                labelText: '타임스탬프',
                hintText: '1:23 또는 1:23:45',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
                helperText: '중단한 시점을 입력하세요',
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // 메모 수정
            TextField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: '메모 (선택)',
                hintText: '이 영상에 대한 메모를 입력하세요',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                helperText: '나중에 기억할 내용을 적어두세요',
              ),
              maxLines: 3,
              maxLength: 500,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 16),

            // 카테고리 이동
            categoriesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, stack) => const Text('카테고리를 불러올 수 없습니다'),
              data: (categories) => _buildCategoryDropdown(categories),
            ),

            // 카테고리 변경 안내
            if (_isCategoryChanged)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '저장 시 영상이 새 카테고리로 이동됩니다',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        // 취소 버튼
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),

        // 저장 버튼
        FilledButton(
          onPressed: _handleSave,
          child: const Text('저장'),
        ),
      ],
    );
  }

  /// [_buildVideoInfo] - 영상 정보 표시 위젯
  Widget _buildVideoInfo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 썸네일
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: widget.video.thumbnailUrl != null
              ? Image.network(
                  widget.video.thumbnailUrl!,
                  width: 100,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildThumbnailPlaceholder(),
                )
              : _buildThumbnailPlaceholder(),
        ),
        const SizedBox(width: 12),

        // 제목 및 채널명
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.video.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (widget.video.channelName != null)
                Text(
                  widget.video.channelName!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// [_buildThumbnailPlaceholder] - 썸네일 플레이스홀더
  Widget _buildThumbnailPlaceholder() {
    return Container(
      width: 100,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.video_library, color: Colors.grey),
    );
  }

  /// [_buildCategoryDropdown] - 카테고리 드롭다운
  Widget _buildCategoryDropdown(List<Category> categories) {
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      decoration: const InputDecoration(
        labelText: '카테고리',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.folder),
      ),
      items: categories.map((category) {
        return DropdownMenuItem<int>(
          value: category.id,
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 현재 카테고리 표시
              if (category.id == widget.currentCategoryId)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '현재',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
          _isCategoryChanged = value != widget.currentCategoryId;
        });
      },
    );
  }

  /// [_handleSave] - 저장 처리
  void _handleSave() {
    // 타임스탬프 파싱
    final newTimestamp = _parseDuration(_timestampController.text) ?? 0;
    final newMemo = _memoController.text.trim().isEmpty
        ? null
        : _memoController.text.trim();

    // 수정된 Video 객체 생성
    final updatedVideo = Video(
      id: widget.video.id,
      categoryId: _selectedCategoryId ?? widget.currentCategoryId,
      youtubeUrl: widget.video.youtubeUrl,
      youtubeVideoId: widget.video.youtubeVideoId,
      title: widget.video.title,
      description: widget.video.description,
      thumbnailUrl: widget.video.thumbnailUrl,
      channelName: widget.video.channelName,
      durationSeconds: widget.video.durationSeconds,
      timestampSeconds: newTimestamp,
      memo: newMemo,
      createdAt: widget.video.createdAt,
      updatedAt: DateTime.now(),
    );

    // 저장 콜백 호출
    if (widget.onSave != null) {
      widget.onSave!(updatedVideo);
    }

    // 다이얼로그 닫기
    Navigator.pop(context);
  }

  /// [_formatDuration] - 초를 시간 문자열로 변환
  ///
  /// Parameters:
  /// - [seconds]: 변환할 초
  ///
  /// Returns: "M:SS" 또는 "H:MM:SS" 형식의 문자열
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  /// [_parseDuration] - 시간 문자열을 초로 변환
  ///
  /// Parameters:
  /// - [input]: "M:SS" 또는 "H:MM:SS" 형식의 문자열
  ///
  /// Returns: 초 단위의 정수, 파싱 실패 시 null
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
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
