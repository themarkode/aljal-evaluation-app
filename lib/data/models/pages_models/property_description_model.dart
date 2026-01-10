// Page name in Figma: 1.2 New Form

class PropertyDescriptionModel {
  // ✅ Word fields (green dots - will be mapped to Word document)

  final String? propertyCondition; // حالة العقار
  final String? finishingType; // نوع التشطيب
  final String? propertyAge; // عمر العقار
  final String? airConditioningType; // نوع التكييف
  final String? exteriorCladding; // التكسية الخارجية
  final int? elevatorCount; // عدد المصاعد
  final int? escalatorCount; // عدد السلالم المتحركة
  final String? publicServices; // الخدمات والمرافق العامة
  final String? neighboringPropertyTypes; // أنواع العقارات المجاورة

  // 🟡 Internal fields (not mapped to Word)

  final double? buildingRatio; // نسبة البناء
  final String? exteriorFacades; // الواجهات الخارجية
  final String? maintenanceNotes; // ملاحظات الصيانة

  PropertyDescriptionModel({
    this.propertyCondition,
    this.finishingType,
    this.propertyAge,
    this.airConditioningType,
    this.exteriorCladding,
    this.elevatorCount,
    this.escalatorCount,
    this.publicServices,
    this.neighboringPropertyTypes,
    this.buildingRatio,
    this.exteriorFacades,
    this.maintenanceNotes,
  });

  factory PropertyDescriptionModel.fromJson(Map<String, dynamic> json) {
    return PropertyDescriptionModel(
      propertyCondition: json['propertyCondition'],
      finishingType: json['finishingType'],
      propertyAge: json['propertyAge'],
      airConditioningType: json['airConditioningType'],
      exteriorCladding: json['exteriorCladding'],
      elevatorCount: json['elevatorCount'],
      escalatorCount: json['escalatorCount'],
      publicServices: json['publicServices'],
      neighboringPropertyTypes: json['neighboringPropertyTypes'],
      buildingRatio: json['buildingRatio']?.toDouble(),
      exteriorFacades: json['exteriorFacades'],
      maintenanceNotes: json['maintenanceNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propertyCondition': propertyCondition,
      'finishingType': finishingType,
      'propertyAge': propertyAge,
      'airConditioningType': airConditioningType,
      'exteriorCladding': exteriorCladding,
      'elevatorCount': elevatorCount,
      'escalatorCount': escalatorCount,
      'publicServices': publicServices,
      'neighboringPropertyTypes': neighboringPropertyTypes,
      'buildingRatio': buildingRatio,
      'exteriorFacades': exteriorFacades,
      'maintenanceNotes': maintenanceNotes,
    };
  }
}
