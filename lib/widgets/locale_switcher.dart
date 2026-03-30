import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class LocaleSwitcher extends StatelessWidget {
  const LocaleSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return DropdownButton<Locale>(
      value: localeProvider.locale,
      icon: const Icon(Icons.language, color: Colors.indigo),
      underline: const SizedBox(),
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          localeProvider.setLocale(newLocale);
        }
      },
      items: const [
        DropdownMenuItem(
          value: Locale('en'),
          child: Text('English (EN)'),
        ),
        DropdownMenuItem(
          value: Locale('es'),
          child: Text('Español (ES)'),
        ),
        DropdownMenuItem(
          value: Locale('ja'),
          child: Text('日本語 (JA)'),
        ),
        DropdownMenuItem(
          value: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
          child: Text('简体中文 (ZH)'),
        ),
      ],
    );
  }
}
