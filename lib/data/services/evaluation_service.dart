import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/evaluation_model.dart';

/// Pagination result containing evaluations and the last document for cursor-based pagination
class PaginatedEvaluations {
  final List<EvaluationModel> evaluations;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  PaginatedEvaluations({
    required this.evaluations,
    this.lastDocument,
    required this.hasMore,
  });
}

class EvaluationService {
  final _collection = FirebaseFirestore.instance.collection('evaluations');
  
  /// Default pagination limit
  static const int defaultLimit = 25;

  // Create new evaluation
  Future<String> createEvaluation(EvaluationModel evaluation) async {
    try {
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
        buildingLandCost: evaluation.buildingLandCost,
        economicIncome: evaluation.economicIncome,
      );

      await docRef.set(evaluationWithId.toJson());
      return docRef.id;
    } catch (e) {
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
        buildingLandCost: evaluation.buildingLandCost,
        economicIncome: evaluation.economicIncome,
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
      DocumentSnapshot doc = await _collection.doc(evaluationId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      // Ensure evaluationId is set from document ID
      data['evaluationId'] = doc.id;

      return EvaluationModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get evaluation: $e');
    }
  }

  // Get all evaluations with pagination
  Future<PaginatedEvaluations> getAllEvaluations({
    int limit = defaultLimit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query =
          _collection.orderBy('updatedAt', descending: true).limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      QuerySnapshot querySnapshot = await query.get();

      final evaluations = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure evaluationId is set from document ID
        data['evaluationId'] = doc.id;
        return EvaluationModel.fromJson(data);
      }).toList();

      return PaginatedEvaluations(
        evaluations: evaluations,
        lastDocument: querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null,
        hasMore: evaluations.length >= limit,
      );
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

