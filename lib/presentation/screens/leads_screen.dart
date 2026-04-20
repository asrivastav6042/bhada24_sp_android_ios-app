import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/lead_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';
import 'package:bhada24_sp/presentation/widgets/common/bottom_nav.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});
  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final spId = context.read<AuthProvider>().user?.spId;
      if (spId != null) context.read<LeadProvider>().loadLeads(spId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final leadProvider = context.watch<LeadProvider>();

    return Scaffold(
      appBar: const AppHeader(title: 'Leads'),
      bottomNavigationBar: const BottomNav(),
      body: leadProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : leadProvider.leads.isEmpty
                  ? const Center(child: Text('No leads yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      itemCount: leadProvider.leads.length,
                      itemBuilder: (ctx, i) {
                        final lead = leadProvider.leads[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  child: Text((lead.userName ?? 'U')[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(lead.userName ?? 'Unknown', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                    if (lead.interactionType != null)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                        child: Text(lead.interactionType!, style: const TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.w600)),
                                      ),
                                  ]),
                                ),
                              ]),
                              const SizedBox(height: 10),
                              if (lead.serviceName != null)
                                _detail(Icons.miscellaneous_services, lead.serviceName!),
                              if (lead.userPhone != null)
                                _detail(Icons.phone, lead.userPhone!),
                              if (lead.city != null)
                                _detail(Icons.location_on, lead.city!),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _detail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ]),
    );
  }
}
