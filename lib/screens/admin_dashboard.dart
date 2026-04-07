import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tenant_provider.dart';
import '../providers/locale_provider.dart';
import '../models/booking_model.dart';
import '../services/database_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/regional_formatter.dart';
import '../widgets/locale_switcher.dart';
import 'services_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tenantProvider = context.watch<TenantProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final config = tenantProvider.tenantConfig;
    final l10n = AppLocalizations.of(context);
    
    final String currentLocale = localeProvider.locale.toString();
    final String currencyCode = (config?['config']?['currency']) ?? 'USD';

    final formatter = RegionalFormatter(
      locale: currentLocale,
      currencyCode: currencyCode,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(config?['name'] ?? l10n?.appTitle ?? 'Dashboard'),
        actions: [
          const LocaleSwitcher(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<TenantProvider>().logout(),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.business, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    config?['name'] ?? 'OmniService Hub',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context), // Already there
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: Text(l10n?.manageServices ?? 'Manage Services'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ServicesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(l10n?.manageAppointments ?? 'Manage Appointments'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/appointments');
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Public Booking Link'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/booking', arguments: tenantProvider.tenantId);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(l10n?.settings ?? 'Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                context.read<TenantProvider>().logout();
              },
            ),
          ],
        ),
      ),
      body: tenantProvider.tenantId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<BookingModel>>(
              stream: DatabaseService().getTodayBookings(tenantProvider.tenantId!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error loading agenda: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final sortedBookings = snapshot.data!;
                
                // Calculate today's confirmed revenue
                double totalRevenue = 0;
                final confirmedBookings = sortedBookings.where((b) => b.status == BookingStatus.confirmed);
                for (var b in confirmedBookings) {
                  totalRevenue += b.price;
                }

                return Column(
                  children: [
                    _buildAnalyticsHeader(context, formatter, totalRevenue, confirmedBookings.length, l10n),
                    const Divider(),
                    Expanded(
                      child: sortedBookings.isEmpty
                          ? Center(child: Text("No bookings for today.", style: Theme.of(context).textTheme.titleMedium))
                          : ListView.builder(
                              itemCount: sortedBookings.length,
                              itemBuilder: (context, index) {
                                final booking = sortedBookings[index];
                                return ListTile(
                                  leading: const Icon(Icons.event_seat),
                                  title: Text(
                                    "Client: ${(booking.clientId?.isNotEmpty ?? false) ? booking.clientName : 'Guest'}",
                                  ),
                                  subtitle: Text("Date: ${formatter.formatDate(booking.startTime)} Time: ${formatter.formatTime(booking.startTime)}"),                      
                                  trailing: Chip(
                                    label: Text(booking.status.name.toUpperCase()),
                                    backgroundColor: booking.status == BookingStatus.confirmed ? Colors.green.shade100 : Colors.grey.shade200,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ServicesScreen()),
        ),
        child: const Icon(Icons.category),
        tooltip: l10n?.manageServices ?? 'Manage Services',
      ),
    );
  }

  Widget _buildAnalyticsHeader(BuildContext context, RegionalFormatter formatter, double revenue, int count, AppLocalizations? l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatCard(title: "Today's Revenue", value: formatter.formatCurrency(revenue)),
          _StatCard(title: "Confirmed", value: "$count"),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.indigo, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
