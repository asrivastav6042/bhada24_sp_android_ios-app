import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/core/config/app_config.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/otp_input.dart';
import 'package:bhada24_sp/presentation/widgets/common/toast_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final auth = context.read<AuthProvider>();
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      showAppToast(context, 'Please enter a valid 10-digit phone number.', isError: true);
      return;
    }
    final valid = await auth.validateMobile(phone);
    if (!valid) {
      if (mounted) showAppToast(context, auth.error ?? 'Mobile not registered.', isError: true);
      return;
    }
    final sent = await auth.sendOtp(phone);
    if (sent && mounted) {
      setState(() => _otpSent = true);
      showAppToast(context, 'OTP sent successfully!');
    } else if (mounted) {
      showAppToast(context, auth.error ?? 'Failed to send OTP.', isError: true);
    }
  }

  Future<void> _handleVerifyOtp() async {
    final auth = context.read<AuthProvider>();
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      showAppToast(context, 'Please enter 6-digit OTP.', isError: true);
      return;
    }
    final success = await auth.verifyOtp(otp, _phoneController.text.trim());
    if (success && mounted) {
      context.go('/dashboard');
    } else if (mounted) {
      showAppToast(context, auth.error ?? 'Verification failed.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        AppConfig.logoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.business,
                          color: AppColors.primary,
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _otpSent ? 'Verify OTP' : 'Login',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _otpSent
                        ? 'Sent to +91 ${_phoneController.text}'
                        : 'Login to continue',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Phone / OTP Input
                  if (!_otpSent) ...[
                    _buildLabel('Mobile Number'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              border: Border(right: BorderSide(color: AppColors.border)),
                            ),
                            child: const Text('+91', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: const InputDecoration(
                                hintText: 'Enter mobile number',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                counterText: '',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    _buildLabel('Enter OTP'),
                    const SizedBox(height: 12),
                    Center(
                      child: OtpInput(
                        controller: _otpController,
                        onCompleted: (_) => _handleVerifyOtp(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _otpSent = false;
                        _otpController.clear();
                      }),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Change Number'),
                    ),
                    if (auth.resendTimer > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Resend in ${auth.resendTimer}s',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      )
                    else
                      TextButton.icon(
                        onPressed: auth.isLoading ? null : _handleSendOtp,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Resend OTP'),
                      ),
                  ],

                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: auth.isLoading
                          ? null
                          : (_otpSent ? _handleVerifyOtp : _handleSendOtp),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              _otpSent ? 'Verify & Continue' : 'Send OTP',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary)),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
