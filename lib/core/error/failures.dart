import 'package:equatable/equatable.dart';

/// [Failure] - Domain Layer에서 사용하는 추상 실패 클래스
///
/// 주요 특징:
/// - Data Layer의 Exception을 Domain Layer의 Failure로 변환
/// - UI에서 에러 타입에 따라 다른 메시지 표시 가능
/// - Equatable을 통해 동등성 비교 가능
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// [DatabaseFailure] - 데이터베이스 작업 실패
///
/// 발생 원인:
/// - SQL 쿼리 실패
/// - 제약 조건 위반
/// - 데이터베이스 연결 오류
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// [CacheFailure] - 로컬 캐시 조회 실패
///
/// 발생 원인:
/// - 요청한 데이터 없음
/// - 직렬화/역직렬화 오류
/// - 캐시 데이터 손상
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// [ValidationFailure] - 데이터 유효성 검증 실패
///
/// 발생 원인:
/// - 필수 필드 누락
/// - 잘못된 형식 (URL, 날짜 등)
/// - 허용 범위 초과
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(super.message, [this.fieldErrors]);

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// [NetworkFailure] - 네트워크 요청 실패 (Step 2에서 사용 예정)
///
/// 발생 원인:
/// - 인터넷 연결 없음
/// - API 서버 오류
/// - 타임아웃
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
