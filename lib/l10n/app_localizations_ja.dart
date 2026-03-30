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

  @override
  String get welcome_back => 'おかえりなさい。続行するにはサインインしてください。';

  @override
  String get email_label => 'メールアドレス';

  @override
  String get password_label => 'パスワード';

  @override
  String get sign_in_button => 'サインイン';

  @override
  String get no_account => 'アカウントをお持ちでないですか？ビジネスを作成';

  @override
  String get start_business => 'ビジネスを開始';

  @override
  String get create_business_desc => 'アカウントを作成し、数秒でサービスハブを初期化します。';

  @override
  String get business_name_label => 'ビジネス名';

  @override
  String get business_name_hint => '例: Acme配管';

  @override
  String get business_name_required => 'ビジネス名が必要です';

  @override
  String get create_account_button => 'アカウント作成';

  @override
  String get have_account => 'すでにアカウントをお持ちですか？サインイン';

  @override
  String get manage_services => 'サービス管理';

  @override
  String get add_service => '新しいサービスを追加';

  @override
  String get service_name => 'サービス名';

  @override
  String get description => '説明';

  @override
  String get price => '価格';

  @override
  String get add => '追加';

  @override
  String get cancel => 'キャンセル';
}
