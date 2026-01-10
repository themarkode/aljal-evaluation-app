import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages_models/general_info_model.dart';
import 'pages_models/general_property_info_model.dart';
import 'pages_models/property_description_model.dart';
import 'pages_models/floor_model.dart';
import 'pages_models/area_details_model.dart';
import 'pages_models/income_notes_model.dart';
import 'pages_models/site_plans_model.dart';
import 'pages_models/image_model.dart';
import 'pages_models/additional_data_model.dart';
import 'pages_models/building_land_cost_model.dart';
import 'pages_models/economic_income_model.dart';

class EvaluationModel {
  // Core evaluation metadata
  final String? evaluationId; // معرف التقييم
  final DateTime? createdAt; // تاريخ الإنشاء
  final DateTime? updatedAt; // تاريخ آخر تحديث
  final String? status; // حالة التقييم (draft, completed, deleted)
  final String? previousStatus; // الحالة السابقة قبل الحذف (للاستعادة)

  // Page models - each step of the form
  final GeneralInfoModel? generalInfo; // Step 1
  final GeneralPropertyInfoModel? generalPropertyInfo; // Step 1.1
  final PropertyDescriptionModel? propertyDescription; // Step 1.2
  final int? floorsCount; // عدد الأدوار (from step 1.3)
  final List<FloorModel>? floors; // قائمة الأدوار (from step 1.3)
  final AreaDetailsModel? areaDetails; // Step 1.4
  final IncomeNotesModel? incomeNotes; // Step 1.5
  final SitePlansModel? sitePlans; // Step 1.6
  final ImageModel? propertyImages; // Step 1.7
  final AdditionalDataModel? additionalData; // Step 1.8
  final BuildingLandCostModel? buildingLandCost; // Step 10
  final EconomicIncomeModel? economicIncome; // Step 11

  EvaluationModel({
    this.evaluationId,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.previousStatus,
    this.generalInfo,
    this.generalPropertyInfo,
    this.propertyDescription,
    this.floorsCount,
    this.floors,
    this.areaDetails,
    this.incomeNotes,
    this.sitePlans,
    this.propertyImages,
    this.additionalData,
    this.buildingLandCost,
    this.economicIncome,
  });

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    return EvaluationModel(
      evaluationId: json['evaluationId'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      status: json['status'],
      previousStatus: json['previousStatus'],
      generalInfo: json['generalInfo'] != null
          ? GeneralInfoModel.fromJson(json['generalInfo'])
          : null,
      generalPropertyInfo: json['generalPropertyInfo'] != null
          ? GeneralPropertyInfoModel.fromJson(json['generalPropertyInfo'])
          : null,
      propertyDescription: json['propertyDescription'] != null
          ? PropertyDescriptionModel.fromJson(json['propertyDescription'])
          : null,
      floorsCount: json['floorsCount'],
      floors: json['floors'] != null
          ? (json['floors'] as List)
              .map((floor) => FloorModel.fromJson(floor))
              .toList()
          : null,
      areaDetails: json['areaDetails'] != null
          ? AreaDetailsModel.fromJson(json['areaDetails'])
          : null,
      incomeNotes: json['incomeNotes'] != null
          ? IncomeNotesModel.fromJson(json['incomeNotes'])
          : null,
      sitePlans: json['sitePlans'] != null
          ? SitePlansModel.fromJson(json['sitePlans'])
          : null,
      propertyImages: json['propertyImages'] != null
          ? ImageModel.fromJson(json['propertyImages'])
          : null,
      additionalData: json['additionalData'] != null
          ? AdditionalDataModel.fromJson(json['additionalData'])
          : null,
      buildingLandCost: json['buildingLandCost'] != null
          ? BuildingLandCostModel.fromJson(json['buildingLandCost'])
          : null,
      economicIncome: json['economicIncome'] != null
          ? EconomicIncomeModel.fromJson(json['economicIncome'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evaluationId': evaluationId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'status': status,
      'previousStatus': previousStatus,
      'generalInfo': generalInfo?.toJson(),
      'generalPropertyInfo': generalPropertyInfo?.toJson(),
      'propertyDescription': propertyDescription?.toJson(),
      'floorsCount': floorsCount,
      'floors': floors?.map((floor) => floor.toJson()).toList(),
      'areaDetails': areaDetails?.toJson(),
      'incomeNotes': incomeNotes?.toJson(),
      'sitePlans': sitePlans?.toJson(),
      'propertyImages': propertyImages?.toJson(),
      'additionalData': additionalData?.toJson(),
      'buildingLandCost': buildingLandCost?.toJson(),
      'economicIncome': economicIncome?.toJson(),
    };
  }

  // Helper method to create a new evaluation with timestamp
  EvaluationModel copyWith({
    String? evaluationId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    String? previousStatus,
    GeneralInfoModel? generalInfo,
    GeneralPropertyInfoModel? generalPropertyInfo,
    PropertyDescriptionModel? propertyDescription,
    int? floorsCount,
    List<FloorModel>? floors,
    AreaDetailsModel? areaDetails,
    IncomeNotesModel? incomeNotes,
    SitePlansModel? sitePlans,
    ImageModel? propertyImages,
    AdditionalDataModel? additionalData,
    BuildingLandCostModel? buildingLandCost,
    EconomicIncomeModel? economicIncome,
  }) {
    return EvaluationModel(
      evaluationId: evaluationId ?? this.evaluationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      status: status ?? this.status,
      previousStatus: previousStatus ?? this.previousStatus,
      generalInfo: generalInfo ?? this.generalInfo,
      generalPropertyInfo: generalPropertyInfo ?? this.generalPropertyInfo,
      propertyDescription: propertyDescription ?? this.propertyDescription,
      floorsCount: floorsCount ?? this.floorsCount,
      floors: floors ?? this.floors,
      areaDetails: areaDetails ?? this.areaDetails,
      incomeNotes: incomeNotes ?? this.incomeNotes,
      sitePlans: sitePlans ?? this.sitePlans,
      propertyImages: propertyImages ?? this.propertyImages,
      additionalData: additionalData ?? this.additionalData,
      buildingLandCost: buildingLandCost ?? this.buildingLandCost,
      economicIncome: economicIncome ?? this.economicIncome,
    );
  }
}