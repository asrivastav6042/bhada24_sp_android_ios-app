import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/core/di/service_locator.dart';
import 'package:bhada24_sp/data/models/availability_exception_model.dart';
import 'package:bhada24_sp/data/models/event_service_model.dart';
import 'package:bhada24_sp/domain/repositories/i_availability_repository.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/event_service_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/bottom_nav.dart';
import 'package:bhada24_sp/presentation/widgets/common/toast_widget.dart';

class MarkBusyScreen extends StatefulWidget {
  const MarkBusyScreen({super.key});
  @override
  State<MarkBusyScreen> createState() => _MarkBusyScreenState();
}

class _MarkBusyScreenState extends State<MarkBusyScreen> {
  static const String _availabilityServiceType = 'EVENT';
  static const String _listingServiceType = 'listing_service';
  static const List<String> _busyReasons = [
    'External Booking',
    'Booking from Bhada24',
    'Personal Work',
    'Maintenance',
    'Not Available',
  ];

  bool _viewAllMode = false;
  String? _selectedServiceType = _listingServiceType;
  int? _selectedServiceId;
  DateTime? _selectedDate;
  String? _selectedReason;
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<AvailabilityExceptionModel> _selectedExceptions = [];
  List<AvailabilityExceptionModel> _allExceptions = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadListingServices(preselectFirst: true);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<EventServiceModel> get _listingServices =>
      context
          .read<EventServiceProvider>()
          .services
          .where((service) => service.esId != null)
          .toList();

  EventServiceModel? get _selectedService {
    for (final service in _listingServices) {
      if (service.esId == _selectedServiceId) {
        return service;
      }
    }
    return null;
  }

  Future<void> _loadListingServices({bool preselectFirst = false}) async {
    final spId = context.read<AuthProvider>().user?.spId;
    if (spId == null) return;

    await context.read<EventServiceProvider>().loadServices(spId);
    final services = _listingServices;

    if (!mounted) return;

    setState(() {
      if (services.isEmpty) {
        _selectedServiceId = null;
        _selectedExceptions = [];
        _allExceptions = [];
        return;
      }

      final hasSelectedService = services.any(
        (service) => service.esId == _selectedServiceId,
      );

      if (preselectFirst || !hasSelectedService) {
        _selectedServiceId = services.first.esId;
      }
    });

    if (_selectedServiceId != null) {
      await _loadExceptions();
    }
    await _loadAllExceptions();
  }

  Future<void> _loadExceptions() async {
    if (_selectedServiceId == null) return;
    setState(() => _loading = true);
    final repo = getIt<IAvailabilityRepository>();
    final result = await repo.getExceptions(
      _availabilityServiceType,
      _selectedServiceId!,
    );
    if (!mounted) return;
    setState(() {
      _selectedExceptions = result;
      _loading = false;
    });
  }

  Future<void> _loadAllExceptions() async {
    final services = _listingServices;
    if (services.isEmpty) return;

    setState(() => _loading = true);
    final repo = getIt<IAvailabilityRepository>();
    final all = <AvailabilityExceptionModel>[];

    for (final service in services) {
      if (service.esId == null) continue;
      final result = await repo.getExceptions(
        _availabilityServiceType,
        service.esId!,
      );
      all.addAll(result);
    }

    if (!mounted) return;
    setState(() {
      _allExceptions = all;
      _loading = false;
    });
  }

  Future<void> _addBusy() async {
    if (_selectedServiceId == null ||
        _selectedDate == null ||
        _selectedReason == null ||
        _selectedReason!.trim().isEmpty) {
      showAppToast(context, 'Please fill all fields.', isError: true);
      return;
    }

    final selectedDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );

