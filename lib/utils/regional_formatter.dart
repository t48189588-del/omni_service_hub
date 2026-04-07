import 'package:intl/intl.dart';

class RegionalFormatter {
  final String locale;
  final String currencyCode;

  RegionalFormatter({
    required this.locale,
    required this.currencyCode,
  });

  /// Formats currency based on tenant configuration.
  /// JPY: 0 decimals
  /// USD/PAB: 2 decimals
  String formatCurrency(double amount) {
    int? decimalDigits;
    if (currencyCode.toUpperCase() == 'JPY') {
      decimalDigits = 0;
    } else if (['USD', 'PAB'].contains(currencyCode.toUpperCase())) {
      decimalDigits = 2;
    }

    final format = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
      decimalDigits: decimalDigits,
    );

    return format.format(amount);
  }

  /// Formats date based on the active locale's yMd format.
  String formatDate(DateTime date) {
    return DateFormat.yMd(locale).format(date);
  }

  String formatTime(DateTime date) {
  return DateFormat.jm(locale).format(date);
}
}
