import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../providers/category_provider.dart';
import '../widgets/category_card_brutalist.dart';
import '../widgets/add_edit_category_dialog.dart';
import '../widgets/category_selection_dialog.dart';
import '../../../videos/presentation/screens/video_list_screen.dart';
import '../../../videos/presentation/providers/video_provider.dart';
import '../../../../core/theme/app_theme.dart';

/// [CategoriesListScreenBrutalist] - Neo-Brutalist 디자인의 카테고리 메인 화면
///
/// 디자인 특징:
/// - 대담한 타이포그래피와 비대칭 레이아웃
/// - 날카로운 기하학적 형태
/// - 강렬한 색상 대비
/// - 레이어드 UI와 강한 그림자
class CategoriesListScreenBrutalist extends ConsumerWidget {
  const CategoriesListScreenBrutalist({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final sharedUrlResult = ref.watch(sharedUrlStateProvider);

    // 공유 URL 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sharedUrlResult != null) {
        _showCategorySelectionDialog(context, ref, sharedUrlResult);
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 커스텀 헤더
            _buildBrutalistHeader(context, ref, categoriesAsync),

            // 메인 콘텐츠
            Expanded(
              child: categoriesAsync.when(
                loading: () => _buildLoadingView(context),
                error: (error, stackTrace) =>
                    _buildErrorView(context, error.toString()),
                data: (categories) {
                  if (categories.isEmpty) {
                    return _buildEmptyView(context, ref);
                  }
                  return _buildCategoryGrid(context, ref, categories);
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
    AsyncValue categoriesAsync,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
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
          // 타이틀 with accent mark
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.accentElectric,
                      AppTheme.accentNeon,
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PAUSE IT',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: 2,
                            height: 0.9,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'TIMESTAMP ARCHIVE',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.accentElectric,
                            letterSpacing: 3,
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
                  ref.read(categoryListProvider.notifier).loadCategories();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 통계 스트립
          categoriesAsync.when(
            data: (categories) => _buildStatsStrip(context, categories.length),
            loading: () => _buildStatsStrip(context, 0),
            error: (_, __) => _buildStatsStrip(context, 0),
          ),
        ],
      ),
    );
  }

  /// [_buildStatsStrip] - 통계 정보 스트립
  Widget _buildStatsStrip(BuildContext context, int categoryCount) {
    return Row(
      children: [
        _buildStatBox(
          context: context,
          label: 'CATEGORIES',
          value: '$categoryCount',
          color: AppTheme.accentElectric,
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          context: context,
          label: 'SYSTEM',
          value: 'ACTIVE',
          color: AppTheme.accentNeon,
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
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  /// [_buildCategoryGrid] - 카테고리 그리드
  Widget _buildCategoryGrid(
    BuildContext context,
    WidgetRef ref,
    List<Category> categories,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisExtent: 200,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final videoCountAsync = ref.watch(videoCountProvider(category.id!));

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(
            milliseconds: 300 + (index * 50),
          ),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: videoCountAsync.when(
            data: (count) => CategoryCardBrutalist(
              category: category,
              videoCount: count,
              onTap: () => _navigateToVideoList(context, category),
              onEdit: () => _showEditCategoryDialog(context, ref, category),
              onDelete: () => _deleteCategory(context, ref, category),
            ),
            loading: () => CategoryCardBrutalist(
              category: category,
              videoCount: 0,
              onTap: () => _navigateToVideoList(context, category),
              onEdit: () => _showEditCategoryDialog(context, ref, category),
              onDelete: () => _deleteCategory(context, ref, category),
            ),
            error: (_, __) => CategoryCardBrutalist(
              category: category,
              videoCount: 0,
              onTap: () => _navigateToVideoList(context, category),
              onEdit: () => _showEditCategoryDialog(context, ref, category),
              onDelete: () => _deleteCategory(context, ref, category),
            ),
          ),
        );
      },
    );
  }

  /// [_buildEmptyView] - 빈 화면
  Widget _buildEmptyView(BuildContext context, WidgetRef ref) {
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
                  color: AppTheme.accentElectric,
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
              child: const Icon(
                Icons.folder_open,
                size: 70,
                color: AppTheme.accentElectric,
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'NO CATEGORIES',
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
                '카테고리를 추가하여\n유튜브 영상을 관리하세요',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            _buildCTAButton(
              context: context,
              label: 'ADD CATEGORY',
              icon: Icons.add,
              onPressed: () => _showAddCategoryDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  /// [_buildLoadingView] - 로딩 화면
  Widget _buildLoadingView(BuildContext context) {
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
            'LOADING...',
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
              'ERROR',
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

  /// [_buildCTAButton] - Call-to-Action 버튼
  Widget _buildCTAButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            Icon(icon, color: AppTheme.primaryDark, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
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

  /// [_buildBrutalistFAB] - Brutalist FAB
  Widget _buildBrutalistFAB(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _showAddCategoryDialog(context, ref),
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
              'ADD',
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

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddEditCategoryDialog(
        onSave: (name, colorValue) async {
          final success = await ref
              .read(categoryListProvider.notifier)
              .addCategory(name, colorValue);

          if (!context.mounted) return;

          if (success) {
            _showBrutalistSnackbar(
              context,
              'CATEGORY ADDED',
              AppTheme.success,
              Icons.check_circle,
            );
          } else {
            _showBrutalistSnackbar(
              context,
              'FAILED TO ADD',
              AppTheme.error,
              Icons.error,
            );
          }
        },
      ),
    );
  }

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
          final updatedCategory = Category(
            id: category.id,
            name: name,
            colorValue: colorValue,
            createdAt: category.createdAt,
            updatedAt: DateTime.now(),
          );

          final success = await ref
              .read(categoryListProvider.notifier)
              .updateCategory(updatedCategory);

          if (!context.mounted) return;

          if (success) {
            _showBrutalistSnackbar(
              context,
              'CATEGORY UPDATED',
              AppTheme.success,
              Icons.check_circle,
            );
          } else {
            _showBrutalistSnackbar(
              context,
              'FAILED TO UPDATE',
              AppTheme.error,
              Icons.error,
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteCategory(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final success =
        await ref.read(categoryListProvider.notifier).deleteCategory(category.id!);

    if (!context.mounted) return;

    if (success) {
      _showBrutalistSnackbar(
        context,
        'CATEGORY DELETED',
        AppTheme.success,
        Icons.check_circle,
      );
    } else {
      _showBrutalistSnackbar(
        context,
        'FAILED TO DELETE',
        AppTheme.error,
        Icons.error,
      );
    }
  }

  void _navigateToVideoList(BuildContext context, Category category) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            VideoListScreen(category: category),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: AppTheme.animationDurationNormal,
      ),
    );
  }

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
