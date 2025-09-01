// Page name in Figma: 1.8 New Form

import 'package:cloud_firestore/cloud_firestore.dart';

class AdditionalDataModel {
  // ✅ Word fields (green dots - will be mapped to Word document)
  
  final String? evaluationPurpose; // الغرض من التقييم
  final String? buildingSystem; // نظام البناء
  final String? buildingRatio; // النسبة
  final String? accordingTo; // حسب
  final double? totalValue; // القيمة الإجمالية
  final DateTime? evaluationIssueDate; // تاريخ إصدار التقييم

  AdditionalDataModel({
    this.evaluationPurpose,
    this.buildingSystem,
    this.buildingRatio,
    this.accordingTo,
    this.totalValue,
    this.evaluationIssueDate,
  });

  factory AdditionalDataModel.fromJson(Map<String, dynamic> json) {
    return AdditionalDataModel(
      evaluationPurpose: json['evaluationPurpose'],
      buildingSystem: json['buildingSystem'],
      buildingRatio: json['buildingRatio'],
      accordingTo: json['accordingTo'],
      totalValue: json['totalValue']?.toDouble(),
      evaluationIssueDate: json['evaluationIssueDate'] != null 
          ? (json['evaluationIssueDate'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evaluationPurpose': evaluationPurpose,
      'buildingSystem': buildingSystem,
      'buildingRatio': buildingRatio,
      'accordingTo': accordingTo,
      'totalValue': totalValue,
      'evaluationIssueDate': evaluationIssueDate != null 
          ? Timestamp.fromDate(evaluationIssueDate!) 
          : null,
    };
  }
}