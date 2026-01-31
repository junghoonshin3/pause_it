import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// [Category] - 카테고리 도메인 엔티티
///
/// 주요 특징:
/// - UI와 독립적인 비즈니스 로직 표현
/// - Equatable을 통한 객체 비교 (테스트/캐싱에 유용)
/// - Immutable 객체 (모든 필드 final)
///
/// 사용 예시:
/// ```dart
/// final category = Category(
///   id: 1,
///   name: '개발 강의',
///   colorValue: Colors.blue.value,
///   createdAt: DateTime.now(),
///   updatedAt: DateTime.now(),
/// );
/// ```
class Category extends Equatable {
  /// 카테고리 ID (Primary Key, Auto Increment)
  final int? id;

  /// 카테고리 이름 (예: "개발 강의", "요리", "운동")
  final String name;

  /// Material Color 값 (0xFFRRGGBB 형식)
  /// - 예: Colors.blue.value = 0xFF2196F3
  /// - null인 경우 기본 색상 사용
  final int? colorValue;

  /// 생성 일시
  final DateTime createdAt;

  /// 마지막 수정 일시
  final DateTime updatedAt;

  const Category({
    this.id,
    required this.name,
    this.colorValue,
    required this.createdAt,
    required this.updatedAt,
  });

  /// [color] - Material Color 객체 반환
  ///
  /// Returns:
  /// - colorValue가 있으면 Color 객체로 변환
  /// - null이면 기본 색상 (Colors.grey) 반환
  Color get color {
    if (colorValue != null) {
      return Color(colorValue!);
    }
    return Colors.grey;
  }

  /// [copyWith] - 일부 속성만 변경한 새 객체 생성
  ///
  /// Parameters: 변경하고 싶은 필드만 전달
  /// Returns: 변경된 새 Category 객체
  ///
  /// 사용 예시:
  /// ```dart
  /// final updated = category.copyWith(name: '새 이름');
  /// ```
  Category copyWith({
    int? id,
    String? name,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// [props] - Equatable 동등성 비교에 사용할 속성 목록
  ///
  /// 동작:
  /// - 모든 필드가 같으면 두 객체를 동일하다고 판단
  /// - 테스트 및 상태 관리에서 객체 비교 시 유용
  @override
  List<Object?> get props => [id, name, colorValue, createdAt, updatedAt];

  @override
  String toString() {
    return 'Category(id: $id, name: $name, colorValue: $colorValue, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
