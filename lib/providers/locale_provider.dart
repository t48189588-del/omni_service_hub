import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  // Helper to determine the currency based on the language
  String getCurrencyForLocale() {
    switch (_locale.languageCode) {
      case 'ja':
        return 'JPY';
      case 'es':
        return 'USD'; // Assuming USD for Panama/General Spanish
      case 'zh':
        return 'CNY'; // Simplified Chinese
      default:
        return 'USD';
    }
  }
}
