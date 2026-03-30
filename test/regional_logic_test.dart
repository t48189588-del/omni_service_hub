import 'package:flutter_test/flutter_test.dart';
import 'package:omni_service_hub/utils/regional_formatter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ja', null);
    await initializeDateFormatting('es_PA', null);
    await initializeDateFormatting('en_US', null);
  });

  group('RegionalFormatter Currency Tests', () {
    test('JPY should have 0 decimals', () {
      final formatter = RegionalFormatter(locale: 'ja', currencyCode: 'JPY');
      // NumberFormat adding symbols/formatting depends on locale, 
      // but we care about the 0 decimals.
      final result = formatter.formatCurrency(1234.56);
      expect(result.contains('.'), isFalse);
      expect(result.contains('1,235') || result.contains('1235'), isTrue);
    });

    test('USD should have 2 decimals', () {
      final formatter = RegionalFormatter(locale: 'en_US', currencyCode: 'USD');
      final result = formatter.formatCurrency(1234.5);
      expect(result.contains('.50'), isTrue);
    });

    test('PAB should have 2 decimals', () {
      final formatter = RegionalFormatter(locale: 'es_PA', currencyCode: 'PAB');
      final result = formatter.formatCurrency(100.0);
      expect(result.contains('100,00') || result.contains('100.00'), isTrue);
    });
  });

  group('RegionalFormatter Date Tests', () {
    final testDate = DateTime(2026, 3, 30);

    test('Japanese format should be Y/M/D style', () {
      final formatter = RegionalFormatter(locale: 'ja', currencyCode: 'JPY');
      final result = formatter.formatDate(testDate);
      // ja locale yMd is typically 2026/03/30 or similar
      expect(result, contains('2026'));
      expect(result, contains('3'));
      expect(result, contains('30'));
    });

    test('Panama Spanish format should be D/M/Y style', () {
      final formatter = RegionalFormatter(locale: 'es_PA', currencyCode: 'USD');
      final result = formatter.formatDate(testDate);
      // es_PA locale yMd is typically 30/3/2026
      expect(result.startsWith('30'), isTrue);
      expect(result.endsWith('2026'), isTrue);
    });
  });
}
