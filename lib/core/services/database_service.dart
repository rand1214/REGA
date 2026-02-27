import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class DatabaseService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // ============================================
  // PROFILE OPERATIONS
  // ============================================

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // CHAPTER OPERATIONS
  // ============================================

  Future<List<Map<String, dynamic>>> getChapters() async {
    try {
      final response = await _supabase
          .from('chapters')
          .select()
          .order('order_index', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getChapter(int chapterId) async {
    try {
      final response = await _supabase
          .from('chapters')
          .select()
          .eq('id', chapterId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // QUESTION OPERATIONS
  // ============================================

  Future<List<Map<String, dynamic>>> getQuestionsByChapter(int chapterId) async {
    try {
      final response = await _supabase
          .from('questions')
          .select()
          .eq('chapter_id', chapterId)
          .order('order_index', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getQuestion(String questionId) async {
    try {
      final response = await _supabase
          .from('questions')
          .select()
          .eq('id', questionId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // USER PROGRESS OPERATIONS
  // ============================================

  Future<Map<String, dynamic>?> getUserProgress(int chapterId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('chapter_id', chapterId)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUserProgress() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('user_progress')
          .select('*, chapters(*)')
          .eq('user_id', userId)
          .order('last_attempted_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<void> updateUserProgress({
    required int chapterId,
    required int totalQuestions,
    required int correctAnswers,
    required int incorrectAnswers,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final completionPercentage = (correctAnswers / totalQuestions * 100).toStringAsFixed(2);

      await _supabase.from('user_progress').upsert({
        'user_id': userId,
        'chapter_id': chapterId,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'incorrect_answers': incorrectAnswers,
        'completion_percentage': double.parse(completionPercentage),
        'last_attempted_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // QUIZ ATTEMPT OPERATIONS
  // ============================================

  Future<String> createQuizAttempt({
    required int chapterId,
    required int score,
    required int totalQuestions,
    int? timeInSeconds,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase.from('quiz_attempts').insert({
        'user_id': userId,
        'chapter_id': chapterId,
        'score': score,
        'total_questions': totalQuestions,
        'time_taken_seconds': timeInSeconds,
        'completed_at': DateTime.now().toIso8601String(),
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getQuizAttempts({int? chapterId}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      var query = _supabase
          .from('quiz_attempts')
          .select('*, chapters(*)')
          .eq('user_id', userId);

      if (chapterId != null) {
        query = query.eq('chapter_id', chapterId);
      }

      final response = await query.order('completed_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // USER ANSWER OPERATIONS
  // ============================================

  Future<void> saveUserAnswer({
    required String attemptId,
    required String questionId,
    required String userAnswer,
    required bool isCorrect,
    int? timeInSeconds,
  }) async {
    try {
      await _supabase.from('user_answers').insert({
        'attempt_id': attemptId,
        'question_id': questionId,
        'user_answer': userAnswer,
        'is_correct': isCorrect,
        'time_taken_seconds': timeInSeconds,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserAnswers(String attemptId) async {
    try {
      final response = await _supabase
          .from('user_answers')
          .select('*, questions(*)')
          .eq('attempt_id', attemptId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // BOOK OPERATIONS
  // ============================================

  Future<List<Map<String, dynamic>>> getBooks() async {
    try {
      final response = await _supabase
          .from('books')
          .select()
          .order('order_index', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getBook(String bookId) async {
    try {
      final response = await _supabase
          .from('books')
          .select()
          .eq('id', bookId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // PAYMENT TRANSACTION OPERATIONS
  // ============================================

  Future<String> createPaymentTransaction({
    required String subscriptionId,
    required double amount,
    required String paymentMethod,
    required String paymentProvider,
    String? transactionId,
    String currency = 'USD',
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase.from('payment_transactions').insert({
        'user_id': userId,
        'subscription_id': subscriptionId,
        'amount': amount,
        'currency': currency,
        'payment_method': paymentMethod,
        'payment_provider': paymentProvider,
        'transaction_id': transactionId,
        'status': 'pending',
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePaymentTransactionStatus({
    required String transactionId,
    required String status,
  }) async {
    try {
      await _supabase
          .from('payment_transactions')
          .update({'status': status})
          .eq('id', transactionId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentTransactions() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('payment_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
