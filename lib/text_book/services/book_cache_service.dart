// filepath: lib/text_book/services/book_cache_service.dart
import 'dart:async';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:otzaria/models/books.dart';

/// High-performance caching service for book data
/// Optimizes loading speed by caching parsed content, links, and TOC
class BookCacheService {
  static final BookCacheService _instance = BookCacheService._internal();

  // In-memory cache with TTL
  final Map<String, _CacheEntry> _memoryCache = {};
  final Duration _cacheTTL = const Duration(hours: 1);
  
  // Fast lookup maps
  final Map<String, List<String>> _contentLineCache = {};
  final Map<String, Map<String, dynamic>> _linksIndexCache = {};
  
  // Batch loading
  final Map<String, Future> _loadingFutures = {};
  final List<String> _priorityQueue = [];

  factory BookCacheService() {
    return _instance;
  }

  BookCacheService._internal();

  /// Get or load book content with caching
  Future<List<String>> getCachedContent(
    TextBook book,
    Future<List<String>> Function() loader,
  ) async {
    final cacheKey = '${book.title}_content';
    
    // Return from memory cache if valid
    if (_memoryCache.containsKey(cacheKey)) {
      final entry = _memoryCache[cacheKey]!;
      if (!entry.isExpired) {
        return entry.data as List<String>;
      } else {
        _memoryCache.remove(cacheKey);
      }
    }

    // Avoid duplicate loads during fetch
    if (_loadingFutures.containsKey(cacheKey)) {
      return await _loadingFutures[cacheKey]!;
    }

    // Load and cache
    final future = loader();
    _loadingFutures[cacheKey] = future;

    try {
      final data = await future;
      _memoryCache[cacheKey] = _CacheEntry(data, DateTime.now());
      _contentLineCache[cacheKey] = data;
      return data;
    } finally {
      _loadingFutures.remove(cacheKey);
    }
  }

  /// Get or load links with caching
  Future<Map<int, List<Link>>> getCachedLinks(
    TextBook book,
    Future<Map<int, List<Link>>> Function() loader,
  ) async {
    final cacheKey = '${book.title}_links';
    
    if (_memoryCache.containsKey(cacheKey)) {
      final entry = _memoryCache[cacheKey]!;
      if (!entry.isExpired) {
        return entry.data as Map<int, List<Link>>;
      }
    }

    if (_loadingFutures.containsKey(cacheKey)) {
      return await _loadingFutures[cacheKey]!;
    }

    final future = loader();
    _loadingFutures[cacheKey] = future;

    try {
      final data = await future;
      _memoryCache[cacheKey] = _CacheEntry(data, DateTime.now());
      _linksIndexCache[cacheKey] = data;
      return data;
    } finally {
      _loadingFutures.remove(cacheKey);
    }
  }

  /// Preload frequently accessed books
  Future<void> preloadBook(
    TextBook book, {
    required Future<List<String>> Function() contentLoader,
    required Future<Map<int, List<Link>>> Function() linksLoader,
  }) async {
    // Priority preload - parallel loading
    await Future.wait([
      getCachedContent(book, contentLoader),
      getCachedLinks(book, linksLoader),
    ]);
  }

  /// Clear cache for specific book
  void clearBookCache(String bookTitle) {
    _memoryCache.remove('${bookTitle}_content');
    _memoryCache.remove('${bookTitle}_links');
    _memoryCache.remove('${bookTitle}_toc');
    _contentLineCache.remove('${bookTitle}_content');
    _linksIndexCache.remove('${bookTitle}_links');
  }

  /// Clear all caches
  void clearAllCaches() {
    _memoryCache.clear();
    _contentLineCache.clear();
    _linksIndexCache.clear();
    _loadingFutures.clear();
  }
}

class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  _CacheEntry(this.data, this.timestamp);

  bool get isExpired =>
      DateTime.now().difference(timestamp).inHours > 1;
}
