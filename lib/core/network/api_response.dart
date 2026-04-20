/// Standard API response wrapper matching backend format:
/// { responseCode, responseMessage, responseData }
class ApiResponse<T> {
  final int responseCode;
  final String responseMessage;
  final T? responseData;

  const ApiResponse({
    required this.responseCode,
    required this.responseMessage,
    this.responseData,
  });

  bool get isSuccess => responseCode == 200 || responseCode == 0;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      responseCode: json['responseCode'] is int
          ? json['responseCode']
          : int.tryParse(json['responseCode']?.toString() ?? '500') ?? 500,
      responseMessage: json['responseMessage']?.toString() ?? '',
      responseData: json['responseData'] != null && fromJsonT != null
          ? fromJsonT(json['responseData'])
          : json['responseData'] as T?,
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(
      responseCode: 500,
      responseMessage: message,
      responseData: null,
    );
  }
}
