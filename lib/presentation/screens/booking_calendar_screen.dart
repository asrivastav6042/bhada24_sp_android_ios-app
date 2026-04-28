import 'package:bhada24_sp/core/di/service_locator.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/data/models/availability_exception_model.dart';
import 'package:bhada24_sp/data/models/booking_model.dart';
import 'package:bhada24_sp/data/models/event_service_model.dart';
import 'package:bhada24_sp/domain/repositories/i_availability_repository.dart';
import 'package:bhada24_sp/domain/repositories/i_auth_repository.dart';
import 'package:bhada24_sp/domain/repositories/i_booking_repository.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/event_service_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookingCalendarScreen extends StatefulWidget {
  const BookingCalendarScreen({super.key});

  @override
  State<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  static const String _serviceType = 'EVENT';

  final IBookingRepository _bookingRepo = getIt<IBookingRepository>();
  final IAvailabilityRepository _availabilityRepo = getIt<IAvailabilityRepository>();

  List<EventServiceModel> _services = [];
  int? _selectedServiceId;
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = _dateOnly(DateTime.now());

  bool _loading = false;
  List<BookingModel> _bookings = [];
  List<AvailabilityExceptionModel> _busyDates = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServicesAndData();
    });
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  Future<void> _loadServicesAndData() async {
    final auth = context.read<AuthProvider>();
    int? spId = auth.user?.spId;

    if (spId == null) {
      final authRepo = getIt<IAuthRepository>();
      final phone = auth.user?.phone?.trim();

      final candidates = <String>{
        if (phone != null && phone.isNotEmpty) phone,
        if (phone != null && phone.startsWith('+91') && phone.length > 3)
          phone.substring(3),
        if (phone != null && !phone.startsWith('+91')) '+91$phone',
      }.toList();

      for (final mobile in candidates) {
        final refreshed = await authRepo.getUserByMobile(mobile);
        if (refreshed?.spId != null) {
          await auth.saveUser(refreshed!);
          spId = refreshed.spId;
          break;
        }
      }
    }

    if (spId == null) {
      return;
    }

    await context.read<EventServiceProvider>().loadServices(spId);
    final loadedServices =
        context.read<EventServiceProvider>().services.where((s) => s.esId != null).toList();

    if (!mounted) return;

    setState(() {
      _services = loadedServices;
      if (_selectedServiceId == null && loadedServices.isNotEmpty) {
        _selectedServiceId = loadedServices.first.esId;
      }
    });

    if (_selectedServiceId != null) {
      await _loadCalendarData(_selectedServiceId!);
    }
  }

  Future<void> _loadCalendarData(int esId) async {
    setState(() => _loading = true);
    try {
      // Keep the calendar usable even if bookings endpoint fails.
      List<BookingModel> bookings = [];
      List<AvailabilityExceptionModel> busy = [];

      try {
        bookings = await _bookingRepo.getBookingsByEsId(esId);
      } catch (_) {
        bookings = [];
      }

      try {
        busy = await _availabilityRepo.getExceptions(_serviceType, esId);
      } catch (_) {
        busy = [];
      }

      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _busyDates = busy;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  DateTime? _parseBookingDate(BookingModel booking) {
    if (booking.bookingDate != null && booking.bookingDate!.isNotEmpty) {
      return DateTime.tryParse(booking.bookingDate!);
    }
    if (booking.createdAt != null && booking.createdAt!.isNotEmpty) {
      return DateTime.tryParse(booking.createdAt!);
    }
    return null;
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isInRange(DateTime day, AvailabilityExceptionModel exception) {
    final start = DateTime.tryParse(exception.startDate ?? '');
    final end = DateTime.tryParse(exception.endDate ?? '');
    if (start == null || end == null) return false;

    final startDay = _dateOnly(start);
    final endDay = _dateOnly(end);
    return !day.isBefore(startDay) && !day.isAfter(endDay);
  }

  bool _hasBooking(DateTime day) {
    for (final booking in _bookings) {
      final bookingDate = _parseBookingDate(booking);
      if (bookingDate != null && _isSameDate(_dateOnly(bookingDate), day)) {
        return true;
      }
    }
    return false;
  }

  bool _hasBusy(DateTime day) {
    for (final exception in _busyDates) {
      if (_isInRange(day, exception)) {
        return true;
      }
    }
    return false;
  }

  List<BookingModel> _bookingsForDay(DateTime day) {
    return _bookings.where((booking) {
      final bookingDate = _parseBookingDate(booking);
      return bookingDate != null && _isSameDate(_dateOnly(bookingDate), day);
    }).toList();
  }

  List<AvailabilityExceptionModel> _busyForDay(DateTime day) {
    return _busyDates.where((item) => _isInRange(day, item)).toList();
  }

  String _serviceLabel(EventServiceModel service) =>
      service.businessName ?? service.serviceName ?? 'Service ${service.esId}';

  @override
  Widget build(BuildContext context) {
    final selectedBookings = _bookingsForDay(_selectedDate);
    final selectedBusy = _busyForDay(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, size: 22),
            onPressed: () => context.push('/mark-busy'),
          ),
          const SizedBox(width: 8),
        ],
        title: const Text(
          'Booking Calendar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: const BottomNav(),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedServiceId != null) {
            await _loadCalendarData(_selectedServiceId!);
          } else {
            await _loadServicesAndData();
          }
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          children: [
            _buildServiceSelector(),
            const SizedBox(height: 18),
            _buildCalendarCard(),
            const SizedBox(height: 14),
            _buildLegend(),
            const SizedBox(height: 14),
            Text(
              'Bookings on ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _buildDayDetails(selectedBookings, selectedBusy),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a Service',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: _selectedServiceId,
            isExpanded: true,
            hint: const Text('Choose a service to view bookings...'),
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Color(0xFF6D84EC), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Color(0xFF6D84EC), width: 2),
              ),
            ),
            items: _services
                .map(
                  (service) => DropdownMenuItem<int>(
                    value: service.esId!,
                    child: Text(
                      _serviceLabel(service),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) async {
              if (value == null) return;
              setState(() => _selectedServiceId = value);
              await _loadCalendarData(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    final monthTitle = DateFormat('MMMM yyyy').format(_focusedMonth);
    final dates = _calendarDatesForMonth(_focusedMonth);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              _MonthNav(
                icon: Icons.keyboard_double_arrow_left,
                onTap: () => _changeMonth(-12),
              ),
              const SizedBox(width: 8),
              _MonthNav(
                icon: Icons.keyboard_arrow_left,
                onTap: () => _changeMonth(-1),
              ),
              const Spacer(),
              Text(
                monthTitle,
                style: const TextStyle(
                  fontSize: 20 * 0.75,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              _MonthNav(
                icon: Icons.keyboard_arrow_right,
                onTap: () => _changeMonth(1),
              ),
              const SizedBox(width: 8),
              _MonthNav(
                icon: Icons.keyboard_double_arrow_right,
                onTap: () => _changeMonth(12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _DaysHeader(),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dates.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 2,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (_, index) {
              final day = dates[index];
              final inCurrentMonth = day.month == _focusedMonth.month;
              final dayOnly = _dateOnly(day);
              final hasBooking = _hasBooking(dayOnly);
              final hasBusy = _hasBusy(dayOnly);
              final isSelected = _isSameDate(dayOnly, _selectedDate);

              Decoration? decoration;
              Color textColor = inCurrentMonth
                  ? AppColors.textPrimary
                  : const Color(0xFFA8B0BC);

              if (hasBooking && hasBusy) {
                decoration = BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1976D2),
                      Color(0xFF1976D2),
                      Color(0xFFFFA500),
                      Color(0xFFFFA500),
                    ],
                    stops: [0, 0.5, 0.5, 1],
                  ),
                  borderRadius: BorderRadius.circular(4),
                );
                textColor = Colors.white;
              } else if (hasBooking) {
                decoration = BoxDecoration(
                  color: const Color(0xFF1976D2),
                  borderRadius: BorderRadius.circular(4),
                );
                textColor = Colors.white;
              } else if (hasBusy) {
                decoration = BoxDecoration(
                  color: const Color(0xFFEACD63),
                  borderRadius: BorderRadius.circular(4),
                );
              }

              if (isSelected) {
                decoration = BoxDecoration(
                  border: Border.all(color: const Color(0xFF111827), width: 1.5),
                  color: decoration == null ? const Color(0xFFE9EAEE) : null,
                  gradient: decoration is BoxDecoration ? decoration.gradient : null,
                  borderRadius: BorderRadius.circular(4),
                );
              }

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = dayOnly;
                    if (day.month != _focusedMonth.month) {
                      _focusedMonth = DateTime(day.year, day.month);
                    }
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: decoration,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 20 * 0.75,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
          if (_loading) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 2),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          _LegendItem(color: Color(0xFF1976D2), label: 'Booking'),
          SizedBox(height: 12),
          _LegendItem(color: Color(0xFFEACD63), label: 'Marked Busy'),
          SizedBox(height: 12),
          _LegendBothItem(label: 'Both'),
        ],
      ),
    );
  }

  Widget _buildDayDetails(
    List<BookingModel> bookings,
    List<AvailabilityExceptionModel> busy,
  ) {
    if (bookings.isEmpty && busy.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        color: Colors.white,
        child: const Text(
          'No bookings or busy dates found.',
          style: TextStyle(
            fontSize: 16 * 0.75,
            color: Color(0xFF64748B),
          ),
        ),
      );
    }

    final rows = <Widget>[];

    for (final booking in bookings) {
      rows.add(
        _InfoRow(
          title: booking.userName?.trim().isNotEmpty == true
              ? booking.userName!
              : 'Booking #${booking.bookingId ?? '-'}',
          subtitle:
              'Booking | ${booking.status ?? 'pending'}${booking.startTime != null ? ' | ${booking.startTime}' : ''}',
          indicatorColor: const Color(0xFF1976D2),
        ),
      );
    }

    for (final item in busy) {
      rows.add(
        _InfoRow(
          title: item.reason?.trim().isNotEmpty == true
              ? item.reason!
              : 'Marked Busy',
          subtitle: 'Busy | Service ID: ${item.serviceId ?? '-'}',
          indicatorColor: const Color(0xFFEACD63),
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        children: rows,
      ),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + offset);
    });
  }

  List<DateTime> _calendarDatesForMonth(DateTime month) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final lastOfMonth = DateTime(month.year, month.month + 1, 0);

    final leadingCount = (firstOfMonth.weekday + 6) % 7;
    final totalDays = lastOfMonth.day;

    final result = <DateTime>[];

    for (int i = leadingCount; i > 0; i--) {
      result.add(firstOfMonth.subtract(Duration(days: i)));
    }

    for (int d = 1; d <= totalDays; d++) {
      result.add(DateTime(month.year, month.month, d));
    }

    while (result.length % 7 != 0) {
      result.add(result.last.add(const Duration(days: 1)));
    }

    while (result.length < 35) {
      result.add(result.last.add(const Duration(days: 1)));
    }

    return result;
  }
}

class _MonthNav extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MonthNav({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, color: AppColors.textPrimary, size: 28 * 0.75),
    );
  }
}

class _DaysHeader extends StatelessWidget {
  const _DaysHeader();

  @override
  Widget build(BuildContext context) {
    const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return Row(
      children: labels
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 17 * 0.75,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 42 * 0.75, height: 42 * 0.75, color: color),
        const SizedBox(width: 16),
        Text(
          label,
          style: const TextStyle(fontSize: 20 * 0.75, color: Color(0xFF555C67)),
        ),
      ],
    );
  }
}

class _LegendBothItem extends StatelessWidget {
  final String label;

  const _LegendBothItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42 * 0.75,
          height: 42 * 0.75,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1976D2),
                Color(0xFF1976D2),
                Color(0xFFFFA500),
                Color(0xFFFFA500),
              ],
              stops: [0, 0.5, 0.5, 1],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: const TextStyle(fontSize: 20 * 0.75, color: Color(0xFF555C67)),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color indicatorColor;

  const _InfoRow({
    required this.title,
    required this.subtitle,
    required this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: indicatorColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16 * 0.75,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14 * 0.75,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
