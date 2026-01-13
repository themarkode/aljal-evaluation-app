// Page name in Figma: 1.8 New Form

class AdditionalDataModel {
  // ✅ Word fields (green dots - will be mapped to Word document)

  final String? evaluationPurpose; // الغرض من التقييم
  final String? buildingSystem; // نظام البناء
  final String? buildingRatio; // النسبة
  final String? accordingTo; // حسب
  // Note: القيمة الإجمالية is now auto-calculated in Step 11 (EconomicIncomeModel)
  // Note: تاريخ إصدار التقييم is in Step 1 (GeneralInfoModel.issueDate)

  AdditionalDataModel({
    this.evaluationPurpose,
    this.buildingSystem,
    this.buildingRatio,
    this.accordingTo,
  });

  factory AdditionalDataModel.fromJson(Map<String, dynamic> json) {
    return AdditionalDataModel(
      evaluationPurpose: json['evaluationPurpose'],
      buildingSystem: json['buildingSystem'],
      buildingRatio: json['buildingRatio'],
      accordingTo: json['accordingTo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evaluationPurpose': evaluationPurpose,
      'buildingSystem': buildingSystem,
      'buildingRatio': buildingRatio,
      'accordingTo': accordingTo,
    };
  }
}
