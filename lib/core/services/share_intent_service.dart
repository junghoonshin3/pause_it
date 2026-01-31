import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// [ShareIntentService] - 공유 인텐트 수신 서비스
///
/// 주요 기능:
/// - receive_sharing_intent 패키지 래핑
/// - 앱 최초 실행 시 공유 데이터 처리
/// - 앱 실행 중 공유 스트림 제공
class ShareIntentService {
  /// 앱 실행 중 공유 텍스트 스트림
  ///
  /// SharedMediaFile의 path를 추출하여 텍스트로 반환
  Stream<String> get sharedTextStream {
    return ReceiveSharingIntent.instance.getMediaStream().map((sharedFiles) {
      if (sharedFiles.isEmpty) return '';

      // 텍스트 타입의 첫 번째 파일 찾기
      final textFile = sharedFiles.firstWhere(
        (file) => file.type == SharedMediaType.text,
        orElse: () => sharedFiles.first,
      );

      return textFile.path;
    });
  }

  /// 앱 최초 실행 시 공유 텍스트 가져오기
  Future<String?> getInitialSharedText() async {
    final sharedFiles = await ReceiveSharingIntent.instance.getInitialMedia();

    if (sharedFiles.isEmpty) return null;

    // 텍스트 타입의 첫 번째 파일 찾기
    final textFile = sharedFiles.firstWhere(
      (file) => file.type == SharedMediaType.text,
      orElse: () => sharedFiles.first,
    );

    return textFile.path;
  }

  /// 공유 인텐트 초기화
  void reset() {
    ReceiveSharingIntent.instance.reset();
  }
}
