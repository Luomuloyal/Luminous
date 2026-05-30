class LucentEnvelope<T> {
  const LucentEnvelope({
    required this.code,
    required this.message,
    required this.data,
    this.meta,
  });

  final int code;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;

  bool get isSuccess => code == 0;

  factory LucentEnvelope.fromJson(
    Map<String, dynamic> json, {
    T Function(Object? rawData)? dataDecoder,
  }) {
    final codeValue = json['code'];
    final messageValue = json['message'];
    final rawData = json['data'];
    final metaValue = json['meta'];

    return LucentEnvelope<T>(
      code: _parseCode(codeValue),
      message: messageValue?.toString() ?? '',
      data: dataDecoder == null ? rawData as T? : dataDecoder(rawData),
      meta: metaValue is Map<String, dynamic>
          ? metaValue
          : metaValue is Map
          ? metaValue.map(
              (key, value) => MapEntry(key.toString(), value),
            )
          : null,
    );
  }

  static int _parseCode(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? -1;
    return -1;
  }
}
