import 'package:ecommerce_app/features/product/data/models/product_model.dart';

class WishlistItemModel {
  const WishlistItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.createdAt,
    this.product,
  });

  final String id;
  final String userId;
  final String productId;
  final DateTime createdAt;
  final ProductModel? product;

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['products'] as Map<String, dynamic>?;
    return WishlistItemModel(
      id:        json['id']         as String,
      userId:    json['user_id']    as String,
      productId: json['product_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      product: productJson != null
          ? ProductModel.fromJson(productJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':         id,
        'user_id':    userId,
        'product_id': productId,
        'created_at': createdAt.toIso8601String(),
      };

  Map<String, dynamic> toInsertJson() => {
        'user_id':    userId,
        'product_id': productId,
      };
}
