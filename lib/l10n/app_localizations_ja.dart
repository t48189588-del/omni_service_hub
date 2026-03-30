// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'OmniService Hub';

  @override
  String get loading => '読み込み中...';

  @override
  String get app_title => 'OmniService Hub ダッシュボード';

  @override
  String get book_button => '今すぐ予約';

  @override
  String get payment_confirmed => '支払い完了';

  @override
  String get select_service => 'サービスを選択';
}
