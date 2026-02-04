import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../domain/entities/video.dart';
import '../../../../core/utils/timestamp_utils.dart';
import '../../../../generated/l10n/app_localizations.dart';

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
      text: TimestampUtils.formatDuration(widget.video.timestampSeconds),
    );
    _memoController = TextEditingController(
      text: widget.video.memo ?? '',
    );
    // 🔒 LAYER 2 VALIDATION: Initialize with currentCategoryId (guaranteed non-null by Layer 1)
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
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.videoEditTitle),
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
              decoration: InputDecoration(
                labelText: l10n.videoTimestampLabel,
                hintText: l10n.videoTimestampHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.access_time),
                helperText: widget.video.durationSeconds != null
                    ? l10n.videoTimestampHelperWithMax(TimestampUtils.formatDuration(widget.video.durationSeconds!))
                    : l10n.videoTimestampHelperEdit,
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9:thms=]')),
                _TimeStampInputFormatter(),
              ],
            ),
            const SizedBox(height: 16),

            // 메모 수정
            TextField(
              controller: _memoController,
              decoration: InputDecoration(
                labelText: l10n.videoMemoLabel,
                hintText: l10n.videoMemoHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.note),
                helperText: l10n.videoMemoHelper,
              ),
              maxLines: 3,
              maxLength: 500,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 16),

            // 카테고리 이동
            categoriesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, stack) => Text(l10n.categorySelectionLoadError),
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
                        l10n.videoCategoryMoveInfo,
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
          child: Text(l10n.commonButtonCancel),
        ),

        // 저장 버튼
        FilledButton(
          onPressed: _handleSave,
          child: Text(l10n.commonButtonSave),
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
    final l10n = AppLocalizations.of(context)!;

    // 🔒 LAYER 2 VALIDATION: Filter out categories with null IDs
    final validCategories = categories.where((c) => c.id != null).toList();

    // 🔒 Ensure selected category exists in valid list
    if (_selectedCategoryId != null) {
      final categoryExists = validCategories.any((c) => c.id == _selectedCategoryId);
      if (!categoryExists && validCategories.isNotEmpty) {
        _selectedCategoryId = validCategories.first.id;
      }
    } else if (validCategories.isNotEmpty) {
      _selectedCategoryId = validCategories.first.id;
    }

    return DropdownButtonFormField<int>(
      value: _selectedCategoryId, // Validated by Layer 2
      decoration: InputDecoration(
        labelText: l10n.videoCategoryLabel,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.folder),
      ),
      items: validCategories.map((category) {
        return DropdownMenuItem<int>(
          value: category.id!, // Guaranteed non-null by Layer 2 filtering
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
              Text(
                category.name,
                overflow: TextOverflow.ellipsis,
              ),
              // 현재 카테고리 표시
              if (category.id == widget.currentCategoryId) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n.categoryCurrentBadge,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
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
    final l10n = AppLocalizations.of(context)!;

    // 타임스탬프 파싱 (초 단위로 변환)
    final newTimestamp = TimestampUtils.parseDuration(_timestampController.text);

    // 타임스탬프 형식 검증
    if (newTimestamp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorTimestampInvalidFormat),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // 디버깅: 값 확인
    debugPrint('🔍 입력된 타임스탬프(초): $newTimestamp');
    debugPrint('🔍 영상 총 길이(초): ${widget.video.durationSeconds}');

    // 영상 길이 초과 검증
    if (widget.video.durationSeconds != null) {
      if (newTimestamp > widget.video.durationSeconds!) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.errorTimestampExceeds(
                TimestampUtils.formatDuration(newTimestamp),
                TimestampUtils.formatDuration(widget.video.durationSeconds!),
              ),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }
    } else {
      // durationSeconds가 null인 경우 경고
      debugPrint('⚠️ 경고: 영상 길이 정보가 없습니다. 검증을 건너뜁니다.');
    }

    final newMemo = _memoController.text.trim().isEmpty
        ? null
        : _memoController.text.trim();

    // 🔒 LAYER 3 VALIDATION: Use _selectedCategoryId (guaranteed non-null by Layer 2)
    // Layer 2 ensures _selectedCategoryId is always valid, so this is safe
    final finalCategoryId = _selectedCategoryId!;

    // 수정된 Video 객체 생성
    final updatedVideo = Video(
      id: widget.video.id,
      categoryId: finalCategoryId, // Guaranteed non-null by Layer 2 validation
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

}

/// [_TimeStampInputFormatter] - 타임스탬프 입력 포맷터
///
/// 주요 기능:
/// - MM:SS / HH:MM:SS 형식과 YouTube 스타일(t=Xh Ym Zs) 모두 허용
/// - 연속된 콜론(::) 방지
/// - 콜론 형식 시 최대 2개의 콜론까지만 허용
class _TimeStampInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // 빈 문자열은 허용
    if (text.isEmpty) return newValue;

    // YouTube 스타일 형식 입력 중인 경우 콜론 관련 검증 건너뛰기
    if (text.contains('h') || text.contains('m') || text.contains('s') || text.contains('=')) {
      return newValue;
    }

    // 연속된 콜론 방지
    if (text.contains('::')) {
      return oldValue;
    }

    // 콜론 개수 제한 (최대 2개: HH:MM:SS)
    final colonCount = ':'.allMatches(text).length;
    if (colonCount > 2) {
      return oldValue;
    }

    // 콜론으로 시작하면 안 됨
    if (text.startsWith(':')) {
      return oldValue;
    }

    return newValue;
  }
}
