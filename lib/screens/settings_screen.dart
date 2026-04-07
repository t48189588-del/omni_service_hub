import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tenant_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/locale_switcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  int _startHour = 9;
  int _endHour = 17;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final config = context.read<TenantProvider>().tenantConfig;
    if (config != null) {
      _nameController.text = config['name'] ?? '';
      _typeController.text = config['businessType'] ?? '';
      
      final bHours = config['config']?['businessHours'];
      if (bHours != null) {
        // Convert from 900 to 9 etc.
        _startHour = bHours['start'] ~/ 100;
        _endHour = bHours['end'] ~/ 100;
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Logical Business Hour Validation
    if (_endHour <= _startHour) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Validation Error: Closing hour must be later than opening hour.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      // Fetch current config to safely update nested fields
      final tenantProvider = context.read<TenantProvider>();
      final currentConfig = Map<String, dynamic>.from(tenantProvider.tenantConfig?['config'] ?? {});
      
      currentConfig['businessHours'] = {
        'start': _startHour * 100,
        'end': _endHour * 100,
      };

      await tenantProvider.updateBusinessSettings({
        'name': _nameController.text,
        'businessType': _typeController.text,
        'config': currentConfig,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved successfully.')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settings ?? 'Settings'),
        actions: const [LocaleSwitcher()],
      ),
      body: _isSaving 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Business Profile", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n?.businessNameLabel ?? 'Business Name',
                        hintText: l10n?.businessNameHint,
                      ),
                      validator: (v) => v == null || v.isEmpty ? (l10n?.businessNameRequired ?? 'Required') : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _typeController,
                      decoration: const InputDecoration(
                        labelText: 'Business Type',
                        hintText: 'e.g. Salon, Consulting, Logistics',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),
                    
                    Text("Business Hours", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _startHour,
                            decoration: const InputDecoration(labelText: 'Opening Hour'),
                            items: List.generate(24, (i) => DropdownMenuItem(value: i, child: Text("$i:00"))),
                            onChanged: (v) => setState(() => _startHour = v ?? 9),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _endHour,
                            decoration: const InputDecoration(labelText: 'Closing Hour'),
                            items: List.generate(24, (i) => DropdownMenuItem(value: i, child: Text("$i:00"))),
                            onChanged: (v) => setState(() => _endHour = v ?? 17),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        child: const Text('Save Settings'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