  /// Soft delete - marks evaluation as 'deleted' status
  /// The evaluation can be recovered or permanently deleted later
  /// Saves the previous status so it can be restored later
  Future<void> softDeleteEvaluation(String evaluationId) async {
    try {
      // First get the current status to save as previousStatus
      final doc = await _collection.doc(evaluationId).get();
      final currentStatus = doc.data()?['status'] ?? 'draft';
      
      await _collection.doc(evaluationId).update({
        'previousStatus': currentStatus,
        'status': 'deleted',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to soft delete evaluation: $e');
    }
  }
  
  /// Permanent delete - completely removes the evaluation from Firebase
  /// This should only be used for evaluations already in 'deleted' status
  Future<void> permanentlyDeleteEvaluation(String evaluationId) async {
    try {
      await _collection.doc(evaluationId).delete();
    } catch (e) {
      throw Exception('Failed to permanently delete evaluation: $e');
    }
  }
  
  /// Restore a soft-deleted evaluation back to its previous status
  /// If no previous status is stored, defaults to 'draft'
  Future<void> restoreEvaluation(String evaluationId) async {
    try {
      // Get the previous status to restore to
      final doc = await _collection.doc(evaluationId).get();
      final previousStatus = doc.data()?['previousStatus'] ?? 'draft';
      
      await _collection.doc(evaluationId).update({
        'status': previousStatus,
        'previousStatus': null, // Clear the previousStatus field
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to restore evaluation: $e');
    }
  }

  /// Approve evaluation - marks it as 'approved' status
  /// Approved evaluations cannot be edited or deleted until unapproved
  Future<void> approveEvaluation(String evaluationId) async {
    try {
      // First get the current status to save as previousStatus
      final doc = await _collection.doc(evaluationId).get();
      final currentStatus = doc.data()?['status'] ?? 'draft';
      
      await _collection.doc(evaluationId).update({
        'previousStatus': currentStatus,
        'status': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to approve evaluation: $e');
    }
  }

  /// Unapprove evaluation - restores it to 'completed' status
  /// This allows the evaluation to be edited or deleted again
  Future<void> unapproveEvaluation(String evaluationId) async {
    try {
      await _collection.doc(evaluationId).update({
        'status': 'completed', // Always restore to completed
        'previousStatus': null, // Clear previousStatus
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to unapprove evaluation: $e');
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

/// Search evaluations across multiple fields:
  /// اسم العميل، المنطقة، القطعة، القسيمة، الرقم الآلي، التاريخ، رقم هاتف العميل، نوع العقار، رقم الوثيقة، رقم المخطط
  Future<List<EvaluationModel>> searchEvaluations(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }
      
      final queryLower = query.toLowerCase().trim();
      
      // Fetch all evaluations (limited for performance)
      QuerySnapshot querySnapshot = await _collection
          .orderBy('updatedAt', descending: true)
          .limit(200) // Fetch a reasonable number for client-side filtering
          .get();

      final evaluations = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['evaluationId'] = doc.id;
        return EvaluationModel.fromJson(data);
      }).toList();

      // Filter client-side across all specified fields
      return evaluations.where((eval) {
        // اسم العميل - Client Name
        final clientName = eval.generalInfo?.clientName?.toLowerCase() ?? '';
        if (clientName.contains(queryLower)) return true;
        
        // المنطقة - Area
        final area = eval.generalPropertyInfo?.area?.toLowerCase() ?? '';
        if (area.contains(queryLower)) return true;
        
        // القطعة - Plot Number
        final plotNumber = eval.generalPropertyInfo?.plotNumber?.toLowerCase() ?? '';
        if (plotNumber.contains(queryLower)) return true;
        
        // القسيمة - Parcel Number
        final parcelNumber = eval.generalPropertyInfo?.parcelNumber?.toLowerCase() ?? '';
        if (parcelNumber.contains(queryLower)) return true;
        
        // الرقم الآلي - Auto Number
        final autoNumber = eval.generalPropertyInfo?.autoNumber?.toLowerCase() ?? '';
        if (autoNumber.contains(queryLower)) return true;
        
        // رقم هاتف العميل - Client Phone
        final clientPhone = eval.generalInfo?.clientPhone?.toLowerCase() ?? '';
        if (clientPhone.contains(queryLower)) return true;
        
        // نوع العقار - Property Type
        final propertyType = eval.generalPropertyInfo?.propertyType?.toLowerCase() ?? '';
        if (propertyType.contains(queryLower)) return true;
        
        // رقم الوثيقة - Document Number
        final documentNumber = eval.generalPropertyInfo?.documentNumber?.toLowerCase() ?? '';
        if (documentNumber.contains(queryLower)) return true;
        
        // رقم المخطط - Plan Number
        final planNumber = eval.generalPropertyInfo?.planNumber?.toLowerCase() ?? '';
        if (planNumber.contains(queryLower)) return true;
        
        // التاريخ - Date (search by formatted date string)
        final requestDate = eval.generalInfo?.requestDate;
        if (requestDate != null) {
          final dateStr = '${requestDate.day}/${requestDate.month}/${requestDate.year}';
          if (dateStr.contains(queryLower)) return true;
        }
        
        final createdAt = eval.createdAt;
        if (createdAt != null) {
          final dateStr = '${createdAt.day}/${createdAt.month}/${createdAt.year}';
          if (dateStr.contains(queryLower)) return true;
        }
        
        return false;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search evaluations: $e');
    }
  }
  
  /// Legacy method - kept for backward compatibility
  Future<List<EvaluationModel>> searchByClientName(String clientName) async {
    return searchEvaluations(clientName);
  }

// Get evaluations by status (draft, completed, etc.)
  Future<PaginatedEvaluations> getEvaluationsByStatus({
    required String status,
    int limit = defaultLimit,
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

      final evaluations = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure evaluationId is set from document ID
        data['evaluationId'] = doc.id;
        return EvaluationModel.fromJson(data);
      }).toList();

      return PaginatedEvaluations(
        evaluations: evaluations,
        lastDocument: querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null,
        hasMore: evaluations.length >= limit,
      );
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

  /// Real-time stream of all evaluations
  /// This enables automatic sync across devices
  Stream<List<EvaluationModel>> watchEvaluations({int limit = defaultLimit}) {
    return _collection
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['evaluationId'] = doc.id;
        return EvaluationModel.fromJson(data);
      }).toList();
    });
  }

  /// Real-time stream of evaluations filtered by status
  Stream<List<EvaluationModel>> watchEvaluationsByStatus({
    required String status,
    int limit = defaultLimit,
  }) {
    return _collection
        .where('status', isEqualTo: status)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['evaluationId'] = doc.id;
        return EvaluationModel.fromJson(data);
      }).toList();
    });
  }

  /// Real-time stream for a single evaluation
  Stream<EvaluationModel?> watchEvaluation(String evaluationId) {
    return _collection.doc(evaluationId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['evaluationId'] = doc.id;
      return EvaluationModel.fromJson(data);
    });
  }
}
