import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/data/models/lead_model.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/lead_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/bottom_nav.dart';

enum _LeadFilter { all, today, week, month }

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});
  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  _LeadFilter _activeFilter = _LeadFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLeads());
  }

  Future<void> _loadLeads() async {
    final spId = context.read<AuthProvider>().user?.spId;
    if (spId != null) {
      await context.read<LeadProvider>().loadLeads(spId);
    }
  }

  DateTime? _parseLeadDate(LeadModel lead) {
    final raw = lead.createdAt;
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  bool _inCurrentWeek(DateTime date, DateTime now) {
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return !date.isBefore(startOfWeek) && date.isBefore(endOfWeek);
  }

  List<LeadModel> _applyFilter(List<LeadModel> source) {
    final now = DateTime.now();
    switch (_activeFilter) {
      case _LeadFilter.all:
        return source;
      case _LeadFilter.today:
        return source.where((lead) {
          final date = _parseLeadDate(lead);
          if (date == null) return false;
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).toList();
      case _LeadFilter.week:
        return source.where((lead) {
          final date = _parseLeadDate(lead);
          if (date == null) return false;
          return _inCurrentWeek(date, now);
        }).toList();
      case _LeadFilter.month:
        return source.where((lead) {
          final date = _parseLeadDate(lead);
          if (date == null) return false;
          return date.year == now.year && date.month == now.month;
        }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadProvider = context.watch<LeadProvider>();
    final leads = leadProvider.leads;
    final filteredLeads = _applyFilter(leads);
    final now = DateTime.now();
    final todayCount =
        leads.where((l) {
          final date = _parseLeadDate(l);
          if (date == null) return false;
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).length;
    final weekCount =
        leads.where((l) {
          final date = _parseLeadDate(l);
          if (date == null) return false;
          return _inCurrentWeek(date, now);
        }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FA),
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
          'Leads',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: leadProvider.isLoading ? null : _loadLeads,
            icon: const Icon(Icons.refresh, size: 22),
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: const BottomNav(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Row(
              children: [
                _LeadStatChip(label: 'Total', value: '${leads.length}', color: AppColors.primary),
                const SizedBox(width: 8),
                _LeadStatChip(label: 'Today', value: '$todayCount', color: const Color(0xFF22C55E)),
                const SizedBox(width: 8),
                _LeadStatChip(label: 'This Week', value: '$weekCount', color: const Color(0xFF7C3AED)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('All', _LeadFilter.all),
                  _chip('Today', _LeadFilter.today),
                  _chip('This Week', _LeadFilter.week),
                  _chip('This Month', _LeadFilter.month),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child:
                leadProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredLeads.isEmpty
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 44, color: Color(0xFFB9C2D1)),
                            SizedBox(height: 10),
                            Text(
                              'No leads found',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Leads appear here when users view or interact with your services.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: filteredLeads.length,
                      itemBuilder: (ctx, i) {
                        final lead = filteredLeads[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    child: Text(
                                      (lead.userName ?? 'U')
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      lead.userName ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if ((lead.interactionType ?? '').isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.info.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        lead.interactionType!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.info,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if ((lead.serviceName ?? '').isNotEmpty)
                                _detail(
                                  Icons.miscellaneous_services,
                                  lead.serviceName!,
                                ),
                              if ((lead.userPhone ?? '').isNotEmpty)
                                _detail(Icons.phone, lead.userPhone!),
                              if ((lead.city ?? '').isNotEmpty)
                                _detail(Icons.location_on, lead.city!),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, _LeadFilter value) {
    final active = _activeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _activeFilter = value),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? AppColors.primary : const Color(0xFFCAD2DE),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : const Color(0xFF6B7486),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _LeadStatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
