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
  String get businessActive => 'Business Active';

  @override
  String get tenantIdLabel => 'Tenant ID';

  @override
  String get regionalPrecision => 'Regional Precision';

  @override
  String get samplePrice => 'Sample Price';

  @override
  String get currentDate => 'Current Date';

  @override
  String get durationLabel => 'Duration (min)';

  @override
  String get conflictError =>
      'This slot is already booked. Please choose another.';

  @override
  String get bookingSuccess => 'Booking confirmed! Awaiting approval.';

  @override
  String get pending => 'Pending';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get approve => 'Approve';

  @override
  String get reschedule => 'Reschedule';

  @override
  String get loading => 'Loading...';

  @override
  String get appTitle => 'OmniService Hub Dashboard';

  @override
  String get bookNow => 'Book Now';

  @override
  String get settings => 'Settings';

  @override
  String get currencySymbol => '\$';

  @override
  String get paymentConfirmed => 'Payment Confirmed';

  @override
  String get selectService => 'Select a Service';

  @override
  String get welcomeBack => 'Welcome back. Please sign in to continue.';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signInButton => 'Sign In';

  @override
  String get noAccount => 'Don\'t have an account? Create a business';

  @override
  String get startBusiness => 'Start Your Business';

  @override
  String get createBusinessDesc =>
      'Create your account and initialize your service hub in seconds.';

  @override
  String get businessNameLabel => 'Business Name';

  @override
  String get businessNameHint => 'e.g. Acme Plumbing';

  @override
  String get businessNameRequired => 'Business Name required';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get haveAccount => 'Already have an account? Sign In';

  @override
  String get businessTypeLabel => 'Business Type';

  @override
  String get businessTypeHint => 'e.g. Salon, Consulting, Logistics';

  @override
  String get manageServices => 'Manage Services';

  @override
  String get manageAppointments => 'Manage Appointments';

  @override
  String get addService => 'Add New Service';

  @override
  String get serviceName => 'Service Name';

  @override
  String get description => 'Description';

  @override
  String get price => 'Price';

  @override
  String get add => 'Add';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Are you sure you want to delete this service?';
}
