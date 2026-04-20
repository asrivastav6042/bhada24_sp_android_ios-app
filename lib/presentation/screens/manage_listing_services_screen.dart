import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/event_service_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';
import 'package:bhada24_sp/presentation/widgets/common/confirm_popup.dart';
import 'package:bhada24_sp/presentation/widgets/common/toast_widget.dart';

class ManageListingServicesScreen extends StatefulWidget {
  const ManageListingServicesScreen({super.key});
  @override
  State<ManageListingServicesScreen> createState() => _ManageListingServicesScreenState();
}

class _ManageListingServicesScreenState extends State<ManageListingServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final spId = context.read<AuthProvider>().user?.spId;
    if (spId != null) context.read<EventServiceProvider>().loadServices(spId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventServiceProvider>();

    return Scaffold(
      appBar: AppHeader(
        title: 'My Listing Services',
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-listing-service'),
        icon: const Icon(Icons.add),
        label: const Text('Add New'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.services.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_rounded, size: 64, color: AppColors.textLight),
                      const SizedBox(height: 16),
                      const Text('No services yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/add-listing-service'),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Service'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.services.length,
                  itemBuilder: (ctx, i) {
                    final svc = provider.services[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (svc.imageUrls != null && svc.imageUrls!.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(svc.imageUrls!.first, height: 140, width: double.infinity, fit: BoxFit.cover),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(child: Text(svc.serviceName ?? 'Untitled', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: svc.active == true ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(svc.active == true ? 'Active' : 'Inactive',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                            color: svc.active == true ? AppColors.success : AppColors.error)),
                                  ),
                                ]),
                                const SizedBox(height: 4),
                                Text('${svc.category ?? ''} • ${svc.subCategory ?? ''}',
                                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                if (svc.price != null) ...[
                                  const SizedBox(height: 4),
                                  Text('₹${svc.price}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => context.push('/edit-listing-service/${svc.esId}'),
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text('Edit'),
                                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          final confirm = await ConfirmPopup.show(context,
                                              title: 'Delete Service', message: 'Are you sure?', confirmColor: AppColors.error);
                                          if (confirm == true) {
                                            final ok = await provider.deleteService(svc.esId!);
                                            if (mounted) showAppToast(context, ok ? 'Deleted!' : 'Failed', isError: !ok);
                                          }
                                        },
                                        icon: const Icon(Icons.delete, size: 16),
                                        label: const Text('Delete'),
                                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
