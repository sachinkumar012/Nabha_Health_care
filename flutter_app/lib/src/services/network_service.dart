import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

class NetworkService {
  static const String _baseUrl = AppConstants.baseUrl;
  static const Duration _timeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> _getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // GET request
  static Future<http.Response> get(
    String endpoint, {
    String? token,
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse('$_baseUrl$endpoint');

      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri, headers: _getHeaders(token: token))
          .timeout(_timeout);

      return response;
    } catch (e) {
      throw NetworkException('GET request failed: $e');
    }
  }

  // POST request
  static Future<http.Response> post(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');

      final response = await http
          .post(
            uri,
            headers: _getHeaders(token: token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return response;
    } catch (e) {
      throw NetworkException('POST request failed: $e');
    }
  }

  // PUT request
  static Future<http.Response> put(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');

      final response = await http
          .put(
            uri,
            headers: _getHeaders(token: token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return response;
    } catch (e) {
      throw NetworkException('PUT request failed: $e');
    }
  }

  // Multipart request for file uploads
  static Future<http.StreamedResponse> uploadFile(
    String endpoint, {
    String? token,
    required File file,
    required String fieldName,
    Map<String, String>? fields,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );

      // Add additional fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send().timeout(_timeout);
      return streamedResponse;
    } catch (e) {
      throw NetworkException('File upload failed: $e');
    }
  }

  // Handle API response
  static Map<String, dynamic> handleResponse(http.Response response) {
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else {
      throw ApiException(
        message: responseData['message'] ?? 'Request failed',
        statusCode: response.statusCode,
      );
    }
  }

  // Handle streamed response
  static Future<Map<String, dynamic>> handleStreamedResponse(
      http.StreamedResponse streamedResponse) async {
    final response = await http.Response.fromStream(streamedResponse);
    return handleResponse(response);
  }
}

// Custom exceptions
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
