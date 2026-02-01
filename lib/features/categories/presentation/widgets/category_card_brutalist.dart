import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import '../../../../core/theme/app_theme.dart';

/// [CategoryCardBrutalist] - Neo-Brutalist 스타일 카테고리 카드
///
/// 디자인 특징:
/// - 날카로운 직각 모서리와 두꺼운 보더
/// - 대담한 타이포그래피와 기하학적 형태
/// - 강한 드롭섀도우와 레이어 효과
/// - 비대칭 레이아웃
///
/// Parameters:
/// - [category]: 표시할 카테고리
/// - [videoCount]: 해당 카테고리의 영상 개수
/// - [onTap]: 카드 탭 시 콜백
/// - [onEdit]: 편집 버튼 탭 시 콜백
/// - [onDelete]: 삭제 버튼 탭 시 콜백
class CategoryCardBrutalist extends StatefulWidget {
  final Category category;
  final int videoCount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoryCardBrutalist({
    super.key,
    required this.category,
    required this.videoCount,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<CategoryCardBrutalist> createState() => _CategoryCardBrutalistState();
}

class _CategoryCardBrutalistState extends State<CategoryCardBrutalist>
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
                color: widget.category.color,
                border: Border.all(
                  color: AppTheme.primaryDark,
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
              child: Stack(
                children: [
                  // 그리드 패턴 배경 (Brutalist 텍스처)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: GridPatternPainter(
                        color: _getContrastColor(widget.category.color)
                            .withValues(alpha: 0.08),
                      ),
                    ),
                  ),

                  // 메인 콘텐츠
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 상단: 비디오 카운트 배지
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryDark,
                                border: Border.all(
                                  color: _getContrastColor(widget.category.color),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                '${widget.videoCount}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color:
                                          _getContrastColor(widget.category.color),
                                      fontFamily: AppTheme.fontFamilyMono,
                                    ),
                              ),
                            ),
                            // 펄스 애니메이션 인디케이터
                            if (widget.videoCount > 0)
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentElectric,
                                  border: Border.all(
                                    color: AppTheme.primaryDark,
                                    width: 2,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 중앙: 카테고리 아이콘 (큰 기하학적 형태)
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDark,
                            border: Border.all(
                              color: _getContrastColor(widget.category.color),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.folder,
                            size: 28,
                            color: _getContrastColor(widget.category.color),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 하단: 카테고리 이름 (대담한 타이포그래피)
                        Text(
                          widget.category.name.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: _getContrastColor(widget.category.color),
                                    letterSpacing: 0.5,
                                    height: 1.1,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // 보조 텍스트
                        Text(
                          'VIDEOS',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: _getContrastColor(widget.category.color)
                                    .withValues(alpha: 0.6),
                                letterSpacing: 2,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // 코너 장식 (우상단)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 0,
                      height: 0,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: _getContrastColor(widget.category.color)
                                .withValues(alpha: 0.3),
                            width: 30,
                          ),
                          right: BorderSide(
                            color: _getContrastColor(widget.category.color)
                                .withValues(alpha: 0.3),
                            width: 30,
                          ),
                        ),
                      ),
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

  /// [_showOptionsBottomSheet] - 편집/삭제 옵션 표시
  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark,
          border: const Border(
            top: BorderSide(color: AppTheme.accentElectric, width: 4),
            left: BorderSide(color: AppTheme.accentElectric, width: 4),
            right: BorderSide(color: AppTheme.accentElectric, width: 4),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
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
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.category.color,
                        border: Border.all(
                          color: AppTheme.primaryDark,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.folder,
                        color: _getContrastColor(widget.category.color),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category.name.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${widget.videoCount} VIDEOS',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                  letterSpacing: 1,
                                ),
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
                color: AppTheme.accentElectric,
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
                  if (widget.onDelete != null) _showDeleteConfirmation(context);
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
                    'DELETE CATEGORY',
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
                '\'${widget.category.name}\' 카테고리를 삭제하시겠습니까?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  border: Border.all(
                    color: AppTheme.accentNeon.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: AppTheme.accentNeon,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '이 카테고리에 포함된 모든 영상도 함께 삭제됩니다.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.accentNeon,
                            ),
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
                      label: 'CANCEL',
                      color: AppTheme.textSecondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDialogButton(
                      context: context,
                      label: 'DELETE',
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

  /// [_getContrastColor] - 배경색에 대비되는 색상 반환
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? AppTheme.primaryDark : AppTheme.textPrimary;
  }
}

/// [GridPatternPainter] - 그리드 패턴 페인터 (Brutalist 텍스처)
class GridPatternPainter extends CustomPainter {
  final Color color;

  GridPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;

    // 수직선
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // 수평선
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPatternPainter oldDelegate) => color != oldDelegate.color;
}
