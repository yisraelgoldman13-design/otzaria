// filepath: lib/text_book/services/parallel_book_loader.dart
import 'dart:async';
import 'package:otzaria/models/books.dart';

/// Loads book data in parallel for maximum performance
class ParallelBookLoader {
  /// Load all required book data in parallel
  static Future<BookLoadResult> loadBook(
    TextBook book, {
    required Future<List<String>> Function() contentLoader,
    required Future<Map<int, List>> Function() linksLoader,
    required Future<Map<String, dynamic>> Function() tocLoader,
    required Future<void> Function() metadataLoader,
  }) async {
    try {
      // Load all data in parallel - don't wait sequentially
      final stopwatch = Stopwatch()..start();

      final results = await Future.wait<dynamic>([
        contentLoader(),           // Index 0
        linksLoader(),             // Index 1
        tocLoader(),               // Index 2
        metadataLoader(),          // Index 3
      ], eagerError: true);

      stopwatch.stop();

      return BookLoadResult(
        content: results[0] as List<String>,
        links: results[1] as Map<int, List>,
        tableOfContents: results[2] as Map<String, dynamic>,
        loadTimeMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Load with timeout protection
  static Future<BookLoadResult> loadBookWithTimeout(
    TextBook book, {
    required Future<List<String>> Function() contentLoader,
    required Future<Map<int, List>> Function() linksLoader,
    required Future<Map<String, dynamic>> Function() tocLoader,
    required Future<void> Function() metadataLoader,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      return await loadBook(
        book,
        contentLoader: contentLoader,
        linksLoader: linksLoader,
        tocLoader: tocLoader,
        metadataLoader: metadataLoader,
      ).timeout(timeout, onTimeout: () {
        throw TimeoutException('Book loading exceeded $timeout');
      });
    } catch (e) {
      rethrow;
    }
  }
}

class BookLoadResult {
  final List<String> content;
  final Map<int, List> links;
  final Map<String, dynamic> tableOfContents;
  final int loadTimeMs;

  BookLoadResult({
    required this.content,
    required this.links,
    required this.tableOfContents,
    required this.loadTimeMs,
  });
}
