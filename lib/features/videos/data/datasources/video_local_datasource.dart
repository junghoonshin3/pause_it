import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/error/exceptions.dart' as app_exceptions;
import '../../../../shared/data/database/database_helper.dart';
import '../models/video_model.dart';

/// [VideoLocalDataSource] - 비디오 타임스탬프 로컬 데이터 소스
///
/// 주요 기능:
/// - SQLite를 사용한 비디오 CRUD 작업
/// - 예외 발생 시 적절한 Exception throw
/// - Parameterized Query를 통한 SQL Injection 방지
///
/// 사용 예시:
/// ```dart
/// final datasource = VideoLocalDataSource();
/// final videos = await datasource.getVideosByCategory(1);
/// ```
class VideoLocalDataSource {
  final DatabaseHelper _databaseHelper;

  VideoLocalDataSource({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  /// [getAllVideos] - 모든 비디오 조회
  ///
  /// Returns: VideoModel 리스트
  /// Throws: DatabaseException - 조회 실패 시
  ///
  /// 정렬: 생성일시 내림차순 (최근 추가 순)
  Future<List<VideoModel>> getAllVideos() async {
    try {
      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tableVideos,
        orderBy: '${DatabaseConstants.columnVideoCreatedAt} DESC',
      );

      return maps.map((map) => VideoModel.fromMap(map)).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException('비디오 목록 조회 실패', e);
    }
  }

  /// [getVideosByCategory] - 특정 카테고리의 비디오 목록 조회
  ///
  /// Parameters:
  /// - [categoryId]: 조회할 카테고리 ID
  ///
  /// Returns: VideoModel 리스트
  /// Throws: DatabaseException - 조회 실패 시
  ///
  /// 정렬: 생성일시 내림차순
  Future<List<VideoModel>> getVideosByCategory(int categoryId) async {
    try {
      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tableVideos,
        where: '${DatabaseConstants.columnVideoCategoryId} = ?',
        whereArgs: [categoryId],
        orderBy: '${DatabaseConstants.columnVideoCreatedAt} DESC',
      );

      return maps.map((map) => VideoModel.fromMap(map)).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException('카테고리 $categoryId의 비디오 목록 조회 실패', e);
    }
  }

