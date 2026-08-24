import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: SizedBox(
          width: 64,
          height: 64,
          child: Image.network(
            product.image,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.image_not_supported),
          ),
        ),
        title: Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${product.category}  |  \$${product.price.toStringAsFixed(2)}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
