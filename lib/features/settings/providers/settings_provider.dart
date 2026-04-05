import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:saaspos/core/providers/business_provider.dart';

class SettingsState {
  final List<Map<String, dynamic>> userGroups;
  final List<Map<String, dynamic>> staff;
  final bool isLoading;

  SettingsState({
    this.userGroups = const [],
    this.staff = const [],
    this.isLoading = false,
  });

  SettingsState copyWith({
    List<Map<String, dynamic>>? userGroups,
    List<Map<String, dynamic>>? staff,
    bool? isLoading,
  }) {
    return SettingsState(
      userGroups: userGroups ?? this.userGroups,
      staff: staff ?? this.staff,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref ref;
  SettingsNotifier(this.ref) : super(SettingsState(isLoading: true)) {
    loadSettingsData();
  }

  Future<void> loadSettingsData() async {
    final businessState = ref.read(businessProvider);
    final businessId = businessState.business?['id'];
    if (businessId == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final supabase = Supabase.instance.client;

      // Fetch User Groups
      final groups = await supabase
          .from('user_groups')
          .select()
          .eq('business_id', businessId);

      // Fetch Staff Profiles
      final staff = await supabase
          .from('profiles')
          .select('*, group:user_groups(name)')
          .eq('business_id', businessId);

      state = state.copyWith(
        userGroups: List<Map<String, dynamic>>.from(groups),
        staff: List<Map<String, dynamic>>.from(staff),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> createGroup(String name, String description, Map<String, dynamic> permissions) async {
    try {
      final businessId = ref.read(businessProvider).business?['id'];
      if (businessId == null) throw 'Business ID not found. Please reload.';

      await Supabase.instance.client.from('user_groups').insert({
        'business_id': businessId,
        'name': name,
        'description': description,
        'permissions': permissions,
      });
      await loadSettingsData();
    } catch (e) {
      if (kDebugMode) {
        print('Create Group Error: $e');
      }
      throw 'Failed to create group: $e';
    }
  }

  Future<void> createStaff(Map<String, dynamic> staffData) async {
    try {
      final businessId = ref.read(businessProvider).business?['id'];
      if (businessId == null) throw 'Business ID not found. Please reload.';

      await Supabase.instance.client.from('profiles').insert({
        ...staffData,
        'business_id': businessId,
      });
      await loadSettingsData();
    } catch (e) {
      if (kDebugMode) {
        print('Create Staff Error: $e');
      }
      throw 'Failed to add staff: $e';
    }
  }

  Future<void> updateBusiness(Map<String, dynamic> businessData) async {
    try {
      final businessId = ref.read(businessProvider).business?['id'];
      await Supabase.instance.client
          .from('businesses')
          .update(businessData)
          .eq('id', businessId);
      await ref.read(businessProvider.notifier).loadBusinessData();
    } catch (e) {
      if (kDebugMode) {
        print('Update Business Error: $e');
      }
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref);
});
