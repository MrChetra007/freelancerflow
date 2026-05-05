import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/iap_service.dart';

final isPremiumProvider = StateNotifierProvider<IsPremiumNotifier, bool>((ref) {
  return IsPremiumNotifier();
});

class IsPremiumNotifier extends StateNotifier<bool> {
  IsPremiumNotifier() : super(false) {
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    try {
      state = await IapService.instance.isPremium();
    } catch (e) {
      state = false;
    }
  }

  Future<void> refresh() async {
    await IapService.instance.restorePurchases();
    await _loadPremiumStatus();
  }

  Future<void> setPremiumForTesting(bool value) async {
    state = value;
  }
}

final productDetailsProvider = FutureProvider((ref) async {
  return await IapService.instance.getProductDetails();
});
