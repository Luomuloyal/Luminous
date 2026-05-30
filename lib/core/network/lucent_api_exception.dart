class LucentApiException implements Exception {
  const LucentApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.requestId,
    this.data,
  });

  final String message;
  final int? code;
  final int? statusCode;
  final String? requestId;
  final Object? data;

  bool get isTokenExpired => code == 401002;

  bool get isRefreshTokenInvalid => code == 401003;

  @override
  String toString() {
    final parts = <String>[
      'LucentApiException(message: $message',
      if (code != null) ', code: $code',
      if (statusCode != null) ', statusCode: $statusCode',
      if (requestId != null && requestId!.isNotEmpty) ', requestId: $requestId',
      ')',
    ];
    return parts.join();
  }
}
