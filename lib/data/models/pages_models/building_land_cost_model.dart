// Page name: Step 10 - تكلفة المباني والارض (Building and Land Cost)

/// Model for additional area cost entries (dynamic table)
class AreaCostEntry {
  final String? areaName; // اسم المساحة (e.g., السرداب، الخدمات، الارضي)
  final double? area; // المساحة
  final double? pricePerM2; // د/م٢
  // Calculated: totalCost = area * pricePerM2

  AreaCostEntry({
    this.areaName,
    this.area,
    this.pricePerM2,
  });

  double get totalCost => (area ?? 0) * (pricePerM2 ?? 0);

  factory AreaCostEntry.fromJson(Map<String, dynamic> json) {
    return AreaCostEntry(
      areaName: json['areaName'],
      area: json['area']?.toDouble(),
      pricePerM2: json['pricePerM2']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'areaName': areaName,
      'area': area,
      'pricePerM2': pricePerM2,
      'totalCost': totalCost,
    };
  }
}

class BuildingLandCostModel {
  // ✅ Word fields (green dots - will be mapped to Word document)

  // Fixed Building Area Fields (always shown)
  final double? buildingArea; // مساحة البناء - Manual
  final double? buildingAreaPM2; // مساحة البناء د/م٢ - Manual
  // Calculated: buildingAreaTotalCost = buildingArea * buildingAreaPM2

  // Additional Area Costs (dynamic table like floors)
  final List<AreaCostEntry>? additionalAreaCosts; // مساحات إضافية

  // Indirect Cost
  final double? indirectCostPercentage; // التكلفة الغير مباشرة نسبة - Manual
  // Calculated: indirectCostValue = indirectCostPercentage * directTotalCost

  // Depreciation
  final double? depreciationPercentage; // الاستهلاك نسبة - Manual
  // Calculated: depreciationValue = depreciationPercentage * totalBuildingCost

  // Land Area
  // landArea is auto-filled from Step 2 (areaSize)
  final double? landArea; // مساحة الارض م٢
  final double? landAreaPM2; // سعر المتر د.ك - Manual
  // Calculated: totalCostOfLandArea = landArea * landAreaPM2

  BuildingLandCostModel({
    this.buildingArea,
    this.buildingAreaPM2,
    this.additionalAreaCosts,
    this.indirectCostPercentage,
    this.depreciationPercentage,
    this.landArea,
    this.landAreaPM2,
  });

  // ========================================
  // CALCULATED FIELDS
  // ========================================

  /// تكلفة مساحة البناء = مساحة البناء × د/م٢
  double get buildingAreaTotalCost =>
      (buildingArea ?? 0) * (buildingAreaPM2 ?? 0);

  /// التكلفة الاجمالية المباشرة = مجموع كل تكاليف المساحات
  double get directTotalCost {
    double total = buildingAreaTotalCost;
    if (additionalAreaCosts != null) {
      for (var entry in additionalAreaCosts!) {
        total += entry.totalCost;
      }
    }
    return total;
  }

  /// التكلفة الغير مباشرة = النسبة × التكلفة الاجمالية المباشرة
  double get indirectCostValue =>
      (indirectCostPercentage ?? 0) / 100 * directTotalCost;

  /// تكلفة البناء الاجمالية = التكلفة الاجمالية المباشرة + التكلفة الغير مباشرة
  double get totalBuildingCost => directTotalCost + indirectCostValue;

  /// الاستهلاك = النسبة × تكلفة البناء الاجمالية
  double get depreciationValue =>
      (depreciationPercentage ?? 0) / 100 * totalBuildingCost;

  /// قيمة المباني بعد خصم الاستهلاك = تكلفة البناء الاجمالية - الاستهلاك
  double get buildingValueAfterDepreciation =>
      totalBuildingCost - depreciationValue;

  /// اجمالي تكلفة مساحة الأرض = مساحة الارض × سعر المتر
  double get totalCostOfLandArea => (landArea ?? 0) * (landAreaPM2 ?? 0);

  /// القيمة بطريقة التكلفة = قيمة المباني بعد خصم الاستهلاك + اجمالي تكلفة الأرض
  double get valueByCostMethod =>
      buildingValueAfterDepreciation + totalCostOfLandArea;

  factory BuildingLandCostModel.fromJson(Map<String, dynamic> json) {
    return BuildingLandCostModel(
      buildingArea: json['buildingArea']?.toDouble(),
      buildingAreaPM2: json['buildingAreaPM2']?.toDouble(),
      additionalAreaCosts: json['additionalAreaCosts'] != null
          ? (json['additionalAreaCosts'] as List)
              .map((e) => AreaCostEntry.fromJson(e))
              .toList()
          : null,
      indirectCostPercentage: json['indirectCostPercentage']?.toDouble(),
      depreciationPercentage: json['depreciationPercentage']?.toDouble(),
      landArea: json['landArea']?.toDouble(),
      landAreaPM2: json['landAreaPM2']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buildingArea': buildingArea,
      'buildingAreaPM2': buildingAreaPM2,
      'buildingAreaTotalCost': buildingAreaTotalCost,
      'additionalAreaCosts':
          additionalAreaCosts?.map((e) => e.toJson()).toList(),
      'directTotalCost': directTotalCost,
      'indirectCostPercentage': indirectCostPercentage,
      'indirectCostValue': indirectCostValue,
      'totalBuildingCost': totalBuildingCost,
      'depreciationPercentage': depreciationPercentage,
      'depreciationValue': depreciationValue,
      'buildingValueAfterDepreciation': buildingValueAfterDepreciation,
      'landArea': landArea,
      'landAreaPM2': landAreaPM2,
      'totalCostOfLandArea': totalCostOfLandArea,
      'valueByCostMethod': valueByCostMethod,
    };
  }
}
