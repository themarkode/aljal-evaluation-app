// Page name in Figma: 1.6 New Form

import 'package:cloud_firestore/cloud_firestore.dart';

class SitePlansModel {
  // ✅ Word fields (green dots - will be mapped to Word document)

  final String? generalNotes; // ملاحظات عامة

  // 🟡 Internal fields (not mapped to Word)

  final String? approvedPlanComparison; // مقارنة المخطط المعتمد بالموقع
  final String? siteMeasurementNumbers; // رقم المقاسات بالموقع
  final String? violationNotes; // ملاحظات المخالفات

  SitePlansModel({
    this.generalNotes,
    this.approvedPlanComparison,
    this.siteMeasurementNumbers,
    this.violationNotes,
  });

  factory SitePlansModel.fromJson(Map<String, dynamic> json) {
    return SitePlansModel(
      generalNotes: json['generalNotes'],
      approvedPlanComparison: json['approvedPlanComparison'],
      siteMeasurementNumbers: json['siteMeasurementNumbers'],
      violationNotes: json['violationNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generalNotes': generalNotes,
      'approvedPlanComparison': approvedPlanComparison,
      'siteMeasurementNumbers': siteMeasurementNumbers,
      'violationNotes': violationNotes,
    };
  }
}
