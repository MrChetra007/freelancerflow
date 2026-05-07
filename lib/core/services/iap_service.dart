import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IapService {
  static final IapService _instance = IapService._();
  static IapService get instance => _instance;

  final InAppPurchase _iap = InAppPurchase.instance;
  late SharedPreferences _prefs;

  static const String _productId = 'premium_unlock';
  static const String _premiumKey = 'is_premium';

  bool _isInitialized = false;
  bool _isAvailable = false;
  bool _isLoading = false;

  final _premiumStatusController = StreamController<bool>.broadcast();
  Stream<bool> get premiumStatusStream => _premiumStatusController.stream;

  StreamSubscription<List<PurchaseDetails>>? _streamSubscription;

  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;

  IapService._();

  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();

    try {
      _isAvailable = await _iap.isAvailable();
      debugPrint('IAP available: $_isAvailable');

      if (_isAvailable) {
        _streamSubscription = _iap.purchaseStream.listen(_handlePurchase);
        await restorePurchases();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('IAP initialization failed: $e');
    }
  }

  void _handlePurchase(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      debugPrint('Purchase: ${purchase.productID} status=${purchase.status}');

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (purchase.productID == _productId) {
            _prefs.setBool(_premiumKey, true);
            _premiumStatusController.add(true);
          }
          _iap.completePurchase(purchase);
          break;

        case PurchaseStatus.error:
          debugPrint('Purchase error: ${purchase.error?.message}');
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

  Future<bool> checkPremiumStatus() async {
    return _prefs.getBool(_premiumKey) ?? false;
  }

  Future<bool> isPremium() async {
    await initialize();
    return _prefs.getBool(_premiumKey) ?? false;
  }

  Future<bool> purchasePremium() async {
    if (!_isAvailable) return false;

    try {
      final response = await _iap.queryProductDetails({_productId});

      if (response.productDetails.isEmpty) {
        debugPrint('Product not found: $_productId');
        return false;
      }

      final product = response.productDetails.first;
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      return true;
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('Restore failed: $e');
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
