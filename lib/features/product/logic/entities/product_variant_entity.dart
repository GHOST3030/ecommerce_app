enum ProductSize {
  xs,
  s,
  m,
  l,
  xl,
  xxl,
  xxxl,
  oneSize;

  static ProductSize fromString(String value) {
    return switch (value.toUpperCase()) {
      'XS'       => ProductSize.xs,
      'S'        => ProductSize.s,
      'M'        => ProductSize.m,
      'L'        => ProductSize.l,
      'XL'       => ProductSize.xl,
      'XXL'      => ProductSize.xxl,
      'XXXL'     => ProductSize.xxxl,
      'ONE_SIZE' => ProductSize.oneSize,
      _          => throw ArgumentError('Unknown product size: $value'),
    };
  }

  String toDbString() {
    return switch (this) {
      ProductSize.xs      => 'XS',
      ProductSize.s       => 'S',
      ProductSize.m       => 'M',
      ProductSize.l       => 'L',
      ProductSize.xl      => 'XL',
      ProductSize.xxl     => 'XXL',
      ProductSize.xxxl    => 'XXXL',
      ProductSize.oneSize => 'ONE_SIZE',
    };
  }

  String get displayLabel {
    return switch (this) {
      ProductSize.xs      => 'XS',
      ProductSize.s       => 'S',
      ProductSize.m       => 'M',
      ProductSize.l       => 'L',
      ProductSize.xl      => 'XL',
      ProductSize.xxl     => 'XXL',
      ProductSize.xxxl    => 'XXXL',
      ProductSize.oneSize => 'One Size',
    };
  }
}

class ProductVariantEntity {
  const ProductVariantEntity({
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
  final ProductSize size;
  final String colorEn;
  final String colorAr;
  final String colorHex;
  final double price;
  final double? discountPrice;
  final int stock;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;

  double get effectivePrice => discountPrice ?? price;

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((price - discountPrice!) / price) * 100).round();
  }

  bool get inStock => stock > 0;

  String localizedColor(String languageCode) =>
      languageCode == 'ar' ? colorAr : colorEn;

  static const Object _sentinel = Object();

  ProductVariantEntity copyWith({
    String? sku,
    ProductSize? size,
    String? colorEn,
    String? colorAr,
    String? colorHex,
    double? price,
    Object? discountPrice = _sentinel,
    int? stock,
    bool? isActive,
    int? sortOrder,
  }) {
    return ProductVariantEntity(
      id:            id,
      productId:     productId,
      sku:           sku           ?? this.sku,
      size:          size          ?? this.size,
      colorEn:       colorEn       ?? this.colorEn,
      colorAr:       colorAr       ?? this.colorAr,
      colorHex:      colorHex      ?? this.colorHex,
      price:         price         ?? this.price,
      discountPrice: discountPrice == _sentinel
          ? this.discountPrice
          : discountPrice as double?,
      stock:         stock         ?? this.stock,
      isActive:      isActive      ?? this.isActive,
      sortOrder:     sortOrder     ?? this.sortOrder,
      createdAt:     createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariantEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ProductVariantEntity(id: $id, sku: $sku, size: ${size.displayLabel}, color: $colorEn)';
}
