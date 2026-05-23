import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_entity.dart';

class ProductMapper {
  const ProductMapper._();

  static ProductEntity toEntity(ProductModel model) {
    return ProductEntity(
      id: model.id,
      categoryId: model.categoryId,
      nameEn: model.nameEn,
      nameAr: model.nameAr,
      descriptionEn: model.descriptionEn,
      descriptionAr: model.descriptionAr,
      basePrice: model.basePrice,
      discountPrice: model.discountPrice,
      images: model.images,
      isActive: model.isActive,
      isFeatured: model.isFeatured,
      sortOrder: model.sortOrder,
      createdAt: model.createdAt,
    );
  }

  static ProductModel toModel(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      categoryId: entity.categoryId,
      nameEn: entity.nameEn,
      nameAr: entity.nameAr,
      descriptionEn: entity.descriptionEn,
      descriptionAr: entity.descriptionAr,
      basePrice: entity.basePrice,
      discountPrice: entity.discountPrice,
      images: entity.images,
      isActive: entity.isActive,
      isFeatured: entity.isFeatured,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
    );
  }

  static List<ProductEntity> toEntityList(List<ProductModel> models) =>
      models.map(toEntity).toList();

  static List<ProductModel> toModelList(List<ProductEntity> entities) =>
      entities.map(toModel).toList();
}
