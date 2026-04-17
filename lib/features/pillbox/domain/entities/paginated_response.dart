class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int limit;
  final int total;

  PaginatedResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });
}
