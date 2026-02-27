import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/chapter_model.dart';

class ChapterService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Get all chapters
  Future<List<ChapterModel>> getAllChapters() async {
    try {
      final response = await _supabase
          .from('chapters')
          .select()
          .order('order_index', ascending: true);

      return (response as List)
          .map((json) => ChapterModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load chapters: $e');
    }
  }

  // Get single chapter by ID
  Future<ChapterModel?> getChapterById(int chapterId) async {
    try {
      final response = await _supabase
          .from('chapters')
          .select()
          .eq('id', chapterId)
          .single();

      return ChapterModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Get single chapter by chapter number
  Future<ChapterModel?> getChapterByNumber(int chapterNumber) async {
    try {
      final response = await _supabase
          .from('chapters')
          .select()
          .eq('chapter_number', chapterNumber)
          .single();

      return ChapterModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Get only free chapters
  Future<List<ChapterModel>> getFreeChapters() async {
    try {
      final response = await _supabase
          .from('chapters')
          .select()
          .eq('is_free', true)
          .order('order_index', ascending: true);

      return (response as List)
          .map((json) => ChapterModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load free chapters: $e');
    }
  }

  // Get only subscription chapters
  Future<List<ChapterModel>> getSubscriptionChapters() async {
    try {
      final response = await _supabase
          .from('chapters')
          .select()
          .eq('is_free', false)
          .order('order_index', ascending: true);

      return (response as List)
          .map((json) => ChapterModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load subscription chapters: $e');
    }
  }

  // Check if user can access chapter
  Future<bool> canAccessChapter(int chapterId) async {
    try {
      // Get chapter details
      final chapter = await getChapterById(chapterId);
      if (chapter == null) return false;

      // If chapter is free, allow access
      if (chapter.isFree) return true;

      // Check if user has active subscription
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final profile = await _supabase
          .from('profiles')
          .select('subscription_status, subscription_end_date')
          .eq('id', userId)
          .single();

      final status = profile['subscription_status'] as String?;
      final endDate = profile['subscription_end_date'] as String?;

      if (status == 'active' && endDate != null) {
        final expiryDate = DateTime.parse(endDate);
        return expiryDate.isAfter(DateTime.now());
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Get accessible chapters for current user
  Future<List<ChapterModel>> getAccessibleChapters() async {
    try {
      final allChapters = await getAllChapters();
      final userId = _supabase.auth.currentUser?.id;

      // If not logged in, return only free chapters
      if (userId == null) {
        return allChapters.where((chapter) => chapter.isFree).toList();
      }

      // Check subscription status
      final profile = await _supabase
          .from('profiles')
          .select('subscription_status, subscription_end_date')
          .eq('id', userId)
          .single();

      final status = profile['subscription_status'] as String?;
      final endDate = profile['subscription_end_date'] as String?;

      bool hasActiveSubscription = false;
      if (status == 'active' && endDate != null) {
        final expiryDate = DateTime.parse(endDate);
        hasActiveSubscription = expiryDate.isAfter(DateTime.now());
      }

      // If has active subscription, return all chapters
      if (hasActiveSubscription) {
        return allChapters;
      }

      // Otherwise, return only free chapters
      return allChapters.where((chapter) => chapter.isFree).toList();
    } catch (e) {
      // On error, return only free chapters
      final allChapters = await getAllChapters();
      return allChapters.where((chapter) => chapter.isFree).toList();
    }
  }

  // Get chapters with user progress
  Future<List<Map<String, dynamic>>> getChaptersWithProgress() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final chapters = await getAllChapters();
      final progressList = await _supabase
          .from('user_progress')
          .select()
          .eq('user_id', userId);

      // Combine chapters with progress
      return chapters.map((chapter) {
        final progress = progressList.firstWhere(
          (p) => p['chapter_id'] == chapter.id,
          orElse: () => {},
        );

        return {
          'chapter': chapter,
          'progress': progress.isNotEmpty ? progress : null,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
