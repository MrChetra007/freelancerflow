import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, String currency) {
    final format = NumberFormat.currency(
      symbol: _getSymbol(currency),
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  static String formatCompact(double amount, String currency) {
    final format = NumberFormat.compactCurrency(
      symbol: _getSymbol(currency),
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  static String _getSymbol(String currency) {
    return switch (currency.toUpperCase()) {
      'USD' => '\$',
      'EUR' => '€',
      'GBP' => '£',
      'JPY' => '¥',
      'KRW' => '₩',
      'THB' => '฿',
      'KHR' => '៛',
      'SGD' => 'S\$',
      _ => '\$',
    };
  }
}
