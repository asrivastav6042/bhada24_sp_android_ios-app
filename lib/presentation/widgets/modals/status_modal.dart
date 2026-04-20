import 'package:flutter/material.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';

/// Modal for updating booking/service status
Future<String?> showStatusModal(
  BuildContext context, {
  required String currentStatus,
  required List<String> statusOptions,
  String title = 'Update Status',
}) {
  return showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => StatusModal(
      title: title,
      currentStatus: currentStatus,
      statusOptions: statusOptions,
    ),
  );
}

class StatusModal extends StatelessWidget {
  final String title;
  final String currentStatus;
  final List<String> statusOptions;

  const StatusModal({
    super.key,
    required this.title,
    required this.currentStatus,
    required this.statusOptions,
  });

  static Color _colorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'active':
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
      case 'inactive':
        return Colors.red;
      case 'pending':
      case 'processing':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Current: $currentStatus',
              style: TextStyle(
                fontSize: 13,
                color: _colorForStatus(currentStatus),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ...statusOptions.map((status) => ListTile(
                  leading: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _colorForStatus(status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(status),
                  trailing: currentStatus.toLowerCase() ==
                          status.toLowerCase()
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.of(context).pop(status),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
