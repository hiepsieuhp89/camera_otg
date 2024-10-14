import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl = dotenv.env['API_URL'] ?? "http://localhost:3000";
  Map<String, String> defaultHeaders = {
    "Content-Type": "application/json; charset=UTF-8"
  };

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headerParams,
  }) async {
    var uri =
        Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParams);
    final Map<String, String> headers = {
      ...headerParams ?? <String, String>{},
      ...defaultHeaders
    };

    final response = await http.get(uri, headers: headers);
    return _processResponse(response);
  }

  Future<dynamic> post(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headerParams,
  }) async {
    final Map<String, String> headers = {
      ...headerParams ?? <String, String>{},
      ...defaultHeaders
    };

    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParams),
      body: json.encode(body),
      headers: headers,
    );
    return _processResponse(response);
  }

  Future<dynamic> put(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headerParams,
  }) async {
    final Map<String, String> headers = {
      ...headerParams ?? <String, String>{},
      ...defaultHeaders
    };

    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParams),
      body: json.encode(body),
      headers: headers,
    );
    return _processResponse(response);
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headerParams,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParams),
      headers: headerParams,
    );
    return _processResponse(response);
  }

  Future<dynamic> postSingleFile(String endpoint, String filePath,
      {Map<String, String>? headerParams}) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/$endpoint'));
    final file = await http.MultipartFile.fromPath('file', filePath);
    request.files.add(file);
    request.headers.addAll(headerParams ?? {});

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();

      return json.decode(responseBody);
    } else {
      response.stream.bytesToString().then((value) {
        debugPrint('Failed to upload photo: ${response.statusCode} $value');
      });

      throw Exception('Failed to upload photo');
    }
  }

  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return json.decode(utf8.decode(response.bodyBytes));
      case 204:
        return null;
      // NOTE: Backend should throw 401, but whatever
      case 403:
        throw UnauthorizedApiException(
            endpoint: response.request!.url.toString(),
            statusCode: response.statusCode);
      default:
        throw Exception(
            'Error: ${response.statusCode}, Body: ${response.body}');
    }
  }
}

class UnauthorizedApiException implements Exception {
  final String message;
  final String endpoint;
  final int statusCode;

  UnauthorizedApiException({
    this.message = 'Unauthorized request',
    required this.endpoint,
    required this.statusCode,
  });

  @override
  String toString() {
    return 'UnauthorizedApiException: $message (Endpoint: $endpoint, Status Code: $statusCode)';
  }
}
