import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tenant_provider.dart';
import '../services/database_service.dart';
import '../models/service_model.dart';
import '../utils/regional_formatter.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

import '../widgets/locale_switcher.dart';
import '../models/appointment_model.dart';

class BookingPage extends StatefulWidget {
  final String tenantId;
  const BookingPage({super.key, required this.tenantId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  Future<void> _startBookingFlow(BuildContext context, ServiceModel service) async {
    final l10n = AppLocalizations.of(context);
    
    // 1. Pick Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      helpText: l10n?.selectService ?? 'Select Booking Date',
    );

    if (pickedDate == null || !mounted) return;

    // 2. Pick Time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (pickedTime == null || !mounted) return;

    final startDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // 3. Collect Customer Info
    _showCustomerInfoDialog(context, service, startDateTime);
  }

  void _showCustomerInfoDialog(BuildContext context, ServiceModel service, DateTime startTime) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final l10n = AppLocalizations.of(context);
    final db = DatabaseService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.bookNow ?? 'Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Your Name')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email Address')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n?.cancel ?? 'Cancel')),
          ElevatedButton(
            onPressed: () async {
              final isAvailable = await db.checkAvailability(
                widget.tenantId, 
                startTime, 
                service.durationMinutes
              );

              if (!isAvailable) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n?.conflictError ?? 'Slot taken!')),
                  );
                }
                return;
              }

              final appointment = AppointmentModel(
                id: '',
                serviceId: service.id,
                serviceName: service.name,
                customerName: nameController.text,
                customerEmail: emailController.text,
                startTime: startTime,
                endTime: startTime.add(Duration(minutes: service.durationMinutes)),
                status: AppointmentStatus.pending,
              );

              await db.createAppointment(widget.tenantId, appointment);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n?.bookingSuccess ?? 'Confirmed!')),
                );
              }
            },
            child: Text(l10n?.add ?? 'Book'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);

    final formatter = RegionalFormatter(
      locale: localeProvider.locale.toString(),
      currencyCode: localeProvider.getCurrencyForLocale(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.bookNow ?? 'Book a Service'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: const [LocaleSwitcher()],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.indigo.withOpacity(0.05),
            child: Column(
              children: [
                const Icon(Icons.storefront, size: 48, color: Colors.indigo),
                const SizedBox(height: 8),
                Text(
                  l10n?.selectService ?? 'Available Services',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ServiceModel>>(
              stream: DatabaseService().getServices(widget.tenantId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No services available.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final service = snapshot.data![index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    service.description,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${l10n?.durationLabel ?? 'Duration'}: ${service.durationMinutes} min",
                                    style: const TextStyle(fontSize: 12, color: Colors.indigo),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatter.formatCurrency(service.price),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.indigo,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => _startBookingFlow(context, service),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(l10n?.bookNow ?? 'Book'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
