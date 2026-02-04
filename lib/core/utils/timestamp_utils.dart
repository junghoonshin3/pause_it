/// [TimestampUtils] - 타임스탬프 파싱 및 포맷팅 유틸리티
///
/// 주요 기능:
/// - 사용자 입력 문자열을 초 단위로 변환 (parseDuration)
/// - 초 단위를 표준 시간 문자열로 변환 (formatDuration)
///
/// 지원 파싱 형식:
/// - MM:SS (예: 1:23 → 83초)
/// - HH:MM:SS (예: 1:23:45 → 5025초)
/// - YouTube 스타일: t=70s, t=1m10s, 70s, 1m10s, 1h2m30s 등
class TimestampUtils {
  TimestampUtils._();

  /// YouTube 스타일 형식 패턴 (Xh, Xm, Xs 조합)
  static final RegExp _youtubePattern = RegExp(r'^(?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s)?$');

  /// [parseDuration] - 시간 문자열을 초로 변환
  ///
  /// Parameters:
  /// - [input]: 변환할 시간 문자열
  ///
  /// Returns: 초 단위의 정수, 파싱 실패 시 null
  static int? parseDuration(String input) {
    try {
      // 앞뒤 공백 제거 및 앞의 "t=" 제거
      var text = input.trim();
      if (text.startsWith('t=')) {
        text = text.substring(2);
      }

      // YouTube 스타일 형식: Xh, Xm, Xs 조합
      final youtubeMatch = _youtubePattern.firstMatch(text);
      if (youtubeMatch != null && youtubeMatch[0]!.isNotEmpty) {
        final hours = int.parse(youtubeMatch[1] ?? '0');
        final minutes = int.parse(youtubeMatch[2] ?? '0');
        final seconds = int.parse(youtubeMatch[3] ?? '0');
        return hours * 3600 + minutes * 60 + seconds;
      }

      // 기존 형식: MM:SS / HH:MM:SS
      final parts = text.split(':');
      if (parts.isEmpty || parts.any((p) => p.isEmpty)) {
        return null;
      }

      if (parts.length == 2) {
        final minutes = int.parse(parts[0]);
        final seconds = int.parse(parts[1]);
        if (seconds >= 60) return null;
        return minutes * 60 + seconds;
      } else if (parts.length == 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        if (minutes >= 60 || seconds >= 60) return null;
        return hours * 3600 + minutes * 60 + seconds;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// [formatDuration] - 초 단위를 "M:SS" 또는 "H:MM:SS" 형식으로 변환
  ///
  /// Parameters:
  /// - [totalSeconds]: 변환할 초 단위 값
  ///
  /// Returns: "M:SS" (1시간 미만) 또는 "H:MM:SS" 형식의 문자열
  static String formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
