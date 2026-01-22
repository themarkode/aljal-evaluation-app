import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:aljal_evaluation/data/models/evaluation_model.dart';
import 'package:aljal_evaluation/data/services/evaluation_service.dart';

part 'evaluation_list_provider.g.dart';

/// Pagination limit - can be changed as needed
const int _paginationLimit = 25;

// Provider for managing the list of evaluations with real-time sync
@riverpod
class EvaluationListNotifier extends _$EvaluationListNotifier {
  late final EvaluationService _evaluationService;
  StreamSubscription<List<EvaluationModel>>? _subscription;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  
  @override
  EvaluationListState build() {
    _evaluationService = EvaluationService();
    
    // Cancel subscription when provider is disposed
    ref.onDispose(() {
      _subscription?.cancel();
    });
    
    return EvaluationListState(
      evaluations: [],
      isLoading: false,
      hasMore: true,
      selectedFilter: EvaluationFilter.all,
      searchQuery: '',
    );
  }
  
  /// Start listening to real-time updates from Firestore
  /// This enables automatic sync across devices
  void startRealtimeSync() {
    // Cancel any existing subscription
    _subscription?.cancel();
    _lastDocument = null;
    _hasMore = true;
    
    state = state.copyWith(isLoading: true);
    
    // Listen to real-time updates based on current filter
    final stream = state.selectedFilter == EvaluationFilter.all
        ? _evaluationService.watchEvaluations(limit: _paginationLimit)
        : _evaluationService.watchEvaluationsByStatus(
            status: _getStatusFromFilter(state.selectedFilter),
            limit: _paginationLimit,
          );
    
    _subscription = stream.listen(
      (evaluations) {
        state = state.copyWith(
          evaluations: evaluations,
          isLoading: false,
          hasMore: evaluations.length >= _paginationLimit,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
      },
    );
  }
  
  /// Stop real-time sync (useful when leaving the screen)
  void stopRealtimeSync() {
    _subscription?.cancel();
    _subscription = null;
  }
  
  // Load evaluations with pagination (one-time fetch, used for initial load or manual refresh)
  Future<void> loadEvaluations({bool refresh = false}) async {
    if (refresh) {
      _lastDocument = null;
      _hasMore = true;
      state = state.copyWith(evaluations: [], hasMore: true);
    }
    
    if (!_hasMore) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await _evaluationService.getAllEvaluations(
        limit: _paginationLimit,
        startAfter: _lastDocument,
      );
      
      _lastDocument = result.lastDocument;
      _hasMore = result.hasMore;
      
      state = state.copyWith(
        evaluations: refresh ? result.evaluations : [...state.evaluations, ...result.evaluations],
        isLoading: false,
        hasMore: _hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Load more evaluations (pagination)
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore || state.isLoading) return;
    
    _isLoadingMore = true;
    
    try {
      final result = state.selectedFilter == EvaluationFilter.all
          ? await _evaluationService.getAllEvaluations(
              limit: _paginationLimit,
              startAfter: _lastDocument,
            )
          : await _evaluationService.getEvaluationsByStatus(
              status: _getStatusFromFilter(state.selectedFilter),
              limit: _paginationLimit,
              startAfter: _lastDocument,
            );
      
      _lastDocument = result.lastDocument;
      _hasMore = result.hasMore;
      
      state = state.copyWith(
        evaluations: [...state.evaluations, ...result.evaluations],
        hasMore: _hasMore,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      _isLoadingMore = false;
    }
  }
  
  /// Search evaluations across multiple fields:
  /// اسم العميل، المنطقة، القطعة، القسيمة، الرقم الآلي، التاريخ، رقم هاتف العميل، نوع العقار، رقم الوثيقة، رقم المخطط
  Future<void> searchEvaluations(String query) async {
    // Stop real-time sync during search
    stopRealtimeSync();
    
    state = state.copyWith(searchQuery: query, isLoading: true);
    
    if (query.isEmpty) {
      // Resume real-time sync when search is cleared
      startRealtimeSync();
      return;
    }
    
    try {
      final evaluations = await _evaluationService.searchEvaluations(query);
      state = state.copyWith(
        evaluations: evaluations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Legacy method - kept for backward compatibility
  Future<void> searchByClient(String query) async {
    return searchEvaluations(query);
  }
  
  // Filter evaluations by status
  Future<void> filterByStatus(String status) async {
    _lastDocument = null;
    _hasMore = true;
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await _evaluationService.getEvaluationsByStatus(
        status: status,
        limit: _paginationLimit,
      );
      
      _lastDocument = result.lastDocument;
      _hasMore = result.hasMore;
      
      state = state.copyWith(
        evaluations: result.evaluations,
        isLoading: false,
        hasMore: _hasMore,
        selectedFilter: _getFilterFromStatus(status),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  // Filter by date range
  Future<void> filterByDateRange(DateTime start, DateTime end) async {
    // Stop real-time sync during date filter
    stopRealtimeSync();
    
    state = state.copyWith(isLoading: true);
    
    try {
      final evaluations = await _evaluationService.searchEvaluationsByDateRange(
        startDate: start,
        endDate: end,
      );
      
      state = state.copyWith(
        evaluations: evaluations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Soft delete - marks evaluation as 'deleted' status
  /// The evaluation will appear under "deleted" filter and can be permanently deleted later
  /// Saves the previous status so it can be restored later
  Future<void> softDeleteEvaluation(String evaluationId) async {
    try {
      await _evaluationService.softDeleteEvaluation(evaluationId);
      
      // Update local state - save previous status and mark as deleted
      final updatedList = state.evaluations.map((e) {
        if (e.evaluationId == evaluationId) {
          return EvaluationModel(
            evaluationId: e.evaluationId,
            status: 'deleted',
            previousStatus: e.status ?? 'draft', // Save current status before deletion
            createdAt: e.createdAt,
            updatedAt: DateTime.now(),
            generalInfo: e.generalInfo,
            generalPropertyInfo: e.generalPropertyInfo,
            propertyDescription: e.propertyDescription,
            floorsCount: e.floorsCount,
            floors: e.floors,
            areaDetails: e.areaDetails,
            incomeNotes: e.incomeNotes,
            sitePlans: e.sitePlans,
            propertyImages: e.propertyImages,
            additionalData: e.additionalData,
          );
        }
        return e;
      }).toList();
      
      state = state.copyWith(evaluations: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  /// Permanently delete - completely removes the evaluation from Firebase
  /// This should only be used for evaluations already in 'deleted' status
  Future<void> permanentlyDeleteEvaluation(String evaluationId) async {
    try {
      await _evaluationService.permanentlyDeleteEvaluation(evaluationId);
      
      // Optimistically remove from local state
      final updatedList = state.evaluations
          .where((e) => e.evaluationId != evaluationId)
          .toList();
      
      state = state.copyWith(evaluations: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  /// Restore a soft-deleted evaluation back to its previous status
  /// Falls back to 'draft' if no previous status is stored
  Future<void> restoreEvaluation(String evaluationId) async {
    try {
      await _evaluationService.restoreEvaluation(evaluationId);
      
      // Update local state - restore to previous status or 'draft'
      final updatedList = state.evaluations.map((e) {
        if (e.evaluationId == evaluationId) {
          final restoredStatus = e.previousStatus ?? 'draft';
          return EvaluationModel(
            evaluationId: e.evaluationId,
            status: restoredStatus,
            previousStatus: null, // Clear previousStatus after restore
            createdAt: e.createdAt,
            updatedAt: DateTime.now(),
            generalInfo: e.generalInfo,
            generalPropertyInfo: e.generalPropertyInfo,
            propertyDescription: e.propertyDescription,
            floorsCount: e.floorsCount,
            floors: e.floors,
            areaDetails: e.areaDetails,
            incomeNotes: e.incomeNotes,
            sitePlans: e.sitePlans,
            propertyImages: e.propertyImages,
            additionalData: e.additionalData,
          );
        }
        return e;
      }).toList();
      
      state = state.copyWith(evaluations: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  // Delete multiple evaluations (soft delete)
  Future<void> deleteMultiple(List<String> evaluationIds) async {
    try {
      // Soft delete each evaluation
      for (final id in evaluationIds) {
        await _evaluationService.softDeleteEvaluation(id);
      }
      
      // Update local state - save previous status for each
      final updatedList = state.evaluations.map((e) {
        if (evaluationIds.contains(e.evaluationId)) {
          return EvaluationModel(
            evaluationId: e.evaluationId,
            status: 'deleted',
            previousStatus: e.status ?? 'draft', // Save current status
            createdAt: e.createdAt,
            updatedAt: DateTime.now(),
            generalInfo: e.generalInfo,
            generalPropertyInfo: e.generalPropertyInfo,
            propertyDescription: e.propertyDescription,
            floorsCount: e.floorsCount,
            floors: e.floors,
            areaDetails: e.areaDetails,
            incomeNotes: e.incomeNotes,
            sitePlans: e.sitePlans,
            propertyImages: e.propertyImages,
            additionalData: e.additionalData,
          );
        }
        return e;
      }).toList();
      
      state = state.copyWith(evaluations: updatedList, selectedIds: {});
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  // Toggle selection for multiple delete
  void toggleSelection(String evaluationId) {
    if (state.selectedIds.contains(evaluationId)) {
      state = state.copyWith(
        selectedIds: {...state.selectedIds}..remove(evaluationId),
      );
    } else {
      state = state.copyWith(
        selectedIds: {...state.selectedIds, evaluationId},
      );
    }
  }
  
  // Clear all selections
  void clearSelections() {
    state = state.copyWith(selectedIds: {});
  }
  
  // Apply filter with real-time sync
  void applyFilter(EvaluationFilter filter) {
    state = state.copyWith(selectedFilter: filter, searchQuery: '');
    
    // Restart real-time sync with new filter
    startRealtimeSync();
  }
  
  // Helper method
  EvaluationFilter _getFilterFromStatus(String status) {
    switch (status) {
      case 'draft':
        return EvaluationFilter.draft;
      case 'completed':
        return EvaluationFilter.completed;
      case 'approved':
        return EvaluationFilter.approved;
      case 'deleted':
        return EvaluationFilter.deleted;
      default:
        return EvaluationFilter.all;
    }
  }
  
  String _getStatusFromFilter(EvaluationFilter filter) {
    switch (filter) {
      case EvaluationFilter.draft:
        return 'draft';
      case EvaluationFilter.completed:
        return 'completed';
      case EvaluationFilter.approved:
        return 'approved';
      case EvaluationFilter.deleted:
        return 'deleted';
      case EvaluationFilter.all:
        return '';
    }
  }
  
  /// Approve evaluation - marks it as 'approved' status
  /// Approved evaluations cannot be edited or deleted until unapproved
  Future<void> approveEvaluation(String evaluationId) async {
    try {
      await _evaluationService.approveEvaluation(evaluationId);
      
      // Update local state
      final updatedList = state.evaluations.map((e) {
        if (e.evaluationId == evaluationId) {
          return EvaluationModel(
            evaluationId: e.evaluationId,
            status: 'approved',
            previousStatus: e.status ?? 'completed',
            createdAt: e.createdAt,
            updatedAt: DateTime.now(),
            generalInfo: e.generalInfo,
            generalPropertyInfo: e.generalPropertyInfo,
            propertyDescription: e.propertyDescription,
            floorsCount: e.floorsCount,
            floors: e.floors,
            areaDetails: e.areaDetails,
            incomeNotes: e.incomeNotes,
            sitePlans: e.sitePlans,
            propertyImages: e.propertyImages,
            additionalData: e.additionalData,
            buildingLandCost: e.buildingLandCost,
            economicIncome: e.economicIncome,
          );
        }
        return e;
      }).toList();
      
      state = state.copyWith(evaluations: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  /// Unapprove evaluation - restores it to 'completed' status
  Future<void> unapproveEvaluation(String evaluationId) async {
    try {
      await _evaluationService.unapproveEvaluation(evaluationId);
      
      // Update local state
      final updatedList = state.evaluations.map((e) {
        if (e.evaluationId == evaluationId) {
          return EvaluationModel(
            evaluationId: e.evaluationId,
            status: 'completed',
            previousStatus: null,
            createdAt: e.createdAt,
            updatedAt: DateTime.now(),
            generalInfo: e.generalInfo,
            generalPropertyInfo: e.generalPropertyInfo,
            propertyDescription: e.propertyDescription,
            floorsCount: e.floorsCount,
            floors: e.floors,
            areaDetails: e.areaDetails,
            incomeNotes: e.incomeNotes,
            sitePlans: e.sitePlans,
            propertyImages: e.propertyImages,
            additionalData: e.additionalData,
            buildingLandCost: e.buildingLandCost,
            economicIncome: e.economicIncome,
          );
        }
        return e;
      }).toList();
      
      state = state.copyWith(evaluations: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// State class for evaluation list
class EvaluationListState {
  final List<EvaluationModel> evaluations;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final EvaluationFilter selectedFilter;
  final String searchQuery;
  final Set<String> selectedIds;
  
  EvaluationListState({
    required this.evaluations,
    required this.isLoading,
    required this.hasMore,
    this.error,
    required this.selectedFilter,
    required this.searchQuery,
    this.selectedIds = const {},
  });
  
  EvaluationListState copyWith({
    List<EvaluationModel>? evaluations,
    bool? isLoading,
    bool? hasMore,
    String? error,
    EvaluationFilter? selectedFilter,
    String? searchQuery,
    Set<String>? selectedIds,
  }) {
    return EvaluationListState(
      evaluations: evaluations ?? this.evaluations,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

// Enum for filter options
enum EvaluationFilter {
  all,
  draft,
  completed,
  approved,
  deleted,
}

/// Provider to persist view preference (Grid vs List)
/// true = Grid view (card-based), false = List view (table-based)
final isGridViewProvider = StateProvider<bool>((ref) => true);
