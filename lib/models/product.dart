class Product {
  final String? id;
  final String productName;
  final int productCode;
  final String imageUrl;
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const Product({
    this.id,
    required this.productName,
    required this.productCode,
    required this.imageUrl,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['_id'] ?? json['id'] ?? json['ID'])?.toString(),
      productName:
          (json['ProductName'] ?? json['productName'] ?? '').toString(),
      productCode: _toInt(json['ProductCode'] ?? json['productCode']),
      imageUrl: (json['Img'] ?? json['img'] ?? json['image'] ?? '').toString(),
        description: (json['Description'] ??
            json['description'] ??
            json['Details'] ??
            json['details'] ??
            '')
          .toString(),
      quantity: _toInt(json['Qty'] ?? json['qty'] ?? json['quantity']),
      unitPrice:
          _toDouble(json['UnitPrice'] ?? json['unitPrice']),
      totalPrice:
          _toDouble(json['TotalPrice'] ?? json['totalPrice']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ProductName': productName,
      'ProductCode': productCode,
      'Img': imageUrl,
      'Description': description,
      'Qty': quantity,
      'UnitPrice': unitPrice,
      'TotalPrice': totalPrice,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}