import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tenant_provider.dart';
import '../services/database_service.dart';
import '../models/service_model.dart';
import '../utils/regional_formatter.dart';
import '../providers/locale_provider.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  void _showAddServiceDialog(BuildContext context, String tenantId) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Service Name')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final service = ServiceModel(
                id: '',
                name: nameController.text,
                description: descController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
              );
              await DatabaseService().addService(tenantId, service);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenantProvider = context.watch<TenantProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final tenantId = tenantProvider.tenantId;

    if (tenantId == null) return const Scaffold(body: Center(child: Text('No tenant active')));

    final formatter = RegionalFormatter(
      locale: localeProvider.locale.toString(),
      currencyCode: localeProvider.getCurrencyForLocale(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Service Management')),
      body: StreamBuilder<List<ServiceModel>>(
        stream: DatabaseService().getServices(tenantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No services added yet.'));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final service = snapshot.data![index];
              return ListTile(
                title: Text(service.name),
                subtitle: Text(service.description),
                trailing: Text(
                  formatter.formatCurrency(service.price),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                onLongPress: () => DatabaseService().deleteService(tenantId, service.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddServiceDialog(context, tenantId),
        child: const Icon(Icons.add),
      ),
    );
  }
}
