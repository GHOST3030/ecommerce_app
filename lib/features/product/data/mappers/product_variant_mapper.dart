import 'package:ecommerce_app/features/product/data/models/product_variant_model.dart';
import 'package:ecommerce_app/features/product/logic/entities/product_variant_entity.dart';

class ProductVariantMapper {
  const ProductVariantMapper._();

  static ProductVariantEntity toEntity(ProductVariantModel model) {
    return ProductVariantEntity(
      id: model.id,
      productId: model.productId,
      sku: model.sku,
      size: ProductSize.fromString(model.size),
      colorEn: model.colorEn,
      colorAr: model.colorAr,
      colorHex: model.colorHex,
      price: model.price,
      discountPrice: model.discountPrice,
      stock: model.stock,
      isActive: model.isActive,
      sortOrder: model.sortOrder,
      createdAt: model.createdAt,
      productNameEn: model.productNameEn,
      productNameAr: model.productNameAr,
      productImages: model.productImages,
    );
  }

  static ProductVariantModel toModel(ProductVariantEntity entity) {
    return ProductVariantModel(
      id: entity.id,
      productId: entity.productId,
      sku: entity.sku,
      size: entity.size.toDbString(),
      colorEn: entity.colorEn,
      colorAr: entity.colorAr,
      colorHex: entity.colorHex,
      price: entity.price,
      discountPrice: entity.discountPrice,
      stock: entity.stock,
      isActive: entity.isActive,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      productNameEn: entity.productNameEn,
      productNameAr: entity.productNameAr,
      productImages: entity.productImages,
    );
  }

  static List<ProductVariantEntity> toEntityList(
    List<ProductVariantModel> models,
  ) =>
      models.map(toEntity).toList();

  static List<ProductVariantModel> toModelList(
    List<ProductVariantEntity> entities,
  ) =>
      entities.map(toModel).toList();
}
