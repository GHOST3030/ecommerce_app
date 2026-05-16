class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.slug,
    required this.imageUrl,
    required this.parentId,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String slug;
  final String imageUrl;
  final String? parentId;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      nameEn: json['name_en'] as String,
      nameAr: json['name_ar'] as String,
      slug: json['slug'] as String,
      imageUrl: json['image_url'] as String,
      parentId: json['parent_id'] as String?,
      isActive: json['is_active'] as bool,
      sortOrder: json['sort_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
      'slug': slug,
      'image_url': imageUrl,
      'parent_id': parentId,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }
}