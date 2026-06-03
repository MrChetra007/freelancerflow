import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../supabase/supabase_client.dart';

class IapService {
  static final IapService _instance = IapService._();
  static IapService get instance => _instance;

  final InAppPurchase _iap = InAppPurchase.instance;
  late SharedPreferences _prefs;

  static const String _productId = 'premium_unlock';
  static const String _premiumKey = 'is_premium';

  bool _isInitialized = false;
  bool _isAvailable = false;

  final _premiumStatusController = StreamController<bool>.broadcast();
  Stream<bool> get premiumStatusStream => _premiumStatusController.stream;

  StreamSubscription<List<PurchaseDetails>>? _streamSubscription;

  Completer<bool>? _restoreCompleter;

  bool get isAvailable => _isAvailable;

  IapService._();

  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();

    try {
      _isAvailable = await _iap.isAvailable();

      if (_isAvailable) {
        _streamSubscription = _iap.purchaseStream.listen(_handlePurchase);
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('IAP initialization failed: $e');
    }
  }

  Future<void> setPremiumStatus(bool value) async {
    await _prefs.setBool(_premiumKey, value);
    _premiumStatusController.add(value);
  }

  Future<void> _syncPremiumToServer() async {
    try {
      if (!SupabaseConfig.isInitialized) return;
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) return;
      await SupabaseConfig.client
          .from('profiles')
          .update({
            'is_pro': true,
            'pro_expires_at': DateTime.now()
                .add(const Duration(days: 365))
                .toIso8601String(),
          })
          .eq('id', user.id);
    } catch (e) {
      debugPrint('Failed to sync premium to server: $e');
    }
  }

  void _handlePurchase(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (purchase.productID == _productId) {
            _prefs.setBool(_premiumKey, true);
            _premiumStatusController.add(true);
            _restoreCompleter?.complete(true);
            _syncPremiumToServer();
          }
          _iap.completePurchase(purchase);
          break;

        case PurchaseStatus.error:
          _iap.completePurchase(purchase);
          break;

        case PurchaseStatus.canceled:
          _iap.completePurchase(purchase);
          break;

        case PurchaseStatus.pending:
          break;
      }
    }
  }

  Future<bool> isPremium() async {
    await initialize();
    // return _prefs.getBool(_premiumKey) ?? false;
    return true; //for testing
  }

  Future<bool> purchasePremium() async {
    if (!_isAvailable) return false;

    try {
      final response = await _iap.queryProductDetails({_productId});

      if (response.productDetails.isEmpty) {
        return false;
      }

      final product = response.productDetails.first;
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> restorePurchases({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    if (!_isAvailable) return false;

    _restoreCompleter = Completer<bool>();

    await _iap.restorePurchases();

    try {
      final result = await _restoreCompleter!.future.timeout(
        timeout,
        onTimeout: () => false,
      );
      return result;
    } finally {
      _restoreCompleter = null;
    }
  }

  Future<ProductDetails?> getProductDetails() async {
    if (!_isAvailable) return null;

    try {
      final response = await _iap.queryProductDetails({_productId});
      return response.productDetails.firstOrNull;
    } catch (e) {
      return null;
    }
  }

  Future<void> dispose() async {
    await _streamSubscription?.cancel();
  }
}
