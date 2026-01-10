// Page name in Figma: 1.4 New Form

class AreaDetailsModel {
  // ✅ Word fields (green dots - will be mapped to Word document)

  final String? streetsAndInfrastructure; // الشوارع والبنية التحتية
  final String? areaPropertyTypes; // أنواع العقارات بالمنطقة
  final String? areaEntrancesExits; // مداخل ومخارج المنطقة
  final String? generalAreaDirection; // التوجه العام بالمنطقة
  final String? areaRentalRates; // معدل الإيجارات بالمنطقة
  final String? neighboringTenantTypes; // نوع المستأجرين بالعقارات المجاورة

  // 🟡 Internal fields (not mapped to Word)

  final String? areaVacancyRates; // معدلات الشواغر بالمنطقة

  AreaDetailsModel({
    this.streetsAndInfrastructure,
    this.areaPropertyTypes,
    this.areaEntrancesExits,
    this.generalAreaDirection,
    this.areaRentalRates,
    this.neighboringTenantTypes,
    this.areaVacancyRates,
  });

  factory AreaDetailsModel.fromJson(Map<String, dynamic> json) {
    return AreaDetailsModel(
      streetsAndInfrastructure: json['streetsAndInfrastructure'],
      areaPropertyTypes: json['areaPropertyTypes'],
      areaEntrancesExits: json['areaEntrancesExits'],
      generalAreaDirection: json['generalAreaDirection'],
      areaRentalRates: json['areaRentalRates'],
      neighboringTenantTypes: json['neighboringTenantTypes'],
      areaVacancyRates: json['areaVacancyRates'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streetsAndInfrastructure': streetsAndInfrastructure,
      'areaPropertyTypes': areaPropertyTypes,
      'areaEntrancesExits': areaEntrancesExits,
      'generalAreaDirection': generalAreaDirection,
      'areaRentalRates': areaRentalRates,
      'neighboringTenantTypes': neighboringTenantTypes,
      'areaVacancyRates': areaVacancyRates,
    };
  }
}
