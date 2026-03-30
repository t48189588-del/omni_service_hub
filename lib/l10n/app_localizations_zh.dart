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

  @override
  String get welcome_back => '欢迎回来。请登录以继续。';

  @override
  String get email_label => '电子邮件';

  @override
  String get password_label => '密码';

  @override
  String get sign_in_button => '登录';

  @override
  String get no_account => '还没有账号？创建业务';

  @override
  String get start_business => '开始您的业务';

  @override
  String get create_business_desc => '在几秒钟内创建您的账号并初始化您的服务中心。';

  @override
  String get business_name_label => '业务名称';

  @override
  String get create_account_button => '创建账号';

  @override
  String get have_account => '已经有账号了？登录';

  @override
  String get manage_services => '管理服务';

  @override
  String get add_service => '添加新服务';

  @override
  String get service_name => '服务名称';

  @override
  String get description => '描述';

  @override
  String get price => '价格';

  @override
  String get add => '添加';

  @override
  String get cancel => '取消';
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
