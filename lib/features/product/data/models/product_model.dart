class ProductModel {
  const ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      nameEn: json['name_en'] as String,
      nameAr: json['name_ar'] as String,
      descriptionEn: json['description_en'] as String,
      descriptionAr: json['description_ar'] as String,
      basePrice: (json['base_price'] as num).toDouble(),
      discountPrice: json['discount_price'] == null
          ? null
          : (json['discount_price'] as num).toDouble(),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isActive: json['is_active'] as bool,
      isFeatured: json['is_featured'] as bool,
      sortOrder: json['sort_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name_en': nameEn,
      'name_ar': nameAr,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'base_price': basePrice,
      'discount_price': discountPrice,
      'images': images,
      'is_active': isActive,
      'is_featured': isFeatured,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'category_id': categoryId,
      'name_en': nameEn,
      'name_ar': nameAr,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'base_price': basePrice,
      'discount_price': discountPrice,
      'images': images,
      'is_active': isActive,
      'is_featured': isFeatured,
      'sort_order': sortOrder,
    };
  }
}
