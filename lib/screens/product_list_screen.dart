import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form_dialog.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _apiService = ApiService();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await _apiService.fetchProducts();
      if (mounted) setState(() => _products = products);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showForm([Product? product]) async {
    final result = await showDialog<Product>(
      context: context,
      builder: (_) => ProductFormDialog(product: product),
    );
    if (result == null) return;

    try {
      final saved = result.id == null
          ? await _apiService.createProduct(result)
          : await _apiService.updateProduct(result);
      if (!mounted) return;
      setState(() {
        final index = _products.indexWhere((item) => item.id == result.id);
        if (index == -1) {
          _products = [saved, ..._products];
        } else {
          _products[index] = saved;
        }
      });
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    }
  }

  Future<void> _delete(Product product) async {
    if (product.id == null) return;
    try {
      await _apiService.deleteProduct(product.id!);
      if (mounted) {
        setState(() => _products.removeWhere((item) => item.id == product.id));
      }
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [IconButton(onPressed: _loadProducts, icon: const Icon(Icons.refresh))],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 8),
                      OutlinedButton(onPressed: _loadProducts, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _products.length,
                    itemBuilder: (_, index) {
                      final product = _products[index];
                      return ProductCard(
                        product: product,
                        onEdit: () => _showForm(product),
                        onDelete: () => _delete(product),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showForm,
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
    );
  }
}
