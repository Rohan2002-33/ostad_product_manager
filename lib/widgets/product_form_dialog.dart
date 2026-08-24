import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key, this.product});

  final Product? product;

  bool get isEditing => product != null;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _imageController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _qtyController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.productName ?? '');
    _codeController = TextEditingController(text: product?.productCode.toString() ?? '');
    _imageController = TextEditingController(text: product?.imageUrl ?? '');
    _descriptionController = TextEditingController(text: product?.description ?? '');
    _qtyController = TextEditingController(text: product?.quantity.toString() ?? '');
    _priceController = TextEditingController(text: product?.unitPrice.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Product? _buildProduct() {
    if (!_formKey.currentState!.validate()) return null;
    final quantity = int.parse(_qtyController.text.trim());
    final unitPrice = double.parse(_priceController.text.trim());
    return Product(
      id: widget.product?.id,
      productName: _nameController.text.trim(),
      productCode: int.parse(_codeController.text.trim()),
      imageUrl: _imageController.text.trim(),
      description: _descriptionController.text.trim(),
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: quantity * unitPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 440;
    final maxHeight = media.height < 760 ? media.height * 0.62 : media.height * 0.72;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 24, vertical: 24),
      title: Text(widget.isEditing ? 'Edit Product' : 'Add Product'),
      content: SizedBox(
        width: isCompact ? media.width - 24 : 520,
        height: maxHeight,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _fieldLabel('Product Name'),
                _textField(_nameController, hint: 'Enter product name', icon: Icons.inventory_2_outlined, validator: (value) => _required(value, 'Enter product name')),
                const SizedBox(height: 16),
                _fieldLabel('Product Code'),
                _textField(_codeController, hint: 'Enter product code', icon: Icons.qr_code_2_outlined, keyboardType: TextInputType.number, validator: (value) => int.tryParse(value?.trim() ?? '') == null ? 'Enter a valid product code' : null),
                const SizedBox(height: 16),
                _fieldLabel('Image URL'),
                _textField(_imageController, hint: 'Paste image URL', icon: Icons.image_outlined, keyboardType: TextInputType.url, validator: (value) => _required(value, 'Enter image URL')),
                const SizedBox(height: 16),
                _fieldLabel('Product Description'),
                _textField(_descriptionController, hint: 'Write a short description', icon: Icons.description_outlined, maxLines: 4, validator: (value) => _required(value, 'Enter product description')),
                const SizedBox(height: 16),
                if (isCompact) ...[
                  _fieldLabel('Quantity'),
                  _quantityField(),
                  const SizedBox(height: 16),
                  _fieldLabel('Unit Price'),
                  _priceField(),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [_fieldLabel('Quantity'), _quantityField()])),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [_fieldLabel('Unit Price'), _priceField()])),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton.icon(
          onPressed: () {
            final product = _buildProduct();
            if (product != null) Navigator.pop(context, product);
          },
          icon: Icon(widget.isEditing ? Icons.save_outlined : Icons.add),
          label: Text(widget.isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _textField(
    TextEditingController controller, {
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
      maxLines: maxLines,
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
      validator: validator,
    );
  }

  Widget _quantityField() {
    return _textField(_qtyController, hint: 'Enter quantity', icon: Icons.numbers_outlined, keyboardType: TextInputType.number, validator: (value) {
      final number = int.tryParse(value?.trim() ?? '');
      return number == null || number < 0 ? 'Invalid quantity' : null;
    });
  }

  Widget _priceField() {
    return _textField(_priceController, hint: 'Enter unit price', icon: Icons.payments_outlined, keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (value) {
      final number = double.tryParse(value?.trim() ?? '');
      return number == null || number < 0 ? 'Invalid price' : null;
    });
  }

  String? _required(String? value, String message) {
    return value == null || value.trim().isEmpty ? message : null;
  }
}
