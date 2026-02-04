import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/get_video_metadata.dart';
import '../providers/video_provider.dart';
import '../../../../core/utils/timestamp_utils.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// [AddVideoDialog] - 영상 추가 다이얼로그
///
/// 주요 기능:
/// - YouTube URL 입력
/// - URL 자동 파싱 및 메타데이터 추출
/// - 타임스탬프 설정
/// - 로딩 상태 표시
///
/// Parameters:
/// - [categoryId]: 영상을 추가할 카테고리 ID
/// - [onVideoAdded]: 영상 추가 성공 시 콜백
///
/// 사용 예시:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => AddVideoDialog(
///     categoryId: 1,
///     onVideoAdded: (video) {
///       // 영상 추가 성공 처리
///     },
///   ),
/// );
/// ```
class AddVideoDialog extends ConsumerStatefulWidget {
  final int categoryId;
  final Function(Video)? onVideoAdded;

  const AddVideoDialog({
    super.key,
    required this.categoryId,
    this.onVideoAdded,
  });

  @override
  ConsumerState<AddVideoDialog> createState() => _AddVideoDialogState();
}

class _AddVideoDialogState extends ConsumerState<AddVideoDialog> {
  final _urlController = TextEditingController();
  final _timestampController = TextEditingController(text: '0:00');

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _urlController.dispose();
    _timestampController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.videoAddTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 안내 문구
            Text(
              l10n.videoAddPrompt,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // URL 입력 필드
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: l10n.videoUrlLabel,
                hintText: l10n.videoUrlHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.link),
                errorText: _errorMessage,
              ),
              enabled: !_isLoading,
              autofocus: true,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                // 에러 메시지 초기화
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
            ),
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
              enabled: !_isLoading,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
            ),

            // 로딩 인디케이터
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                l10n.videoLoadingMetadata,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        // 취소 버튼
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.commonButtonCancel),
        ),

        // 추가 버튼
        FilledButton(
          onPressed: _isLoading ? null : _handleAddVideo,
          child: Text(l10n.commonButtonAdd),
        ),
      ],
    );
  }

  /// [_handleAddVideo] - 영상 추가 처리
  ///
  /// 1. URL 파싱
  /// 2. 메타데이터 가져오기
  /// 3. Video 객체 생성 및 저장
  Future<void> _handleAddVideo() async {
    final l10n = AppLocalizations.of(context)!;
    final url = _urlController.text.trim();

    // URL 유효성 검증
    if (url.isEmpty) {
      setState(() {
        _errorMessage = l10n.errorUrlEmpty;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. URL 파싱 (video ID 추출)
      final parseUrlUseCase = ref.read(parseYoutubeUrlProvider);
      final parseResult = await parseUrlUseCase(url);

      final parsedUrl = parseResult.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (parsed) => parsed,
      );

      // 2. 메타데이터 가져오기
      final getMetadataUseCase = ref.read(getVideoMetadataProvider);
      final metadataResult = await getMetadataUseCase(
        GetVideoMetadataParams(videoId: parsedUrl.videoId),
      );

      final metadata = metadataResult.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (meta) => meta,
      );

      // 3. 타임스탬프 파싱
      int timestampSeconds;
      if (parsedUrl.timestampSeconds != null && parsedUrl.timestampSeconds > 0) {
        // URL에 타임스탬프가 포함되어 있으면 우선 사용
        timestampSeconds = parsedUrl.timestampSeconds;
      } else {
        // 사용자가 입력한 타임스탬프 사용
        timestampSeconds = TimestampUtils.parseDuration(_timestampController.text) ?? 0;
      }

      // 4. Video 객체 생성
      final now = DateTime.now();
      final newVideo = Video(
        id: null, // DB에서 자동 생성 (null이어야 함)
        categoryId: widget.categoryId,
        youtubeUrl: url,
        youtubeVideoId: metadata.videoId,
        title: metadata.title,
        description: metadata.description,
        thumbnailUrl: metadata.thumbnailUrl,
        channelName: metadata.channelName,
        durationSeconds: metadata.durationSeconds,
        timestampSeconds: timestampSeconds,
        memo: null,
        createdAt: now,
        updatedAt: now,
      );

      // 5. 콜백 호출
      if (widget.onVideoAdded != null) {
        widget.onVideoAdded!(newVideo);
      }

      // 다이얼로그 닫기
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // 에러 처리
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(e.toString());
      });
    }
  }

  /// [_getErrorMessage] - 에러 메시지 사용자 친화적으로 변환
  String _getErrorMessage(String error) {
    final l10n = AppLocalizations.of(context);

    if (error.contains('유효하지 않은') || error.contains('잘못된') ||
        error.contains('Invalid') || error.contains('invalid')) {
      return l10n.errorUrlInvalid;
    } else if (error.contains('네트워크') || error.contains('인터넷') ||
        error.contains('network') || error.contains('Network')) {
      return l10n.errorNetwork;
    } else if (error.contains('찾을 수 없') || error.contains('not found') ||
        error.contains('Not found')) {
      return l10n.errorVideoNotFound;
    } else {
      return l10n.errorVideoMetadataFailed;
    }
  }
}
