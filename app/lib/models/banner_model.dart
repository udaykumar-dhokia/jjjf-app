class BannerModel {
  final String id;
  final String imageUrl;
  final bool isActive;
  final int order;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.isActive,
    required this.order,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isActive: json['isActive'] ?? true,
      order: json['order'] ?? 0,
    );
  }
}
