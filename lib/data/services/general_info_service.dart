// lib/data/services/general_info_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aljal_evaluation/data/models/pages_models/general_info_model.dart';

class GeneralInfoService {
  static final _collection = FirebaseFirestore.instance.collection(
    'generalInfo',
  );

  /// Add a new GeneralInfo document (with specified docId)
  static Future<void> addGeneralInfo(
    GeneralInfoModel data,
    String docId,
  ) async {
    try {
      await _collection.doc(docId).set(data.toJson());
    } catch (e) {
      print('Error adding GeneralInfo: $e');
      rethrow;
    }
  }

  /// Get a GeneralInfo document by ID
  static Future<GeneralInfoModel?> getGeneralInfo(String docId) async {
    try {
      final snapshot = await _collection.doc(docId).get();
      if (snapshot.exists) {
        return GeneralInfoModel.fromJson(snapshot.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching GeneralInfo: $e');
      rethrow;
    }
  }

  /// Update a GeneralInfo document by ID
  static Future<void> updateGeneralInfo(
    GeneralInfoModel data,
    String docId,
  ) async {
    try {
      await _collection.doc(docId).update(data.toJson());
    } catch (e) {
      print('Error updating GeneralInfo: $e');
      rethrow;
    }
  }

  /// Delete a GeneralInfo document by ID
  static Future<void> deleteGeneralInfo(String docId) async {
    try {
      await _collection.doc(docId).delete();
    } catch (e) {
      print('Error deleting GeneralInfo: $e');
      rethrow;
    }
  }

  /// Optional: Fetch all GeneralInfo documents (for listing)
  static Future<List<GeneralInfoModel>> getAllGeneralInfo() async {
    try {
      final snapshot = await _collection.get();
      return snapshot.docs
          .map((doc) => GeneralInfoModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching all GeneralInfo: $e');
      rethrow;
    }
  }
}
