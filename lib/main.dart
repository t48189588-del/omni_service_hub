import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'providers/tenant_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with placeholders
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error (expected if default placeholder is used): $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TenantProvider()),
      ],
      child: const OmniServiceHubApp(),
    ),
  );
}

class OmniServiceHubApp extends StatelessWidget {
  const OmniServiceHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniService Hub', // A static fallback
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Set up Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('ja'), // Japanese
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'), // Simplified Chinese
      ],
      home: const InitializationScreen(),
    );
  }
}

class InitializationScreen extends StatelessWidget {
  const InitializationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tenantProvider = context.watch<TenantProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.appName ?? 'OmniService Hub'),
      ),
      body: Center(
        child: tenantProvider.isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n?.loading ?? 'Loading...'),
                ],
              )
            : Text(
                tenantProvider.tenantId != null
                    ? 'Active Tenant: ${tenantProvider.tenantId}'
                    : 'No Tenant Active\n(User not logged in or unassigned)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
      ),
    );
  }
}
