import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';

/// [CategoryCard] - 카테고리 카드 위젯
///
/// 주요 기능:
/// - 카테고리 정보 표시 (이름, 색상)
/// - 카테고리별 영상 개수 표시
/// - 탭 시 해당 카테고리의 영상 목록으로 이동
/// - 길게 누르면 편집/삭제 옵션 표시
///
/// Parameters:
/// - [category]: 표시할 카테고리
/// - [videoCount]: 해당 카테고리의 영상 개수
/// - [onTap]: 카드 탭 시 콜백
/// - [onEdit]: 편집 버튼 탭 시 콜백
/// - [onDelete]: 삭제 버튼 탭 시 콜백
class CategoryCard extends StatelessWidget {
  final Category category;
  final int videoCount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    required this.videoCount,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showOptionsBottomSheet(context),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [category.color, category.color.withOpacity(0.7)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 카테고리 아이콘
                Icon(
                  Icons.folder,
                  size: 40,
                  color: _getContrastColor(category.color),
                ),
                const SizedBox(height: 12),

                // 카테고리 이름
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getContrastColor(category.color),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // 영상 개수
                Text(
                  '영상 $videoCount개',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getContrastColor(category.color).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// [_showOptionsBottomSheet] - 편집/삭제 옵션 표시
  ///
  /// 카드를 길게 누르면 하단에서 올라오는 옵션 시트 표시
  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 카테고리 이름 표시
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // 편집 옵션
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

            // 삭제 옵션
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('삭제', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                if (onDelete != null) {
                  _showDeleteConfirmation(context);
                }
              },
            ),

            // 취소 버튼
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

  /// [_showDeleteConfirmation] - 삭제 확인 다이얼로그
  ///
  /// 카테고리 삭제 전 사용자 확인 요청
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카테고리 삭제'),
        content: Text(
          '\'${category.name}\' 카테고리를 삭제하시겠습니까?\n\n'
          '⚠️ 이 카테고리에 포함된 모든 영상도 함께 삭제됩니다.',
        ),
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  /// [_getContrastColor] - 배경색에 대비되는 텍스트 색상 계산
  ///
  /// 배경색이 어두우면 흰색, 밝으면 검은색 반환
  /// Luminance 값을 기준으로 판단
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
