import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ja', null);
    await initializeDateFormatting('es_PA', null);
  });

  test('Currency formatting should respect locale rules', () {
    final jaFormat = NumberFormat.simpleCurrency(locale: 'ja');
    final paFormat = NumberFormat.simpleCurrency(locale: 'es_PA');

    // Note: jaFormat.format(5000) for locale 'ja' is usually '￥5,000'
    // paFormat.format(5000) for locale 'es_PA' with default 'USD' is 'USD 5,000.00'
    expect(jaFormat.format(5000), equals('￥5,000')); // No decimals
    expect(paFormat.format(5000), equals('USD 5,000.00')); // Two decimals
  });

  test('Date formatting should follow cultural patterns', () {
    final date = DateTime(2026, 3, 30);
    expect(DateFormat.yMd('ja').format(date), equals('2026/03/30'));
    expect(DateFormat.yMd('es_PA').format(date), equals('30/3/2026'));
  });
}
