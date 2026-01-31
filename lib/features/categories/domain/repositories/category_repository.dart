import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';

/// [CategoryRepository] - 카테고리 저장소 추상 인터페이스
///
/// 주요 특징:
/// - Domain Layer와 Data Layer 간 경계 정의
/// - Either<Failure, T> 패턴으로 에러 핸들링
/// - 구현체는 Data Layer에서 제공 (Dependency Inversion)
///
/// 구현체: lib/features/categories/data/repositories/category_repository_impl.dart
abstract class CategoryRepository {
  /// [getAllCategories] - 모든 카테고리 조회
  ///
  /// Returns:
  /// - Left(Failure): 조회 실패 (DatabaseFailure, CacheFailure 등)
  /// - Right(List<Category>): 성공 (빈 리스트 가능)
  ///
  /// 정렬: 생성일시 내림차순 (최근 생성 순)
  Future<Either<Failure, List<Category>>> getAllCategories();

  /// [getCategoryById] - ID로 특정 카테고리 조회
  ///
  /// Parameters:
  /// - [id]: 조회할 카테고리 ID
  ///
  /// Returns:
  /// - Left(CacheFailure): ID에 해당하는 카테고리 없음
  /// - Left(DatabaseFailure): DB 오류
  /// - Right(Category): 조회 성공
  Future<Either<Failure, Category>> getCategoryById(int id);

  /// [createCategory] - 새 카테고리 생성
  ///
  /// Parameters:
  /// - [category]: 생성할 카테고리 (id는 무시되고 자동 생성됨)
  ///
  /// Returns:
  /// - Left(ValidationFailure): 필수 필드 누락 (name 등)
  /// - Left(DatabaseFailure): 생성 실패
  /// - Right(Category): 생성된 카테고리 (id 포함)
  Future<Either<Failure, Category>> createCategory(Category category);

  /// [updateCategory] - 기존 카테고리 수정
  ///
  /// Parameters:
  /// - [category]: 수정할 카테고리 (id 필수)
  ///
  /// Returns:
  /// - Left(ValidationFailure): id가 null이거나 필수 필드 누락
  /// - Left(CacheFailure): 해당 ID의 카테고리 없음
  /// - Left(DatabaseFailure): 수정 실패
  /// - Right(Category): 수정된 카테고리
  ///
  /// 동작:
  /// - updatedAt은 자동으로 현재 시각으로 갱신
  Future<Either<Failure, Category>> updateCategory(Category category);

  /// [deleteCategory] - 카테고리 삭제
  ///
  /// Parameters:
  /// - [id]: 삭제할 카테고리 ID
  ///
  /// Returns:
  /// - Left(CacheFailure): 해당 ID의 카테고리 없음
  /// - Left(DatabaseFailure): 삭제 실패
  /// - Right(Unit): 삭제 성공
  ///
  /// ⚠️ 주의:
  /// - ON DELETE CASCADE 적용으로 연결된 videos도 함께 삭제됨
  Future<Either<Failure, Unit>> deleteCategory(int id);

  /// [getCategoryCount] - 전체 카테고리 개수 조회
  ///
  /// Returns:
  /// - Left(DatabaseFailure): 조회 실패
  /// - Right(int): 카테고리 개수
  Future<Either<Failure, int>> getCategoryCount();
}
