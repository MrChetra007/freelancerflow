import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/iap_service.dart';

final isPremiumProvider = StateNotifierProvider<IsPremiumNotifier, bool>((ref) {
  return IsPremiumNotifier();
});

class IsPremiumNotifier extends StateNotifier<bool> {
  StreamSubscription<bool>? _subscription;

  IsPremiumNotifier() : super(false) {
    _loadPremiumStatus();
    _listenToPremiumUpdates();
  }

  Future<void> _loadPremiumStatus() async {
    try {
      state = await IapService.instance.isPremium();
    } catch (e) {
      state = false;
    }
  }

  void _listenToPremiumUpdates() {
    _subscription = IapService.instance.premiumStatusStream.listen((isPremium) {
      state = isPremium;
    });
  }

  Future<void> refresh() async {
    await IapService.instance.restorePurchases();
    await _loadPremiumStatus();
  }

  Future<void> setPremiumForTesting(bool value) async {
    state = value;
  }

  Future<void> setPremium(bool value) async {
    state = value;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final productDetailsProvider = FutureProvider((ref) async {
  return await IapService.instance.getProductDetails();
});
