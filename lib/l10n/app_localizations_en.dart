// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'OmniService Hub';

  @override
  String get loading => 'Loading...';

  @override
  String get app_title => 'OmniService Hub Dashboard';

  @override
  String get book_button => 'Book Now';

  @override
  String get payment_confirmed => 'Payment Confirmed';

  @override
  String get select_service => 'Select a Service';
}
