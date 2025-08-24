class ImageModel {
  final String imageUrl;

  ImageModel({required this.imageUrl});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(imageUrl: json['imageUrl'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'imageUrl': imageUrl};
  }
}
