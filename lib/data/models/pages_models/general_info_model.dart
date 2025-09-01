// Page name in Figma: 1 New Form

import 'package:cloud_firestore/cloud_firestore.dart';

class GeneralInfoModel {
  // ✅ Word fields (green dots - will be mapped to Word document)

  final String? requestorName; // اسم الجهة الطالبة للتقييم
  final String? clientName; // العميل
  final String? ownerName; // المالك
  final DateTime? requestDate; // تاريخ طلب التقييم
  final DateTime? issueDate; // تاريخ إصدار التقييم
  final DateTime? inspectionDate; // تاريخ الكشف

  // 🟡 Internal fields (not mapped to Word)

  final String? clientPhone; // رقم العميل
  final String? guardPhone; // رقم حارس العقار
  final String? siteManagerPhone; // رقم مسؤول الموقع

  GeneralInfoModel({
    this.requestorName,
    this.clientName,
    this.ownerName,
    this.requestDate,
    this.issueDate,
    this.inspectionDate,
    this.clientPhone,
    this.guardPhone,
    this.siteManagerPhone,
  });

  factory GeneralInfoModel.fromJson(Map<String, dynamic> json) {
    return GeneralInfoModel(
      requestorName: json['requestorName'],
      clientName: json['clientName'],
      ownerName: json['ownerName'],
      requestDate: json['requestDate'] != null
          ? (json['requestDate'] as Timestamp).toDate()
          : null,
      issueDate: json['issueDate'] != null
          ? (json['issueDate'] as Timestamp).toDate()
          : null,
      inspectionDate: json['inspectionDate'] != null
          ? (json['inspectionDate'] as Timestamp).toDate()
          : null,
      clientPhone: json['clientPhone'],
      guardPhone: json['guardPhone'],
      siteManagerPhone: json['siteManagerPhone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestorName': requestorName,
      'clientName': clientName,
      'ownerName': ownerName,
      'requestDate':
          requestDate != null ? Timestamp.fromDate(requestDate!) : null,
      'issueDate': issueDate != null ? Timestamp.fromDate(issueDate!) : null,
      'inspectionDate':
          inspectionDate != null ? Timestamp.fromDate(inspectionDate!) : null,
      'clientPhone': clientPhone,
      'guardPhone': guardPhone,
      'siteManagerPhone': siteManagerPhone,
    };
  }
}
