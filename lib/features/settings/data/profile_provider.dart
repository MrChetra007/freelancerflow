import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/iap_service.dart';
import '../../../core/supabase/supabase_client.dart';

class ProfileData {
  final String? id;
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final String? businessName;
  final String? businessEmail;
  final String? businessPhone;
  final String? businessAddress;
  final String currency;
  final String timezone;
  final double defaultHourlyRate;
  final String? taxId;
  final String? defaultPaymentTerms;
  final bool isPro;
  final DateTime? proExpiresAt;
  final bool isOnboarding;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileData({
    this.id,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.businessName,
    this.businessEmail,
    this.businessPhone,
    this.businessAddress,
    required this.currency,
    required this.timezone,
    required this.defaultHourlyRate,
    this.taxId,
    this.defaultPaymentTerms,
    required this.isPro,
    this.proExpiresAt,
    required this.isOnboarding,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.parse(value.toString());
    }

    return ProfileData(
      id: json['id'] as String?,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      businessName: json['business_name'] as String?,
      businessEmail: json['business_email'] as String?,
      businessPhone: json['business_phone'] as String?,
      businessAddress: json['business_address'] as String?,
      currency: (json['currency'] as String?) ?? 'USD',
      timezone: (json['timezone'] as String?) ?? 'UTC',
      defaultHourlyRate: double.tryParse(json['default_hourly_rate']?.toString() ?? '0') ?? 0,
      taxId: json['tax_id'] as String?,
      defaultPaymentTerms: json['default_payment_terms'] as String?,
      isPro: (json['is_pro'] as bool?) ?? false,
      proExpiresAt: parseDate(json['pro_expires_at']),
      isOnboarding: (json['is_onboarding'] as bool?) ?? true,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'business_name': businessName,
      'business_email': businessEmail,
      'business_phone': businessPhone,
      'business_address': businessAddress,
      'currency': currency,
      'timezone': timezone,
      'default_hourly_rate': defaultHourlyRate,
      'tax_id': taxId,
      'default_payment_terms': defaultPaymentTerms,
      'is_pro': isPro,
      'pro_expires_at': proExpiresAt?.toIso8601String(),
      'is_onboarding': isOnboarding,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  ProfileData copyWith({
    String? fullName,
    String? email,
    String? avatarUrl,
    String? businessName,
    String? businessEmail,
    String? businessPhone,
    String? businessAddress,
    String? currency,
    String? timezone,
    double? defaultHourlyRate,
    String? taxId,
    String? defaultPaymentTerms,
    bool? isPro,
    DateTime? proExpiresAt,
    bool? isOnboarding,
  }) {
    return ProfileData(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      businessName: businessName ?? this.businessName,
      businessEmail: businessEmail ?? this.businessEmail,
      businessPhone: businessPhone ?? this.businessPhone,
      businessAddress: businessAddress ?? this.businessAddress,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      defaultHourlyRate: defaultHourlyRate ?? this.defaultHourlyRate,
      taxId: taxId ?? this.taxId,
      defaultPaymentTerms: defaultPaymentTerms ?? this.defaultPaymentTerms,
      isPro: isPro ?? this.isPro,
      proExpiresAt: proExpiresAt ?? this.proExpiresAt,
      isOnboarding: isOnboarding ?? this.isOnboarding,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class ProfileState {
  final ProfileData? data;
  final bool isLoading;
  final String? error;

  ProfileState({this.data, this.isLoading = false, this.error});

  ProfileState copyWith({ProfileData? data, bool? isLoading, String? error}) {
    return ProfileState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await SupabaseConfig.client
          .from('profiles')
          .select()
          .single();
      final profile = ProfileData.fromJson(response);
      state = state.copyWith(data: profile, isLoading: false);

      final expiresAt = profile.proExpiresAt;
      if (profile.isPro &&
          (expiresAt == null || expiresAt.isAfter(DateTime.now()))) {
        await IapService.instance.setPremiumStatus(true);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile: ${e.toString()}',
      );
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');
      await SupabaseConfig.client
          .from('profiles')
          .update(updates)
          .eq('id', user.id);
      await loadProfile();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile: ${e.toString()}',
      );
      rethrow;
    }
  }

  Future<void> updateDefaultHourlyRate(double rate) async {
    await updateProfile({'default_hourly_rate': rate});
  }

  Future<void> updateTaxId(String? taxId) async {
    await updateProfile({'tax_id': taxId});
  }

  Future<void> updateDefaultPaymentTerms(String? terms) async {
    await updateProfile({'default_payment_terms': terms});
  }

  Future<void> completeOnboarding() async {
    await updateProfile({'is_onboarding': false});
    if (state.data != null) {
      state = state.copyWith(
        data: state.data!.copyWith(isOnboarding: false),
      );
    }
  }

  Future<void> updateAvatar(String? avatarUrl) async {
    if (avatarUrl != null) {
      await updateProfile({'avatar_url': avatarUrl});
    } else {
      await updateProfile({'avatar_url': null});
    }
    if (state.data != null) {
      state = state.copyWith(
        data: state.data!.copyWith(avatarUrl: avatarUrl),
      );
    }
  }
}
