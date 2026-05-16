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

  // ── Computed helpers ─────────────────────────────────────

  /// Returns discountPrice if set, otherwise basePrice.
  double get effectivePrice => discountPrice ?? basePrice;

  /// True when a discount is active.
  bool get hasDiscount => discountPrice != null && discountPrice! < basePrice;

  /// Discount percentage rounded to nearest integer (0 when no discount).
  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((basePrice - discountPrice!) / basePrice) * 100).round();
  }

  /// First image URL, or empty string when images list is empty.
  String get thumbnailUrl => images.isNotEmpty ? images.first : '';

  /// Localized name based on [languageCode] ('ar' → Arabic, else English).
  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;

  /// Localized description based on [languageCode].
  String localizedDescription(String languageCode) =>
      languageCode == 'ar' ? descriptionAr : descriptionEn;

  // ── Equality ─────────────────────────────────────────────

  ProductEntity copyWith({
    String? categoryId,
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
    double? basePrice,
    double? discountPrice,
    List<String>? images,
    bool? isActive,
    bool? isFeatured,
    int? sortOrder,
  }) {
    return ProductEntity(
      id: id,
      categoryId: categoryId ?? this.categoryId,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      basePrice: basePrice ?? this.basePrice,
      discountPrice: discountPrice ?? this.discountPrice,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
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
