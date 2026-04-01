import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../providers/tenant_provider.dart';
import '../services/database_service.dart';
import '../models/service_model.dart';
import '../models/booking_model.dart';
import '../utils/regional_formatter.dart';
import '../providers/locale_provider.dart';
import '../providers/booking_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/locale_switcher.dart';
import 'client_intake_form.dart';

class BookingPage extends StatefulWidget {
  final String tenantId;
  const BookingPage({super.key, required this.tenantId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now().add(const Duration(days: 1));
  DateTime? _selectedDay;
  ServiceModel? _selectedService;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _onServiceSelected(ServiceModel service) {
    setState(() {
      _selectedService = service;
    });
    // Trigger slot fetch
    context.read<BookingProvider>().fetchAvailableSlots(widget.tenantId, service);
  }

  void _onSlotSelected(DateTime slot) {
    if (_selectedService == null) return;
    
    // Day 3: Navigate to dynamic intake form
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientIntakeForm(
          service: _selectedService!,
          startTime: slot,
          tenantId: widget.tenantId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.bookNow ?? 'Booking Engine'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: const [LocaleSwitcher()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stage 1: Service selection
            _buildServiceSection(context),
            
            if (_selectedService != null) ...[
              const Divider(),
              // Stage 2: Calendar selection
              _buildCalendarSection(),
              
              const Divider(),
              // Stage 3: Slot selection
              _buildSlotsSection(bookingProvider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n?.selectService ?? '1. Select Service', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          StreamBuilder<List<ServiceModel>>(
            stream: DatabaseService().getServices(widget.tenantId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              return SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final s = snapshot.data![index];
                    final isSelected = _selectedService?.id == s.id;
                    return GestureDetector(
                      onTap: () => _onServiceSelected(s),
                      child: Card(
                        color: isSelected ? Colors.indigo : null,
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(s.name, style: TextStyle(color: isSelected ? Colors.white : null, fontWeight: FontWeight.bold)),
                              Text("${s.durationMinutes} min", style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 90)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        if (_selectedService != null) {
          context.read<BookingProvider>().setSelectedDay(selectedDay, widget.tenantId, _selectedService!);
        }
      },
      onFormatChanged: (format) {
        setState(() => _calendarFormat = format);
      },
    );
  }

  Widget _buildSlotsSection(BookingProvider provider) {
    if (provider.isLoading) return const Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator());
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Select a Time Slot (Includes buffer time)", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (provider.availableSlots.isEmpty)
            const Text("No available times for this day.", style: TextStyle(color: Colors.grey))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.availableSlots.map((slot) {
                return ChoiceChip(
                  label: Text(DateFormat.jm().format(slot.toLocal())),
                  selected: false,
                  onSelected: (val) => _onSlotSelected(slot),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
