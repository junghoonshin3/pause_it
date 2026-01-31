/// [DatabaseException] - 데이터베이스 작업 중 발생하는 예외
///
/// 사용 시기:
/// - SQL 쿼리 실패
/// - 데이터베이스 연결 오류
/// - 제약 조건 위반 (Foreign Key, Unique 등)
class DatabaseException implements Exception {
  final String message;
  final dynamic originalError;

  const DatabaseException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return 'DatabaseException: $message (원본 오류: $originalError)';
    }
    return 'DatabaseException: $message';
  }
}

/// [CacheException] - 로컬 캐시/데이터 조회 중 발생하는 예외
///
/// 사용 시기:
/// - 요청한 데이터가 존재하지 않음
/// - 캐시 데이터가 손상됨
/// - 직렬화/역직렬화 실패
class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// [ValidationException] - 데이터 유효성 검증 실패 시 발생하는 예외
///
/// 사용 시기:
/// - 필수 필드 누락
/// - 형식이 올바르지 않음 (예: 잘못된 URL)
/// - 허용 범위를 벗어난 값
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  const ValidationException(this.message, [this.fieldErrors]);

  @override
  String toString() {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      final errors = fieldErrors!.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      return 'ValidationException: $message ($errors)';
    }
    return 'ValidationException: $message';
  }
}
