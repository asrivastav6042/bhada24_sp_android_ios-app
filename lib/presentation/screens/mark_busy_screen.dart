import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/core/di/service_locator.dart';
import 'package:bhada24_sp/data/models/availability_exception_model.dart';
import 'package:bhada24_sp/domain/repositories/i_availability_repository.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/event_service_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';
import 'package:bhada24_sp/presentation/widgets/common/toast_widget.dart';

class MarkBusyScreen extends StatefulWidget {
  const MarkBusyScreen({super.key});
  @override
  State<MarkBusyScreen> createState() => _MarkBusyScreenState();
}

class _MarkBusyScreenState extends State<MarkBusyScreen> {
  int? _selectedServiceId;
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonCtrl = TextEditingController();
  List<AvailabilityExceptionModel> _exceptions = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final spId = context.read<AuthProvider>().user?.spId;
      if (spId != null) context.read<EventServiceProvider>().loadServices(spId);
    });
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExceptions() async {
    if (_selectedServiceId == null) return;
    setState(() => _loading = true);
    final repo = getIt<IAvailabilityRepository>();
    _exceptions = await repo.getExceptions('LISTING', _selectedServiceId!);
    setState(() => _loading = false);
  }

  Future<void> _addBusy() async {
    if (_selectedServiceId == null || _startDate == null || _endDate == null) {
      showAppToast(context, 'Please fill all fields.', isError: true);
      return;
    }
    setState(() => _loading = true);
    final repo = getIt<IAvailabilityRepository>();
    final ok = await repo.addException('LISTING', _selectedServiceId!, {
      'startDate': _startDate!.toIso8601String().split('T')[0],
      'endDate': _endDate!.toIso8601String().split('T')[0],
      'reason': _reasonCtrl.text.trim(),
    });
    if (ok) {
      showAppToast(context, 'Busy dates added!');
      _reasonCtrl.clear();
      _startDate = null;
      _endDate = null;
      await _loadExceptions();
    } else {
      showAppToast(context, 'Failed.', isError: true);
    }
    setState(() => _loading = false);
  }

  Future<void> _deleteException(int id) async {
    final repo = getIt<IAvailabilityRepository>();
    await repo.deleteException(id);
    await _loadExceptions();
  }

  @override
  Widget build(BuildContext context) {
    final services = context.watch<EventServiceProvider>().services;

    return Scaffold(
      appBar: const AppHeader(title: 'Mark Busy'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Service', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedServiceId,
              items: services.map((s) => DropdownMenuItem(value: s.esId, child: Text(s.serviceName ?? 'Service ${s.esId}'))).toList(),
              onChanged: (v) {
                setState(() => _selectedServiceId = v);
                _loadExceptions();
              },
              decoration: const InputDecoration(hintText: 'Choose a service'),
            ),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (picked != null) setState(() => _startDate = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Start Date'),
                    child: Text(_startDate != null ? _startDate!.toIso8601String().split('T')[0] : 'Select', style: const TextStyle(fontSize: 14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(context: context, firstDate: _startDate ?? DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (picked != null) setState(() => _endDate = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'End Date'),
                    child: Text(_endDate != null ? _endDate!.toIso8601String().split('T')[0] : 'Select', style: const TextStyle(fontSize: 14)),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextFormField(controller: _reasonCtrl, decoration: const InputDecoration(labelText: 'Reason (optional)', hintText: 'e.g. Personal event')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _addBusy,
                child: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Mark Busy'),
              ),
            ),
            const SizedBox(height: 24),

            if (_exceptions.isNotEmpty) ...[
              const Text('Existing Busy Dates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ..._exceptions.map((e) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: Row(children: [
                      const Icon(Icons.event_busy, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${e.startDate ?? ''} - ${e.endDate ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          if (e.reason != null && e.reason!.isNotEmpty) Text(e.reason!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ]),
                      ),
                      IconButton(icon: const Icon(Icons.delete, color: AppColors.error, size: 20), onPressed: () => _deleteException(e.exceptionId!)),
                    ]),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
