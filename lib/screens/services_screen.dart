import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tenant_provider.dart';
import '../services/database_service.dart';
import '../models/service_model.dart';
import '../utils/regional_formatter.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  void _showServiceDialog(BuildContext context, String tenantId, {ServiceModel? service}) {
    final nameController = TextEditingController(text: service?.name);
    final descController = TextEditingController(text: service?.description);
    final priceController = TextEditingController(text: service?.price.toString());
    final durationController = TextEditingController(text: (service?.durationMinutes ?? 60).toString());
    final isEditing = service != null;

    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(isEditing ? (l10n?.edit ?? 'Edit Service') : (l10n?.addService ?? 'Add New Service')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n?.serviceName ?? 'Service Name'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: l10n?.description ?? 'Description'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: l10n?.price ?? 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: durationController,
                decoration: InputDecoration(labelText: l10n?.durationLabel ?? 'Duration (min)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newService = ServiceModel(
                  id: service?.id ?? '',
                  name: nameController.text,
                  description: descController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  durationMinutes: int.tryParse(durationController.text) ?? 60,
                );

                if (isEditing) {
                  await DatabaseService().updateService(tenantId, newService);
                } else {
                  await DatabaseService().addService(tenantId, newService);
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? (l10n?.edit ?? 'Save') : (l10n?.add ?? 'Add')),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String tenantId, String serviceId) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n?.delete ?? 'Delete Service'),
          content: Text(l10n?.confirmDelete ?? 'Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseService().deleteService(tenantId, serviceId);
                if (context.mounted) Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n?.delete ?? 'Delete'),
            ),
          ],
        );
      },
    );
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
      appBar: AppBar(title: Text(l10n?.manageServices ?? 'Service Management')),
      body: StreamBuilder<List<ServiceModel>>(
        stream: DatabaseService().getServices(tenantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No services added yet.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final service = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(service.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatter.formatCurrency(service.price),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () => _showServiceDialog(context, tenantId, service: service),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDelete(context, tenantId, service.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceDialog(context, tenantId),
        child: const Icon(Icons.add),
      ),
    );
  }
}
