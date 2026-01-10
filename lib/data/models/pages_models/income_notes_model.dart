// Page name in Figma: 1.5 New Form

class IncomeNotesModel {
  // ✅ Word fields (green dots - will be mapped to Word document)

  final String? tenantType; // نوع المستأجرين

  // 🟡 Internal fields (not mapped to Word)

  final int? unitCount; // عدد الوحدات
  final String? incomeDetails; // تفاصيل الدخل
  final String? unitDescription; // وصف الوحدات
  final String? unitType; // نوع الوحدات
  final double? vacancyRate; // نسبة الشواغر
  final String? rentalValueVerification; // التأكد من القيمة الإيجارية للوحدات

  IncomeNotesModel({
    this.tenantType,
    this.unitCount,
    this.incomeDetails,
    this.unitDescription,
    this.unitType,
    this.vacancyRate,
    this.rentalValueVerification,
  });

  factory IncomeNotesModel.fromJson(Map<String, dynamic> json) {
    return IncomeNotesModel(
      tenantType: json['tenantType'],
      unitCount: json['unitCount'],
      incomeDetails: json['incomeDetails'],
      unitDescription: json['unitDescription'],
      unitType: json['unitType'],
      vacancyRate: json['vacancyRate']?.toDouble(),
      rentalValueVerification: json['rentalValueVerification'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenantType': tenantType,
      'unitCount': unitCount,
      'incomeDetails': incomeDetails,
      'unitDescription': unitDescription,
      'unitType': unitType,
      'vacancyRate': vacancyRate,
      'rentalValueVerification': rentalValueVerification,
    };
  }
}
