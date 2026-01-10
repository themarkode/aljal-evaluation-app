// Page name in Figma: 1.7 New Form

class ImageModel {
  // ✅ Word fields (green dots - will be mapped to Word document)

  final String?
      propertyLocationMapImageUrl; // صور موقع العقار حسب المخطط العام لبلدية الكويت
  final String? propertyImageUrl; // صورة للعقار
  final String? propertyVariousImages1Url; // صور مختلفة للعقار 1
  final String? propertyVariousImages2Url; // صور مختلفة للعقار 2
  final String? satelliteLocationImageUrl; // صورة موقع العقار من القمر الصناعي
  final String?
      civilPlotMapImageUrl; // صور موقع القطعة المدنية حسب المخطط العام لبلدية الكويت
  final String? locationAddressText; // عنوان الموقع
  final String? locationAddressLink; // رابط الموقع

  ImageModel({
    this.propertyLocationMapImageUrl,
    this.propertyImageUrl,
    this.propertyVariousImages1Url,
    this.propertyVariousImages2Url,
    this.satelliteLocationImageUrl,
    this.civilPlotMapImageUrl,
    this.locationAddressText,
    this.locationAddressLink,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      propertyLocationMapImageUrl: json['propertyLocationMapImageUrl'],
      propertyImageUrl: json['propertyImageUrl'],
      propertyVariousImages1Url: json['propertyVariousImages1Url'],
      propertyVariousImages2Url: json['propertyVariousImages2Url'],
      satelliteLocationImageUrl: json['satelliteLocationImageUrl'],
      civilPlotMapImageUrl: json['civilPlotMapImageUrl'],
      locationAddressText: json['locationAddressText'],
      locationAddressLink: json['locationAddressLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propertyLocationMapImageUrl': propertyLocationMapImageUrl,
      'propertyImageUrl': propertyImageUrl,
      'propertyVariousImages1Url': propertyVariousImages1Url,
      'propertyVariousImages2Url': propertyVariousImages2Url,
      'satelliteLocationImageUrl': satelliteLocationImageUrl,
      'civilPlotMapImageUrl': civilPlotMapImageUrl,
      'locationAddressText': locationAddressText,
      'locationAddressLink': locationAddressLink,
    };
  }
}
