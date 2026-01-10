import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:aljal_evaluation/data/models/evaluation_model.dart';
import 'package:aljal_evaluation/data/models/pages_models/general_info_model.dart';
import 'package:aljal_evaluation/data/models/pages_models/general_property_info_model.dart';
import 'package:aljal_evaluation/data/models/pages_models/property_description_model.dart';
import 'package:aljal_evaluation/data/models/pages_models/floor_model.dart';
import 'package:aljal_evaluation/data/models/pages_models/area_details_model.dart';
import 'package:aljal_evaluation/data/models/pages_models/income_notes_model.dart';
import 'package:aljal_evaluation/data/models/pages_models/site_plans_model.dart';
import 'package:aljal_evaluation/data/models/pages_models/image_model.dart';
import 'package:aljal_evaluation/data/models/pages_models/additional_data_model.dart';
import 'package:aljal_evaluation/data/models/pages_models/building_land_cost_model.dart';
import 'package:aljal_evaluation/data/models/pages_models/economic_income_model.dart';
import 'package:aljal_evaluation/data/services/evaluation_service.dart';

part 'evaluation_provider.g.dart';

// This is the main state class for managing evaluation form data
// keepAlive: true prevents the provider from being disposed when navigating between screens
// This is critical for multi-step forms where data needs to persist across screen transitions
@Riverpod(keepAlive: true)
class EvaluationNotifier extends _$EvaluationNotifier {
  late final EvaluationService _evaluationService;
  
