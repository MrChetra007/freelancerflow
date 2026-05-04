import 'package:intl/intl.dart';

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  if (hours > 0) {
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }
  return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
}

String formatDurationShort(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
}

String formatCurrency(double amount, String currency) {
  return NumberFormat.currency(symbol: _getSymbol(currency), decimalDigits: 2)
      .format(amount);
}

String _getSymbol(String currency) => switch (currency) {
      'USD' => '\$',
      'EUR' => '€',
      'GBP' => '£',
      'KHR' => '៛',
      'THB' => '฿',
      'SGD' => 'S\$',
      'AUD' => 'A\$',
      'CAD' => 'C\$',
      _ => '\$',
    };
