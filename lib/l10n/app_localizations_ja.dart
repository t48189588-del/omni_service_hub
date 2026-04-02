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
  String get businessActive => 'ビジネス有効';

  @override
  String get tenantIdLabel => 'テナントID';

  @override
  String get regionalPrecision => '地域の書式設定';

  @override
  String get samplePrice => 'サンプル価格';

  @override
  String get currentDate => '現在の日付';

  @override
  String get durationLabel => '所要時間（分）';

  @override
  String get conflictError => 'この枠はすでに予約されています。別の時間を選択してください。';

  @override
  String get bookingSuccess => '予約が確定しました！承認待ちです。';

  @override
  String get pending => '保留中';

  @override
  String get confirmed => '承認済み';

  @override
  String get cancelled => 'キャンセル';

  @override
  String get approve => '承認';

  @override
  String get reschedule => '再スケジュール';

  @override
  String get loading => '読み込み中...';

  @override
  String get appTitle => 'OmniService Hub ダッシュボード';

  @override
  String get bookNow => '今すぐ予約';

  @override
  String get settings => '設定';

  @override
  String get currencySymbol => '￥';

  @override
  String get paymentConfirmed => '支払いが完了しました';

  @override
  String get selectService => 'サービスを選択';

  @override
  String get welcomeBack => 'おかえりなさい。サインインして続行してください。';

  @override
  String get emailLabel => 'メールアドレス';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get signInButton => 'サインイン';

  @override
  String get noAccount => 'アカウントをお持ちでないですか？ビジネスを作成';

  @override
  String get startBusiness => 'ビジネスを開始';

  @override
  String get createBusinessDesc => '数秒でアカウントを作成し、サービスハブを初期化します。';

  @override
  String get businessNameLabel => 'ビジネス名';

  @override
  String get businessNameHint => '例：アクメ配管';

  @override
  String get businessNameRequired => 'ビジネス名は必須です';

  @override
  String get createAccountButton => 'アカウント作成';

  @override
  String get haveAccount => 'すでにアカウントをお持ちですか？サインイン';

  @override
  String get businessTypeLabel => 'Business Type';

  @override
  String get businessTypeHint => 'e.g. Salon, Consulting, Logistics';

  @override
  String get manageServices => 'サービス管理';

  @override
  String get manageAppointments => '予約管理';

  @override
  String get addService => '新しいサービスを追加';

  @override
  String get serviceName => 'サービス名';

  @override
  String get description => '説明';

  @override
  String get price => '価格';

  @override
  String get add => '追加';

  @override
  String get cancel => 'キャンセル';

  @override
  String get edit => '編集';

  @override
  String get delete => '削除';

  @override
  String get confirmDelete => 'このサービスを削除してもよろしいですか？';
}
