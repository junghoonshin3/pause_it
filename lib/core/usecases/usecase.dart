import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// [UseCase] - 추상 Use Case 베이스 클래스
///
/// 주요 특징:
/// - 단일 책임 원칙: 하나의 Use Case는 하나의 비즈니스 로직만 담당
/// - Either<Failure, T> 패턴으로 에러 핸들링
/// - 재사용 가능한 비즈니스 로직 캡슐화
///
/// Type Parameters:
/// - [Type]: 반환 타입
/// - [Params]: 입력 파라미터 타입
///
/// 사용 예시:
/// ```dart
/// class GetVideoMetadata extends UseCase<YouTubeMetadata, String> {
///   @override
///   Future<Either<Failure, YouTubeMetadata>> call(String videoId) async {
///     // 구현
///   }
/// }
/// ```
abstract class UseCase<Type, Params> {
  /// [call] - Use Case 실행
  ///
  /// Parameters:
  /// - [params]: Use Case에 필요한 입력 파라미터
  ///
  /// Returns:
  /// - Left(Failure): 실패
  /// - Right(Type): 성공
  Future<Either<Failure, Type>> call(Params params);
}

/// [NoParams] - 파라미터가 필요 없는 Use Case용 클래스
///
/// 사용 예시:
/// ```dart
/// class GetAllCategories extends UseCase<List<Category>, NoParams> {
///   @override
///   Future<Either<Failure, List<Category>>> call(NoParams params) async {
///     // 구현
///   }
/// }
/// ```
class NoParams {
  const NoParams();
}
