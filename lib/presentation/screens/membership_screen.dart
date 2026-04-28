import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/membership_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/bottom_nav.dart';
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
    final membership = mp.membership;
    final isActive = membership?.isActive ?? false;
    final planLabel = membership?.planLabel ?? 'Free Plan';

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
          'Membership',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: const BottomNav(),
      body:
          mp.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        gradient: AppColors.welcomeGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.workspace_premium,
                              size: 24,
                              color: Color(0xFFFFE27A),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bhada24 Membership',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  isActive
                                      ? '$planLabel active${membership?.endDate != null ? ' until ${membership!.endDate}' : ''}'
                                      : 'Start free. Only ₹799/year after your first year.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isActive) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFB703)),
                        ),
                        child: const Row(
                          children: [
                            Text('🎉', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Launch Offer — 1 Year FREE!',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF9A4B10),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Get full access free for your first year. Renew at ₹799/year.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9A4B10),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF6E86F0),
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6E86F0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'FREE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  planLabel,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFF16C784)
                                      : const Color(0xFF9CA3AF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isActive
                                      ? (membership?.status ?? 'ACTIVE')
                                      : 'AVAILABLE',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isActive ? 'Active' : '₹0',
                                style: TextStyle(
                                  fontSize: 36 * 0.75,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF5B70E7),
                                ),
                              ),
                              if (!isActive) ...[
                                const SizedBox(width: 6),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '/ 1st year',
                                    style: TextStyle(
                                      fontSize: 18 * 0.75,
                                      color: Color(0xFF98A4B6),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isActive
                                ? 'Current membership is active based on your plan status.'
                                : 'Then ₹799/year — less than ₹67/month',
                            style: const TextStyle(
                              fontSize: 18 * 0.75,
                              color: Color(0xFF6C7890),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFE5EAF2)),
                          const SizedBox(height: 10),
                          ..._features([
                            'Unlimited service listings',
                            'Easy service management',
                            'Real-time notifications',
                            'Analytics & insights dashboard',
                            '24/7 customer support',
                            'Multi-language support',
                          ]),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  isActive
                                      ? null
                                      : () async {
                                        final spId =
                                            context
                                                .read<AuthProvider>()
                                                .user
                                                ?.spId;
                                        if (spId != null) {
                                          final ok = await mp.activateFree(
                                            spId,
                                          );
                                          if (mounted) {
                                            showAppToast(
                                              context,
                                              ok
                                                  ? 'Membership activated!'
                                                  : 'Failed',
                                              isError: !ok,
                                            );
                                          }
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16B978),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(
                                  0xFF16B978,
                                ),
                                disabledForegroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                isActive
                                    ? '$planLabel Active'
                                    : 'Activate Free Plan',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5EAF2)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Color(0xFF6E86F0), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Why is it free?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'We\'re currently offering our complete platform free of charge to help vendors grow their business.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.5,
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

  List<Widget> _features(List<String> items) =>
      items
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Color(0xFF22C55E),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList();
}
