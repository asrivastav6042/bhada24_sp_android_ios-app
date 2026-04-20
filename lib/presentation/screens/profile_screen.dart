import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/core/utils/extensions.dart';
import 'package:bhada24_sp/core/di/service_locator.dart';
import 'package:bhada24_sp/domain/repositories/i_service_provider_repository.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';
import 'package:bhada24_sp/presentation/widgets/common/bottom_nav.dart';
import 'package:bhada24_sp/presentation/widgets/common/toast_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _pincodeCtrl;
  late TextEditingController _businessCtrl;
  late TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _addressCtrl = TextEditingController(text: user?.address ?? '');
    _cityCtrl = TextEditingController(text: user?.city ?? '');
    _stateCtrl = TextEditingController(text: user?.state ?? '');
    _pincodeCtrl = TextEditingController(text: user?.pincode ?? '');
    _businessCtrl = TextEditingController(text: user?.businessName ?? '');
    _descCtrl = TextEditingController(text: user?.description ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    _businessCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final user = context.read<AuthProvider>().user;
    if (user?.spId == null) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
    if (file == null) return;
    setState(() => _loading = true);
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    final spRepo = getIt<IServiceProviderRepository>();
    final url = await spRepo.uploadImage(user!.spId!, base64Str);
    if (url != null) {
      await spRepo.update({'spId': user.spId, 'imageUrl': url});
      await context.read<AuthProvider>().saveUser(user.copyWith(imageUrl: url));
      if (mounted) showAppToast(context, 'Image updated!');
    }
    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user?.spId == null) return;
    setState(() => _loading = true);
    final spRepo = getIt<IServiceProviderRepository>();
    final payload = {
      'spId': user!.spId,
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'pincode': _pincodeCtrl.text.trim(),
      'businessName': _businessCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
    };
    final ok = await spRepo.update(payload);
    if (ok) {
      await auth.saveUser(user.copyWith(
        name: payload['name'] as String,
        email: payload['email'] as String,
        address: payload['address'] as String,
        city: payload['city'] as String,
        state: payload['state'] as String,
        pincode: payload['pincode'] as String,
        businessName: payload['businessName'] as String,
        description: payload['description'] as String,
      ));
      setState(() => _editing = false);
      if (mounted) showAppToast(context, 'Profile updated!');
    } else {
      if (mounted) showAppToast(context, 'Failed to update.', isError: true);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final imageUrl = (user?.imageUrl != null && user!.imageUrl != 'null' && user.imageUrl!.isNotEmpty) ? user.imageUrl : null;

    return Scaffold(
      appBar: AppHeader(
        title: 'Profile',
        actions: [
          if (!_editing)
            IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => _editing = true))
          else
            IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _editing = false)),
        ],
      ),
      bottomNavigationBar: const BottomNav(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16, top: 12),
            child: Column(
              children: [
                // Avatar
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        backgroundImage: imageUrl != null ? CachedNetworkImageProvider(imageUrl) : null,
                        child: imageUrl == null
                            ? Text((user?.name ?? 'U').initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary))
                            : null,
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(user?.name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                if (user?.phone != null) Text('+91 ${user!.phone}', style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),

                // Fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _field('Name', _nameCtrl),
                      _field('Email', _emailCtrl),
                      _field('Business Name', _businessCtrl),
                      _field('Address', _addressCtrl),
                      _field('City', _cityCtrl),
                      _field('State', _stateCtrl),
                      _field('Pincode', _pincodeCtrl),
                      _field('Description', _descCtrl, maxLines: 4),
                      if (_editing) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _saveProfile,
                            child: _loading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        readOnly: !_editing,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: _editing ? Colors.white : AppColors.background,
        ),
      ),
    );
  }
}
