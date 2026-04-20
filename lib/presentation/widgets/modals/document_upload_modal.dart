import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bhada24_sp/core/theme/app_colors.dart';
import 'package:bhada24_sp/presentation/widgets/common/button_spinner.dart';

/// Modal for uploading documents/images (e.g. ID proof, license)
Future<void> showDocumentUploadModal(
  BuildContext context, {
  required String title,
  required Future<bool> Function(XFile file) onUpload,
  String? hint,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DocumentUploadModal(
      title: title,
      onUpload: onUpload,
      hint: hint,
    ),
  );
}

class DocumentUploadModal extends StatefulWidget {
  final String title;
  final Future<bool> Function(XFile file) onUpload;
  final String? hint;

  const DocumentUploadModal({
    super.key,
    required this.title,
    required this.onUpload,
    this.hint,
  });

  @override
  State<DocumentUploadModal> createState() => _DocumentUploadModalState();
}

class _DocumentUploadModalState extends State<DocumentUploadModal> {
  XFile? _selectedFile;
  bool _isUploading = false;
  String? _error;
  bool _success = false;

  Future<void> _pickFile(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (file != null) {
      setState(() {
        _selectedFile = file;
        _error = null;
        _success = false;
      });
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null) return;
    setState(() {
      _isUploading = true;
      _error = null;
    });
    try {
      final ok = await widget.onUpload(_selectedFile!);
      if (mounted) {
        if (ok) {
          setState(() => _success = true);
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) Navigator.of(context).pop(true);
        } else {
          setState(() => _error = 'Upload failed. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Upload failed: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
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
              widget.title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (widget.hint != null) ...[
              const SizedBox(height: 6),
              Text(widget.hint!,
                  style:
                      TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
            const SizedBox(height: 20),
            if (_selectedFile != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: kIsWeb
                    ? Image.network(_selectedFile!.path,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover)
                    : Image.file(File(_selectedFile!.path),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    onPressed:
                        _isUploading ? null : () => _pickFile(ImageSource.camera),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    onPressed: _isUploading
                        ? null
                        : () => _pickFile(ImageSource.gallery),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            if (_success) ...[
              const SizedBox(height: 8),
              const Text('Uploaded successfully!',
                  style: TextStyle(color: Colors.green, fontSize: 13)),
            ],
            const SizedBox(height: 16),
            ButtonSpinner(
              label: 'Upload',
              isLoading: _isUploading,
              onPressed: _selectedFile == null ? null : _upload,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
