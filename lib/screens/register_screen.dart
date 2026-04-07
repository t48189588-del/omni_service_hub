import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tenant_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/locale_switcher.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onShowLogin;
  const RegisterScreen({super.key, required this.onShowLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<TenantProvider>().registerAndInitialize(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            businessName: _businessNameController.text.trim(),
          );
          // 2. Navigate to Settings
        // We use pushReplacementNamed so the user can't "Go Back" to the signup form
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/settings');
          
          // Optional: Show a quick success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Welcome! Let's finish your business setup.")),
          );
        }
    } catch (e) {
      // Error is now handled in the Provider and shown in the UI
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
                    l10n?.startBusiness ?? "Start Your Business",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                    Text(
                      l10n?.createBusinessDesc ?? "Create your account and initialize your service hub in seconds.",
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
                    controller: _businessNameController,
                    decoration: InputDecoration(
                      labelText: l10n?.businessNameLabel ?? 'Business Name',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.business_outlined),
                      hintText: l10n?.businessNameHint ?? 'e.g. Acme Plumbing',
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? (l10n?.businessNameRequired ?? 'Business Name required') : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n?.emailLabel ?? 'Admin Email',
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
                      labelText: l10n?.passwordLabel ?? 'Secure Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _register,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(l10n?.createAccountButton ?? 'Create Account'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: widget.onShowLogin,
                    child: Text(l10n?.haveAccount ?? "Already have an account? Sign In"),
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
