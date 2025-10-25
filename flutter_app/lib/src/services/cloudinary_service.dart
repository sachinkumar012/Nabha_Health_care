import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryService {
  // Your Cloudinary configuration (should match backend .env)
  static const String _cloudName = 'dnnkimx5e';
  static const String _apiKey = '785997849377234';
  static const String _apiSecret = 'xc3mOVW05vrt_RnG9nY8xTQi6_c';
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  // Upload image to Cloudinary
  static Future<String> uploadImage(File imageFile) async {
    try {
      print('🌥️ CLOUDINARY: Starting upload for: ${imageFile.path}');

      // Generate timestamp and signature
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final publicId =
          'nabha_healthcare/profiles/profile_${DateTime.now().millisecondsSinceEpoch}';

      // Create signature for secure upload
      final signatureParams = {
        'folder': 'nabha_healthcare/profiles',
        'public_id': publicId,
        'timestamp': timestamp,
        'transformation': 'c_fill,g_face,h_400,w_400',
      };

      final signature = _generateSignature(signatureParams, _apiSecret);

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Add parameters
      request.fields.addAll({
        'api_key': _apiKey,
        'timestamp': timestamp,
        'signature': signature,
        'folder': 'nabha_healthcare/profiles',
        'public_id': publicId,
        'transformation': 'c_fill,g_face,h_400,w_400',
        'quality': 'auto',
        'fetch_format': 'auto',
      });

      print('🌥️ CLOUDINARY: Sending request...');

      // Send request
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 30),
          );

      final response = await http.Response.fromStream(streamedResponse);

      print('🌥️ CLOUDINARY: Response status: ${response.statusCode}');
      print('🌥️ CLOUDINARY: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageUrl = responseData['secure_url'] as String;

        print('🌥️ CLOUDINARY: Upload successful! URL: $imageUrl');
        return imageUrl;
      } else {
        throw CloudinaryException(
            'Upload failed with status: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      print('❌ CLOUDINARY: Upload error: $e');
      throw CloudinaryException('Failed to upload image: $e');
    }
  }

  // Generate signature for Cloudinary API
  static String _generateSignature(
      Map<String, String> params, String apiSecret) {
    // Sort parameters by key
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    // Create parameter string
    final paramString = sortedParams.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');

    // Add API secret
    final stringToSign = '$paramString$apiSecret';

    // Generate SHA1 hash
    final bytes = utf8.encode(stringToSign);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }

  // Delete image from Cloudinary (optional)
  static Future<bool> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      final signatureParams = {
        'public_id': publicId,
        'timestamp': timestamp,
      };

      final signature = _generateSignature(signatureParams, _apiSecret);

      final response = await http.post(
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/destroy'),
        body: {
          'api_key': _apiKey,
          'timestamp': timestamp,
          'signature': signature,
          'public_id': publicId,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['result'] == 'ok';
      }

      return false;
    } catch (e) {
      print('❌ CLOUDINARY: Delete error: $e');
      return false;
    }
  }
}

// Custom exception for Cloudinary operations
class CloudinaryException implements Exception {
  final String message;
  CloudinaryException(this.message);

  @override
  String toString() => 'CloudinaryException: $message';
}
