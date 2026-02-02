import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// [AddEditCategoryDialog] - 카테고리 추가/편집 다이얼로그
///
/// 주요 기능:
/// - 카테고리 이름 입력
/// - 색상 선택 (Material Design 색상 팔레트)
/// - 추가/수정 모드 자동 전환
///
/// Parameters:
/// - [category]: 편집 모드인 경우 기존 카테고리 (null이면 추가 모드)
/// - [onSave]: 저장 버튼 클릭 시 콜백 (name, colorValue 전달)
///
/// 사용 예시:
/// ```dart
/// // 추가 모드
/// showDialog(
///   context: context,
///   builder: (context) => AddEditCategoryDialog(
///     onSave: (name, colorValue) {
///       // 카테고리 추가 로직
///     },
///   ),
/// );
///
/// // 편집 모드
/// showDialog(
///   context: context,
///   builder: (context) => AddEditCategoryDialog(
///     category: existingCategory,
///     onSave: (name, colorValue) {
///       // 카테고리 수정 로직
///     },
///   ),
/// );
/// ```
class AddEditCategoryDialog extends StatefulWidget {
  final Category? category;
  final Function(String name, int colorValue) onSave;

  const AddEditCategoryDialog({
    super.key,
    this.category,
    required this.onSave,
  });

  @override
  State<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends State<AddEditCategoryDialog> {
  late TextEditingController _nameController;
  late int _selectedColorValue;

  /// 카테고리 색상 팔레트 (Material Design Colors)
  static final List<Color> _colorPalette = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();

    // 편집 모드인 경우 기존 값으로 초기화
    _nameController = TextEditingController(
      text: widget.category?.name ?? '',
    );
    _selectedColorValue = widget.category?.colorValue ?? Colors.blue.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// [_isAddMode] - 추가 모드인지 확인
  bool get _isAddMode => widget.category == null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(_isAddMode ? l10n.categoryAddTitle : l10n.categoryEditTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 이름 입력
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.categoryNameLabel,
                hintText: l10n.categoryNameHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.label),
              ),
              maxLength: 50,
              autofocus: true,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),

            // 색상 선택 섹션
            Text(
              l10n.categoryColorLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),

            // 색상 팔레트 그리드
            _buildColorPalette(),
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
          child: Text(_isAddMode ? l10n.commonButtonAdd : l10n.commonButtonSave),
        ),
      ],
    );
  }

  /// [_buildColorPalette] - 색상 선택 그리드 생성
  Widget _buildColorPalette() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _colorPalette.map((color) {
        final isSelected = color.value == _selectedColorValue;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColorValue = color.value;
            });
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: _getContrastColor(color),
                    size: 28,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  /// [_handleSave] - 저장 버튼 처리
  ///
  /// 유효성 검증 후 onSave 콜백 호출
  void _handleSave() {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();

    // 유효성 검증
    if (name.isEmpty) {
      _showErrorSnackbar(l10n.categoryErrorEmpty);
      return;
    }

    if (name.length < 2) {
      _showErrorSnackbar(l10n.categoryErrorMinLength);
      return;
    }

    // 저장 콜백 호출
    widget.onSave(name, _selectedColorValue);

    // 다이얼로그 닫기
    Navigator.pop(context);
  }

  /// [_showErrorSnackbar] - 에러 메시지 표시
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// [_getContrastColor] - 배경색에 대비되는 색상 반환
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
