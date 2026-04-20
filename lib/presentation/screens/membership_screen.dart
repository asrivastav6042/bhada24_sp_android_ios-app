import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/membership_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';
import 'package:bhada24_sp/presentation/widgets/common/toast_widget.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});
  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final spId = context.read<AuthProvider>().user?.spId;
      if (spId != null) context.read<MembershipProvider>().loadStatus(spId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MembershipProvider>();
    return Scaffold(
      appBar: const AppHeader(title: 'Membership'),
      body: mp.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: mp.isActive ? AppColors.welcomeGradient : null,
                    color: mp.isActive ? null : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 16)],
                  ),
                  child: Column(children: [
                    Icon(mp.isActive ? Icons.verified : Icons.card_membership, size: 48, color: mp.isActive ? Colors.white : AppColors.textLight),
                    const SizedBox(height: 12),
                    Text(mp.isActive ? 'Active Membership' : 'No Active Membership',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: mp.isActive ? Colors.white : AppColors.textPrimary)),
                    if (mp.membership?.plan != null) ...[
                      const SizedBox(height: 4),
                      Text('Plan: ${mp.membership!.plan}', style: TextStyle(color: mp.isActive ? Colors.white70 : AppColors.textSecondary)),
                    ],
                    if (mp.membership?.endDate != null) ...[
                      const SizedBox(height: 4),
                      Text('Expires: ${mp.membership!.endDate}', style: TextStyle(fontSize: 13, color: mp.isActive ? Colors.white70 : AppColors.textSecondary)),
                    ],
                  ]),
                ),
                if (!mp.isActive) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Column(children: [
                      const Text('Free 1 Year Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      const Text('Get started with our free plan including:',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 12),
                      ..._features(['Unlimited listings', 'Customer leads', 'Notifications', 'Priority support']),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final spId = context.read<AuthProvider>().user?.spId;
                            if (spId != null) {
                              final ok = await mp.activateFree(spId);
                              if (mounted) showAppToast(context, ok ? 'Membership activated!' : 'Failed', isError: !ok);
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                          child: const Text('Activate Free Plan'),
                        ),
                      ),
                    ]),
                  ),
                ],
              ]),
            ),
    );
  }

  List<Widget> _features(List<String> items) => items
      .map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              const Icon(Icons.check_circle, size: 18, color: AppColors.success),
              const SizedBox(width: 8),
              Text(f, style: const TextStyle(fontSize: 14)),
            ]),
          ))
      .toList();
}