  /// [getVideoById] - ID로 특정 비디오 조회
  ///
  /// Parameters:
  /// - [id]: 조회할 비디오 ID
  ///
  /// Returns: VideoModel
  /// Throws:
  /// - CacheException: ID에 해당하는 비디오 없음
  /// - DatabaseException: 조회 실패
  Future<VideoModel> getVideoById(int id) async {
    try {
      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tableVideos,
        where: '${DatabaseConstants.columnVideoId} = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        throw app_exceptions.CacheException('ID $id에 해당하는 비디오를 찾을 수 없습니다.');
      }

      return VideoModel.fromMap(maps.first);
    } catch (e) {
      if (e is app_exceptions.CacheException) rethrow;
      throw app_exceptions.DatabaseException('비디오 조회 실패 (ID: $id)', e);
    }
  }

  /// [insertVideo] - 새 비디오 타임스탬프 생성
  ///
  /// Parameters:
  /// - [video]: 생성할 비디오 (id는 무시됨)
  ///
  /// Returns: 생성된 비디오 (생성된 ID 포함)
  /// Throws:
  /// - ValidationException: 필수 필드 누락
  /// - DatabaseException: 생성 실패 (Foreign Key 위반 등)
  Future<VideoModel> insertVideo(VideoModel video) async {
    try {
      // 유효성 검증
      _validateVideo(video);

      final db = await _databaseHelper.database;

      // 현재 시각으로 생성/수정 시각 설정
      final now = DateTime.now();
      final videoToInsert = video.copyWith(
        createdAt: now,
        updatedAt: now,
      );

      // INSERT 실행
      final id = await db.insert(
        DatabaseConstants.tableVideos,
        videoToInsert.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      // 생성된 비디오 반환 (ID 포함)
      return videoToInsert.copyWith(id: id);
    } catch (e) {
      if (e is app_exceptions.ValidationException) rethrow;
      if (e.toString().contains('FOREIGN KEY constraint failed')) {
        throw app_exceptions.DatabaseException('존재하지 않는 카테고리 ID입니다. (categoryId: ${video.categoryId})', e);
      }
      throw app_exceptions.DatabaseException('비디오 생성 실패', e);
    }
  }

  /// [updateVideo] - 기존 비디오 수정
  ///
  /// Parameters:
  /// - [video]: 수정할 비디오 (id 필수)
  ///
  /// Returns: 수정된 비디오
  /// Throws:
  /// - ValidationException: id가 null이거나 필수 필드 누락
  /// - CacheException: 해당 ID의 비디오 없음
  /// - DatabaseException: 수정 실패
  Future<VideoModel> updateVideo(VideoModel video) async {
    try {
      // 유효성 검증
      if (video.id == null) {
        throw app_exceptions.ValidationException('수정할 비디오의 ID가 필요합니다.');
      }
      _validateVideo(video);

      final db = await _databaseHelper.database;

      // updatedAt을 현재 시각으로 갱신
      final videoToUpdate = video.copyWith(updatedAt: DateTime.now());

      // UPDATE 실행
      final rowsAffected = await db.update(
        DatabaseConstants.tableVideos,
        videoToUpdate.toMap(),
        where: '${DatabaseConstants.columnVideoId} = ?',
        whereArgs: [video.id],
      );

      // 영향받은 행이 없으면 해당 ID가 존재하지 않음
      if (rowsAffected == 0) {
        throw app_exceptions.CacheException('ID ${video.id}에 해당하는 비디오를 찾을 수 없습니다.');
      }

      return videoToUpdate;
    } catch (e) {
      if (e is app_exceptions.ValidationException || e is app_exceptions.CacheException) rethrow;
      if (e.toString().contains('FOREIGN KEY constraint failed')) {
        throw app_exceptions.DatabaseException('존재하지 않는 카테고리 ID입니다. (categoryId: ${video.categoryId})', e);
      }
      throw app_exceptions.DatabaseException('비디오 수정 실패 (ID: ${video.id})', e);
    }
  }

  /// [deleteVideo] - 비디오 삭제
  ///
  /// Parameters:
  /// - [id]: 삭제할 비디오 ID
  ///
  /// Returns: 삭제 성공
  /// Throws:
  /// - CacheException: 해당 ID의 비디오 없음
  /// - DatabaseException: 삭제 실패
  Future<void> deleteVideo(int id) async {
    try {
      final db = await _databaseHelper.database;

      final rowsAffected = await db.delete(
        DatabaseConstants.tableVideos,
        where: '${DatabaseConstants.columnVideoId} = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw app_exceptions.CacheException('ID $id에 해당하는 비디오를 찾을 수 없습니다.');
      }
    } catch (e) {
      if (e is app_exceptions.CacheException) rethrow;
      throw app_exceptions.DatabaseException('비디오 삭제 실패 (ID: $id)', e);
    }
  }

  /// [getVideoCountByCategory] - 특정 카테고리의 비디오 개수 조회
  ///
  /// Parameters:
  /// - [categoryId]: 카테고리 ID
  ///
  /// Returns: 비디오 개수
  /// Throws: DatabaseException - 조회 실패 시
  Future<int> getVideoCountByCategory(int categoryId) async {
    try {
      final db = await _databaseHelper.database;

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseConstants.tableVideos} WHERE ${DatabaseConstants.columnVideoCategoryId} = ?',
        [categoryId],
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw app_exceptions.DatabaseException('카테고리 $categoryId의 비디오 개수 조회 실패', e);
    }
  }

  /// [searchVideos] - 제목/메모로 비디오 검색
  ///
  /// Parameters:
  /// - [query]: 검색어
  ///
  /// Returns: 검색 결과 VideoModel 리스트
  /// Throws: DatabaseException - 검색 실패 시
  ///
  /// 검색 대상: title, memo 필드 (LIKE 쿼리, 대소문자 구분 없음)
  Future<List<VideoModel>> searchVideos(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final db = await _databaseHelper.database;
      final searchPattern = '%${query.trim()}%';

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tableVideos,
        where: '${DatabaseConstants.columnVideoTitle} LIKE ? OR ${DatabaseConstants.columnVideoMemo} LIKE ?',
        whereArgs: [searchPattern, searchPattern],
        orderBy: '${DatabaseConstants.columnVideoCreatedAt} DESC',
      );

      return maps.map((map) => VideoModel.fromMap(map)).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException('비디오 검색 실패 (검색어: $query)', e);
    }
  }

  /// [_validateVideo] - 비디오 유효성 검증 (Private)
  ///
  /// Parameters:
  /// - [video]: 검증할 비디오
  ///
  /// Throws: ValidationException - 유효하지 않은 값이 있을 때
  void _validateVideo(VideoModel video) {
    final errors = <String, String>{};

    if (video.youtubeUrl.trim().isEmpty) {
      errors['youtubeUrl'] = '유튜브 URL은 필수입니다.';
    }

    if (video.youtubeVideoId.trim().isEmpty) {
      errors['youtubeVideoId'] = '유튜브 비디오 ID는 필수입니다.';
    }

    if (video.title.trim().isEmpty) {
      errors['title'] = '제목은 필수입니다.';
    }

    if (video.timestampSeconds < 0) {
      errors['timestampSeconds'] = '타임스탬프는 0 이상이어야 합니다.';
    }

    if (errors.isNotEmpty) {
      throw app_exceptions.ValidationException('비디오 유효성 검증 실패', errors);
    }
  }
}
