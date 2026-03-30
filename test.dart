import 'package:intl/intl.dart';

void verifyCurrency(String locale, double amount) {
  // Japan (ja) should have 0 decimals, USA (en) should have 2
  final format = NumberFormat.simpleCurrency(locale: locale);
  print("Locale: $locale | Output: ${format.format(amount)}");
}

// Run this in your terminal or a test file
verifyCurrency('ja', 5500.0); // Expected: ¥5,500
verifyCurrency('en_US', 5500.0); // Expected: $5,500.00