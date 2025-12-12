import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/evaluation_model.dart';

class EvaluationService {
  final _collection = FirebaseFirestore.instance.collection('evaluations');

  // Create new evaluation
  Future<String> createEvaluation(EvaluationModel evaluation) async {
    try {
      print('📤 Service: Creating evaluation...');
      print('   - Has generalInfo: ${evaluation.generalInfo != null}');
      if (evaluation.generalInfo != null) {
        print('   - clientName: ${evaluation.generalInfo?.clientName}');
      }
      
      // Generate new document ID
      DocumentReference docRef = _collection.doc();

      // Add the ID to the evaluation
      EvaluationModel evaluationWithId = EvaluationModel(
        evaluationId: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: evaluation.status ?? 'draft',
        generalInfo: evaluation.generalInfo,
        generalPropertyInfo: evaluation.generalPropertyInfo,
        propertyDescription: evaluation.propertyDescription,
        floorsCount: evaluation.floorsCount,
        floors: evaluation.floors,
        areaDetails: evaluation.areaDetails,
        incomeNotes: evaluation.incomeNotes,
        sitePlans: evaluation.sitePlans,
        propertyImages: evaluation.propertyImages,
        additionalData: evaluation.additionalData,
      );

      final jsonData = evaluationWithId.toJson();
      print('📄 Service: JSON data to save:');
      print('   - Keys: ${jsonData.keys.toList()}');
      print('   - generalInfo: ${jsonData['generalInfo']}');
      
      await docRef.set(jsonData);
      print('✅ Service: Created evaluation with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Service: Error creating evaluation: $e');
      throw Exception('Failed to create evaluation: $e');
    }
  }

  // Update existing evaluation
  Future<void> updateEvaluation(EvaluationModel evaluation) async {
    try {
      if (evaluation.evaluationId == null) {
        throw Exception('Evaluation ID is required for update');
      }

      // Update with new timestamp
      EvaluationModel updatedEvaluation = EvaluationModel(
        evaluationId: evaluation.evaluationId,
        createdAt: evaluation.createdAt,
        updatedAt: DateTime.now(),
        status: evaluation.status,
        generalInfo: evaluation.generalInfo,
        generalPropertyInfo: evaluation.generalPropertyInfo,
        propertyDescription: evaluation.propertyDescription,
        floorsCount: evaluation.floorsCount,
        floors: evaluation.floors,
        areaDetails: evaluation.areaDetails,
        incomeNotes: evaluation.incomeNotes,
        sitePlans: evaluation.sitePlans,
        propertyImages: evaluation.propertyImages,
        additionalData: evaluation.additionalData,
      );

      await _collection
          .doc(evaluation.evaluationId)
          .set(updatedEvaluation.toJson());
    } catch (e) {
      throw Exception('Failed to update evaluation: $e');
    }
  }

  // Get evaluation by ID
  Future<EvaluationModel?> getEvaluationById(String evaluationId) async {
    try {
      print('📥 Service: Getting evaluation by ID: $evaluationId');
      DocumentSnapshot doc = await _collection.doc(evaluationId).get();

      if (!doc.exists) {
        print('❌ Service: Document does not exist!');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      print('📄 Service: Raw data from Firestore:');
      print('   - Keys: ${data.keys.toList()}');
      print('   - Has generalInfo: ${data.containsKey('generalInfo')}');
      if (data.containsKey('generalInfo') && data['generalInfo'] != null) {
        print('   - generalInfo keys: ${(data['generalInfo'] as Map).keys.toList()}');
        print('   - clientName: ${data['generalInfo']['clientName']}');
      }
      
      // Ensure evaluationId is set from document ID
      data['evaluationId'] = doc.id;
      
      final model = EvaluationModel.fromJson(data);
      print('✅ Service: Parsed model - generalInfo is null: ${model.generalInfo == null}');
      if (model.generalInfo != null) {
        print('   - Model clientName: ${model.generalInfo?.clientName}');
      }
      
      return model;
    } catch (e) {
      print('❌ Service: Error getting evaluation: $e');
      throw Exception('Failed to get evaluation: $e');
    }
  }

  // Get all evaluations with pagination
  Future<List<EvaluationModel>> getAllEvaluations({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query =
          _collection.orderBy('updatedAt', descending: true).limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      QuerySnapshot querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure evaluationId is set from document ID
        data['evaluationId'] = doc.id;
        return EvaluationModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get evaluations: $e');
    }
  }

  // Search evaluations by date range
  Future<List<EvaluationModel>> searchEvaluationsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    try {
      QuerySnapshot querySnapshot = await _collection
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure evaluationId is set from document ID
        data['evaluationId'] = doc.id;
        return EvaluationModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search evaluations: $e');
    }
  }

  // Delete evaluation
  Future<void> deleteEvaluation(String evaluationId) async {
    try {
      await _collection.doc(evaluationId).delete();
    } catch (e) {
      throw Exception('Failed to delete evaluation: $e');
    }
  }

  // Get evaluations count
  Future<int> getEvaluationsCount() async {
    try {
      AggregateQuerySnapshot snapshot = await _collection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get evaluations count: $e');
    }
  }

  // Add these methods to your existing EvaluationService class:

// Search evaluations by client name
  Future<List<EvaluationModel>> searchByClientName(String clientName) async {
    try {
      // For partial search, we need to use >= and < with the next character
      String searchEnd = '$clientName\uf8ff';

      QuerySnapshot querySnapshot = await _collection
          .where('generalInfo.clientName', isGreaterThanOrEqualTo: clientName)
          .where('generalInfo.clientName', isLessThan: searchEnd)
          .orderBy('generalInfo.clientName')
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure evaluationId is set from document ID
        data['evaluationId'] = doc.id;
        return EvaluationModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search by client name: $e');
    }
  }

// Get evaluations by status (draft, completed, etc.)
  Future<List<EvaluationModel>> getEvaluationsByStatus({
    required String status,
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _collection
          .where('status', isEqualTo: status)
          .orderBy('updatedAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      QuerySnapshot querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure evaluationId is set from document ID
        data['evaluationId'] = doc.id;
        return EvaluationModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get evaluations by status: $e');
    }
  }

// Batch delete evaluations
  Future<void> deleteMultipleEvaluations(List<String> evaluationIds) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (String id in evaluationIds) {
        batch.delete(_collection.doc(id));
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete multiple evaluations: $e');
    }
  }
}
