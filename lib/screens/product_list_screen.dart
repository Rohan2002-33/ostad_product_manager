import 'package:flutter/material.dart';

import '../models/product.dart';
import 'product_detail_screen.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form_dialog.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() =>
      _ProductListScreenState();
}

class _ProductListScreenState
    extends State<ProductListScreen> {
  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  final Map<int, String> _descriptionOverrides = {};
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  List<Product> get _filteredProducts {
    if (_searchQuery.trim().isEmpty) {
      return _products;
    }

    final query = _searchQuery.toLowerCase().trim();

    return _products.where((product) {
      return product.productName
              .toLowerCase()
              .contains(query) ||
          product.productCode
              .toString()
              .contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts({
    bool showLoader = true,
  }) async {
    if (showLoader) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final products =
          await _apiService.getProducts();

      if (!mounted) return;

      final productsWithDescriptions = products.map((product) {
        final savedDescription = _descriptionOverrides[product.productCode];
        if (product.description.isNotEmpty || savedDescription == null) {
          return product;
        }
        return Product(
          id: product.id,
          productName: product.productName,
          productCode: product.productCode,
          imageUrl: product.imageUrl,
          description: savedDescription,
          quantity: product.quantity,
          unitPrice: product.unitPrice,
          totalPrice: product.totalPrice,
        );
      }).toList();

      setState(() {
        _products = productsWithDescriptions;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _addProduct() async {
    final product =
        await showDialog<Product>(
      context: context,
      builder: (_) =>
          const ProductFormDialog(),
    );

    if (product == null) return;

    setState(() {
      _isLoading = true;
      _descriptionOverrides[product.productCode] =
          product.description;
    });

    try {
      await _apiService.createProduct(product);

      if (!mounted) return;

      _showMessage(
        'Product created successfully.',
      );

      await _loadProducts();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        error.toString(),
        isError: true,
      );
    }
  }

  Future<void> _editProduct(Product product) async {
    final updatedProduct =
        await showDialog<Product>(
      context: context,
      builder: (_) =>
          ProductFormDialog(
        product: product,
      ),
    );

    if (updatedProduct == null) return;

    setState(() {
      _isLoading = true;
      _descriptionOverrides[updatedProduct.productCode] =
          updatedProduct.description;
    });

    try {
      await _apiService
          .updateProduct(updatedProduct);

      if (!mounted) return;

      _showMessage(
        'Product updated successfully.',
      );

      await _loadProducts();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        error.toString(),
        isError: true,
      );
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Product?',
          ),
          content: Text(
            'Are you sure you want to delete '
            '"${product.productName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    Theme.of(context)
                        .colorScheme
                        .error,
              ),
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (product.id == null ||
          product.id!.isEmpty) {
        throw ApiException(
          'Product ID is missing.',
        );
      }

      await _apiService
          .deleteProduct(product.id!);

      if (!mounted) return;

      _showMessage(
        'Product deleted successfully.',
      );

      await _loadProducts();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        error.toString(),
        isError: true,
      );
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          backgroundColor: isError
              ? Theme.of(context)
                  .colorScheme
                  .error
              : null,
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Manager',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading
                ? null
                : () => _loadProducts(),
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                12,
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration:
                    InputDecoration(
                  hintText:
                      'Search products...',
                  prefixIcon: const Icon(
                    Icons.search,
                  ),
                  suffixIcon:
                      _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  _searchQuery =
                                      '';
                                });
                              },
                              icon: const Icon(
                                Icons.clear,
                              ),
                            ),
                ),
              ),
            ),

            Expanded(
              child: _buildBody(products),
            ),
          ],
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _isLoading
            ? null
            : _addProduct,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Product',
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final totalValue =
        _products.fold<double>(
      0,
      (sum, product) =>
          sum + product.totalPrice,
    );

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        14,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Products',
              value: '${_products.length}',
              icon:
                  Icons.inventory_2_outlined,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              title: 'Inventory Value',
              value:
                  '৳${totalValue.toStringAsFixed(0)}',
              icon:
                  Icons.account_balance_wallet_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    List<Product> products,
  ) {
    if (_isLoading && _products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null &&
        _products.isEmpty) {
      return _ErrorState(
        message: _errorMessage!,
        onRetry: () => _loadProducts(),
      );
    }

    if (products.isEmpty) {
      return RefreshIndicator(
        onRefresh: () =>
            _loadProducts(
              showLoader: false,
            ),
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 100),
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'No products found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final padding = const EdgeInsets.fromLTRB(16, 4, 16, 100);

        Widget buildCard(int index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onEdit: () => _editProduct(product),
            onDelete: () => _deleteProduct(product),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: product),
                ),
              );
            },
          );
        }

        final scrollView = isWide
            ? GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: padding,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 540,
                  mainAxisExtent: 292,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 0,
                ),
                itemCount: products.length,
                itemBuilder: (_, index) => buildCard(index),
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: padding,
                itemCount: products.length,
                itemBuilder: (_, index) => buildCard(index),
              );

        return RefreshIndicator(onRefresh: () => _loadProducts(showLoader: false), child: scrollView);
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load products',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}