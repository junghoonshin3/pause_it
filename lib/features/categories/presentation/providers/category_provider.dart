import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

/// [categoryLocalDataSourceProvider] - 카테고리 로컬 데이터소스 Provider
///
/// CategoryLocalDataSource의 싱글톤 인스턴스 제공
final categoryLocalDataSourceProvider = Provider<CategoryLocalDataSource>((
  ref,
) {
  return CategoryLocalDataSource();
});

/// [categoryRepositoryProvider] - 카테고리 저장소 Provider
///
/// CategoryRepository 인터페이스의 구현체 제공
/// 의존성 주입을 통해 데이터소스 연결
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dataSource = ref.watch(categoryLocalDataSourceProvider);
  return CategoryRepositoryImpl(localDataSource: dataSource);
});

/// [categoryListProvider] - 카테고리 목록 상태 Provider
///
/// 주요 기능:
/// - 전체 카테고리 목록 관리
/// - 카테고리 추가/수정/삭제
/// - 자동 목록 갱신
///
/// 사용 예시:
/// ```dart
/// // 카테고리 목록 읽기
/// final categories = ref.watch(categoryListProvider);
///
/// // 카테고리 추가
/// ref.read(categoryListProvider.notifier).addCategory(name, color);
/// ```
final categoryListProvider =
    StateNotifierProvider<CategoryListNotifier, AsyncValue<List<Category>>>((
      ref,
    ) {
      final repository = ref.watch(categoryRepositoryProvider);
      return CategoryListNotifier(repository);
    });

/// [CategoryListNotifier] - 카테고리 목록 상태 관리 클래스
///
/// StateNotifier를 상속하여 불변 상태 관리
/// AsyncValue로 로딩/에러 상태 표현
class CategoryListNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryRepository _repository;

  /// 생성자
  ///
  /// 초기 상태는 로딩 상태로 설정하고,
  /// 자동으로 카테고리 목록을 로드
  CategoryListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  /// [loadCategories] - 카테고리 목록 불러오기
  ///
  /// 데이터베이스에서 전체 카테고리를 조회하여 상태 업데이트
  /// 에러 발생 시 AsyncValue.error로 상태 변경
  Future<void> loadCategories() async {
    state = const AsyncValue.loading();

    final result = await _repository.getAllCategories();

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (categories) {
        state = AsyncValue.data(categories);
      },
    );
  }

  /// [addCategory] - 카테고리 추가
  ///
  /// Parameters:
  /// - [name]: 카테고리 이름
  /// - [colorValue]: 색상 값 (Color.value)
  ///
  /// Returns: 추가 성공 여부 (true/false)
  ///
  /// 추가 성공 시 자동으로 목록 재로드
  Future<bool> addCategory(String name, int colorValue) async {
    try {
      // 현재 시각
      final now = DateTime.now();

      // 임시 카테고리 객체 생성 (ID는 DB에서 자동 할당)
      final newCategory = Category(
        id: null, // DB에서 자동 생성
        name: name,
        colorValue: colorValue,
        createdAt: now,
        updatedAt: now,
      );

      // 저장소에 추가
      final result = await _repository.createCategory(newCategory);

      return result.fold(
        (failure) {
          // 실패 시 false 반환
          return false;
        },
        (category) {
          // 성공 시 목록 재로드
          loadCategories();
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  /// [updateCategory] - 카테고리 수정
  ///
  /// Parameters:
  /// - [category]: 수정할 카테고리 (ID 포함)
  ///
  /// Returns: 수정 성공 여부
  ///
  /// updatedAt 필드는 자동으로 현재 시각으로 업데이트
  Future<bool> updateCategory(Category category) async {
    try {
      // updatedAt 업데이트
      final updatedCategory = Category(
        id: category.id,
        name: category.name,
        colorValue: category.colorValue,
        createdAt: category.createdAt,
        updatedAt: DateTime.now(),
      );

      final result = await _repository.updateCategory(updatedCategory);

      return result.fold((failure) => false, (updatedCategory) {
        loadCategories();
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  /// [deleteCategory] - 카테고리 삭제
  ///
  /// Parameters:
  /// - [categoryId]: 삭제할 카테고리 ID
  ///
  /// Returns: 삭제 성공 여부
  ///
  /// ⚠️ 주의: 해당 카테고리의 영상들도 함께 삭제될 수 있음
  /// (DB 스키마에 따라 다름, 추후 CASCADE 설정 확인 필요)
  Future<bool> deleteCategory(int categoryId) async {
    try {
      final result = await _repository.deleteCategory(categoryId);

      return result.fold((failure) => false, (_) {
        loadCategories();
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  /// [getCategoryById] - ID로 특정 카테고리 조회
  ///
  /// Parameters:
  /// - [categoryId]: 조회할 카테고리 ID
  ///
  /// Returns: 카테고리 객체 또는 null
  Future<Category?> getCategoryById(int categoryId) async {
    final result = await _repository.getCategoryById(categoryId);

    return result.fold((failure) => null, (category) => category);
  }
}
