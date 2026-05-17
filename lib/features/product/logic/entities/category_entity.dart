class CategoryEntity {
  const CategoryEntity({
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

  bool get isRoot => parentId == null;

  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;

  CategoryEntity copyWith({
    String? nameEn,
    String? nameAr,
    String? slug,
    String? imageUrl,
    bool? isActive,
    int? sortOrder,
  }) {
    return CategoryEntity(
      id:        id,
      nameEn:    nameEn    ?? this.nameEn,
      nameAr:    nameAr    ?? this.nameAr,
      slug:      slug      ?? this.slug,
      imageUrl:  imageUrl  ?? this.imageUrl,
      parentId:  parentId,
      isActive:  isActive  ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
