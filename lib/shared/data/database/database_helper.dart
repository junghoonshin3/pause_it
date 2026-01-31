import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../core/constants/database_constants.dart';

/// [DatabaseHelper] - SQLite 데이터베이스 싱글톤 헬퍼
///
/// 주요 기능:
/// - 데이터베이스 초기화 및 스키마 생성
/// - 버전 관리 및 마이그레이션
/// - 전역 데이터베이스 인스턴스 제공
///
/// 사용 예시:
/// ```dart
/// final db = await DatabaseHelper.instance.database;
/// await db.query('categories');
/// ```
class DatabaseHelper {
  // 싱글톤 인스턴스
  static final DatabaseHelper instance = DatabaseHelper._internal();

  // 데이터베이스 인스턴스 (lazy initialization)
  static Database? _database;

  // Private 생성자
  DatabaseHelper._internal();

  /// [database] - 데이터베이스 인스턴스 getter
  ///
  /// Returns: 초기화된 Database 객체
  /// - 첫 호출 시 데이터베이스 생성 및 테이블 스키마 적용
  /// - 이후 호출 시 기존 인스턴스 반환
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  /// [_initDatabase] - 데이터베이스 초기화 (Private)
  ///
  /// Returns: 초기화된 Database 객체
  /// Throws: DatabaseException - 데이터베이스 생성 실패 시
  Future<Database> _initDatabase() async {
    try {
      // 데이터베이스 파일 경로 가져오기
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, DatabaseConstants.databaseName);

      // 데이터베이스 열기 (없으면 생성)
      return await openDatabase(
        path,
        version: DatabaseConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );
    } catch (e) {
      throw Exception('데이터베이스 초기화 실패: $e');
    }
  }

  /// [_onConfigure] - 데이터베이스 설정 (외래키 활성화)
  ///
  /// Parameters:
  /// - [db]: 설정할 데이터베이스 객체
  ///
  /// 주요 설정:
  /// - Foreign Key 제약조건 활성화 (ON DELETE CASCADE 적용)
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// [_onCreate] - 데이터베이스 최초 생성 시 호출
  ///
  /// Parameters:
  /// - [db]: 생성된 데이터베이스 객체
  /// - [version]: 데이터베이스 버전
  ///
  /// 작업 내용:
  /// 1. categories 테이블 생성
  /// 2. videos 테이블 생성
  /// 3. videos 테이블 인덱스 생성
  Future<void> _onCreate(Database db, int version) async {
    // Batch를 사용하여 여러 쿼리를 트랜잭션으로 묶기
    final batch = db.batch();

    // Categories 테이블 생성
    batch.execute(DatabaseConstants.createCategoriesTable);

    // Videos 테이블 생성
    batch.execute(DatabaseConstants.createVideosTable);

    // Videos 인덱스 생성
    batch.execute(DatabaseConstants.createVideosCategoryIdIndex);
    batch.execute(DatabaseConstants.createVideosYoutubeVideoIdIndex);

    // 일괄 실행
    await batch.commit(noResult: true);

    print('✅ 데이터베이스 테이블 생성 완료 (버전: $version)');
  }

  /// [_onUpgrade] - 데이터베이스 버전 업그레이드 시 호출
  ///
  /// Parameters:
  /// - [db]: 업그레이드할 데이터베이스 객체
  /// - [oldVersion]: 이전 버전
  /// - [newVersion]: 새 버전
  ///
  /// 마이그레이션 전략:
  /// - 버전별로 필요한 ALTER TABLE, CREATE INDEX 등 수행
  /// - 기존 데이터 보존을 위해 기본값 할당
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('⚠️ 데이터베이스 업그레이드: $oldVersion -> $newVersion');

    // 버전 1 → 2: Video 테이블에 description, channel_name, duration_seconds 컬럼 추가
    if (oldVersion < 2) {
      final batch = db.batch();

      // 1. description 컬럼 추가 (nullable)
      batch.execute(
        'ALTER TABLE ${DatabaseConstants.tableVideos} '
        'ADD COLUMN ${DatabaseConstants.columnVideoDescription} TEXT'
      );

      // 2. channel_name 컬럼 추가 (NOT NULL, 기본값 필요)
      batch.execute(
        'ALTER TABLE ${DatabaseConstants.tableVideos} '
        'ADD COLUMN ${DatabaseConstants.columnVideoChannelName} TEXT NOT NULL DEFAULT "Unknown Channel"'
      );

      // 3. duration_seconds 컬럼 추가 (NOT NULL, 기본값 0)
      batch.execute(
        'ALTER TABLE ${DatabaseConstants.tableVideos} '
        'ADD COLUMN ${DatabaseConstants.columnVideoDurationSeconds} INTEGER NOT NULL DEFAULT 0'
      );

      await batch.commit(noResult: true);
      print('✅ 버전 2 마이그레이션 완료 (description, channel_name, duration_seconds 컬럼 추가)');
    }
  }

  /// [close] - 데이터베이스 연결 닫기
  ///
  /// 사용 시기:
  /// - 앱 종료 시
  /// - 테스트 완료 후 정리 작업
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('✅ 데이터베이스 연결 종료');
    }
  }

  /// [deleteDatabase] - 데이터베이스 파일 삭제 (개발/테스트용)
  ///
  /// ⚠️ 주의: 모든 데이터가 영구 삭제됩니다!
  ///
  /// 사용 시기:
  /// - 개발 중 스키마 완전 리셋
  /// - 통합 테스트 전후 클린업
  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseConstants.databaseName);

    await close();
    await databaseFactory.deleteDatabase(path);
    print('🗑️ 데이터베이스 삭제 완료: $path');
  }
}
