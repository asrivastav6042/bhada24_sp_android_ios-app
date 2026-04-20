import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bhada24_sp/core/config/api_config.dart';
import 'package:bhada24_sp/core/network/api_client.dart';

/// Handles image picking and base64 upload to the server
class ImageUploadService {
  final ApiClient _api;
  final ImagePicker _picker = ImagePicker();

  ImageUploadService(this._api);

  /// Pick image from [source] and upload as base64.
  /// Returns the CDN URL on success, null on failure/cancel.
  Future<String?> pickAndUpload({
    required ImageSource source,
    int imageQuality = 80,
    double? maxWidth = 1024,
    double? maxHeight = 1024,
  }) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      if (picked == null) return null;
      return await _uploadXFile(picked);
    } catch (e) {
      debugPrint('ImageUploadService.pickAndUpload error: $e');
      return null;
    }
  }

  Future<String?> _uploadXFile(XFile file) async {
    try {
      String base64Image;
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        base64Image = base64Encode(bytes);
      } else {
        final bytes = await File(file.path).readAsBytes();
        base64Image = base64Encode(bytes);
      }
      final mimeType = _mimeTypeFromExtension(file.name);
      final dataUri = 'data:$mimeType;base64,$base64Image';

      final res = await _api.post(ApiConfig.uploadBase64Image,
          data: {'image': dataUri});
      final data = res.data;
      if (data is Map && (data['responseCode'] == 200 || data['responseCode'] == 0)) {
        final payload = data['responseData'];
        if (payload is Map<String, dynamic>) {
          return payload['url'] as String? ??
              payload['imageUrl'] as String? ??
              payload['data'] as String?;
        }
        if (payload is String) return payload;
      }
      return null;
    } catch (e) {
      debugPrint('ImageUploadService._uploadXFile error: $e');
      return null;
    }
  }

  String _mimeTypeFromExtension(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
