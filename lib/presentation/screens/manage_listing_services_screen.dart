import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/data/models/event_service_model.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/event_service_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/bottom_nav.dart';
import 'package:bhada24_sp/presentation/widgets/common/confirm_popup.dart';
import 'package:bhada24_sp/presentation/widgets/common/toast_widget.dart';

class ManageListingServicesScreen extends StatefulWidget {
  const ManageListingServicesScreen({super.key});
  @override
  State<ManageListingServicesScreen> createState() =>
      _ManageListingServicesScreenState();
}

class _ManageListingServicesScreenState
    extends State<ManageListingServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final spId = context.read<AuthProvider>().user?.spId;
    if (spId != null) {
      context.read<EventServiceProvider>().loadServices(spId);
    } else {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        final retrySpId = context.read<AuthProvider>().user?.spId;
        if (retrySpId != null) {
          context.read<EventServiceProvider>().loadServices(retrySpId);
        }
      });
    }
  }

  Future<void> _confirmDelete(
    EventServiceProvider provider,
    EventServiceModel service,
  ) async {
    if (service.esId == null) return;
    final confirm = await ConfirmPopup.show(
      context,
      title: 'Delete Listing',
      message: 'Are you sure you want to delete this listing? This action cannot be undone.',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );
    if (confirm != true || !mounted) return;
    final ok = await provider.deleteService(service.esId!);
    if (!mounted) return;
    showAppToast(
      context,
      ok ? 'Listing deleted successfully.' : 'Failed to delete listing.',
      isError: !ok,
    );
  }

  void _openDetails(EventServiceModel service) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _ListingDetailsScreen(service: service)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventServiceProvider>();
    final services = provider.services;
    final categoryCount = services
        .map((s) => (s.category ?? '').trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      bottomNavigationBar: const BottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Manage Listings',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/add-listing-service'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('Add', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!provider.isLoading)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  children: [
                    _StatChip(label: 'Services', value: '${services.length}', color: AppColors.primary),
                    const SizedBox(width: 8),
                    _StatChip(label: 'Categories', value: '$categoryCount', color: const Color(0xFF7C3AED)),
                  ],
                ),
              ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async => _load(),
                      child: services.isEmpty
                          ? _EmptyState(onTap: () => context.push('/add-listing-service'))
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: services.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (_, i) => _ListingCard(
                                service: services[i],
                                onView: () => _openDetails(services[i]),
                                onEdit: () => context.push('/edit-listing-service/${services[i].esId}'),
                                onDelete: () => _confirmDelete(provider, services[i]),
                              ),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final EventServiceModel service;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ListingCard({
    required this.service,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  String get _title => service.businessName ?? service.serviceName ?? 'Untitled';

  String get _imageUrl {
    if (service.imageUrls != null && service.imageUrls!.isNotEmpty) return service.imageUrls!.first;
    if (service.serviceImageUrls?.trim().isNotEmpty == true) return service.serviceImageUrls!.split(',').first.trim();
    return '';
  }

  String get _price {
    final min = service.minPrice ?? service.priceMin ?? service.price;
    final max = service.maxPrice ?? service.priceMax;
    if (min == null && max == null) return 'On request';
    if (min != null && max != null) return '₹${min.toStringAsFixed(0)}–₹${max.toStringAsFixed(0)}';
    return '₹${(min ?? max)!.toStringAsFixed(0)}';
  }

  Color get _approvalColor {
    final v = (service.approvalStatus ?? 'pending').toLowerCase();
    if (v == 'approved') return const Color(0xFF22C55E);
    if (v == 'rejected') return AppColors.error;
    return AppColors.warning;
  }

  String get _approvalLabel {
    final v = (service.approvalStatus ?? 'pending').trim();
    if (v.isEmpty) return 'Pending';
    return '${v[0].toUpperCase()}${v.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(height: 160, width: double.infinity, child: _ServiceImage(url: _imageUrl)),
              Positioned(
                top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _approvalColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(_approvalLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ),
              if ((service.subCategory ?? '').isNotEmpty)
                Positioned(
                  bottom: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(20)),
                    child: Text(service.subCategory!,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(_title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ),
                    const SizedBox(width: 8),
                    Text(_price,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
                if ((service.ownerName ?? '').isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(service.ownerName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
                const SizedBox(height: 6),
                if (_fullAddress(service) != '-')
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(_fullAddress(service),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _MiniChip(
                      label: (service.status ?? 'inactive').toUpperCase(),
                      color: (service.status ?? '').toLowerCase() == 'active'
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF94A3B8),
                    ),
                    if ((service.experience ?? '').isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _MiniChip(label: '${service.experience} yrs', color: const Color(0xFF6A79F0)),
                    ],
                    const Spacer(),
                    Text('ID: ${service.esId ?? '-'}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
                if ((service.adminComment ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 12, color: AppColors.error),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(service.adminComment!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.error)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    _CompactButton(label: 'View', icon: Icons.remove_red_eye_outlined,
                        color: const Color(0xFF0789D8), onTap: onView),
                    const SizedBox(width: 8),
                    _CompactButton(label: 'Edit', icon: Icons.edit_outlined,
                        color: AppColors.primary, onTap: onEdit),
                    const SizedBox(width: 8),
                    _CompactButton(label: 'Delete', icon: Icons.delete_outline,
                        color: const Color(0xFFF23A3A), onTap: onDelete),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _CompactButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CompactButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFFB9C2D1)),
              const SizedBox(height: 12),
              const Text('No listings yet',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text(
                'Create your first listing to start receiving bookings.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text('Add Listing',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ListingDetailsScreen extends StatelessWidget {
  final EventServiceModel service;
  const _ListingDetailsScreen({required this.service});

  @override
  Widget build(BuildContext context) {
    final imageUrl = service.imageUrls?.isNotEmpty == true
        ? service.imageUrls!.first
        : (service.serviceImageUrls?.split(',').first.trim() ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 10),
                  const Text('Listing Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(height: 220, child: _ServiceImage(url: imageUrl)),
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.businessName ?? service.serviceName ?? 'Untitled',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        if ((service.ownerName ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(service.ownerName!,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 12),
                        _DetailRow(icon: Icons.phone_outlined, label: 'Contact', value: service.primaryContact ?? '-'),
                        _DetailRow(icon: Icons.location_on_outlined, label: 'Address', value: _fullAddress(service)),
                        _DetailRow(
                          icon: Icons.currency_rupee,
                          label: 'Price',
                          value: 'INR ${_numberLabel(service.minPrice ?? service.price)} – ${_numberLabel(service.maxPrice ?? service.priceMax)}',
                        ),
                        _DetailRow(icon: Icons.work_outline, label: 'Experience', value: '${service.experience ?? 'N/A'} years'),
                        _DetailRow(icon: Icons.badge_outlined, label: 'Sub-category', value: service.subCategory ?? '-'),
                        _DetailRow(icon: Icons.tag, label: 'Service ID', value: '${service.esId ?? '-'}'),
                        _DetailRow(
                          icon: Icons.verified_outlined,
                          label: 'Status',
                          value: '${service.status ?? '-'} · ${service.approvalStatus ?? '-'}',
                        ),
                        if ((service.serviceDescription ?? '').isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFF0F0F0)),
                          const SizedBox(height: 12),
                          const Text('Description',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary, letterSpacing: 0.5)),
                          const SizedBox(height: 8),
                          Text(service.serviceDescription!,
                              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.55)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _ServiceImage extends StatelessWidget {
  final String url;
  const _ServiceImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return Container(
        color: const Color(0xFFEAF0F8),
        child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 40, color: Color(0xFFB8C2D1))),
      );
    }
    return Image.network(
      url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFEAF0F8),
        child: const Center(child: Icon(Icons.broken_image_outlined, size: 36, color: Color(0xFFB8C2D1))),
      ),
    );
  }
}

String _fullAddress(EventServiceModel service) {
  final parts = [service.address, service.city, service.state, service.pincode]
      .where((p) => p != null && p.trim().isNotEmpty)
      .map((e) => e!.trim())
      .toList();
  return parts.isEmpty ? '-' : parts.join(', ');
}

String _numberLabel(double? value) {
  if (value == null) return '-';
  return value.toStringAsFixed(0);
}
