import '../../domain/entities/category.dart';

/// [CategoryModel] - Category 엔티티의 Data Layer 모델
///
/// 주요 기능:
/// - SQLite Map <-> Category Entity 변환
/// - JSON 직렬화/역직렬화 (향후 API 연동 시 사용)
/// - Domain Layer와 Data Layer 간 데이터 변환 담당
///
/// 사용 예시:
/// ```dart
/// // DB에서 읽기
/// final map = await db.query('categories', where: 'id = ?', whereArgs: [1]);
/// final category = CategoryModel.fromMap(map.first);
///
/// // DB에 쓰기
/// final model = CategoryModel.fromEntity(category);
/// await db.insert('categories', model.toMap());
/// ```
class CategoryModel extends Category {
  const CategoryModel({
    super.id,
    required super.name,
    super.colorValue,
    required super.createdAt,
    required super.updatedAt,
  });

  /// [fromEntity] - Domain Entity를 Model로 변환
  ///
  /// Parameters:
  /// - [category]: 변환할 Category 엔티티
  ///
  /// Returns: CategoryModel 객체
  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      colorValue: category.colorValue,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }

  /// [fromMap] - SQLite Map을 CategoryModel로 변환
  ///
  /// Parameters:
  /// - [map]: SQLite 쿼리 결과 맵
  ///
  /// Returns: CategoryModel 객체
  ///
  /// Map 구조:
  /// ```dart
  /// {
  ///   'id': 1,
  ///   'name': '개발 강의',
  ///   'color_value': 0xFF2196F3,
  ///   'created_at': 1704067200000,
  ///   'updated_at': 1704067200000,
  /// }
  /// ```
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      colorValue: map['color_value'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// [toMap] - CategoryModel을 SQLite Map으로 변환
  ///
  /// Returns: SQLite INSERT/UPDATE용 맵
  ///
  /// 주의사항:
  /// - id가 null인 경우 맵에 포함하지 않음 (Auto Increment)
  /// - DateTime은 millisecondsSinceEpoch로 변환 (Unix timestamp)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'color_value': colorValue,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };

    // id가 있는 경우에만 추가 (UPDATE 시)
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  /// [toEntity] - Model을 Domain Entity로 변환
  ///
  /// Returns: Category 엔티티
  ///
  /// 사용 시기:
  /// - Data Layer에서 조회한 데이터를 Domain Layer로 전달 시
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      colorValue: colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// [copyWith] - 일부 속성만 변경한 새 모델 생성
  @override
  CategoryModel copyWith({
    int? id,
    String? name,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, colorValue: $colorValue, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
