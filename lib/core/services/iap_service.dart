import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IapService {
  static final IapService _instance = IapService._();
  static IapService get instance => _instance;

  final InAppPurchase _iap = InAppPurchase.instance;
  late SharedPreferences _prefs;

  static const _premiumKey = 'is_premium';
  static const _productId = 'premium_unlock';

  bool _isInitialized = false;
  bool _isPremium = false;
  bool _isAvailable = false;

  bool get isPremium => _isPremium;
  bool get isAvailable => _isAvailable;

  IapService._();

  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    _isPremium = _prefs.getBool(_premiumKey) ?? false;

    try {
      _isAvailable = await _iap.isAvailable();

      if (_isAvailable) {
        final productIds = {_productId};
        final response = await _iap.queryProductDetails(productIds);

        if (response.productDetails.isNotEmpty) {
          _iap.purchaseStream.listen(_handlePurchase);
        }
      }
    } catch (e) {
      debugPrint('IAP initialization failed: $e');
    }

    _isInitialized = true;
  }

  void _handlePurchase(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        if (purchase.productID == _productId) {
          _grantPremium();
        }
        _iap.completePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.restored) {
        _grantPremium();
        _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _grantPremium() async {
    await _prefs.setBool(_premiumKey, true);
    _isPremium = true;
  }

  Future<bool> purchasePremium() async {
    if (!_isAvailable) {
      debugPrint('IAP not available on this device');
      return false;
    }

    try {
      final productIds = {_productId};
      final response = await _iap.queryProductDetails(productIds);

      if (response.productDetails.isEmpty) {
        debugPrint('Product not found');
        return false;
      }

      final product = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: product);

      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
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
      final productIds = {_productId};
      final response = await _iap.queryProductDetails(productIds);
      return response.productDetails.firstOrNull;
    } catch (e) {
      debugPrint('Failed to get product: $e');
      return null;
    }
  }
}
