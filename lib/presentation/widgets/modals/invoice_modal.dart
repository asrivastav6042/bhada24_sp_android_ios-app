import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/data/models/booking_model.dart';

/// Invoice/receipt modal for a booking
Future<void> showInvoiceModal(
  BuildContext context, {
  required BookingModel booking,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => InvoiceModal(booking: booking),
  );
}

class InvoiceModal extends StatelessWidget {
  final BookingModel booking;

  const InvoiceModal({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final currencyFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(24),
        child: ListView(
          controller: controller,
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
            const Center(
              child: Text(
                'Invoice',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            _buildDivider(),
            _buildRow('Booking ID',
                '#${booking.bookingId ?? 'N/A'}'),
            _buildRow('Service',
                booking.serviceName ?? 'N/A'),
            _buildRow('Customer',
                booking.userName ?? 'N/A'),
            _buildRow('Phone',
                booking.userPhone ?? 'N/A'),
            _buildRow('Date',
                booking.bookingDate != null
                    ? DateFormat('dd MMM yyyy')
                        .format(DateTime.parse(booking.bookingDate!))
                    : 'N/A'),
            if (booking.startTime != null)
              _buildRow('Time',
                  '${booking.startTime} - ${booking.endTime ?? ''}'),
            _buildRow('Status',
                booking.status ?? 'N/A',
                valueColor: _statusColor(booking.status)),
            _buildDivider(),
            _buildRow(
              'Amount',
              booking.amount != null
                  ? currencyFmt.format(booking.amount)
                  : 'N/A',
              isBold: true,
            ),
            _buildDivider(),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Share Invoice'),
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 24);

  Widget _buildRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Color? _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return null;
    }
  }
}
