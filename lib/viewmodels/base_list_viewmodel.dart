import 'package:flutter/foundation.dart';

class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.hasNext,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final bool hasNext;

  bool get hasPrevious => page > 0;
}

abstract class BaseListViewModel extends ChangeNotifier {
  static const defaultPageSize = 10;

  String? message;

  PagedResult<T> paginate<T>(
    Iterable<T> source, {
    int page = 0,
    int pageSize = defaultPageSize,
    String query = '',
    String Function(T item)? searchableText,
    Comparator<T>? sortBy,
    bool descending = false,
  }) {
    final safePage = page < 0 ? 0 : page;
    final safePageSize = pageSize < 1 ? defaultPageSize : pageSize;
    final normalizedQuery = query.toLowerCase().trim();
    final filtered = normalizedQuery.isEmpty || searchableText == null
        ? source
        : source.where(
            (item) =>
                searchableText(item).toLowerCase().contains(normalizedQuery),
          );
    final ordered = filtered.toList();
    if (sortBy != null) ordered.sort(sortBy);
    final pagedSource = descending ? ordered.reversed : ordered;
    final window = pagedSource
        .skip(safePage * safePageSize)
        .take(safePageSize + 1)
        .toList();

    return PagedResult<T>(
      items: window.take(safePageSize).toList(),
      page: safePage,
      pageSize: safePageSize,
      hasNext: window.length > safePageSize,
    );
  }

  bool runAction(String Function() action) {
    // Semua aksi CRUD lewat helper ini supaya sukses/error punya pola sama:
    // service menjalankan validasi, ViewModel menyimpan pesan, lalu UI refresh.
    try {
      message = action();
      notifyListeners();
      return true;
    } on StateError catch (error) {
      message = error.message;
      notifyListeners();
      return false;
    }
  }
}
