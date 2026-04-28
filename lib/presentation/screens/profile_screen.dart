import 'dart:convert';

import 'package:bhada24_sp/core/di/service_locator.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/core/utils/extensions.dart';
import 'package:bhada24_sp/domain/repositories/i_service_provider_repository.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/bottom_nav.dart';
import 'package:bhada24_sp/presentation/widgets/common/toast_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  bool _loading = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  String? _gender;
  DateTime? _dob;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');

    // Prefer backend values when available, fallback to local cache.
    _gender = user?.gender;
    final dob = user?.dateOfBirth;
    _dob = (dob == null || dob.isEmpty) ? null : DateTime.tryParse(dob);

    _loadLocalExtras();
  }

  Future<void> _loadLocalExtras() async {
    final spId = context.read<AuthProvider>().user?.spId;
    if (spId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final gender = prefs.getString('profile_gender_$spId');
    final dob = prefs.getString('profile_dob_$spId');

    if (!mounted) return;
    setState(() {
      _gender = gender?.isEmpty == true ? null : gender;
      _dob = dob == null ? null : DateTime.tryParse(dob);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  String _spCode(int spId) => 'SP${spId.toString().padLeft(4, '0')}';

  String? _formatDob(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _pickAndUploadImage() async {
    final user = context.read<AuthProvider>().user;
    if (user?.spId == null) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (file == null) return;

    setState(() => _loading = true);
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    final spRepo = getIt<IServiceProviderRepository>();
    final url = await spRepo.uploadImage(user!.spId!, base64Str);

    if (url != null) {
      await spRepo.update({'spId': _spCode(user.spId!), 'imageUrl': url});
      await context.read<AuthProvider>().saveUser(user.copyWith(imageUrl: url));
      if (mounted) showAppToast(context, 'Image updated!');
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    setState(() => _dob = picked);
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user?.spId == null) return;

    setState(() => _loading = true);
    final spRepo = getIt<IServiceProviderRepository>();
    final dob = _formatDob(_dob) ?? user!.dateOfBirth;

    final payload = {
      'spId': _spCode(user!.spId!),
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': user.phone ?? '',
      'role': user.role ?? 'SP',
      'verified': user.verified ?? true,
      'imageUrl': user.imageUrl ?? '',
      'gender': _gender ?? '',
      'dateOfBirth': dob ?? '',
      'status': user.status ?? '',
      'mobile_notification': user.mobileNotification ?? true,
      'email_notification': user.emailNotification ?? true,
      'language': user.language ?? 'english',
      'createdAt': user.createdAt ?? '',
      'updatedAt': DateTime.now().toIso8601String(),
    };

    final ok = await spRepo.update(payload);
    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_gender_${user.spId}', _gender ?? '');
      if (_dob != null) {
        await prefs.setString(
          'profile_dob_${user.spId}',
          _dob!.toIso8601String(),
        );
      } else {
        await prefs.remove('profile_dob_${user.spId}');
      }

      await auth.saveUser(
        user.copyWith(
          name: payload['name'] as String,
          email: payload['email'] as String,
          gender: payload['gender'] as String,
          dateOfBirth: payload['dateOfBirth'] as String,
          status: payload['status'] as String,
          verified: payload['verified'] as bool,
          mobileNotification: payload['mobile_notification'] as bool,
          emailNotification: payload['email_notification'] as bool,
          language: payload['language'] as String,
          updatedAt: payload['updatedAt'] as String,
        ),
      );

      if (mounted) {
        setState(() {
          _editing = false;
          _loading = false;
        });
        showAppToast(context, 'Profile updated!');
      }
      return;
    }

    if (mounted) {
      setState(() => _loading = false);
      showAppToast(context, 'Failed to update.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final imageUrl =
        (user?.imageUrl != null &&
                user!.imageUrl != 'null' &&
                user.imageUrl!.isNotEmpty)
            ? user.imageUrl
            : null;
    final roleLabel =
        (user?.role ?? 'Service Provider').trim().isEmpty
            ? 'Service Provider'
            : (user?.role ?? 'Service Provider');

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
          'Profile',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: const BottomNav(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              children: [
                _HeroCard(
                  name: user?.name ?? '',
                  roleLabel: roleLabel,
                  imageUrl: imageUrl,
                  editing: _editing,
                  onEditTap: () => setState(() => _editing = true),
                  onImageTap: _pickAndUploadImage,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE2E8F0)),
                      if (_editing) ...[
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 8, bottom: 14),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFD),
                            border: Border.all(color: const Color(0xFFDCE4EE)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, color: Color(0xFF66748D), size: 16),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Update your personal details below. Changes will be saved to your account.',
                                  style: TextStyle(
                                    color: Color(0xFF5D6C81),
                                    fontSize: 12,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else
                        const SizedBox(height: 16),
                      _ProfileField(
                        label: 'Name',
                        icon: Icons.person,
                        controller: _nameCtrl,
                        enabled: _editing,
                      ),
                      _ProfileField(
                        label: 'Phone',
                        icon: Icons.phone,
                        initialValue: user?.phone ?? '',
                        enabled: false,
                      ),
                      _ProfileField(
                        label: 'Email',
                        icon: Icons.email,
                        controller: _emailCtrl,
                        enabled: _editing,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _GenderField(
                        editing: _editing,
                        gender: _gender,
                        onChanged: (value) => setState(() => _gender = value),
                      ),
                      _DobField(editing: _editing, dob: _dob, onTap: _pickDob),
                      if (_editing) ...[
                        const Divider(color: Color(0xFFE2E8F0), height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: ElevatedButton(
                                  onPressed:
                                      _loading
                                          ? null
                                          : () =>
                                              setState(() => _editing = false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3464E0),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black.withValues(alpha: 0.05),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String name;
  final String roleLabel;
  final String? imageUrl;
  final bool editing;
  final VoidCallback onEditTap;
  final VoidCallback onImageTap;

  const _HeroCard({
    required this.name,
    required this.roleLabel,
    required this.imageUrl,
    required this.editing,
    required this.onEditTap,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD9E3EF), width: 2),
                    ),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFFF1F5FB),
                      backgroundImage:
                          imageUrl != null
                              ? CachedNetworkImageProvider(imageUrl!)
                              : null,
                      child:
                          imageUrl == null
                              ? Text(
                                name.isEmpty ? 'U' : name.initials,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4B5D79),
                                ),
                              )
                              : null,
                    ),
                  ),
                  if (editing)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: InkWell(
                        onTap: onImageTap,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFF33435B),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7FB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFDCE4EE)),
                      ),
                      child: Text(
                        roleLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF67788F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!editing)
                GestureDetector(
                  onTap: onEditTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDBE3EE)),
                      color: const Color(0xFFFBFCFE),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.edit_outlined, color: Color(0xFF76839A), size: 14),
                        SizedBox(width: 4),
                        Text('Edit', style: TextStyle(fontSize: 12, color: Color(0xFF76839A), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final String? initialValue;
  final bool enabled;
  final TextInputType? keyboardType;

  const _ProfileField({
    required this.label,
    required this.icon,
    this.controller,
    this.initialValue,
    required this.enabled,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final text = controller?.text ?? initialValue ?? '';
    final display = text.trim().isEmpty ? 'Not set' : text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4B5B74),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: enabled,
            readOnly: !enabled,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 13,
              color: enabled ? AppColors.textPrimary : const Color(0xFF6C7B91),
              fontStyle:
                  display == 'Not set' ? FontStyle.italic : FontStyle.normal,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: enabled ? Colors.white : const Color(0xFFF7F9FC),
              prefixIcon: Icon(icon, color: const Color(0xFF97A6BB), size: 18),
              hintText: !enabled ? display : null,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Color(0xFFDCE4EE)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Color(0xFFDCE4EE)),
              ),
              disabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Color(0xFFE4EAF2)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Color(0xFF6E86F0), width: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderField extends StatelessWidget {
  final bool editing;
  final String? gender;
  final ValueChanged<String?> onChanged;

  const _GenderField({
    required this.editing,
    required this.gender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final display = gender == null || gender!.isEmpty ? 'Not set' : gender!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gender',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4B5B74),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: editing ? Colors.white : const Color(0xFFF7F9FC),
              border: Border.all(color: const Color(0xFFDCE4EE)),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                editing
                    ? DropdownButtonFormField<String>(
                      value: gender,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.transgender,
                          color: Color(0xFF97A6BB),
                        ),
                      ),
                      hint: const Text('Select Gender'),
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(
                          value: 'Female',
                          child: Text('Female'),
                        ),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: onChanged,
                    )
                    : ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.transgender,
                        color: Color(0xFF97A6BB),
                      ),
                      title: Text(
                        display,
                        style: TextStyle(
                          color: const Color(0xFF6C7B91),
                          fontStyle:
                              display == 'Not set'
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class _DobField extends StatelessWidget {
  final bool editing;
  final DateTime? dob;
  final VoidCallback onTap;

  const _DobField({
    required this.editing,
    required this.dob,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatted =
        dob == null ? 'Not set' : DateFormat('dd/MM/yyyy').format(dob!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date of Birth',
            style: TextStyle(
              fontSize: 18 * 0.75,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4B5B74),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: editing ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: editing ? Colors.white : const Color(0xFFF7F9FC),
                border: Border.all(color: const Color(0xFFDCE4EE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cake, color: Color(0xFF97A6BB)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formatted,
                      style: TextStyle(
                        fontSize: 18 * 0.75,
                        color: const Color(0xFF6C7B91),
                        fontStyle:
                            formatted == 'Not set'
                                ? FontStyle.italic
                                : FontStyle.normal,
                      ),
                    ),
                  ),
                  if (editing)
                    const Icon(Icons.calendar_today, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
