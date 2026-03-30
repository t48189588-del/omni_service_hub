import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'providers/tenant_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'utils/regional_formatter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      title: 'OmniService Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('ja'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      ],
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showLogin = true;

  void _toggleView() {
    setState(() => _showLogin = !_showLogin);
  }

  @override
  Widget build(BuildContext context) {
    final tenantProvider = context.watch<TenantProvider>();
    final l10n = AppLocalizations.of(context);

    // 1. Loading state (Authenticating or fetching Tenant)
    if (tenantProvider.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n?.loading ?? "Initializing Hub..."),
            ],
          ),
        ),
      );
    }

    // 2. Logged In and Tenant Loaded
    if (tenantProvider.tenantId != null) {
      return const DashboardScreen();
    }

    // 3. Not Logged In
    if (_showLogin) {
      return LoginScreen(onShowRegister: _toggleView);
    } else {
      return RegisterScreen(onShowLogin: _toggleView);
    }
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tenantProvider = context.watch<TenantProvider>();
    final config = tenantProvider.tenantConfig;
    final l10n = AppLocalizations.of(context);
    
    // Determine active locale and currency
    final String currentLocale = Localizations.localeOf(context).toString();
    final String currentCurrency = config?['config']?['currency'] ?? 'USD';

    final formatter = RegionalFormatter(
      locale: currentLocale,
      currencyCode: currentCurrency,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(config?['name'] ?? l10n?.app_title ?? 'Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<TenantProvider>().logout(),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.business_center_outlined, size: 64, color: Colors.indigo),
            const SizedBox(height: 16),
            Text(
              "Business Active", 
              style: Theme.of(context).textTheme.headlineSmall
            ),
            const SizedBox(height: 8),
            Text("Tenant ID: ${tenantProvider.tenantId}"),
            const SizedBox(height: 32),
            
            // Regional Formatting Demo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("Regional Precision", style: Theme.of(context).textTheme.titleMedium),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.payments_outlined),
                      title: const Text("Sample Price"),
                      trailing: Text(
                        formatter.formatCurrency(15000.0),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text("Current Date"),
                      trailing: Text(formatter.formatDate(DateTime.now())),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Localized Actions Demo
            Wrap(
              spacing: 16,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(l10n?.book_button ?? 'Book'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                  label: Text(l10n?.select_service ?? 'Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
