import 'package:ecommerce_app/features/product/data/models/category_model.dart';
import 'package:ecommerce_app/features/product/logic/entities/category_entity.dart';

class CategoryMapper {
  const CategoryMapper._();

  static CategoryEntity toEntity(CategoryModel model) {
    return CategoryEntity(
      id: model.id,
      nameEn: model.nameEn,
      nameAr: model.nameAr,
      slug: model.slug,
      imageUrl: model.imageUrl,
      parentId: model.parentId,
      isActive: model.isActive,
      sortOrder: model.sortOrder,
      createdAt: model.createdAt,
    );
  }

  static CategoryModel toModel(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      nameEn: entity.nameEn,
      nameAr: entity.nameAr,
      slug: entity.slug,
      imageUrl: entity.imageUrl,
      parentId: entity.parentId,
      isActive: entity.isActive,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
    );
  }
}