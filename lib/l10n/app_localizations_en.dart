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

  @override
  String get welcome_back => 'Welcome back. Please sign in to continue.';

  @override
  String get email_label => 'Email Address';

  @override
  String get password_label => 'Password';

  @override
  String get sign_in_button => 'Sign In';

  @override
  String get no_account => 'Don\'t have an account? Create a business';

  @override
  String get start_business => 'Start Your Business';

  @override
  String get create_business_desc =>
      'Create your account and initialize your service hub in seconds.';

  @override
  String get business_name_label => 'Business Name';

  @override
  String get business_name_hint => 'e.g. Acme Plumbing';

  @override
  String get business_name_required => 'Business Name required';

  @override
  String get create_account_button => 'Create Account';

  @override
  String get have_account => 'Already have an account? Sign In';

  @override
  String get manage_services => 'Manage Services';

  @override
  String get add_service => 'Add New Service';

  @override
  String get service_name => 'Service Name';

  @override
  String get description => 'Description';

  @override
  String get price => 'Price';

  @override
  String get add => 'Add';

  @override
  String get cancel => 'Cancel';
}
