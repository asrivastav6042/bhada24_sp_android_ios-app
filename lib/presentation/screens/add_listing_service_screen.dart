import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/core/di/service_locator.dart';
import 'package:bhada24_sp/domain/repositories/i_service_provider_repository.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/category_provider.dart';
import 'package:bhada24_sp/presentation/providers/event_service_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';
import 'package:bhada24_sp/presentation/widgets/common/toast_widget.dart';

class AddListingServiceScreen extends StatefulWidget {
  const AddListingServiceScreen({super.key});
  @override
  State<AddListingServiceScreen> createState() => _AddListingServiceScreenState();
}

class _AddListingServiceScreenState extends State<AddListingServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  String? _selectedSubCategory;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _priceMinCtrl = TextEditingController();
  final _priceMaxCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  String _pricingType = 'Fixed';
  List<String> _imageUrls = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
      final user = context.read<AuthProvider>().user;
      _cityCtrl.text = user?.city ?? '';
      _stateCtrl.text = user?.state ?? '';
      _addressCtrl.text = user?.address ?? '';
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _priceMinCtrl.dispose();
    _priceMaxCtrl.dispose();
    _expCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
    if (file == null) return;
    setState(() => _saving = true);
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    final user = context.read<AuthProvider>().user;
    final spRepo = getIt<IServiceProviderRepository>();
    final url = await spRepo.uploadImage(user!.spId!, base64Str);
    if (url != null) {
      setState(() => _imageUrls.add(url));
    }
    setState(() => _saving = false);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().user;
    if (user?.spId == null) return;
    setState(() => _saving = true);
    final payload = {
      'serviceName': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'category': _selectedCategory,
      'subCategory': _selectedSubCategory,
      'pricingType': _pricingType,
      'price': _pricingType == 'Fixed' ? double.tryParse(_priceCtrl.text) : null,
      'priceMin': _pricingType != 'Fixed' ? double.tryParse(_priceMinCtrl.text) : null,
      'priceMax': _pricingType != 'Fixed' ? double.tryParse(_priceMaxCtrl.text) : null,
      'experience': _expCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'imageUrls': _imageUrls,
      'spId': user!.spId,
      'active': true,
    };
    final ok = await context.read<EventServiceProvider>().createService(payload);
    setState(() => _saving = false);
    if (ok && mounted) {
      showAppToast(context, 'Service created successfully!');
      context.pop();
    } else if (mounted) {
      showAppToast(context, 'Failed to create service.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CategoryProvider>();
    final cats = catProvider.categories.map((c) => c.name ?? '').where((s) => s.isNotEmpty).toList();
    final subs = _selectedCategory != null ? catProvider.getSubcategoriesForCategory(_selectedCategory!) : <String>[];

    return Scaffold(
      appBar: const AppHeader(title: 'Add Listing Service'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Service Name *'),
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'e.g. Wedding Decoration'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),

              _label('Category *'),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: cats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() { _selectedCategory = v; _selectedSubCategory = null; }),
                decoration: const InputDecoration(hintText: 'Select category'),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              if (subs.isNotEmpty) ...[
                _label('Sub Category'),
                DropdownButtonFormField<String>(
                  value: _selectedSubCategory,
                  items: subs.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _selectedSubCategory = v),
                  decoration: const InputDecoration(hintText: 'Select sub category'),
                ),
                const SizedBox(height: 16),
              ],

              _label('Description'),
              TextFormField(controller: _descCtrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Describe your service')),
              const SizedBox(height: 16),

              _label('Pricing Type'),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Fixed', label: Text('Fixed')),
                  ButtonSegment(value: 'Range', label: Text('Range')),
                  ButtonSegment(value: 'Negotiable', label: Text('Negotiable')),
                ],
                selected: {_pricingType},
                onSelectionChanged: (v) => setState(() => _pricingType = v.first),
              ),
              const SizedBox(height: 12),
              if (_pricingType == 'Fixed')
                TextFormField(controller: _priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Price (₹)', prefixText: '₹ '))
              else if (_pricingType == 'Range')
                Row(children: [
                  Expanded(child: TextFormField(controller: _priceMinCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Min ₹', prefixText: '₹ '))),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _priceMaxCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Max ₹', prefixText: '₹ '))),
                ]),
              const SizedBox(height: 16),

              _label('Experience (years)'),
              TextFormField(controller: _expCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'e.g. 5')),
              const SizedBox(height: 16),

              _label('Address'),
              TextFormField(controller: _addressCtrl, decoration: const InputDecoration(hintText: 'Service address')),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextFormField(controller: _cityCtrl, decoration: const InputDecoration(hintText: 'City'))),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: _stateCtrl, decoration: const InputDecoration(hintText: 'State'))),
              ]),
              const SizedBox(height: 16),

              _label('Images'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._imageUrls.map((url) => ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                            Positioned(
                              top: 0, right: 0,
                              child: GestureDetector(
                                onTap: () => setState(() => _imageUrls.remove(url)),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                      ),
                      child: const Icon(Icons.add_a_photo, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Create Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      );
}