    setState(() => _loading = true);
    final repo = getIt<IAvailabilityRepository>();
    final ok = await repo
        .addException(_availabilityServiceType, _selectedServiceId!, {
          'reason': _selectedReason!.trim(),
          'unavailableFrom': selectedDate.toIso8601String(),
          'unavailableTo':
              DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                23,
                59,
                59,
                999,
              ).toIso8601String(),
        });
    if (ok) {
      showAppToast(context, 'Busy dates added!');
      _selectedDate = null;
      _selectedReason = null;
      await _loadExceptions();
      await _loadAllExceptions();
      if (mounted) {
        setState(() => _viewAllMode = true);
      }
    } else {
      showAppToast(context, 'Failed.', isError: true);
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteException(int id) async {
    final repo = getIt<IAvailabilityRepository>();
    await repo.deleteException(id);
    await _loadExceptions();
    await _loadAllExceptions();
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  bool _isBusyDate(DateTime day, List<AvailabilityExceptionModel> exceptions) {
    final target = DateTime(day.year, day.month, day.day);
    for (final exception in exceptions) {
      final start = _parseDate(exception.startDate);
      final end = _parseDate(exception.endDate);
      if (start == null || end == null) continue;
      final startDay = DateTime(start.year, start.month, start.day);
      final endDay = DateTime(end.year, end.month, end.day);
      if (!target.isBefore(startDay) && !target.isAfter(endDay)) {
        return true;
      }
    }
    return false;
  }

  List<AvailabilityExceptionModel> _exceptionsForDate(
    DateTime day,
    List<AvailabilityExceptionModel> exceptions,
  ) {
    final target = DateTime(day.year, day.month, day.day);
    return exceptions.where((exception) {
      final start = _parseDate(exception.startDate);
      final end = _parseDate(exception.endDate);
      if (start == null || end == null) return false;
      final startDay = DateTime(start.year, start.month, start.day);
      final endDay = DateTime(end.year, end.month, end.day);
      return !target.isBefore(startDay) && !target.isAfter(endDay);
    }).toList();
  }

  Future<void> _showBusyDateDetails(
    DateTime day,
    List<AvailabilityExceptionModel> exceptions,
  ) async {
    final matches = _exceptionsForDate(day, exceptions);
    if (matches.isEmpty || !mounted) return;

    final services = _listingServices;
    final serviceMap = {
      for (final service in services)
        if (service.esId != null) service.esId!: _serviceLabel(service),
    };

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Busy date: ${_formatDay(day)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...matches.map(
                  (exception) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_busy, color: AppColors.warning),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                serviceMap[exception.serviceId] ??
                                    'Service ${exception.serviceId ?? ''}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if ((exception.reason ?? '').isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  exception.reason!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                _formatExceptionRange(exception),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (exception.exceptionId != null)
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: AppColors.error,
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _deleteException(exception.exceptionId!);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<DateTime?> _buildCalendarCells() {
    final first = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = first.weekday; // Mon=1
    final leading = firstWeekday - 1;
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final cells = <DateTime?>[];

    for (var i = 0; i < leading; i++) {
      cells.add(null);
    }

    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(DateTime(_currentMonth.year, _currentMonth.month, day));
    }

    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return cells;
  }

  String _serviceLabel(EventServiceModel service) {
    final title =
        service.businessName ??
        service.serviceName ??
        service.subCategory ??
        'Service ${service.esId ?? ''}';
    if (service.esId == null) return title;
    return '${service.esId} - $title';
  }

  String _formatDay(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatExceptionRange(AvailabilityExceptionModel exception) {
    final start = _parseDate(exception.startDate);
    final end = _parseDate(exception.endDate);
    if (start == null && end == null) return 'Unknown date';
    if (start != null && end != null && DateUtils.isSameDay(start, end)) {
      return _formatDay(start);
    }
    final startLabel = start != null ? _formatDay(start) : '-';
    final endLabel = end != null ? _formatDay(end) : '-';
    return '$startLabel - $endLabel';
  }

  void _handleCalendarTap(
    DateTime day,
    List<AvailabilityExceptionModel> exceptions,
  ) {
    if (_isBusyDate(day, exceptions)) {
      _showBusyDateDetails(day, exceptions);
      return;
    }
    setState(() => _selectedDate = day);
  }

  Widget _buildCalendarCard({
    required List<AvailabilityExceptionModel> exceptions,
    required bool showSelection,
  }) {
    final monthCells = _buildCalendarCells();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EAF2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed:
                    () => setState(
                      () =>
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month - 1,
                          ),
                    ),
                icon: const Icon(Icons.keyboard_double_arrow_left),
              ),
              IconButton(
                onPressed:
                    () => setState(
                      () =>
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month - 1,
                          ),
                    ),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                    style: const TextStyle(
                      fontSize: 22 * 0.75,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed:
                    () => setState(
                      () =>
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month + 1,
                          ),
                    ),
                icon: const Icon(Icons.chevron_right),
              ),
              IconButton(
                onPressed:
                    () => setState(
                      () =>
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month + 1,
                          ),
                    ),
                icon: const Icon(Icons.keyboard_double_arrow_right),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              _DayHeader('MON'),
              _DayHeader('TUE'),
              _DayHeader('WED'),
              _DayHeader('THU'),
              _DayHeader('FRI'),
              _DayHeader('SAT'),
              _DayHeader('SUN'),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: monthCells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              crossAxisSpacing: 2,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (_, index) {
              final day = monthCells[index];
              if (day == null) return const SizedBox.shrink();

              final isBusy = _isBusyDate(day, exceptions);
              final isSelected =
                  showSelection &&
                  _selectedDate != null &&
                  DateUtils.isSameDay(day, _selectedDate);
              final isToday = DateUtils.isSameDay(day, DateTime.now());

              Color backgroundColor = Colors.transparent;
              Color textColor = AppColors.textPrimary;

              if (isBusy) {
                backgroundColor = const Color(0xFFFFE082);
                textColor = const Color(0xFF975A16);
              } else if (isSelected) {
                backgroundColor = const Color(0xFF12C48B);
                textColor = Colors.white;
              } else if (isToday) {
                backgroundColor = const Color(0xFFE9EAEE);
              }

              return InkWell(
                onTap: () => _handleCalendarTap(day, exceptions),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 16 * 0.75,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend({bool includeSelected = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      color: Colors.white,
      child: Wrap(
        spacing: 18,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LegendBox(color: Color(0xFFFBC02D)),
              SizedBox(width: 10),
              Text(
                'Already Busy',
                style: TextStyle(
                  fontSize: 18 * 0.75,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (includeSelected)
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LegendBox(color: Color(0xFF12C48B)),
                SizedBox(width: 10),
                Text(
                  'Selected',
                  style: TextStyle(
                    fontSize: 18 * 0.75,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedServicePreview(EventServiceModel service) {
    final imageUrl =
        service.imageUrls?.isNotEmpty == true
            ? service.imageUrls!.first
            : service.serviceImageUrls;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        border: Border.all(color: const Color(0xFFDDE2EA)),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE4EAF2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, _, _) => const Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: Color(0xFFBAC3D0),
                          ),
                    )
                    : const Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: Color(0xFFBAC3D0),
                    ),
          ),
          const SizedBox(height: 16),
          Text(
            _serviceLabel(service),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18 * 0.75,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = context.watch<EventServiceProvider>().services;
    final serviceMap = {
      for (final service in services)
        if (service.esId != null) service.esId!: _serviceLabel(service),
    };
    final monthLabel = _monthName(_currentMonth.month);
    final calendarExceptions =
        _viewAllMode ? _allExceptions : _selectedExceptions;
    final monthBusyDates =
        _buildCalendarCells()
            .whereType<DateTime>()
            .where((day) => _isBusyDate(day, calendarExceptions))
            .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Mark Busy',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: const BottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _tabButton(
                      label: 'View All Busy\nDates',
                      icon: Icons.calendar_month,
                      active: _viewAllMode,
                      onTap: () async {
                        setState(() => _viewAllMode = true);
                        if (_allExceptions.isEmpty) {
                          await _loadAllExceptions();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _tabButton(
                      label: 'Add Busy Date',
                      icon: Icons.block,
                      active: !_viewAllMode,
                      onTap: () => setState(() => _viewAllMode = false),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (_viewAllMode) ...[
              Container(
                width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Busy Dates',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'View and manage all your marked busy dates across all services',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      value: '${services.length}',
                      label: 'Total Services',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      value: '${_allExceptions.length}',
                      label: 'Total Busy Marks',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                child: _buildCalendarCard(
                  exceptions: _allExceptions,
                  showSelection: false,
                ),
              ),
              const SizedBox(height: 12),
              _buildLegend(),
              const SizedBox(height: 12),
              if (_allExceptions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 56),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 62,
                        color: Color(0xFFDEE5EF),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No busy dates found',
                        style: TextStyle(
                          fontSize: 20 * 0.75,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._allExceptions.map(
                  (e) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_busy, color: AppColors.warning),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatExceptionRange(e),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                serviceMap[e.serviceId] ?? 'Unknown Service',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (e.exceptionId != null)
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: AppColors.error,
                            ),
                            onPressed: () => _deleteException(e.exceptionId!),
                          ),
                      ],
                    ),
                  ),
                ),
              if (monthBusyDates > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '$monthBusyDates busy day(s) in $monthLabel ${_currentMonth.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EDFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.block, size: 20, color: Color(0xFF7466D7)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mark Service as Busy',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF7466D7),
                            ),
                          ),
                          Text(
                            'Select a service and date to mark as unavailable',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF7466D7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SERVICE TYPE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Color(0xFF67768E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedServiceType,
                      items: const [
                        DropdownMenuItem(
                          value: _listingServiceType,
                          child: Text('Listing Service'),
                        ),
                      ],
                      onChanged: (value) async {
                        setState(() {
                          _selectedServiceType = value;
                          _selectedServiceId = null;
                          _selectedDate = null;
                          _selectedReason = null;
                          _selectedExceptions = [];
                        });
                        if (value == _listingServiceType) {
                          await _loadListingServices(preselectFirst: true);
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'Select service type...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'SELECT LISTING SERVICE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Color(0xFF67768E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: _selectedServiceId,
                      items:
                          _listingServices
                              .map(
                                (service) => DropdownMenuItem(
                                  value: service.esId,
                                  child: Text(_serviceLabel(service)),
                                ),
                              )
                              .toList(),
                      onChanged: (value) async {
                        setState(() {
                          _selectedServiceId = value;
                          _selectedDate = null;
                        });
                        await _loadExceptions();
                        await _loadAllExceptions();
                      },
                      decoration: const InputDecoration(
                        hintText: 'Select listing service...',
                      ),
                    ),
                    if (_selectedService != null) ...[
                      const SizedBox(height: 16),
                      _buildSelectedServicePreview(_selectedService!),
                    ],
                    const SizedBox(height: 14),
                    const Row(
                      children: [
                        Icon(Icons.calendar_month, color: Color(0xFF6C7689), size: 16),
                        SizedBox(width: 8),
                        Text(
                          'PLEASE SELECT A DATE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Color(0xFF67768E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildCalendarCard(
                      exceptions: _selectedExceptions,
                      showSelection: true,
                    ),
                    const SizedBox(height: 12),
                    _buildLegend(includeSelected: true),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F1FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB7D0FF)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info, color: Color(0xFF3F7AE0)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Click on busy dates to view details and delete if needed',
                              style: TextStyle(
                                color: Color(0xFF315EB4),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'REASON *',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Color(0xFF67768E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedReason,
                      items:
                          _busyReasons
                              .map(
                                (reason) => DropdownMenuItem(
                                  value: reason,
                                  child: Text(reason),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() => _selectedReason = value);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Select reason...',
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _addBusy,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3464E0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child:
                            _loading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Mark Busy',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedExceptions.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'Existing Busy Dates',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ..._selectedExceptions.map(
                  (e) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_busy, color: AppColors.warning),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatExceptionRange(e),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              if (e.reason != null && e.reason!.isNotEmpty)
                                Text(
                                  e.reason!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (e.exceptionId != null)
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: AppColors.error,
                              size: 20,
                            ),
                            onPressed: () => _deleteException(e.exceptionId!),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _tabButton({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 108 * 0.75,
        decoration: BoxDecoration(
          gradient: active ? AppColors.welcomeGradient : null,
          color: active ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? const Color(0xFF7393FF) : const Color(0xFFD5DCE6),
            width: 1.5,
          ),
          boxShadow:
              active
                  ? [
                    BoxShadow(
                      color: const Color(0xFF7A65D4).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? Colors.white : const Color(0xFF6C7689)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20 * 0.75,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : const Color(0xFF6C7689),
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({required String value, required String label}) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 56 * 0.75,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6D84EC),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20 * 0.75,
              color: Color(0xFF6E7789),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }
}

class _DayHeader extends StatelessWidget {
  final String label;
  const _DayHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 17 * 0.75,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _LegendBox extends StatelessWidget {
  final Color color;
  const _LegendBox({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 32, height: 32, color: color);
  }
}
