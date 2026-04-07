import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tenant_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/locale_switcher.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onShowRegister;
  const LoginScreen({super.key, required this.onShowRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<TenantProvider>().login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    } catch (e) {
      // Error is now also handled in the provider and exposed via errorMessage
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tenantProvider = context.watch<TenantProvider>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.topRight,
                    child: LocaleSwitcher(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.appName ?? 'OmniService Hub',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n?.welcomeBack ?? "Welcome back. Please sign in to continue.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (tenantProvider.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        tenantProvider.errorMessage!,
                        style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n?.emailLabel ?? 'Email Address',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n?.passwordLabel ?? 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _login,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(l10n?.signInButton ?? 'Sign In'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: widget.onShowRegister,
                    child: Text(l10n?.noAccount ?? "Don't have an account? Create a business"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
