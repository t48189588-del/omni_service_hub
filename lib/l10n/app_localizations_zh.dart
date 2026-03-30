// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'OmniService Hub';

  @override
  String get loading => '加载中...';

  @override
  String get app_title => 'OmniService Hub 仪表板';

  @override
  String get book_button => '立即预订';

  @override
  String get payment_confirmed => '支付已确认';

  @override
  String get select_service => '选择服务';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appName => 'OmniService Hub';

  @override
  String get loading => '加载中...';

  @override
  String get app_title => 'OmniService Hub 仪表板';

  @override
  String get book_button => '立即预订';

  @override
  String get payment_confirmed => '支付已确认';

  @override
  String get select_service => '选择服务';
}
