import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  await initializeDateFormatting('ja', null);
  await initializeDateFormatting('es_PA', null);

  final jaFormat = NumberFormat.simpleCurrency(locale: 'ja');
  final paFormat = NumberFormat.simpleCurrency(locale: 'es_PA');

  print('JA Currency: "${jaFormat.format(5000)}"');
  print('PA Currency: "${paFormat.format(5000)}"');

  final date = DateTime(2026, 3, 30);
  print('JA Date: "${DateFormat.yMd('ja').format(date)}"');
  print('PA Date: "${DateFormat.yMd('es_PA').format(date)}"');
}
