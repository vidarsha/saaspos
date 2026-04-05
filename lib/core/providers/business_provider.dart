import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessState {
  final Map<String, dynamic>? business;
  final List<Map<String, dynamic>> branches;
  final Map<String, dynamic>? currentBranch;
  final Map<String, dynamic>? profile;
  final bool isLoading;

  BusinessState({
    this.business,
    this.branches = const [],
    this.currentBranch,
    this.profile,
    this.isLoading = false,
  });

  BusinessState copyWith({
    Map<String, dynamic>? business,
    List<Map<String, dynamic>>? branches,
    Map<String, dynamic>? currentBranch,
    Map<String, dynamic>? profile,
    bool? isLoading,
  }) {
    return BusinessState(
      business: business ?? this.business,
      branches: branches ?? this.branches,
      currentBranch: currentBranch ?? this.currentBranch,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BusinessNotifier extends StateNotifier<BusinessState> {
  BusinessNotifier() : super(BusinessState(isLoading: true)) {
    loadBusinessData();
  }

  Future<void> loadBusinessData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      state = state.copyWith(isLoading: true);

      // 1. Fetch Profile
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      final businessId = profile['business_id'];
      if (businessId == null) {
        state = state.copyWith(isLoading: false, profile: profile);
        return;
      }

      // 2. Fetch Business
      final business = await supabase
          .from('businesses')
          .select()
          .eq('id', businessId)
          .single();

      // 3. Fetch Branches
      final branches = await supabase
          .from('branches')
          .select()
          .eq('business_id', businessId);

      state = state.copyWith(
        profile: profile,
        business: business,
        branches: List<Map<String, dynamic>>.from(branches),
        currentBranch: branches.isNotEmpty ? branches.first : null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void switchBranch(Map<String, dynamic> branch) {
    state = state.copyWith(currentBranch: branch);
  }
}

final businessProvider = StateNotifierProvider<BusinessNotifier, BusinessState>((ref) {
  return BusinessNotifier();
});
