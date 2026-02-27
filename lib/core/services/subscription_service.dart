import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SubscriptionService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('profiles')
          .select('subscription_status, subscription_end_date')
          .eq('id', userId)
          .single();

      final status = response['subscription_status'] as String?;
      final endDate = response['subscription_end_date'] as String?;

      if (status == 'active' && endDate != null) {
        final expiryDate = DateTime.parse(endDate);
        return expiryDate.isAfter(DateTime.now());
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Get user subscription details
  Future<Map<String, dynamic>?> getSubscriptionDetails() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  // Create subscription (called after successful payment)
  Future<Map<String, dynamic>> createSubscription({
    required String planType, // 'monthly' or 'yearly'
    required double amount,
    required String paymentMethod,
    String currency = 'USD',
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Calculate end date based on plan type
      final startDate = DateTime.now();
      final endDate = planType == 'monthly'
          ? startDate.add(const Duration(days: 30))
          : startDate.add(const Duration(days: 365));

      // Create subscription record
      final subscription = await _supabase.from('subscriptions').insert({
        'user_id': userId,
        'plan_type': planType,
        'status': 'active',
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'payment_method': paymentMethod,
        'amount': amount,
        'currency': currency,
        'auto_renew': true,
      }).select().single();

      // Update user profile
      await _supabase.from('profiles').update({
        'subscription_status': 'active',
        'subscription_tier': planType,
        'subscription_start_date': startDate.toIso8601String(),
        'subscription_end_date': endDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return subscription;
    } catch (e) {
      rethrow;
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Update subscription status
      await _supabase
          .from('subscriptions')
          .update({
            'status': 'cancelled',
            'auto_renew': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('status', 'active');

      // Update profile
      await _supabase.from('profiles').update({
        'subscription_status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Renew subscription
  Future<Map<String, dynamic>> renewSubscription({
    required String subscriptionId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Get current subscription
      final currentSub = await _supabase
          .from('subscriptions')
          .select()
          .eq('id', subscriptionId)
          .single();

      final planType = currentSub['plan_type'] as String;
      final currentEndDate = DateTime.parse(currentSub['end_date'] as String);

      // Calculate new end date
      final newEndDate = planType == 'monthly'
          ? currentEndDate.add(const Duration(days: 30))
          : currentEndDate.add(const Duration(days: 365));

      // Update subscription
      final updated = await _supabase
          .from('subscriptions')
          .update({
            'end_date': newEndDate.toIso8601String(),
            'status': 'active',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', subscriptionId)
          .select()
          .single();

      // Update profile
      await _supabase.from('profiles').update({
        'subscription_status': 'active',
        'subscription_end_date': newEndDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return updated;
    } catch (e) {
      rethrow;
    }
  }

  // Get subscription history
  Future<List<Map<String, dynamic>>> getSubscriptionHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Check if content is accessible (free or subscribed)
  Future<bool> canAccessContent({required bool isFreeContent}) async {
    if (isFreeContent) return true;
    return await hasActiveSubscription();
  }
}
