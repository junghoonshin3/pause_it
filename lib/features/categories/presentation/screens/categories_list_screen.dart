import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../providers/category_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/add_edit_category_dialog.dart';
import '../widgets/category_selection_dialog.dart';
import '../../../videos/presentation/screens/video_list_screen.dart';
import '../../../videos/presentation/providers/video_provider.dart';

/// [CategoriesListScreen] - 카테고리 목록 메인 화면
///
/// 주요 기능:
/// - 전체 카테고리 목록 표시 (그리드 레이아웃)
/// - 카테고리 추가 FAB
/// - 카테고리 편집/삭제
/// - 빈 화면 상태 처리
/// - 로딩/에러 상태 처리
///
/// 상태 관리: Riverpod (categoryListProvider)
class CategoriesListScreen extends ConsumerWidget {
  const CategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 카테고리 목록 상태 구독
    final categoriesAsync = ref.watch(categoryListProvider);
    final sharedUrlResult = ref.watch(sharedUrlStateProvider);

    // 공유 URL 처리 - 다이얼로그 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sharedUrlResult != null) {
        _showCategorySelectionDialog(context, ref, sharedUrlResult);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pause it'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 새로고침 버튼
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: () {
              ref.read(categoryListProvider.notifier).loadCategories();
            },
          ),
        ],
      ),
      body: categoriesAsync.when(
        // 로딩 상태
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        // 에러 상태
        error: (error, stackTrace) => _buildErrorView(context, error.toString()),

        // 데이터 로드 완료
        data: (categories) {
          if (categories.isEmpty) {
            return _buildEmptyView(context, ref);
          }
          return _buildCategoryGrid(context, ref, categories);
        },
      ),

      // Floating Action Button - 카테고리 추가
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('카테고리 추가'),
      ),
    );
  }

  /// [_buildCategoryGrid] - 카테고리 그리드 뷰 생성
  ///
  /// 반응형 그리드 레이아웃:
  /// - 화면 너비에 따라 열 개수 자동 조절
  /// - 최소 너비: 150px, 최대 너비: 300px
  Widget _buildCategoryGrid(
    BuildContext context,
    WidgetRef ref,
    List<Category> categories,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200, // 카드 최대 너비
        mainAxisExtent: 150, // 카드 높이
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        // 영상 개수 조회
        final videoCountAsync = ref.watch(videoCountProvider(category.id!));

        return videoCountAsync.when(
          // 데이터 로드 완료
          data: (count) => CategoryCard(
            category: category,
            videoCount: count,
            onTap: () => _navigateToVideoList(context, category),
            onEdit: () => _showEditCategoryDialog(context, ref, category),
            onDelete: () => _deleteCategory(context, ref, category),
          ),
          // 로딩 중 - 0개로 표시
          loading: () => CategoryCard(
            category: category,
            videoCount: 0,
            onTap: () => _navigateToVideoList(context, category),
            onEdit: () => _showEditCategoryDialog(context, ref, category),
            onDelete: () => _deleteCategory(context, ref, category),
          ),
          // 에러 발생 - 0개로 표시
          error: (_, __) => CategoryCard(
            category: category,
            videoCount: 0,
            onTap: () => _navigateToVideoList(context, category),
            onEdit: () => _showEditCategoryDialog(context, ref, category),
            onDelete: () => _deleteCategory(context, ref, category),
          ),
        );
      },
    );
  }

  /// [_buildEmptyView] - 빈 화면 상태 (카테고리가 없을 때)
  Widget _buildEmptyView(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '카테고리가 없습니다',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '아래 버튼을 눌러 첫 카테고리를 추가해보세요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showAddCategoryDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('카테고리 추가'),
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

  /// [_showAddCategoryDialog] - 카테고리 추가 다이얼로그 표시
  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddEditCategoryDialog(
        onSave: (name, colorValue) async {
          // 카테고리 추가
          final success = await ref
              .read(categoryListProvider.notifier)
              .addCategory(name, colorValue);

          if (!context.mounted) return;

          // 결과 메시지 표시
          if (success) {
            _showSuccessSnackbar(context, '카테고리가 추가되었습니다.');
          } else {
            _showErrorSnackbar(context, '카테고리 추가에 실패했습니다.');
          }
        },
      ),
    );
  }

  /// [_showEditCategoryDialog] - 카테고리 편집 다이얼로그 표시
  void _showEditCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddEditCategoryDialog(
        category: category,
        onSave: (name, colorValue) async {
          // 업데이트된 카테고리 생성
          final updatedCategory = Category(
            id: category.id,
            name: name,
            colorValue: colorValue,
            createdAt: category.createdAt,
            updatedAt: DateTime.now(),
          );

          // 카테고리 수정
          final success = await ref
              .read(categoryListProvider.notifier)
              .updateCategory(updatedCategory);

          if (!context.mounted) return;

          // 결과 메시지 표시
          if (success) {
            _showSuccessSnackbar(context, '카테고리가 수정되었습니다.');
          } else {
            _showErrorSnackbar(context, '카테고리 수정에 실패했습니다.');
          }
        },
      ),
    );
  }

  /// [_deleteCategory] - 카테고리 삭제
  Future<void> _deleteCategory(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final success =
        await ref.read(categoryListProvider.notifier).deleteCategory(category.id!);

    if (!context.mounted) return;

    if (success) {
      _showSuccessSnackbar(context, '카테고리가 삭제되었습니다.');
    } else {
      _showErrorSnackbar(context, '카테고리 삭제에 실패했습니다.');
    }
  }

  /// [_navigateToVideoList] - 카테고리별 영상 목록 화면으로 이동
  void _navigateToVideoList(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoListScreen(category: category),
      ),
    );
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

  /// [_showCategorySelectionDialog] - 카테고리 선택 다이얼로그 표시
  ///
  /// YouTube 공유로 받은 영상을 어떤 카테고리에 추가할지 선택
  void _showCategorySelectionDialog(
    BuildContext context,
    WidgetRef ref,
    result,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CategorySelectionDialog(
        sharedUrlResult: result,
        onCancel: () {
          ref.read(sharedUrlStateProvider.notifier).state = null;
          Navigator.pop(context);
        },
      ),
    );
  }
}
