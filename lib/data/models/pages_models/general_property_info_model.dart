// Page name in Figma: 1.1 New Form

import 'package:cloud_firestore/cloud_firestore.dart';

class GeneralPropertyInfoModel {
  // ✅ Word fields (green dots – will be mapped to Word document)

  final String governorate; // اسم المحافظة
  final String area; // اسم المنطقة
  final String plotNumber; // رقم القطعة
  final String parcelNumber; // رقم القسيمة
  final String planNumber; // رقم المخطط
  final String documentNumber; // رقم الوثيقة
  final DateTime documentDate; // تاريخ الوثيقة
  final double areaSize; // المساحة م²
  final String propertyType; // نوع العقار

  // 🟡 Internal fields (not mapped to Word)

  final String? autoNumber; // الرقم الآلي
  final String? houseNumber; // رقم المنزل
  final int? streetCount; // عدد الشوارع المحيطة
  final int? parkingCount; // عدد مواقف السيارات
  final String? landNotes; // ملاحظات على أرض العقار
  final String? landFacing; // اتجاه واجهة القسيمة
  final String? landShape; // شكل وتضاريس الأرض

  GeneralPropertyInfoModel({
    required this.governorate,
    required this.area,
    required this.plotNumber,
    required this.parcelNumber,
    required this.planNumber,
    required this.documentNumber,
    required this.documentDate,
    required this.areaSize,
    required this.propertyType,
    this.autoNumber,
    this.houseNumber,
    this.streetCount,
    this.parkingCount,
    this.landNotes,
    this.landFacing,
    this.landShape,
  });

  factory GeneralPropertyInfoModel.fromJson(Map<String, dynamic> json) {
    return GeneralPropertyInfoModel(
      governorate: json['governorate'] ?? '',
      area: json['area'] ?? '',
      plotNumber: json['plotNumber'] ?? '',
      parcelNumber: json['parcelNumber'] ?? '',
      planNumber: json['planNumber'] ?? '',
      documentNumber: json['documentNumber'] ?? '',
      documentDate: (json['documentDate'] as Timestamp).toDate(),
      areaSize: (json['areaSize'] ?? 0).toDouble(),
      propertyType: json['propertyType'] ?? '',
      autoNumber: json['autoNumber'],
      houseNumber: json['houseNumber'],
      streetCount: json['streetCount'],
      parkingCount: json['parkingCount'],
      landNotes: json['landNotes'],
      landFacing: json['landFacing'],
      landShape: json['landShape'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'governorate': governorate,
      'area': area,
      'plotNumber': plotNumber,
      'parcelNumber': parcelNumber,
      'planNumber': planNumber,
      'documentNumber': documentNumber,
      'documentDate': Timestamp.fromDate(documentDate),
      'areaSize': areaSize,
      'propertyType': propertyType,
      'autoNumber': autoNumber,
      'houseNumber': houseNumber,
      'streetCount': streetCount,
      'parkingCount': parkingCount,
      'landNotes': landNotes,
      'landFacing': landFacing,
      'landShape': landShape,
    };
  }
}
