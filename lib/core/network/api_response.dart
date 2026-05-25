/// Wrapper untuk response envelope standar backend:
/// {"success": bool, "message": str, "data": any, "meta": {...}}
///
/// Penggunaan:
/// ```dart
/// final resp = ApiResponse.fromJson(response.data, MyModel.fromJson);
/// final model = resp.data; // MyModel
/// ```
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  final bool success;
  final String message;
  final T? data;
  final ApiMeta? meta;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromData,
  ) {
    final rawData = json['data'];
    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      data: rawData != null ? fromData(rawData) : null,
      meta: json['meta'] != null
          ? ApiMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Buat response untuk list data.
  static ApiResponse<List<T>> fromJsonList<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final rawData = json['data'];
    final list = rawData is List
        ? rawData.map((e) => fromItem(e as Map<String, dynamic>)).toList()
        : <T>[];
    return ApiResponse<List<T>>(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      data: list,
      meta: json['meta'] != null
          ? ApiMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ApiMeta {
  const ApiMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      currentPage: json['current_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      lastPage: json['last_page'] as int? ?? 1,
    );
  }

  bool get hasNextPage => currentPage < lastPage;
}
