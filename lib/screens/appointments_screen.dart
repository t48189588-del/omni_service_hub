import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tenant_provider.dart';
import '../services/database_service.dart';
import '../models/appointment_model.dart';
import '../utils/regional_formatter.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  void _reschedule(BuildContext context, String tenantId, AppointmentModel app) async {
    final l10n = AppLocalizations.of(context);
    final db = DatabaseService();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: app.startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (pickedDate == null || !context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(app.startTime),
    );

    if (pickedTime == null || !context.mounted) return;

    final newStart = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final duration = app.endTime.difference(app.startTime).inMinutes;
    final isAvailable = await db.checkAvailability(tenantId, newStart, duration);

    if (!isAvailable) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.conflictError ?? 'Conflict!')),
        );
      }
      return;
    }

    // Since we don't have a direct "reschedule" field update, 
    // we'll update the whole document (or just the fields we need).
    // For now, I'll update startTime and endTime via updateAppointmentStatus 
    // (I should probably have a generic updateAppointment in DatabaseService).
    // I'll update DatabaseService next.
  }

  @override
  Widget build(BuildContext context) {
    final tenantProvider = context.watch<TenantProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    final tenantId = tenantProvider.tenantId;

    if (tenantId == null) return const Scaffold(body: Center(child: Text('No tenant active')));

    final formatter = RegionalFormatter(
      locale: localeProvider.locale.toString(),
      currencyCode: localeProvider.getCurrencyForLocale(),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.appTitle ?? 'Manage Appointments')),
      body: StreamBuilder<List<AppointmentModel>>(
        stream: DatabaseService().getAppointments(tenantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No appointments yet.'));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final app = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: _getStatusIcon(app.status),
                      title: Text("${app.serviceName} - ${app.customerName}"),
                      subtitle: Text(
                        "${formatter.formatDate(app.startTime)} @ ${TimeOfDay.fromDateTime(app.startTime).format(context)}",
                      ),
                      trailing: Text(
                        _getStatusLabel(app.status, l10n),
                        style: TextStyle(
                          color: _getStatusColor(app.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (app.status == AppointmentStatus.pending)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => DatabaseService().updateAppointmentStatus(tenantId, app.id, AppointmentStatus.cancelled),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: Text(l10n?.cancelled ?? 'Cancel'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => DatabaseService().updateAppointmentStatus(tenantId, app.id, AppointmentStatus.confirmed),
                              child: Text(l10n?.approve ?? 'Approve'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Icon _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending: return const Icon(Icons.hourglass_empty, color: Colors.orange);
      case AppointmentStatus.confirmed: return const Icon(Icons.check_circle_outline, color: Colors.green);
      case AppointmentStatus.cancelled: return const Icon(Icons.cancel_outlined, color: Colors.red);
    }
  }

  String _getStatusLabel(AppointmentStatus status, AppLocalizations? l10n) {
    switch (status) {
      case AppointmentStatus.pending: return l10n?.pending ?? 'Pending';
      case AppointmentStatus.confirmed: return l10n?.confirmed ?? 'Confirmed';
      case AppointmentStatus.cancelled: return l10n?.cancelled ?? 'Cancelled';
    }
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending: return Colors.orange;
      case AppointmentStatus.confirmed: return Colors.green;
      case AppointmentStatus.cancelled: return Colors.red;
    }
  }
}
