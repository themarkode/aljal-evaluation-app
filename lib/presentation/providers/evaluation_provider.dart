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
    print('📝 Provider: Updating generalInfo...');
    print('   - clientName: ${generalInfo.clientName}');
    print('   - Previous state evaluationId: ${state.evaluationId}');
    
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
    );
    
    print('✅ Provider: Updated state - generalInfo is null: ${state.generalInfo == null}');
  }
  
  // Update general property info (Step 1.1)
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
    );
  }
  
  // Update property description (Step 1.2)
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
    );
  }
  
  // Update floors (Step 1.3)
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
  
  // Update area details (Step 1.4)
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
    );
  }
  
  // Update income notes (Step 1.5)
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
    );
  }
  
  // Update site plans (Step 1.6)
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
    );
  }
  
  // Update property images (Step 1.7)
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
    );
  }
  
  // Update additional data (Step 1.8)
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
    );
  }
  
  // Save evaluation to Firebase
  Future<String?> saveEvaluation() async {
    try {
      print('💾 Provider: Saving evaluation...');
      print('   - Current evaluationId: ${state.evaluationId}');
      print('   - Has generalInfo: ${state.generalInfo != null}');
      if (state.generalInfo != null) {
        print('   - generalInfo clientName: ${state.generalInfo?.clientName}');
      }
      
      if (state.evaluationId == null) {
        // Create new evaluation
        print('   - Creating NEW evaluation');
        final id = await _evaluationService.createEvaluation(state);
        print('   - Created with ID: $id');
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
        );
        return id;
      } else {
        // Update existing evaluation
        print('   - Updating EXISTING evaluation: ${state.evaluationId}');
        await _evaluationService.updateEvaluation(state);
        return state.evaluationId;
      }
    } catch (e) {
      print('❌ Provider: Error saving evaluation: $e');
      throw Exception('Failed to save evaluation: $e');
    }
  }
  
  // Load evaluation from Firebase
  Future<void> loadEvaluation(String evaluationId) async {
    try {
      print('🔄 Provider: Loading evaluation $evaluationId');
      final evaluation = await _evaluationService.getEvaluationById(evaluationId);
      if (evaluation != null) {
        print('✅ Provider: Got evaluation from service');
        print('   - Evaluation ID: ${evaluation.evaluationId}');
        print('   - Has generalInfo: ${evaluation.generalInfo != null}');
        if (evaluation.generalInfo != null) {
          print('   - Client name: ${evaluation.generalInfo?.clientName}');
          print('   - Requestor name: ${evaluation.generalInfo?.requestorName}');
        }
        
        // Update state
        state = evaluation;
        
        // Verify state was updated
        print('✅ Provider: State updated');
        print('   - State evaluationId: ${state.evaluationId}');
        print('   - State has generalInfo: ${state.generalInfo != null}');
      } else {
        print('❌ Provider: Evaluation not found');
        throw Exception('Evaluation not found with ID: $evaluationId');
      }
    } catch (e) {
      print('❌ Provider: Error loading evaluation: $e');
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


