class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.categoryId,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.basePrice,
    required this.discountPrice,
    required this.images,
    required this.isActive,
    required this.isFeatured,
    required this.sortOrder,
    required this.createdAt,
  });

  final String id;
  final String categoryId;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final double basePrice;
  final double? discountPrice;
  final List<String> images;
  final bool isActive;
  final bool isFeatured;
  final int sortOrder;
  final DateTime createdAt;

  double get effectivePrice => discountPrice ?? basePrice;

  bool get hasDiscount => discountPrice != null && discountPrice! < basePrice;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((basePrice - discountPrice!) / basePrice) * 100).round();
  }

  String get thumbnailUrl => images.isNotEmpty ? images.first : '';

  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;

  String localizedDescription(String languageCode) =>
      languageCode == 'ar' ? descriptionAr : descriptionEn;

  static const Object _sentinel = Object();

  ProductEntity copyWith({
    String? categoryId,
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
    double? basePrice,
    Object? discountPrice = _sentinel,
    List<String>? images,
    bool? isActive,
    bool? isFeatured,
    int? sortOrder,
  }) {
    return ProductEntity(
      id:            id,
      categoryId:    categoryId    ?? this.categoryId,
      nameEn:        nameEn        ?? this.nameEn,
      nameAr:        nameAr        ?? this.nameAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      basePrice:     basePrice     ?? this.basePrice,
      discountPrice: discountPrice == _sentinel
          ? this.discountPrice
          : discountPrice as double?,
      images:        images        ?? this.images,
      isActive:      isActive      ?? this.isActive,
      isFeatured:    isFeatured    ?? this.isFeatured,
      sortOrder:     sortOrder     ?? this.sortOrder,
      createdAt:     createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ProductEntity(id: $id, nameEn: $nameEn)';
}
