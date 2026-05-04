import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';

class ProfileData {
  final String? id;
  final String? fullName;
  final String? email;
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
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileData({
    this.id,
    this.fullName,
    this.email,
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
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
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
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  ProfileData copyWith({
    String? fullName,
    String? email,
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
  }) {
    return ProfileData(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
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
      await SupabaseConfig.client.from('profiles').update(updates);
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
}
