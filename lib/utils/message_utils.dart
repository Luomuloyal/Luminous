/// 用户可见消息清洗工具。
///
/// 用于把异常对象或服务端长文案压缩成适合直接展示给用户的简洁提示。
class MessageUtils {
  /// 私有构造函数。
  MessageUtils._();

  /// 从异常对象里提取适合展示的错误消息。
  static String extractError(
    Object? error, {
    String fallback = '操作失败，请稍后重试',
    int maxLength = 80,
  }) {
    return normalize(
      error?.toString() ?? '',
      fallback: fallback,
      maxLength: maxLength,
    );
  }

  /// 清洗一段用户可见消息。
  static String normalize(
    String message, {
    String fallback = '操作失败，请稍后重试',
    int maxLength = 80,
  }) {
    var text = message.trim();
    if (text.isEmpty) {
      return fallback;
    }

    text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();

    // HTML/大段内容直接收口为通用提示，避免把服务端异常页整段展示出来。
    final lower = text.toLowerCase();
    if (lower.contains('<!doctype html') || lower.contains('<html')) {
      return fallback;
    }

    // 常见异常前缀清理。
    text = text.replaceFirst(RegExp(r'^DioException\s*\[[^\]]*\]:\s*'), '');

    for (final prefix in _prefixes) {
      if (text.startsWith(prefix)) {
        text = text.substring(prefix.length).trim();
      }
    }

    final firstLine = text
        .split('\n')
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => '');
    text = firstLine.isEmpty ? text : firstLine;

    for (final marker in _stopMarkers) {
      final index = text.indexOf(marker);
      if (index > 0) {
        text = text.substring(0, index).trim();
      }
    }

    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (text.isEmpty) {
      return fallback;
    }

    if (text.length > maxLength) {
      final cutIndex = _findNaturalCutIndex(text, maxLength: maxLength);
      if (cutIndex > 0) {
        text = text.substring(0, cutIndex).trim();
      } else {
        text = '${text.substring(0, maxLength).trim()}...';
      }
    }

    return text.isEmpty ? fallback : text;
  }

  static int _findNaturalCutIndex(String text, {required int maxLength}) {
    const separators = ['。', '！', '？', ';', '；', '. ', ' | ', ' - '];
    for (final separator in separators) {
      final index = text.indexOf(separator);
      if (index >= 8 && index <= maxLength) {
        return separator.length == 1 ? index + 1 : index;
      }
    }
    return -1;
  }

  static const List<String> _prefixes = [
    'Unhandled Exception:',
    'Exception:',
    'ApiException:',
    'DioException:',
    'Invalid argument(s):',
    'Error:',
  ];

  static const List<String> _stopMarkers = [
    'StackTrace:',
    'This exception was thrown',
    '#0',
    ' at ',
    '(package:',
    'package:',
  ];
}
