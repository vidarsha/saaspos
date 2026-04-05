import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:saaspos/core/providers/providers.dart';

class BusinessSetupState {
  final Map<String, dynamic> businessData;
  final Map<String, dynamic> branchData;
  final String subscriptionPlan;
  final bool isLoading;
  final String? error;

  BusinessSetupState({
    this.businessData = const {},
    this.branchData = const {},
    this.subscriptionPlan = 'Free',
    this.isLoading = false,
    this.error,
  });

  BusinessSetupState copyWith({
    Map<String, dynamic>? businessData,
    Map<String, dynamic>? branchData,
    String? subscriptionPlan,
    bool? isLoading,
    String? error,
  }) {
    return BusinessSetupState(
      businessData: businessData ?? this.businessData,
      branchData: branchData ?? this.branchData,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class BusinessSetupNotifier extends StateNotifier<BusinessSetupState> {
  final SupabaseClient _supabase;
  BusinessSetupNotifier(this._supabase) : super(BusinessSetupState());

  void updateBusinessData(Map<String, dynamic> data) {
    state = state.copyWith(businessData: {...state.businessData, ...data});
  }

  void updateBranchData(Map<String, dynamic> data) {
    state = state.copyWith(branchData: {...state.branchData, ...data});
  }

  void setSubscriptionPlan(String plan) {
    state = state.copyWith(subscriptionPlan: plan);
  }

  Future<bool> completeSetup() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // 1. Create Business
      final businessResponse = await _supabase.from('businesses').insert({
        ...state.businessData,
      }).select().single();

      final businessId = businessResponse['id'];

      // 2. Create Initial Branch
      await _supabase.from('branches').insert({
        'business_id': businessId,
        ...state.branchData,
      });

      // 3. Update User Profile with business_id
      await _supabase.from('profiles').update({
        'business_id': businessId,
      }).eq('id', user.id);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final businessSetupProvider = StateNotifierProvider<BusinessSetupNotifier, BusinessSetupState>((ref) {
  return BusinessSetupNotifier(ref.watch(supabaseClientProvider));
});
