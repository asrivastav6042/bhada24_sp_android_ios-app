import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/presentation/widgets/common/button_spinner.dart';

/// Modal for adding/managing service images
Future<List<String>?> showServiceImageModal(
  BuildContext context, {
  required List<String> existingImages,
  required Future<String?> Function(XFile file) onUpload,
  required Future<void> Function(String url) onDelete,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ServiceImageModal(
      existingImages: existingImages,
      onUpload: onUpload,
      onDelete: onDelete,
    ),
  );
}

class ServiceImageModal extends StatefulWidget {
  final List<String> existingImages;
  final Future<String?> Function(XFile file) onUpload;
  final Future<void> Function(String url) onDelete;

  const ServiceImageModal({
    super.key,
    required this.existingImages,
    required this.onUpload,
    required this.onDelete,
  });

  @override
  State<ServiceImageModal> createState() => _ServiceImageModalState();
}

class _ServiceImageModalState extends State<ServiceImageModal> {
  late List<String> _images;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.existingImages);
  }

  Future<void> _addImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: source, imageQuality: 80, maxWidth: 1024);
    if (file == null) return;
    setState(() => _isUploading = true);
    try {
      final url = await widget.onUpload(file);
      if (url != null && mounted) {
        setState(() => _images.add(url));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _removeImage(String url) async {
    await widget.onDelete(url);
    setState(() => _images.remove(url));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
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
            const Text('Service Images',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Add up to 5 images for your service.',
                style: TextStyle(
                    fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                controller: controller,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _images.length + (_images.length < 5 ? 1 : 0),
                itemBuilder: (ctx, i) {
                  if (i == _images.length) {
                    // Add button
                    return GestureDetector(
                      onTap: _isUploading
                          ? null
                          : () => _showSourcePicker(context),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.primary,
                              style: BorderStyle.solid),
                          color: AppColors.primary.withAlpha(13),
                        ),
                        child: _isUploading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2))
                            : const Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate,
                                      color: AppColors.primary, size: 28),
                                  SizedBox(height: 4),
                                  Text('Add',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12)),
                                ],
                              ),
                      ),
                    );
                  }
                  final url = _images[i];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _confirmRemove(context, url),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            ButtonSpinner(
              label: 'Done',
              onPressed: () => Navigator.of(context).pop(_images),
            ),
          ],
        ),
      ),
    );
  }

  void _showSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _addImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library,
                  color: AppColors.primary),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _addImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Image'),
        content: const Text(
            'Are you sure you want to remove this image?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeImage(url);
            },
            child: const Text('Remove',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
