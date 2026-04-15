import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/iap_service.dart';

final premiumPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize SharedPreferences in main.dart');
});

final iapServiceProvider = Provider<IapService>((ref) {
  return IapService.instance;
});

final isPremiumProvider = StateNotifierProvider<IsPremiumNotifier, bool>((ref) {
  return IsPremiumNotifier();
});

class IsPremiumNotifier extends StateNotifier<bool> {
  IsPremiumNotifier() : super(false) {
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    await IapService.instance.initialize();
    state = IapService.instance.isPremium;
  }

  Future<void> refresh() async {
    state = IapService.instance.isPremium;
  }

  void setPremium(bool value) {
    state = value;
  }
}
