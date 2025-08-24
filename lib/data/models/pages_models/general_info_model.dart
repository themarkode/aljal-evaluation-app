// Page name in Figma: 1 New Form

import 'package:cloud_firestore/cloud_firestore.dart';

class GeneralInfoModel {
  // ✅ Word fields (green dots - will be mapped to Word document)

  final String requestorName; // اسم الجهة الطالبة للتقييم
  final String clientName; // العميل
  final String ownerName; // المالك
  final DateTime requestDate; // تاريخ طلب التقييم
  final DateTime issueDate; // تاريخ إصدار التقييم
  final DateTime inspectionDate; // تاريخ الكشف

  // 🟡 Internal fields (not mapped to Word)

  final String clientPhone; // رقم العميل
  final String guardPhone; // رقم حارس العقار
  final String siteManagerPhone; // رقم مسؤول الموقع

  GeneralInfoModel({
    required this.requestorName,
    required this.clientName,
    required this.ownerName,
    required this.requestDate,
    required this.issueDate,
    required this.inspectionDate,
    required this.clientPhone,
    required this.guardPhone,
    required this.siteManagerPhone,
  });

  factory GeneralInfoModel.fromJson(Map<String, dynamic> json) {
    return GeneralInfoModel(
      requestorName: json['requestorName'] ?? '',
      clientName: json['clientName'] ?? '',
      ownerName: json['ownerName'] ?? '',
      requestDate: (json['requestDate'] as Timestamp).toDate(),
      issueDate: (json['issueDate'] as Timestamp).toDate(),
      inspectionDate: (json['inspectionDate'] as Timestamp).toDate(),
      clientPhone: json['clientPhone'] ?? '',
      guardPhone: json['guardPhone'] ?? '',
      siteManagerPhone: json['siteManagerPhone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestorName': requestorName,
      'clientName': clientName,
      'ownerName': ownerName,
      'requestDate': Timestamp.fromDate(requestDate),
      'issueDate': Timestamp.fromDate(issueDate),
      'inspectionDate': Timestamp.fromDate(inspectionDate),
      'clientPhone': clientPhone,
      'guardPhone': guardPhone,
      'siteManagerPhone': siteManagerPhone,
    };
  }
}
