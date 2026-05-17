class ProductVariantModel {
  const ProductVariantModel({
    required this.id,
    required this.productId,
    required this.sku,
    required this.size,
    required this.colorEn,
    required this.colorAr,
    required this.colorHex,
    required this.price,
    required this.discountPrice,
    required this.stock,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final String sku;
  final String size;
  final String colorEn;
  final String colorAr;
  final String colorHex;
  final double price;
  final double? discountPrice;
  final int stock;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id:            json['id']             as String,
      productId:     json['product_id']     as String,
      sku:           json['sku']            as String,
      size:          json['size']           as String,
      colorEn:       json['color_en']       as String,
      colorAr:       json['color_ar']       as String,
      colorHex:      json['color_hex']      as String,
      price:        (json['price']          as num).toDouble(),
      discountPrice: json['discount_price'] == null
          ? null
          : (json['discount_price'] as num).toDouble(),
      stock:         json['stock']          as int,
      isActive:      json['is_active']      as bool,
      sortOrder:     json['sort_order']     as int,
      createdAt:     DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':             id,
      'product_id':     productId,
      'sku':            sku,
      'size':           size,
      'color_en':       colorEn,
      'color_ar':       colorAr,
      'color_hex':      colorHex,
      'price':          price,
      'discount_price': discountPrice,
      'stock':          stock,
      'is_active':      isActive,
      'sort_order':     sortOrder,
      'created_at':     createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'product_id':     productId,
      'sku':            sku,
      'size':           size,
      'color_en':       colorEn,
      'color_ar':       colorAr,
      'color_hex':      colorHex,
      'price':          price,
      'discount_price': discountPrice,
      'stock':          stock,
      'is_active':      isActive,
      'sort_order':     sortOrder,
    };
  }
}
