import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'providers/tenant_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/booking_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/services_screen.dart';
import 'screens/booking_page.dart';
import 'screens/appointments_screen.dart';
import 'screens/booking_success_screen.dart';
import 'utils/regional_formatter.dart';
import 'widgets/locale_switcher.dart';
import 'screens/admin_dashboard.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => TenantProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: const OmniServiceHubApp(),
    ),
  );
}

class OmniServiceHubApp extends StatelessWidget {
  const OmniServiceHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'OmniService Hub',
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      onGenerateRoute: (settings) {
        if (settings.name == '/booking') {
          final tenantId = settings.arguments as String?;
          if (tenantId != null) {
            return MaterialPageRoute(
              builder: (context) => BookingPage(tenantId: tenantId),
            );
          }
        }
        if (settings.name == '/booking_success') {
          final humanId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => BookingSuccessScreen(humanReadableId: humanId),
          );
        }
        if (settings.name == '/appointments') {
          return MaterialPageRoute(
            builder: (context) => const AppointmentsScreen(),
          );
        }
        if (settings.name == '/settings') {
          return MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          );
        }
        return null;
      },
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
      // home: const DashboardScreen(),
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

    if (tenantProvider.tenantId != null) {
      return const DashboardScreen();
    }

    if (_showLogin) {
      return LoginScreen(onShowRegister: _toggleView);
    } else {
      return RegisterScreen(onShowLogin: _toggleView);
    }
  }
}
