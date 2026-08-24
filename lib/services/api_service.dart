import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _productsUri = Uri.parse('https://fakestoreapi.com/products');
  final http.Client _client;

  Future<List<Product>> fetchProducts() async {
    final response = await _client.get(_productsUri);
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Product> createProduct(Product product) async {
    final response = await _client.post(
      _productsUri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    _ensureSuccess(response);
    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Product> updateProduct(Product product) async {
    final response = await _client.put(
      _productsUri.replace(path: '${_productsUri.path}/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    _ensureSuccess(response);
    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteProduct(int id) async {
    final response = await _client.delete(
      _productsUri.replace(path: '${_productsUri.path}/$id'),
    );
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Request failed (${response.statusCode})');
    }
  }
}
