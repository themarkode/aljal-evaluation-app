import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:aljal_evaluation/data/models/evaluation_model.dart';
import 'package:aljal_evaluation/data/services/evaluation_service.dart';

part 'evaluation_list_provider.g.dart';

// Provider for managing the list of evaluations
@riverpod
class EvaluationListNotifier extends _$EvaluationListNotifier {
  late final EvaluationService _evaluationService;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  
  @override
  EvaluationListState build() {
    _evaluationService = EvaluationService();
    // Load initial evaluations
    loadEvaluations();
    return EvaluationListState(
      evaluations: [],
      isLoading: true,
      hasMore: true,
      selectedFilter: EvaluationFilter.all,
      searchQuery: '',
    );
  }
  
  // Load evaluations with pagination
  Future<void> loadEvaluations({bool refresh = false}) async {
    if (refresh) {
      _lastDocument = null;
      _hasMore = true;
      state = state.copyWith(evaluations: [], hasMore: true);
    }
    
    if (!_hasMore) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final evaluations = await _evaluationService.getAllEvaluations(
        limit: 10,
        startAfter: _lastDocument,
      );
      
      if (evaluations.isNotEmpty) {
        // Get last document for pagination
        final lastDoc = await FirebaseFirestore.instance
            .collection('evaluations')
            .doc(evaluations.last.evaluationId)
            .get();
        _lastDocument = lastDoc;
      }
      
      _hasMore = evaluations.length == 10;
      
      state = state.copyWith(
        evaluations: refresh ? evaluations : [...state.evaluations, ...evaluations],
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
  
  // Search evaluations by client name
  Future<void> searchByClient(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true);
    
    if (query.isEmpty) {
      await loadEvaluations(refresh: true);
      return;
    }
    
    try {
      final evaluations = await _evaluationService.searchByClientName(query);
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
  
  // Filter evaluations by status
  Future<void> filterByStatus(String status) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final evaluations = await _evaluationService.getEvaluationsByStatus(
        status: status,
        limit: 10,
      );
      
      state = state.copyWith(
        evaluations: evaluations,
        isLoading: false,
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
  
  // Delete evaluation
  Future<void> deleteEvaluation(String evaluationId) async {
    try {
      await _evaluationService.deleteEvaluation(evaluationId);
      
      // Remove from local state
      final updatedList = state.evaluations
          .where((e) => e.evaluationId != evaluationId)
          .toList();
      
      state = state.copyWith(evaluations: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  // Delete multiple evaluations
  Future<void> deleteMultiple(List<String> evaluationIds) async {
    try {
      await _evaluationService.deleteMultipleEvaluations(evaluationIds);
      
      // Remove from local state
      final updatedList = state.evaluations
          .where((e) => !evaluationIds.contains(e.evaluationId))
          .toList();
      
      state = state.copyWith(evaluations: updatedList);
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
  
  // Apply filter
  void applyFilter(EvaluationFilter filter) {
    state = state.copyWith(selectedFilter: filter);
    
    switch (filter) {
      case EvaluationFilter.all:
        loadEvaluations(refresh: true);
        break;
      case EvaluationFilter.draft:
        filterByStatus('draft');
        break;
      case EvaluationFilter.completed:
        filterByStatus('completed');
        break;
    }
  }
  
  // Helper method
  EvaluationFilter _getFilterFromStatus(String status) {
    switch (status) {
      case 'draft':
        return EvaluationFilter.draft;
      case 'completed':
        return EvaluationFilter.completed;
      default:
        return EvaluationFilter.all;
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
}


