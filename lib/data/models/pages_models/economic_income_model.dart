// Page name: Step 11 - الدخل الاقتصادي (Economic Income)

/// Model for economic income unit entries (dynamic table)
class EconomicIncomeUnit {
  final int? unitCount; // العدد - Manual
  final String? unitType; // نوع الوحدة - Manual
  final double? unitArea; // المساحة م٢ - Manual
  final double? economicRent; // ايجار اقتصادي - Manual
  // Calculated: monthlyIncome = unitCount * economicRent

  EconomicIncomeUnit({
    this.unitCount,
    this.unitType,
    this.unitArea,
    this.economicRent,
  });

  /// دخل شهري = العدد × ايجار اقتصادي
  double get monthlyIncome => (unitCount ?? 0) * (economicRent ?? 0);

  factory EconomicIncomeUnit.fromJson(Map<String, dynamic> json) {
    return EconomicIncomeUnit(
      unitCount: json['unitCount'],
      unitType: json['unitType'],
      unitArea: json['unitArea']?.toDouble(),
      economicRent: json['economicRent']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unitCount': unitCount,
      'unitType': unitType,
      'unitArea': unitArea,
      'economicRent': economicRent,
      'monthlyIncome': monthlyIncome,
    };
  }
}

class EconomicIncomeModel {
  // ✅ Word fields (green dots - will be mapped to Word document)

  // Economic Income Units (dynamic table)
  final List<EconomicIncomeUnit>? incomeUnits; // وحدات الدخل الاقتصادي

  // Capitalization Rate
  final double? capitalizationRate; // معدل الرسملة % - Manual

  // Monthly Property Rent
  final double? monthlyPropertyRent; // الايجار الشهري للعقار - Manual

  EconomicIncomeModel({
    this.incomeUnits,
    this.capitalizationRate,
    this.monthlyPropertyRent,
  });

  // ========================================
  // CALCULATED FIELDS
  // ========================================

  /// الإجمالي الشهري = مجموع كل دخل شهري
  double get monthlyTotalIncome {
    if (incomeUnits == null || incomeUnits!.isEmpty) return 0;
    return incomeUnits!.fold(0.0, (sum, unit) => sum + unit.monthlyIncome);
  }

  /// إجمالي العدد = مجموع كل الوحدات
  int get totalUnitCount {
    if (incomeUnits == null || incomeUnits!.isEmpty) return 0;
    return incomeUnits!.fold(0, (sum, unit) => sum + (unit.unitCount ?? 0));
  }

  /// الدخل الاجمالي السنوي = الإجمالي الشهري × 12
  double get annualTotalIncome => monthlyTotalIncome * 12;

  /// القيمة الاجمالية = الدخل الاجمالي السنوي / معدل الرسملة
  double get finalTotalValue {
    if (capitalizationRate == null || capitalizationRate == 0) return 0;
    return annualTotalIncome / (capitalizationRate! / 100);
  }

  factory EconomicIncomeModel.fromJson(Map<String, dynamic> json) {
    return EconomicIncomeModel(
      incomeUnits: json['incomeUnits'] != null
          ? (json['incomeUnits'] as List)
              .map((e) => EconomicIncomeUnit.fromJson(e))
              .toList()
          : null,
      capitalizationRate: json['capitalizationRate']?.toDouble(),
      monthlyPropertyRent: json['monthlyPropertyRent']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incomeUnits': incomeUnits?.map((e) => e.toJson()).toList(),
      'totalUnitCount': totalUnitCount,
      'monthlyTotalIncome': monthlyTotalIncome,
      'annualTotalIncome': annualTotalIncome,
      'capitalizationRate': capitalizationRate,
      'monthlyPropertyRent': monthlyPropertyRent,
      'finalTotalValue': finalTotalValue,
    };
  }
}
