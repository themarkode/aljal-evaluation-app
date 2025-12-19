import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:aljal_evaluation/data/models/evaluation_model.dart';
import 'package:aljal_evaluation/data/services/evaluation_service.dart';

part 'evaluation_list_provider.g.dart';

// Provider for managing the list of evaluations with real-time sync
@riverpod
class EvaluationListNotifier extends _$EvaluationListNotifier {
  late final EvaluationService _evaluationService;
  StreamSubscription<List<EvaluationModel>>? _subscription;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  
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
    
    state = state.copyWith(isLoading: true);
    
    // Listen to real-time updates based on current filter
    final stream = state.selectedFilter == EvaluationFilter.all
        ? _evaluationService.watchEvaluations(limit: 50)
        : _evaluationService.watchEvaluationsByStatus(
            status: _getStatusFromFilter(state.selectedFilter),
            limit: 50,
          );
    
    _subscription = stream.listen(
      (evaluations) {
        state = state.copyWith(
          evaluations: evaluations,
          isLoading: false,
          hasMore: evaluations.length >= 50,
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
    // Stop real-time sync during search
    stopRealtimeSync();
    
    state = state.copyWith(searchQuery: query, isLoading: true);
    
    if (query.isEmpty) {
      // Resume real-time sync when search is cleared
      startRealtimeSync();
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
  
  // Delete evaluation
  Future<void> deleteEvaluation(String evaluationId) async {
    try {
      await _evaluationService.deleteEvaluation(evaluationId);
      
      // With real-time sync, the list will auto-update
      // But we can optimistically remove it for better UX
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
      
      // Optimistically remove from local state
      final updatedList = state.evaluations
          .where((e) => !evaluationIds.contains(e.evaluationId))
          .toList();
      
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
      case EvaluationFilter.all:
        return '';
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
