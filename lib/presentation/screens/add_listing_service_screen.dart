import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:bhada24_sp/core/di/service_locator.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/core/utils/validators.dart';
import 'package:bhada24_sp/data/models/event_service_model.dart';
import 'package:bhada24_sp/domain/repositories/i_service_provider_repository.dart';
import 'package:bhada24_sp/presentation/providers/auth_provider.dart';
import 'package:bhada24_sp/presentation/providers/category_provider.dart';
import 'package:bhada24_sp/presentation/providers/event_service_provider.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';
import 'package:bhada24_sp/presentation/widgets/common/toast_widget.dart';
import 'package:bhada24_sp/presentation/widgets/modals/ai_description_editor_dialog.dart';
import 'package:bhada24_sp/presentation/widgets/modals/document_upload_modal.dart';
import 'package:bhada24_sp/services/ai_description_service.dart';
import 'package:bhada24_sp/services/location_suggestion_service.dart';

class AddListingServiceScreen extends StatefulWidget {
  final int? editEsId;

  const AddListingServiceScreen({super.key, this.editEsId});

  @override
  State<AddListingServiceScreen> createState() =>
      _AddListingServiceScreenState();
}

class _AddListingServiceScreenState extends State<AddListingServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationService = LocationSuggestionService();

  final _ownerNameCtrl = TextEditingController();
  final _primaryContactCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  final _serviceDescCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();

  final _addressCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();

  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();
  final _advanceBookingCtrl = TextEditingController(text: '7');
  final _radiusCtrl = TextEditingController(text: '5');

  final _ownerIdProofNoCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  final _businessRegCtrl = TextEditingController();
  final _fssaiNoCtrl = TextEditingController();

  String? _selectedCategory;
  String? _selectedSubCategory;
  String? _ownerIdProofType;

  bool _availableOnWeekends = true;
  bool _acceptedTerms = false;
  bool _saving = false;
  bool _loadingExisting = false;

  double? _latitude;
  double? _longitude;

  List<String> _imageUrls = [];
  String? _ownerIdProofUrl;
  String? _businessLicenseUrl;
  String? _fssaiLicenseUrl;
  String? _insuranceCertificateUrl;

  Timer? _addressDebounce;
  bool _isSearchingAddress = false;
  bool _isResolvingCurrentLocation = false;
  List<LocationSuggestion> _addressSuggestions = [];

  bool get _isEditMode => widget.editEsId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final catProvider = context.read<CategoryProvider>();
      await catProvider.loadCategories();
      _prefillFromLoggedInUser();
      if (_isEditMode) {
        await _loadExisting(widget.editEsId!);
      }
    });
  }

  @override
  void dispose() {
    _addressDebounce?.cancel();

    _ownerNameCtrl.dispose();
    _primaryContactCtrl.dispose();
    _whatsappCtrl.dispose();
    _businessNameCtrl.dispose();
    _serviceDescCtrl.dispose();
    _experienceCtrl.dispose();
    _addressCtrl.dispose();
    _pincodeCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    _advanceBookingCtrl.dispose();
    _radiusCtrl.dispose();
    _ownerIdProofNoCtrl.dispose();
    _gstCtrl.dispose();
    _businessRegCtrl.dispose();
    _fssaiNoCtrl.dispose();
    super.dispose();
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  void _prefillFromLoggedInUser() {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    _ownerNameCtrl.text = user.name ?? '';
    _primaryContactCtrl.text = _digitsOnly(user.phone ?? '');
    _businessNameCtrl.text = user.businessName ?? '';

    _addressCtrl.text = user.address ?? '';
    _cityCtrl.text = user.city ?? '';
    _stateCtrl.text = user.state ?? '';
    _pincodeCtrl.text = user.pincode ?? '';
    _latitude = user.latitude;
    _longitude = user.longitude;
  }

  Future<void> _loadExisting(int esId) async {
    setState(() => _loadingExisting = true);
    try {
      final provider = context.read<EventServiceProvider>();
      await provider.loadServiceById(esId);
      final svc = provider.selectedService;
      if (svc == null) return;
      _prefillFromService(svc);
    } finally {
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

  void _prefillFromService(EventServiceModel svc) {
    _ownerNameCtrl.text = svc.ownerName ?? _ownerNameCtrl.text;
    _primaryContactCtrl.text = _digitsOnly(
      svc.primaryContact ?? _primaryContactCtrl.text,
    );
    _whatsappCtrl.text = _digitsOnly(svc.whatsappNumber ?? '');

    _businessNameCtrl.text =
        svc.businessName ?? svc.serviceName ?? _businessNameCtrl.text;
    _selectedCategory = svc.category;
    _selectedSubCategory = svc.subCategory;

    _serviceDescCtrl.text = svc.serviceDescription ?? svc.description ?? '';
    _experienceCtrl.text = svc.experience ?? '';

    _addressCtrl.text = svc.address ?? _addressCtrl.text;
    _cityCtrl.text = svc.city ?? _cityCtrl.text;
    _stateCtrl.text = svc.state ?? _stateCtrl.text;
    _pincodeCtrl.text = svc.pincode ?? _pincodeCtrl.text;

    _latitude = svc.latitude ?? _latitude;
    _longitude = svc.longitude ?? _longitude;

    _minPriceCtrl.text =
        (svc.minPrice ?? svc.priceMin ?? svc.price ?? '').toString();
    _maxPriceCtrl.text = (svc.maxPrice ?? svc.priceMax ?? '').toString();

    _advanceBookingCtrl.text = (svc.advanceBookingDays ?? 7).toString();
    _availableOnWeekends = svc.availableOnWeekends ?? true;
    _radiusCtrl.text = (svc.radius ?? 5).toString();

    _ownerIdProofType = svc.ownerIdProofType;
    _ownerIdProofNoCtrl.text = svc.ownerIdProofNumber ?? '';
    _ownerIdProofUrl = svc.ownerIdProofUrl;

    _gstCtrl.text = svc.gstNumber ?? '';
    _businessRegCtrl.text = svc.businessRegistrationNumber ?? '';
    _businessLicenseUrl = svc.businessLicenseUrl;

    _fssaiNoCtrl.text = svc.fssaiLicenseNumber ?? '';
    _fssaiLicenseUrl = svc.fssaiLicenseUrl;
    _insuranceCertificateUrl = svc.insuranceCertificateUrl;

    // Prefer imageUrls list; fall back to comma-separated serviceImageUrls
    if (svc.imageUrls != null && svc.imageUrls!.isNotEmpty) {
      _imageUrls = List<String>.from(svc.imageUrls!);
    } else if (svc.serviceImageUrls?.trim().isNotEmpty == true) {
      _imageUrls = svc.serviceImageUrls!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      _imageUrls = [];
    }
  }

  void _onAddressChanged(String value) {
    _addressDebounce?.cancel();
    _addressDebounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      if (value.trim().length < 3) {
        setState(() => _addressSuggestions = []);
        return;
      }
      setState(() => _isSearchingAddress = true);
      try {
        final suggestions = await _locationService.searchAddress(value.trim());
        if (mounted) {
          setState(() => _addressSuggestions = suggestions);
        }
      } catch (_) {
        if (mounted) {
          setState(() => _addressSuggestions = []);
        }
      } finally {
        if (mounted) {
          setState(() => _isSearchingAddress = false);
        }
      }
    });
  }

  void _applySuggestion(LocationSuggestion suggestion) {
    setState(() {
      _addressCtrl.text = suggestion.address;
      _cityCtrl.text = suggestion.city;
      _stateCtrl.text = suggestion.state;
      _pincodeCtrl.text = suggestion.pincode;
      _latitude = suggestion.latitude;
      _longitude = suggestion.longitude;
      _addressSuggestions = [];
    });
  }

  Future<void> _useSavedLocation() async {
    if (_isResolvingCurrentLocation) return;
    setState(() => _isResolvingCurrentLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        showAppToast(
          context,
          'Please enable location services and try again.',
          isError: true,
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        showAppToast(
          context,
          'Location permission is required to auto-fill address.',
          isError: true,
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final suggestion = await _locationService.reverseGeocode(
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      if (!mounted) return;
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _addressCtrl.text = suggestion?.address ?? _addressCtrl.text;
        _cityCtrl.text = suggestion?.city ?? _cityCtrl.text;
        _stateCtrl.text = suggestion?.state ?? _stateCtrl.text;
        _pincodeCtrl.text = suggestion?.pincode ?? _pincodeCtrl.text;
        _addressSuggestions = [];
      });

      if (suggestion == null) {
        showAppToast(
          context,
          'Current coordinates captured. Please complete address manually if needed.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      showAppToast(
        context,
        'Unable to fetch current location. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isResolvingCurrentLocation = false);
      }
    }
  }

  List<Map<String, String>> _aiCategoriesPayload() {
    final list = <Map<String, String>>[];
    if ((_selectedSubCategory ?? '').trim().isNotEmpty) {
      list.add({
        'label': _selectedSubCategory!.trim(),
        'value': _selectedSubCategory!.trim(),
        'category': (_selectedCategory ?? 'other').trim().toLowerCase(),
      });
      return list;
    }
    if ((_selectedCategory ?? '').trim().isNotEmpty) {
      list.add({
        'label': _selectedCategory!.trim(),
        'value': _selectedCategory!.trim(),
        'category': _selectedCategory!.trim().toLowerCase(),
      });
      return list;
    }
    list.add({
      'label': 'Event Service',
      'value': 'Event Service',
      'category': 'other',
    });
    return list;
  }

  Future<String> _generateAiDescription(String language) async {
    final categories = _aiCategoriesPayload();
    final experience = int.tryParse(_experienceCtrl.text.trim()) ?? 0;

    if (language == 'mix') {
      final en = await AiDescriptionService.generateAsync(
        serviceCategories: categories,
        businessName: _businessNameCtrl.text.trim(),
        experience: experience,
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        language: 'en',
      );
      final hi = await AiDescriptionService.generateAsync(
        serviceCategories: categories,
        businessName: _businessNameCtrl.text.trim(),
        experience: experience,
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        language: 'hi',
      );
      return '$en\n\n$hi';
    }

    return AiDescriptionService.generateAsync(
      serviceCategories: categories,
      businessName: _businessNameCtrl.text.trim(),
      experience: experience,
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      language: language,
    );
  }

  Future<void> _openAiDescriptionEditor() async {
    final generated = await showAiDescriptionEditorDialog(
      context,
      initialText: _serviceDescCtrl.text,
      onGenerate: _generateAiDescription,
    );

    if (generated == null || !mounted) return;
    setState(() => _serviceDescCtrl.text = generated);
  }

  Future<String?> _uploadXFile(XFile file, {String? label}) async {
    final user = context.read<AuthProvider>().user;
    if (user?.spId == null) return null;

    final spRepo = getIt<IServiceProviderRepository>();
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    final uploadedUrl = await spRepo.uploadImage(user!.spId!, base64Str);

    if (uploadedUrl == null && mounted) {
      showAppToast(context, '${label ?? 'File'} upload failed.', isError: true);
    }
    return uploadedUrl;
  }

  Future<void> _pickServiceImage() async {
    await showDocumentUploadModal(
      context,
      title: 'Upload Service Image',
      onUpload: (file) async {
        final url = await _uploadXFile(file, label: 'Service image');
        if (url == null) return false;
        if (mounted) {
          setState(() => _imageUrls.add(url));
        }
        return true;
      },
    );
  }

  Future<void> _pickDoc({
    required String title,
    required void Function(String url) onUploaded,
  }) async {
    await showDocumentUploadModal(
      context,
      title: title,
      onUpload: (file) async {
        final url = await _uploadXFile(file, label: title);
        if (url == null) return false;
        if (mounted) {
          setState(() => onUploaded(url));
        }
        return true;
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      showAppToast(
        context,
        'Please accept Terms & Privacy Policy.',
        isError: true,
      );
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user?.spId == null) {
      showAppToast(context, 'User session not found.', isError: true);
      return;
    }

    setState(() => _saving = true);

    final minPrice = double.tryParse(_minPriceCtrl.text.trim()) ?? 0;
    final maxPrice = double.tryParse(_maxPriceCtrl.text.trim()) ?? 0;
    final experience = int.tryParse(_experienceCtrl.text.trim()) ?? 0;
    final advanceDays = int.tryParse(_advanceBookingCtrl.text.trim()) ?? 0;
    final radius = int.tryParse(_radiusCtrl.text.trim()) ?? 0;

    final payload = <String, dynamic>{
      'spId': user!.spId,
      'ownerName': _ownerNameCtrl.text.trim(),
      'primaryContact': _digitsOnly(_primaryContactCtrl.text),
      'whatsappNumber': _digitsOnly(_whatsappCtrl.text),
      'businessName': _businessNameCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'pincode': _pincodeCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'latitude': _latitude ?? 0,
      'longitude': _longitude ?? 0,
      'serviceDescription': _serviceDescCtrl.text.trim(),
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'serviceImageUrls': _imageUrls.join(','),
      'experience': experience,
      'advanceBookingDays': advanceDays,
      'availableOnWeekends': _availableOnWeekends,
      'ownerIdProofType': _ownerIdProofType ?? '',
      'ownerIdProofNumber': _ownerIdProofNoCtrl.text.trim(),
      'ownerIdProofUrl': _ownerIdProofUrl ?? '',
      'gstNumber': _gstCtrl.text.trim(),
      'businessRegistrationNumber': _businessRegCtrl.text.trim(),
      'businessLicenseUrl': _businessLicenseUrl ?? '',
      'fssaiLicenseNumber': _fssaiNoCtrl.text.trim(),
      'fssaiLicenseUrl': _fssaiLicenseUrl ?? '',
      'insuranceCertificateUrl': _insuranceCertificateUrl ?? '',
      'page': 0,
      'size': 20,
      'category': _selectedCategory,
      'subCategory': _selectedSubCategory,
      'radius': radius,

      // Compatibility keys used by existing UI/backend contracts.
      'serviceName': _businessNameCtrl.text.trim(),
      'description': _serviceDescCtrl.text.trim(),
      'price': minPrice,
      'priceMin': minPrice,
      'priceMax': maxPrice > 0 ? maxPrice : null,
      'imageUrls': _imageUrls,
      'active': true,
    };

    final provider = context.read<EventServiceProvider>();
    final ok =
        _isEditMode
            ? await provider.updateService({
              ...payload,
              'esId': widget.editEsId,
            })
            : await provider.createService(payload);

    if (mounted) setState(() => _saving = false);

    if (!mounted) return;
    if (ok) {
      showAppToast(
        context,
        _isEditMode
            ? 'Service updated successfully!'
            : 'Service created successfully!',
      );
      context.pop();
      return;
    }

    showAppToast(
      context,
      provider.error ??
          (_isEditMode
              ? 'Failed to update service.'
              : 'Failed to create service.'),
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CategoryProvider>();
    final categories =
        catProvider.categories
            .map((c) => c.name ?? '')
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList();

    final subCategories =
        _selectedCategory == null
            ? <String>[]
            : catProvider
                .getSubcategoriesForCategory(_selectedCategory!)
                .toSet()
                .toList();

    final selectedCategoryValue =
        categories.contains(_selectedCategory) ? _selectedCategory : null;
    final selectedSubCategoryValue =
        subCategories.contains(_selectedSubCategory)
            ? _selectedSubCategory
            : null;
    const ownerIdProofTypes = ['AADHAAR', 'PAN', 'DL', 'VOTER_ID'];
    final selectedOwnerIdProofType =
        ownerIdProofTypes.contains(_ownerIdProofType)
            ? _ownerIdProofType
            : null;

    return Scaffold(
      appBar: AppHeader(
        title: _isEditMode ? 'Edit Listing Service' : 'Add Listing Service',
      ),
      body:
          _loadingExisting
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Owner & Business Details'),
                      _label('Owner Name *'),
                      TextFormField(
                        controller: _ownerNameCtrl,
                        validator: Validators.validateName,
                        decoration: const InputDecoration(
                          hintText: 'Owner name',
                        ),
                      ),
                      const SizedBox(height: 12),

                      _label('Primary Contact *'),
                      TextFormField(
                        controller: _primaryContactCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: Validators.validatePhone,
                        decoration: const InputDecoration(
                          hintText: '10-digit mobile',
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 12),

                      _label('WhatsApp Number'),
                      TextFormField(
                        controller: _whatsappCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          return Validators.validatePhone(v.trim());
                        },
                        decoration: const InputDecoration(
                          hintText: 'Optional',
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 12),

                      _label('Business / Service Name *'),
                      TextFormField(
                        controller: _businessNameCtrl,
                        validator:
                            (v) =>
                                Validators.validateRequired(v, 'Business name'),
                        decoration: const InputDecoration(
                          hintText: 'Business name',
                        ),
                      ),
                      const SizedBox(height: 12),

                      _label('Main Category *'),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: selectedCategoryValue,
                        items:
                            categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                      c,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedCategory = v;
                            _selectedSubCategory = null;
                          });
                        },
                        validator:
                            (v) => v == null ? 'Category is required' : null,
                        decoration: const InputDecoration(
                          hintText: 'Select category',
                        ),
                      ),
                      const SizedBox(height: 12),

                      _label('Service Sub-Category *'),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: selectedSubCategoryValue,
                        items:
                            subCategories
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            subCategories.isEmpty
                                ? null
                                : (v) =>
                                    setState(() => _selectedSubCategory = v),
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Sub-category is required'
                                    : null,
                        decoration: InputDecoration(
                          hintText:
                              subCategories.isEmpty
                                  ? 'Please select main category first'
                                  : 'Select sub category',
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(child: _label('Service Description')),
                          OutlinedButton.icon(
                            onPressed: _openAiDescriptionEditor,
                            icon: const Icon(Icons.auto_awesome, size: 16),
                            label: const Text('AI Auto Fill'),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _serviceDescCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Describe your service',
                        ),
                      ),
                      const SizedBox(height: 12),

                      _label('Years of Experience'),
                      TextFormField(
                        controller: _experienceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'e.g. 5'),
                      ),
                      const SizedBox(height: 20),

                      _sectionTitle('Location Details'),
                      Row(
                        children: [
                          Expanded(child: _label('Address *')),
                          TextButton.icon(
                            onPressed:
                                _isResolvingCurrentLocation
                                    ? null
                                    : _useSavedLocation,
                            icon:
                                _isResolvingCurrentLocation
                                    ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.my_location, size: 16),
                            label: Text(
                              _isResolvingCurrentLocation
                                  ? 'Locating...'
                                  : 'Use Current Location',
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _addressCtrl,
                        validator:
                            (v) => Validators.validateRequired(v, 'Address'),
                        onChanged: _onAddressChanged,
                        decoration: InputDecoration(
                          hintText: 'Enter location',
                          suffixIcon:
                              _isSearchingAddress
                                  ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                  : null,
                        ),
                      ),

                      if (_addressSuggestions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _addressSuggestions.length,
                            separatorBuilder:
                                (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final suggestion = _addressSuggestions[index];
                              return ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                ),
                                title: Text(
                                  suggestion.address,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  [
                                        suggestion.city,
                                        suggestion.state,
                                        suggestion.pincode,
                                      ]
                                      .where((e) => e.trim().isNotEmpty)
                                      .join(', '),
                                ),
                                onTap: () => _applySuggestion(suggestion),
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),
                      _label('Pincode *'),
                      TextFormField(
                        controller: _pincodeCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Pincode is required';
                          }
                          if (!RegExp(r'^\d{6}$').hasMatch(v.trim())) {
                            return 'Enter valid 6-digit pincode';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(counterText: ''),
                      ),
                      const SizedBox(height: 12),

                      _label('City *'),
                      TextFormField(
                        controller: _cityCtrl,
                        validator:
                            (v) => Validators.validateRequired(v, 'City'),
                        decoration: const InputDecoration(hintText: 'City'),
                      ),
                      const SizedBox(height: 12),

                      _label('State *'),
                      TextFormField(
                        controller: _stateCtrl,
                        validator:
                            (v) => Validators.validateRequired(v, 'State'),
                        decoration: const InputDecoration(hintText: 'State'),
                      ),
                      const SizedBox(height: 12),

                      _label('Latitude'),
                      TextFormField(
                        controller: TextEditingController(
                          text: _latitude?.toString() ?? '',
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 12),
                      _label('Longitude'),
                      TextFormField(
                        controller: TextEditingController(
                          text: _longitude?.toString() ?? '',
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),

                      _sectionTitle('Service Images'),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ..._imageUrls.map(
                            (url) => Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    url,
                                    width: 88,
                                    height: 88,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap:
                                        () => setState(
                                          () => _imageUrls.remove(url),
                                        ),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _pickServiceImage,
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(
                                Icons.add_a_photo,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _sectionTitle('Pricing Details'),
                      _label('Minimum Price (₹) *'),
                      TextFormField(
                        controller: _minPriceCtrl,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Minimum price is required';
                          }
                          return Validators.validatePrice(v);
                        },
                      ),
                      const SizedBox(height: 12),

                      _label('Maximum Price (₹)'),
                      TextFormField(
                        controller: _maxPriceCtrl,
                        keyboardType: TextInputType.number,
                        validator: Validators.validatePrice,
                        decoration: const InputDecoration(hintText: 'Optional'),
                      ),
                      const SizedBox(height: 12),

                      _label('Advance Booking (Days)'),
                      TextFormField(
                        controller: _advanceBookingCtrl,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),

                      _label('Service Radius (KM)'),
                      TextFormField(
                        controller: _radiusCtrl,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),

                      _label('Available on Weekends'),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Yes'),
                            selected: _availableOnWeekends,
                            onSelected:
                                (_) =>
                                    setState(() => _availableOnWeekends = true),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('No'),
                            selected: !_availableOnWeekends,
                            onSelected:
                                (_) => setState(
                                  () => _availableOnWeekends = false,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _sectionTitle('Additional Details'),
                      _label('ID Proof Type'),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: selectedOwnerIdProofType,
                        items: const [
                          DropdownMenuItem(
                            value: 'AADHAAR',
                            child: Text('Aadhaar'),
                          ),
                          DropdownMenuItem(value: 'PAN', child: Text('PAN')),
                          DropdownMenuItem(
                            value: 'DL',
                            child: Text('Driving License'),
                          ),
                          DropdownMenuItem(
                            value: 'VOTER_ID',
                            child: Text('Voter ID'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _ownerIdProofType = v),
                        decoration: const InputDecoration(
                          hintText: 'Select ID proof type',
                        ),
                      ),
                      const SizedBox(height: 12),

                      _label('ID Proof Number'),
                      TextFormField(
                        controller: _ownerIdProofNoCtrl,
                        decoration: const InputDecoration(hintText: 'Optional'),
                      ),
                      const SizedBox(height: 10),

                      _docTile(
                        title: 'Owner ID Proof',
                        value: _ownerIdProofUrl,
                        onUpload:
                            () => _pickDoc(
                              title: 'Upload Owner ID Proof',
                              onUploaded: (url) => _ownerIdProofUrl = url,
                            ),
                      ),
                      const SizedBox(height: 12),

                      _label('GST Number'),
                      TextFormField(
                        controller: _gstCtrl,
                        decoration: const InputDecoration(hintText: 'Optional'),
                      ),
                      const SizedBox(height: 12),

                      _label('Business Registration Number'),
                      TextFormField(
                        controller: _businessRegCtrl,
                        decoration: const InputDecoration(hintText: 'Optional'),
                      ),
                      const SizedBox(height: 10),

                      _docTile(
                        title: 'Business License',
                        value: _businessLicenseUrl,
                        onUpload:
                            () => _pickDoc(
                              title: 'Upload Business License',
                              onUploaded: (url) => _businessLicenseUrl = url,
                            ),
                      ),
                      const SizedBox(height: 12),

                      _label('FSSAI License Number'),
                      TextFormField(
                        controller: _fssaiNoCtrl,
                        decoration: const InputDecoration(hintText: 'Optional'),
                      ),
                      const SizedBox(height: 10),

                      _docTile(
                        title: 'FSSAI License',
                        value: _fssaiLicenseUrl,
                        onUpload:
                            () => _pickDoc(
                              title: 'Upload FSSAI License',
                              onUploaded: (url) => _fssaiLicenseUrl = url,
                            ),
                      ),
                      const SizedBox(height: 10),

                      _docTile(
                        title: 'Insurance Certificate',
                        value: _insuranceCertificateUrl,
                        onUpload:
                            () => _pickDoc(
                              title: 'Upload Insurance Certificate',
                              onUploaded:
                                  (url) => _insuranceCertificateUrl = url,
                            ),
                      ),
                      const SizedBox(height: 18),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.35),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _acceptedTerms,
                              onChanged:
                                  (v) => setState(
                                    () => _acceptedTerms = v ?? false,
                                  ),
                            ),
                            const Expanded(
                              child: Text(
                                'I have read and agree to the Terms & Conditions and Privacy Policy',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _saving ? null : _submit,
                                child:
                                    _saving
                                        ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : Text(
                                          _isEditMode
                                              ? 'Update Event Service'
                                              : 'Add Event Service',
                                        ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed:
                                    _saving
                                        ? null
                                        : () => _formKey.currentState?.reset(),
                                child: const Text('Reset'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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

  Widget _docTile({
    required String title,
    required String? value,
    required VoidCallback onUpload,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            value == null || value.isEmpty
                ? 'No document uploaded'
                : 'Uploaded',
            style: TextStyle(
              color:
                  value == null || value.isEmpty
                      ? AppColors.textSecondary
                      : AppColors.success,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_file),
              label: Text('Upload $title'),
            ),
          ),
        ],
      ),
    );
  }
}
