// filepath: lib/text_book/services/lazy_content_loader.dart
import 'dart:async';

/// Lazy loads book content in chunks for instant first-page display
class LazyContentLoader {
  final List<String> _fullContent;
  final int chunkSize;
  
  late List<List<String>> _chunks;
  final List<bool> _chunkLoaded;

  LazyContentLoader(
    this._fullContent, {
    this.chunkSize = 100,
  }) : _chunkLoaded = List<bool>.filled((_fullContent.length / 100).ceil(), false) {
    _initializeChunks();
  }

  void _initializeChunks() {
    _chunks = [];
    for (int i = 0; i < _fullContent.length; i += chunkSize) {
      final end = (i + chunkSize < _fullContent.length) ? i + chunkSize : _fullContent.length;
      _chunks.add(_fullContent.sublist(i, end));
    }
  }

  /// Get first chunk immediately (instant display)
  List<String> getFirstChunk() {
    if (_chunks.isEmpty) return [];
    _chunkLoaded[0] = true;
    return _chunks[0];
  }

  /// Get specific chunk
  List<String> getChunk(int index) {
    if (index < 0 || index >= _chunks.length) return [];
    _chunkLoaded[index] = true;
    return _chunks[index];
  }

  /// Preload next N chunks asynchronously
  Future<void> preloadNextChunks(int currentChunkIndex, int count) async {
    // Simulates async preload - in real scenario would yield to event loop
    await Future.delayed(const Duration(milliseconds: 1));
    
    for (int i = currentChunkIndex + 1; i < (currentChunkIndex + count + 1) && i < _chunks.length; i++) {
      _chunkLoaded[i] = true;
    }
  }

  /// Get chunk loading status
  Map<int, bool> getChunkStatus() => Map.fromEntries(
    List.generate(_chunks.length, (i) => MapEntry(i, _chunkLoaded[i]))
  );

  int get totalChunks => _chunks.length;
}
