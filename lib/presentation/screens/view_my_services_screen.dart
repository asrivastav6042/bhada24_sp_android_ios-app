import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/event_service_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';
import 'package:bhada24_sp/presentation/widgets/common/bottom_nav.dart';

class ViewMyServicesScreen extends StatefulWidget {
  const ViewMyServicesScreen({super.key});
  @override
  State<ViewMyServicesScreen> createState() => _ViewMyServicesScreenState();
}

class _ViewMyServicesScreenState extends State<ViewMyServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final spId = context.read<AuthProvider>().user?.spId;
      if (spId != null) context.read<EventServiceProvider>().loadServices(spId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventServiceProvider>();

    return Scaffold(
      appBar: const AppHeader(title: 'My Services'),
      bottomNavigationBar: const BottomNav(),
      body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.services.isEmpty
                  ? const Center(child: Text('No services found.', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      itemCount: provider.services.length,
                      itemBuilder: (ctx, i) {
                        final svc = provider.services[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              if (svc.imageUrls != null && svc.imageUrls!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(svc.imageUrls!.first, width: 70, height: 70, fit: BoxFit.cover),
                                )
                              else
                                Container(
                                  width: 70, height: 70,
                                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.image, color: AppColors.textLight, size: 32),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(svc.serviceName ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Text('${svc.category ?? ''} • ${svc.city ?? ''}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        if (svc.averageRating != null && svc.averageRating! > 0) ...[
                                          const Icon(Icons.star, size: 16, color: AppColors.warning),
                                          const SizedBox(width: 4),
                                          Text(svc.averageRating!.toStringAsFixed(1), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                          Text(' (${svc.ratingCount})', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                                          const SizedBox(width: 12),
                                        ],
                                        if (svc.price != null)
                                          Text('₹${svc.price}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
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
