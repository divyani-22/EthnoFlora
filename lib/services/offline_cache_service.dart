import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineCacheService {
  static const String _proofQueueKey = 'offline_proof_queue';
  static const String _quizHistoryKey = 'offline_quiz_history';

  static final OfflineCacheService instance = OfflineCacheService._internal();
  factory OfflineCacheService() => instance;
  OfflineCacheService._internal();

  /// Caches a mission proof submission locally when offline.
  Future<void> cacheMissionProofDraft(Map<String, dynamic> proofData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingQueue = prefs.getStringList(_proofQueueKey) ?? [];
      existingQueue.add(jsonEncode(proofData));
      await prefs.setStringList(_proofQueueKey, existingQueue);
      print('💾 OfflineCacheService: Cached mission proof draft offline');
    } catch (e) {
      print('❌ OfflineCacheService: Failed to cache proof draft: $e');
    }
  }

  /// Gets all pending offline mission proof drafts.
  Future<List<Map<String, dynamic>>> getPendingProofDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingQueue = prefs.getStringList(_proofQueueKey) ?? [];
      return existingQueue
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('❌ OfflineCacheService: Failed to fetch pending drafts: $e');
      return [];
    }
  }

  /// Clears pending queue after successful sync.
  Future<void> clearPendingProofQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_proofQueueKey);
      print('✅ OfflineCacheService: Cleared pending proof queue');
    } catch (e) {
      print('❌ OfflineCacheService: Failed to clear queue: $e');
    }
  }

  /// Caches quiz attempt locally when offline.
  Future<void> cacheOfflineQuizAttempt(Map<String, dynamic> attemptData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_quizHistoryKey) ?? [];
      history.add(jsonEncode(attemptData));
      await prefs.setStringList(_quizHistoryKey, history);
      print('💾 OfflineCacheService: Cached quiz attempt offline');
    } catch (e) {
      print('❌ OfflineCacheService: Failed to cache quiz attempt: $e');
    }
  }
}
