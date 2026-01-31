import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/error/exceptions.dart' as app_exceptions;
import '../../../../shared/data/database/database_helper.dart';
import '../models/category_model.dart';

/// [CategoryLocalDataSource] - 카테고리 로컬 데이터 소스
///
/// 주요 기능:
/// - SQLite를 사용한 카테고리 CRUD 작업
/// - 예외 발생 시 적절한 Exception throw
/// - Parameterized Query를 통한 SQL Injection 방지
///
/// 사용 예시:
/// ```dart
/// final datasource = CategoryLocalDataSource();
/// final categories = await datasource.getAllCategories();
/// ```
class CategoryLocalDataSource {
  final DatabaseHelper _databaseHelper;

  CategoryLocalDataSource({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  /// [getAllCategories] - 모든 카테고리 조회
  ///
  /// Returns: CategoryModel 리스트
  /// Throws: DatabaseException - 조회 실패 시
  ///
  /// 정렬: 생성일시 내림차순 (최근 생성 순)
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tableCategories,
        orderBy: '${DatabaseConstants.columnCategoryCreatedAt} DESC',
      );

      return maps.map((map) => CategoryModel.fromMap(map)).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException('카테고리 목록 조회 실패', e);
    }
  }

  /// [getCategoryById] - ID로 특정 카테고리 조회
  ///
  /// Parameters:
  /// - [id]: 조회할 카테고리 ID
  ///
  /// Returns: CategoryModel
  /// Throws:
  /// - CacheException: ID에 해당하는 카테고리 없음
  /// - DatabaseException: 조회 실패
  Future<CategoryModel> getCategoryById(int id) async {
    try {
      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tableCategories,
        where: '${DatabaseConstants.columnCategoryId} = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        throw app_exceptions.CacheException('ID $id에 해당하는 카테고리를 찾을 수 없습니다.');
      }

      return CategoryModel.fromMap(maps.first);
    } catch (e) {
      if (e is app_exceptions.CacheException) rethrow;
      throw app_exceptions.DatabaseException('카테고리 조회 실패 (ID: $id)', e);
    }
  }

  /// [insertCategory] - 새 카테고리 생성
  ///
  /// Parameters:
  /// - [category]: 생성할 카테고리 (id는 무시됨)
  ///
  /// Returns: 생성된 카테고리 (생성된 ID 포함)
  /// Throws:
  /// - ValidationException: 필수 필드 누락
  /// - DatabaseException: 생성 실패
  Future<CategoryModel> insertCategory(CategoryModel category) async {
    try {
      // 유효성 검증
      if (category.name.trim().isEmpty) {
        throw app_exceptions.ValidationException('카테고리 이름은 필수입니다.');
      }

      final db = await _databaseHelper.database;

      // 현재 시각으로 생성/수정 시각 설정
      final now = DateTime.now();
      final categoryToInsert = category.copyWith(
        createdAt: now,
        updatedAt: now,
      );

      // INSERT 실행
      final id = await db.insert(
        DatabaseConstants.tableCategories,
        categoryToInsert.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      // 생성된 카테고리 반환 (ID 포함)
      return categoryToInsert.copyWith(id: id);
    } catch (e) {
      if (e is app_exceptions.ValidationException) rethrow;
      throw app_exceptions.DatabaseException('카테고리 생성 실패', e);
    }
  }

  /// [updateCategory] - 기존 카테고리 수정
  ///
  /// Parameters:
  /// - [category]: 수정할 카테고리 (id 필수)
  ///
  /// Returns: 수정된 카테고리
  /// Throws:
  /// - ValidationException: id가 null이거나 필수 필드 누락
  /// - CacheException: 해당 ID의 카테고리 없음
  /// - DatabaseException: 수정 실패
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      // 유효성 검증
      if (category.id == null) {
        throw app_exceptions.ValidationException('수정할 카테고리의 ID가 필요합니다.');
      }

      if (category.name.trim().isEmpty) {
        throw app_exceptions.ValidationException('카테고리 이름은 필수입니다.');
      }

      final db = await _databaseHelper.database;

      // updatedAt을 현재 시각으로 갱신
      final categoryToUpdate = category.copyWith(updatedAt: DateTime.now());

      // UPDATE 실행
      final rowsAffected = await db.update(
        DatabaseConstants.tableCategories,
        categoryToUpdate.toMap(),
        where: '${DatabaseConstants.columnCategoryId} = ?',
        whereArgs: [category.id],
      );

      // 영향받은 행이 없으면 해당 ID가 존재하지 않음
      if (rowsAffected == 0) {
        throw app_exceptions.CacheException('ID ${category.id}에 해당하는 카테고리를 찾을 수 없습니다.');
      }

      return categoryToUpdate;
    } catch (e) {
      if (e is app_exceptions.ValidationException || e is app_exceptions.CacheException) rethrow;
      throw app_exceptions.DatabaseException('카테고리 수정 실패 (ID: ${category.id})', e);
    }
  }

  /// [deleteCategory] - 카테고리 삭제
  ///
  /// Parameters:
  /// - [id]: 삭제할 카테고리 ID
  ///
  /// Returns: 삭제 성공 시 true
  /// Throws:
  /// - CacheException: 해당 ID의 카테고리 없음
  /// - DatabaseException: 삭제 실패
  ///
  /// ⚠️ 주의: ON DELETE CASCADE로 연결된 videos도 함께 삭제됨
  Future<void> deleteCategory(int id) async {
    try {
      final db = await _databaseHelper.database;

      final rowsAffected = await db.delete(
        DatabaseConstants.tableCategories,
        where: '${DatabaseConstants.columnCategoryId} = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw app_exceptions.CacheException('ID $id에 해당하는 카테고리를 찾을 수 없습니다.');
      }
    } catch (e) {
      if (e is app_exceptions.CacheException) rethrow;
      throw app_exceptions.DatabaseException('카테고리 삭제 실패 (ID: $id)', e);
    }
  }

  /// [getCategoryCount] - 전체 카테고리 개수 조회
  ///
  /// Returns: 카테고리 개수
  /// Throws: DatabaseException - 조회 실패 시
  Future<int> getCategoryCount() async {
    try {
      final db = await _databaseHelper.database;

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseConstants.tableCategories}',
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw app_exceptions.DatabaseException('카테고리 개수 조회 실패', e);
    }
  }
}
