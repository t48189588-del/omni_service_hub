import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tenant_provider.dart';
import '../services/database_service.dart';
import '../models/booking_model.dart';
import '../utils/regional_formatter.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

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
      body: StreamBuilder<List<BookingModel>>(
        stream: DatabaseService().getBookings(tenantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No bookings yet.'));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final booking = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: _getStatusIcon(booking.status),
                      title: Text("${booking.serviceName} - ${booking.clientName}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${formatter.formatDate(booking.startTime)} @ ${TimeOfDay.fromDateTime(booking.startTime).format(context)}"),
                          Text("ID: ${booking.humanReadableId}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      trailing: Text(
                        _getStatusLabel(booking.status, l10n),
                        style: TextStyle(
                          color: _getStatusColor(booking.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (booking.status == BookingStatus.confirmed) // Or whatever logic for cancellation
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => DatabaseService().updateBookingStatus(tenantId, booking.id, BookingStatus.cancelled),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: Text(l10n?.cancelled ?? 'Cancel'),
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

  Icon _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed: return const Icon(Icons.check_circle_outline, color: Colors.green);
      case BookingStatus.cancelled: return const Icon(Icons.cancel_outlined, color: Colors.red);
    }
  }

  String _getStatusLabel(BookingStatus status, AppLocalizations? l10n) {
    switch (status) {
      case BookingStatus.confirmed: return l10n?.confirmed ?? 'Confirmed';
      case BookingStatus.cancelled: return l10n?.cancelled ?? 'Cancelled';
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed: return Colors.green;
      case BookingStatus.cancelled: return Colors.red;
    }
  }
}