  @override
  EvaluationModel build() {
    _evaluationService = EvaluationService();
    // Return initial empty evaluation
    return EvaluationModel(
      status: 'draft',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  // Update general info (Step 1)
  void updateGeneralInfo(GeneralInfoModel generalInfo) {
    state = EvaluationModel(
      evaluationId: state.evaluationId,
      status: state.status,
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
      generalInfo: generalInfo,
      generalPropertyInfo: state.generalPropertyInfo,
      propertyDescription: state.propertyDescription,
      floorsCount: state.floorsCount,
      floors: state.floors,
      areaDetails: state.areaDetails,
      incomeNotes: state.incomeNotes,
      sitePlans: state.sitePlans,
      propertyImages: state.propertyImages,
      additionalData: state.additionalData,
      buildingLandCost: state.buildingLandCost,
      economicIncome: state.economicIncome,
    );
  }
  
  // Update general property info (Step 2)
  void updateGeneralPropertyInfo(GeneralPropertyInfoModel propertyInfo) {
    state = EvaluationModel(
      evaluationId: state.evaluationId,
      status: state.status,
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
      generalInfo: state.generalInfo,
      generalPropertyInfo: propertyInfo,
      propertyDescription: state.propertyDescription,
      floorsCount: state.floorsCount,
      floors: state.floors,
      areaDetails: state.areaDetails,
      incomeNotes: state.incomeNotes,
      sitePlans: state.sitePlans,
      propertyImages: state.propertyImages,
      additionalData: state.additionalData,
      buildingLandCost: state.buildingLandCost,
      economicIncome: state.economicIncome,
    );
  }
  
  // Update property description (Step 3)
  void updatePropertyDescription(PropertyDescriptionModel description) {
    state = EvaluationModel(
      evaluationId: state.evaluationId,
      status: state.status,
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
      generalInfo: state.generalInfo,
      generalPropertyInfo: state.generalPropertyInfo,
      propertyDescription: description,
      floorsCount: state.floorsCount,
      floors: state.floors,
      areaDetails: state.areaDetails,
      incomeNotes: state.incomeNotes,
      sitePlans: state.sitePlans,
      propertyImages: state.propertyImages,
      additionalData: state.additionalData,
      buildingLandCost: state.buildingLandCost,
      economicIncome: state.economicIncome,
    );
  }
  
  // Update floors (Step 4)
  void updateFloors(List<FloorModel> floors) {
    state = EvaluationModel(
      evaluationId: state.evaluationId,
      status: state.status,
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
      generalInfo: state.generalInfo,
      generalPropertyInfo: state.generalPropertyInfo,
      propertyDescription: state.propertyDescription,
      floorsCount: floors.length,
      floors: floors,
      areaDetails: state.areaDetails,
      incomeNotes: state.incomeNotes,
      sitePlans: state.sitePlans,
      propertyImages: state.propertyImages,
      additionalData: state.additionalData,
      buildingLandCost: state.buildingLandCost,
      economicIncome: state.economicIncome,
    );
  }
  
  // Add a new floor
  void addFloor(FloorModel floor) {
    final currentFloors = state.floors ?? [];
    updateFloors([...currentFloors, floor]);
  }
  
  // Remove a floor
  void removeFloor(int index) {
    final currentFloors = state.floors ?? [];
    if (index >= 0 && index < currentFloors.length) {
      final updatedFloors = [...currentFloors]..removeAt(index);
      updateFloors(updatedFloors);
    }
  }
  
  // Update area details (Step 5)
  void updateAreaDetails(AreaDetailsModel areaDetails) {
    state = EvaluationModel(
      evaluationId: state.evaluationId,
      status: state.status,
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
      generalInfo: state.generalInfo,
      generalPropertyInfo: state.generalPropertyInfo,
      propertyDescription: state.propertyDescription,
      floorsCount: state.floorsCount,
      floors: state.floors,
      areaDetails: areaDetails,
      incomeNotes: state.incomeNotes,
      sitePlans: state.sitePlans,
      propertyImages: state.propertyImages,
      additionalData: state.additionalData,
      buildingLandCost: state.buildingLandCost,
      economicIncome: state.economicIncome,
    );
  }
  
  // Update income notes (Step 6)
  void updateIncomeNotes(IncomeNotesModel incomeNotes) {
    state = EvaluationModel(
      evaluationId: state.evaluationId,
      status: state.status,
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
      generalInfo: state.generalInfo,
      generalPropertyInfo: state.generalPropertyInfo,
      propertyDescription: state.propertyDescription,
      floorsCount: state.floorsCount,
      floors: state.floors,
      areaDetails: state.areaDetails,
      incomeNotes: incomeNotes,
      sitePlans: state.sitePlans,
      propertyImages: state.propertyImages,
      additionalData: state.additionalData,
      buildingLandCost: state.buildingLandCost,
      economicIncome: state.economicIncome,
    );
  }
  
  // Update site plans (Step 7)
  void updateSitePlans(SitePlansModel sitePlans) {
    state = EvaluationModel(
      evaluationId: state.evaluationId,
      status: state.status,
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
      generalInfo: state.generalInfo,
      generalPropertyInfo: state.generalPropertyInfo,
      propertyDescription: state.propertyDescription,
      floorsCount: state.floorsCount,
      floors: state.floors,
      areaDetails: state.areaDetails,
      incomeNotes: state.incomeNotes,
      sitePlans: sitePlans,
      propertyImages: state.propertyImages,
      additionalData: state.additionalData,
      buildingLandCost: state.buildingLandCost,
      economicIncome: state.economicIncome,
    );
  }
  
  // Update property images (Step 8)
  void updatePropertyImages(ImageModel images) {
    state = EvaluationModel(
      evaluationId: state.evaluationId,
      status: state.status,
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
      generalInfo: state.generalInfo,
      generalPropertyInfo: state.generalPropertyInfo,
      propertyDescription: state.propertyDescription,
      floorsCount: state.floorsCount,
      floors: state.floors,
      areaDetails: state.areaDetails,
      incomeNotes: state.incomeNotes,
      sitePlans: state.sitePlans,
      propertyImages: images,
      additionalData: state.additionalData,
      buildingLandCost: state.buildingLandCost,
      economicIncome: state.economicIncome,
    );
  }
  
  // Update additional data (Step 9)
  void updateAdditionalData(AdditionalDataModel additionalData) {
    state = EvaluationModel(
      evaluationId: state.evaluationId,
      status: state.status,
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
      generalInfo: state.generalInfo,
      generalPropertyInfo: state.generalPropertyInfo,
      propertyDescription: state.propertyDescription,
      floorsCount: state.floorsCount,
      floors: state.floors,
      areaDetails: state.areaDetails,
      incomeNotes: state.incomeNotes,
      sitePlans: state.sitePlans,
      propertyImages: state.propertyImages,
      additionalData: additionalData,
      buildingLandCost: state.buildingLandCost,
      economicIncome: state.economicIncome,
    );
  }
  
  // Update building and land cost (Step 10)
  void updateBuildingLandCost(BuildingLandCostModel buildingLandCost) {
    state = EvaluationModel(
      evaluationId: state.evaluationId,
      status: state.status,
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
      generalInfo: state.generalInfo,
      generalPropertyInfo: state.generalPropertyInfo,
      propertyDescription: state.propertyDescription,
      floorsCount: state.floorsCount,
      floors: state.floors,
      areaDetails: state.areaDetails,
      incomeNotes: state.incomeNotes,
      sitePlans: state.sitePlans,
      propertyImages: state.propertyImages,
      additionalData: state.additionalData,
      buildingLandCost: buildingLandCost,
      economicIncome: state.economicIncome,
    );
  }
  
  // Update economic income (Step 11)
  void updateEconomicIncome(EconomicIncomeModel economicIncome) {
    state = EvaluationModel(
      evaluationId: state.evaluationId,
      status: state.status,
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
      generalInfo: state.generalInfo,
      generalPropertyInfo: state.generalPropertyInfo,
      propertyDescription: state.propertyDescription,
      floorsCount: state.floorsCount,
      floors: state.floors,
      areaDetails: state.areaDetails,
      incomeNotes: state.incomeNotes,
      sitePlans: state.sitePlans,
      propertyImages: state.propertyImages,
      additionalData: state.additionalData,
      buildingLandCost: state.buildingLandCost,
      economicIncome: economicIncome,
    );
  }
  
  // Save evaluation to Firebase
  Future<String?> saveEvaluation() async {
    try {
      if (state.evaluationId == null) {
        // Create new evaluation
        final id = await _evaluationService.createEvaluation(state);
        state = EvaluationModel(
          evaluationId: id,
          status: state.status,
          createdAt: state.createdAt,
          updatedAt: DateTime.now(),
          generalInfo: state.generalInfo,
          generalPropertyInfo: state.generalPropertyInfo,
          propertyDescription: state.propertyDescription,
          floorsCount: state.floorsCount,
          floors: state.floors,
          areaDetails: state.areaDetails,
          incomeNotes: state.incomeNotes,
          sitePlans: state.sitePlans,
          propertyImages: state.propertyImages,
          additionalData: state.additionalData,
          buildingLandCost: state.buildingLandCost,
          economicIncome: state.economicIncome,
        );
        return id;
      } else {
        // Update existing evaluation
        await _evaluationService.updateEvaluation(state);
        return state.evaluationId;
      }
    } catch (e) {
      throw Exception('Failed to save evaluation: $e');
    }
  }
  
  /// Auto-save evaluation as draft
  /// This is called automatically when navigating between steps or leaving the form
  /// Returns the evaluation ID (creates new if needed)
  Future<String?> saveAsDraft() async {
    try {
      // Only save if there's actual data to save
      if (!_hasAnyData()) {
        return state.evaluationId;
      }
      
      // Don't auto-save deleted forms - they should remain deleted until explicitly restored
      if (state.status == 'deleted') {
        return state.evaluationId;
      }
      
      // Ensure status is draft (unless already completed)
      if (state.status != 'completed') {
        state = EvaluationModel(
          evaluationId: state.evaluationId,
          status: 'draft',
          previousStatus: state.previousStatus,
          createdAt: state.createdAt,
          updatedAt: DateTime.now(),
          generalInfo: state.generalInfo,
          generalPropertyInfo: state.generalPropertyInfo,
          propertyDescription: state.propertyDescription,
          floorsCount: state.floorsCount,
          floors: state.floors,
          areaDetails: state.areaDetails,
          incomeNotes: state.incomeNotes,
          sitePlans: state.sitePlans,
          propertyImages: state.propertyImages,
          additionalData: state.additionalData,
          buildingLandCost: state.buildingLandCost,
          economicIncome: state.economicIncome,
        );
      }
      
      if (state.evaluationId == null) {
        // Create new draft evaluation
        final id = await _evaluationService.createEvaluation(state);
        state = EvaluationModel(
          evaluationId: id,
          status: state.status,
          createdAt: state.createdAt,
          updatedAt: DateTime.now(),
          generalInfo: state.generalInfo,
          generalPropertyInfo: state.generalPropertyInfo,
          propertyDescription: state.propertyDescription,
          floorsCount: state.floorsCount,
          floors: state.floors,
          areaDetails: state.areaDetails,
          incomeNotes: state.incomeNotes,
          sitePlans: state.sitePlans,
          propertyImages: state.propertyImages,
          additionalData: state.additionalData,
          buildingLandCost: state.buildingLandCost,
          economicIncome: state.economicIncome,
        );
        return id;
      } else {
        // Update existing draft
        await _evaluationService.updateEvaluation(state);
        return state.evaluationId;
      }
    } catch (e) {
      // Don't throw - auto-save should fail silently
      // Error logged: Auto-save failed with error: $e
      return state.evaluationId;
    }
  }
  
  /// Check if there's any data worth saving
  bool _hasAnyData() {
    return state.generalInfo != null ||
           state.generalPropertyInfo != null ||
           state.propertyDescription != null ||
           (state.floors != null && state.floors!.isNotEmpty) ||
           state.areaDetails != null ||
           state.incomeNotes != null ||
           state.sitePlans != null ||
           state.propertyImages != null ||
           state.additionalData != null ||
           state.buildingLandCost != null ||
           state.economicIncome != null;
  }
  
  // Load evaluation from Firebase
  Future<void> loadEvaluation(String evaluationId) async {
    try {
      final evaluation = await _evaluationService.getEvaluationById(evaluationId);
      if (evaluation != null) {
        state = evaluation;
      } else {
        throw Exception('Evaluation not found with ID: $evaluationId');
      }
    } catch (e) {
      throw Exception('Failed to load evaluation: $e');
    }
  }
  
  // Update evaluation status
  void updateStatus(String status) {
    state = EvaluationModel(
      evaluationId: state.evaluationId,
      status: status,
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
      generalInfo: state.generalInfo,
      generalPropertyInfo: state.generalPropertyInfo,
      propertyDescription: state.propertyDescription,
      floorsCount: state.floorsCount,
      floors: state.floors,
      areaDetails: state.areaDetails,
      incomeNotes: state.incomeNotes,
      sitePlans: state.sitePlans,
      propertyImages: state.propertyImages,
      additionalData: state.additionalData,
      buildingLandCost: state.buildingLandCost,
      economicIncome: state.economicIncome,
    );
  }
  
  // Reset evaluation to initial state
  void resetEvaluation() {
    state = EvaluationModel(
      status: 'draft',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  // Check if evaluation is complete (all required sections filled)
  bool isComplete() {
    return state.generalInfo != null &&
           state.generalPropertyInfo != null &&
           state.propertyDescription != null &&
           state.areaDetails != null &&
           state.additionalData != null;
  }
}
