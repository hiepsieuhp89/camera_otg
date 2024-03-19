import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class BaseApiService {
  final String baseUrl = dotenv.env['API_URL'] ?? "http://localhost:3000";

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? query}) async {
    var uri = Uri.parse('$baseUrl/$endpoint').replace(queryParameters: query);

    final response = await http
        .get(uri, headers: {'Content-Type': 'application/json; charset=utf-8'});
    return _processResponse(response);
  }

  Future<dynamic> post(String endpoint, Object? body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );
    return _processResponse(response);
  }

  Future<dynamic> put(String endpoint, {dynamic body}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );
    return _processResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );
    return _processResponse(response);
  }

  Future<dynamic> postSingleFile(String endpoint, String filePath) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/$endpoint'));
    final file = await http.MultipartFile.fromPath('file', filePath);
    request.files.add(file);

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
      default:
        throw Exception(
            'Error: ${response.statusCode}, Body: ${response.body}');
    }
  }
}
