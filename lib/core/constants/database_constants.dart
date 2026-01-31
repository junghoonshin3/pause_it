/// [DatabaseConstants] - 데이터베이스 테이블 및 컬럼명 상수
///
/// 주요 기능:
/// - SQL 쿼리에서 사용할 테이블/컬럼명을 상수로 관리
/// - 오타 방지 및 리팩토링 용이성 제공
class DatabaseConstants {
  // 데이터베이스 정보
  static const String databaseName = 'pause_it.db';
  static const int databaseVersion = 2;

  // ===== Categories 테이블 =====
  static const String tableCategories = 'categories';

  // Categories 컬럼명
  static const String columnCategoryId = 'id';
  static const String columnCategoryName = 'name';
  static const String columnCategoryColorValue = 'color_value';
  static const String columnCategoryCreatedAt = 'created_at';
  static const String columnCategoryUpdatedAt = 'updated_at';

  // Categories 테이블 생성 SQL
  static const String createCategoriesTable = '''
    CREATE TABLE $tableCategories (
      $columnCategoryId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnCategoryName TEXT NOT NULL,
      $columnCategoryColorValue INTEGER,
      $columnCategoryCreatedAt INTEGER NOT NULL,
      $columnCategoryUpdatedAt INTEGER NOT NULL
    )
  ''';

  // ===== Videos 테이블 =====
  static const String tableVideos = 'videos';

  // Videos 컬럼명
  static const String columnVideoId = 'id';
  static const String columnVideoCategoryId = 'category_id';
  static const String columnVideoYoutubeUrl = 'youtube_url';
  static const String columnVideoYoutubeVideoId = 'youtube_video_id';
  static const String columnVideoTitle = 'title';
  static const String columnVideoDescription = 'description';
  static const String columnVideoThumbnailUrl = 'thumbnail_url';
  static const String columnVideoChannelName = 'channel_name';
  static const String columnVideoDurationSeconds = 'duration_seconds';
  static const String columnVideoTimestampSeconds = 'timestamp_seconds';
  static const String columnVideoMemo = 'memo';
  static const String columnVideoCreatedAt = 'created_at';
  static const String columnVideoUpdatedAt = 'updated_at';

  // Videos 테이블 생성 SQL
  static const String createVideosTable = '''
    CREATE TABLE $tableVideos (
      $columnVideoId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnVideoCategoryId INTEGER NOT NULL,
      $columnVideoYoutubeUrl TEXT NOT NULL,
      $columnVideoYoutubeVideoId TEXT NOT NULL,
      $columnVideoTitle TEXT NOT NULL,
      $columnVideoDescription TEXT,
      $columnVideoThumbnailUrl TEXT,
      $columnVideoChannelName TEXT NOT NULL,
      $columnVideoDurationSeconds INTEGER NOT NULL,
      $columnVideoTimestampSeconds INTEGER NOT NULL DEFAULT 0,
      $columnVideoMemo TEXT,
      $columnVideoCreatedAt INTEGER NOT NULL,
      $columnVideoUpdatedAt INTEGER NOT NULL,
      FOREIGN KEY ($columnVideoCategoryId) REFERENCES $tableCategories($columnCategoryId) ON DELETE CASCADE
    )
  ''';

  // Videos 인덱스 생성 SQL
  static const String createVideosCategoryIdIndex = '''
    CREATE INDEX idx_videos_category_id ON $tableVideos($columnVideoCategoryId)
  ''';

  static const String createVideosYoutubeVideoIdIndex = '''
    CREATE INDEX idx_videos_youtube_video_id ON $tableVideos($columnVideoYoutubeVideoId)
  ''';
}
