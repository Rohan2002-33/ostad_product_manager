import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl =
      'https://crud-api-ostad-live.onrender.com/api/v1';

  Future<List<Product>> getProducts() async {
    final response = await http
        .get(Uri.parse('$baseUrl/ReadProduct'))
        .timeout(const Duration(seconds: 20));

    _checkResponse(response);

    final dynamic decoded = jsonDecode(response.body);

    return _extractProducts(decoded);
  }

  Future<Product?> getProductById(String id) async {
    final response = await http
        .get(Uri.parse('$baseUrl/ReadProductById/$id'))
        .timeout(const Duration(seconds: 20));

    _checkResponse(response);

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      final data = _extractMap(decoded);

      if (data != null) {
        return Product.fromJson(data);
      }
    }

    return null;
  }

  Future<void> createProduct(Product product) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/CreateProduct'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(product.toJson()),
        )
        .timeout(const Duration(seconds: 20));

    _checkResponse(response);
  }

  Future<void> updateProduct(Product product) async {
    if (product.id == null || product.id!.isEmpty) {
      throw ApiException('Product ID is missing.');
    }

    final response = await http
        .post(
          Uri.parse('$baseUrl/UpdateProduct/${product.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(product.toJson()),
        )
        .timeout(const Duration(seconds: 20));

    _checkResponse(response);
  }

  Future<void> deleteProduct(String id) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/DeleteProduct/$id'),
          headers: {
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 20));

    _checkResponse(response);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String message = 'Request failed (${response.statusCode})';

    try {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        message =
            (body['message'] ??
                    body['Message'] ??
                    body['error'] ??
                    body['Error'] ??
                    message)
                .toString();
      }
    } catch (_) {
      // Keep default error message.
    }

    throw ApiException(message);
  }

  List<Product> _extractProducts(dynamic decoded) {
    dynamic data = decoded;

    if (decoded is Map<String, dynamic>) {
      data = decoded['data'] ??
          decoded['Data'] ??
          decoded['products'] ??
          decoded['Products'] ??
          decoded['result'] ??
          decoded['Result'] ??
          decoded;
    }

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList();
    }

    if (data is Map<String, dynamic>) {
      return [Product.fromJson(data)];
    }

    return [];
  }

  Map<String, dynamic>? _extractMap(Map<String, dynamic> decoded) {
    final dynamic data = decoded['data'] ??
        decoded['Data'] ??
        decoded['product'] ??
        decoded['Product'] ??
        decoded['result'] ??
        decoded['Result'] ??
        decoded;

    if (data is Map<String, dynamic>) {
      return data;
    }

    return null;
  }
}