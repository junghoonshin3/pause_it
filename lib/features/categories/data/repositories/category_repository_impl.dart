import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

/// [CategoryRepositoryImpl] - CategoryRepository의 구현체
///
/// 주요 기능:
/// - DataSource의 Exception을 Domain Layer의 Failure로 변환
/// - Either<Failure, T> 패턴으로 에러 핸들링
/// - Entity <-> Model 변환
///
/// 사용 예시:
/// ```dart
/// final repository = CategoryRepositoryImpl(datasource);
/// final result = await repository.getAllCategories();
/// result.fold(
///   (failure) => print('에러: ${failure.message}'),
///   (categories) => print('성공: ${categories.length}개'),
/// );
/// ```
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _localDataSource;

  CategoryRepositoryImpl({
    required CategoryLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() async {
    try {
      final categoryModels = await _localDataSource.getAllCategories();
      // Model -> Entity 변환
      final categories = categoryModels.map((model) => model.toEntity()).toList();
      return Right(categories);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('알 수 없는 오류 발생: $e'));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(int id) async {
    try {
      final categoryModel = await _localDataSource.getCategoryById(id);
      return Right(categoryModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('알 수 없는 오류 발생: $e'));
    }
  }

  @override
  Future<Either<Failure, Category>> createCategory(Category category) async {
    try {
      // Entity -> Model 변환
      final categoryModel = CategoryModel.fromEntity(category);

      // 생성 실행
      final createdModel = await _localDataSource.insertCategory(categoryModel);

      return Right(createdModel.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('알 수 없는 오류 발생: $e'));
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory(Category category) async {
    try {
      // Entity -> Model 변환
      final categoryModel = CategoryModel.fromEntity(category);

      // 수정 실행
      final updatedModel = await _localDataSource.updateCategory(categoryModel);

      return Right(updatedModel.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('알 수 없는 오류 발생: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(int id) async {
    try {
      await _localDataSource.deleteCategory(id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('알 수 없는 오류 발생: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getCategoryCount() async {
    try {
      final count = await _localDataSource.getCategoryCount();
      return Right(count);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('알 수 없는 오류 발생: $e'));
    }
  }
}
