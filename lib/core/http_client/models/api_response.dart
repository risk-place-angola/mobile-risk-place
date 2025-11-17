/// Generic API response wrapper
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int? statusCode;
  final Map<String, dynamic>? meta;

  ApiResponse({
    this.data,
    this.message,
    required this.success,
    this.statusCode,
    this.meta,
  });

  /// Factory for successful responses
  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
    Map<String, dynamic>? meta,
  }) {
    return ApiResponse(
      data: data,
      message: message,
      success: true,
      statusCode: statusCode,
      meta: meta,
    );
  }

  /// Factory for error responses
  factory ApiResponse.error({
    String? message,
    int? statusCode,
    Map<String, dynamic>? meta,
  }) {
    return ApiResponse(
      data: null,
      message: message ?? 'Ocorreu um erro',
      success: false,
      statusCode: statusCode,
      meta: meta,
    );
  }

  /// Create ApiResponse from JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'] as String?,
      success: json['success'] as bool? ?? (json['data'] != null),
      statusCode: json['statusCode'] as int?,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'message': message,
      'success': success,
      'statusCode': statusCode,
      'meta': meta,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}
