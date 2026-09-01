import '../../../../core/network/api_response.dart';

class PaginatedResult<T> {
  final List<T> items;
  final ApiMeta meta;

  const PaginatedResult({
    required this.items,
    required this.meta,
  });
}
