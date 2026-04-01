import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking_model.dart';
import '../models/service_model.dart';
import '../providers/tenant_provider.dart';
import '../services/database_service.dart';
import '../l10n/app_localizations.dart';

class ClientIntakeForm extends StatefulWidget {
  final ServiceModel service;
  final DateTime startTime;
  final String tenantId;

  const ClientIntakeForm({
    super.key,
    required this.service,
    required this.startTime,
    required this.tenantId,
  });

  @override
  State<ClientIntakeForm> createState() => _ClientIntakeFormState();
}

class _ClientIntakeFormState extends State<ClientIntakeForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Custom Fields (Dynamic)
  final Map<String, dynamic> _customFields = {};
  
  bool _tcAccepted = false;
  bool _isSubmitting = false;

  String? _validatePhone(String? value, String businessType) {
    if (value == null || value.isEmpty) return 'Phone required';
    
    // Day 3 Mission: Regex for Panama / Japan
    // Panama: 507 + 8 digits
    final panamaRegex = RegExp(r'^\+?507[\s-]?\d{4}[\s-]?\d{4}$');
    // Japan: 81 + 9/10 digits
    final japanRegex = RegExp(r'^\+?81[\s-]?\d[\s-]?\d{4}[\s-]?\d{4}$');

    if (!panamaRegex.hasMatch(value) && !japanRegex.hasMatch(value)) {
      return 'Enter a valid Panama (+507) or Japan (+81) phone';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tenantProvider = context.watch<TenantProvider>();
    final businessType = tenantProvider.tenantConfig?['businessType'] ?? 'massage';
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.bookNow ?? 'Client Intake')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n?.serviceName ?? 'Details', style: Theme.of(context).textTheme.headlineSmall),
              Text("${widget.service.name} @ ${widget.startTime.toLocal()}"),
              const Divider(height: 32),
              
              // Common Fields
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone (Internal Format)'),
                validator: (v) => _validatePhone(v, businessType),
              ),

              const SizedBox(height: 24),
              const Text("Business Specific Info", style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),

              // Dynamic Fields based on Business Type
              if (businessType == 'massage') ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Any Allergies?'),
                  onChanged: (v) => _customFields['allergies'] = v,
                ),
                const SizedBox(height: 16),
                const Text("Preferred Pressure"),
                Wrap(
                  spacing: 8,
                  children: ['Light', 'Medium', 'Firm'].map((p) {
                    final isSelected = _customFields['pressure'] == p;
                    return ChoiceChip(
                      label: Text(p),
                      selected: isSelected,
                      onSelected: (val) => setState(() => _customFields['pressure'] = p),
                    );
                  }).toList(),
                ),
              ] else if (businessType == 'it') ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Issue Type'),
                  items: ['Hardware', 'Software', 'Network'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => _customFields['issueType'] = v,
                ),
                SwitchListTile(
                  title: const Text("Remote Access Available?"),
                  value: _customFields['remoteAccess'] ?? false,
                  onChanged: (v) => setState(() => _customFields['remoteAccess'] = v),
                ),
              ] else if (businessType == 'logistics') ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Shipment Size'),
                  onChanged: (v) => _customFields['shipmentSize'] = v,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Pickup Req. (e.g. Forklift)'),
                  onChanged: (v) => _customFields['pickupReq'] = v,
                ),
              ],

              const SizedBox(height: 24),
              CheckboxListTile(
                title: const Text("I accept terms and conditions"),
                value: _tcAccepted,
                onChanged: (v) => setState(() => _tcAccepted = v ?? false),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || !_tcAccepted) ? null : _submit,
                  child: _isSubmitting ? const CircularProgressIndicator() : const Text("Complete Booking"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final db = DatabaseService();
      
      final booking = BookingModel(
        id: '',
        tenantId: widget.tenantId,
        serviceId: widget.service.id,
        serviceName: widget.service.name,
        clientId: 'GUEST-${DateTime.now().millisecondsSinceEpoch}',
        clientName: _nameController.text,
        clientEmail: _emailController.text,
        clientPhone: _phoneController.text,
        startTime: widget.startTime.toUtc(),
        endTime: widget.startTime.add(Duration(minutes: widget.service.durationMinutes)).toUtc(),
        humanReadableId: '', // Generated by transaction
        customFields: _customFields,
      );

      final totalDurationPlusBuffer = widget.service.durationMinutes + widget.service.bufferMinutes;

      final humanId = await db.performBooking(widget.tenantId, booking, totalDurationPlusBuffer);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/booking_success', arguments: humanId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
