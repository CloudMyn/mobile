import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../models/comment_item.dart';
import '../models/informasi_category.dart';
import '../models/informasi_item.dart';

class InformasiFeedResult {
  const InformasiFeedResult({
    required this.pinned,
    required this.items,
    required this.categories,
  });

  final List<InformasiItem> pinned;
  final List<InformasiItem> items;
  final List<InformasiCategory> categories;
}

class InformasiDetailResult {
  const InformasiDetailResult({
    required this.article,
    required this.comments,
  });

  final InformasiItem article;
  final List<CommentItem> comments;
}

class InformasiService {
  InformasiService(this._dio);

  final Dio _dio;

  Future<InformasiFeedResult> fetchFeed() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/mobile/information');
      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => data as Map<String, dynamic>,
      );
      final payload = envelope.data ?? <String, dynamic>{};

      return InformasiFeedResult(
        pinned: (payload['pinned'] as List<dynamic>? ?? [])
            .map((item) => InformasiItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        items: (payload['items'] as List<dynamic>? ?? [])
            .map((item) => InformasiItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        categories: ((payload['filters'] as Map<String, dynamic>?)?['categories']
                    as List<dynamic>? ??
                [])
            .map((item) => InformasiCategory.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat informasi');
    }
  }

  Future<InformasiDetailResult> fetchDetail(String slug) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/mobile/information/$slug');
      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => data as Map<String, dynamic>,
      );
      final payload = envelope.data ?? <String, dynamic>{};
      final articleJson = payload['article'] as Map<String, dynamic>? ?? {};
      final commentsJson = payload['comments'] as List<dynamic>? ?? [];

      return InformasiDetailResult(
        article: InformasiItem.fromJson(articleJson),
        comments: [],
      );
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat detail informasi');
    }
  }

  Future<CommentItem> addComment({
    required String articleId,
    required String articleSlug,
    required String content,
    String? parentId,
  }) async {
    try {
      Response<Map<String, dynamic>> response;
      if (parentId == null) {
        response = await _dio.post<Map<String, dynamic>>(
          '/mobile/information/$articleId/comments',
          data: {'content': content},
        );
      } else {
        response = await _dio.post<Map<String, dynamic>>(
          '/mobile/information/$articleId/comments/$parentId/replies',
          data: {'content': content},
        );
      }

      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => data as Map<String, dynamic>,
      );
      final payload = envelope.data ?? <String, dynamic>{};
      final commentJson = payload['comment'] as Map<String, dynamic>? ?? {};
      return CommentItem.fromJson(commentJson);
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal mengirim komentar');
    }
  }

  Future<List<CommentItem>> fetchComments(String slug, {int page = 1}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/mobile/information/$slug/comments',
        queryParameters: {'page': page},
      );
      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => data as Map<String, dynamic>,
      );
      final payload = envelope.data ?? <String, dynamic>{};
      final itemsJson = payload['items'] as List<dynamic>? ?? [];
      return itemsJson
          .map((item) => CommentItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat komentar');
    }
  }

  Exception _mapDioError(DioException e, String fallbackMessage) {
    final err = e.error;
    if (err is ApiException) return err;
    if (err is NetworkException) return err;
    return ApiException(
      statusCode: e.response?.statusCode ?? 0,
      message: e.message ?? fallbackMessage,
    );
  }
}
