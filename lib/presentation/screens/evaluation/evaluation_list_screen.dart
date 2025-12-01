import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/routing/route_names.dart';
import 'package:aljal_evaluation/core/routing/route_arguments.dart';
import 'package:aljal_evaluation/core/utils/ui_helpers.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_list_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/organisms/evaluation_list.dart';
import 'package:aljal_evaluation/presentation/widgets/organisms/evaluation_list_toolbar.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/loading_indicator.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/empty_state.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_button.dart';
import 'package:aljal_evaluation/data/models/evaluation_model.dart';

/// Main evaluation list screen - the home screen of the app
/// Displays all evaluations with search, filter, and actions
class EvaluationListScreen extends ConsumerStatefulWidget {
  const EvaluationListScreen({super.key});

  @override
  ConsumerState<EvaluationListScreen> createState() =>
      _EvaluationListScreenState();
}

class _EvaluationListScreenState extends ConsumerState<EvaluationListScreen> {
  bool _isGridView = false; // Default to list view

  @override
  void initState() {
    super.initState();
    // Load evaluations on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(evaluationListNotifierProvider.notifier)
          .loadEvaluations(refresh: true);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(evaluationListNotifierProvider.notifier).searchByClient(query);
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _onAddNew() {
    Navigator.pushNamed(
      context,
      RouteNames.formStep1,
      arguments: FormStepArguments.forStep(
        step: 1,
        evaluationId: null, // New evaluation
      ),
    );
  }

  void _onEditEvaluation(EvaluationModel evaluation) {
    Navigator.pushNamed(
      context,
      RouteNames.formStep1,
      arguments: FormStepArguments.forStep(
        step: 1,
        evaluationId: evaluation.evaluationId,
      ),
    );
  }

  Future<void> _onDeleteEvaluation(EvaluationModel evaluation) async {
    final confirmed = await UIHelpers.showDeleteConfirmationDialog(context);

    if (confirmed == true) {
      try {
        await ref
            .read(evaluationListNotifierProvider.notifier)
            .deleteEvaluation(evaluation.evaluationId!);

        if (mounted) {
          UIHelpers.showSuccessSnackBar(
            context,
            'تم حذف التقرير بنجاح',
          );
        }
      } catch (e) {
        if (mounted) {
          UIHelpers.showErrorSnackBar(
            context,
            'فشل حذف التقرير: $e',
          );
        }
      }
    }
  }

  Future<void> _onExportEvaluation(EvaluationModel evaluation) async {
    try {
      UIHelpers.showLoadingDialog(
        context,
        message: 'جاري التصدير...',
      );

      // TODO: Implement Word export functionality
      // await ref.read(wordGenerationServiceProvider).generateDocument(evaluation);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        UIHelpers.showSuccessSnackBar(
          context,
          'تم تصدير التقرير بنجاح',
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        UIHelpers.showErrorSnackBar(
          context,
          'فشل تصدير التقرير: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(evaluationListNotifierProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header with logo and title
              _buildHeader(),

              AppSpacing.verticalSpaceMD,

              // Toolbar (Grid/List toggle, Search, Filter)
              Padding(
                padding: AppSpacing.screenPaddingMobileInsets,
                child: EvaluationListToolbar(
                  searchQuery: state.searchQuery,
                  onSearchChanged: _onSearch,
                  onFilterTap: () {
                    // TODO: implement filter bottom sheet using UIHelpers.showCustomBottomSheet
                  },
                  isGridView: _isGridView,
                  onViewToggle: _toggleView,
                  onAddNew: _onAddNew,
                  hasActiveFilters:
                      state.selectedFilter != EvaluationFilter.all ||
                          state.searchQuery.isNotEmpty,
                ),
              ),

              AppSpacing.verticalSpaceMD,

              // Evaluations list or grid
              Expanded(
                child: _buildContent(state),
              ),
            ],
          ),
        ),
        // Floating action button for adding new evaluation
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _onAddNew,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'إنشاء نموذج جديد',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final state = ref.watch(evaluationListNotifierProvider);
    final count = state.evaluations.length;

    return Container(
      padding: AppSpacing.screenPaddingMobileInsets,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Count
          Text(
            'التقارير ($count)',
            style: AppTypography.heading,
            textDirection: TextDirection.rtl,
          ),

          // Right side - Logo
          Image.asset(
            'assets/images/logo.png',
            height: 60,
            width: 60,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if logo doesn't exist
              return Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: AppSpacing.radiusMD,
                ),
                child: const Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 30,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(EvaluationListState state) {
    // Show loading on initial load
    if (state.isLoading && state.evaluations.isEmpty) {
      return const Center(child: LoadingIndicator());
    }

    // Show error if any
    if (state.error != null && state.evaluations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 60,
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              'حدث خطأ: ${state.error}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceMD,
            CustomButton(
              text: 'إعادة المحاولة',
              onPressed: () {
                ref
                    .read(evaluationListNotifierProvider.notifier)
                    .loadEvaluations(refresh: true);
              },
            ),
          ],
        ),
      );
    }

    // Show empty state
    if (state.evaluations.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.description_outlined,
          title: state.searchQuery.isNotEmpty
              ? 'لا توجد نتائج للبحث'
              : 'لا توجد تقارير حتى الآن',
          subtitle:
              state.searchQuery.isNotEmpty ? null : 'ابدأ بإنشاء تقرير جديد',
          action: state.searchQuery.isEmpty
              ? CustomButton(
                  text: 'إنشاء تقرير جديد',
                  onPressed: _onAddNew,
                )
              : null,
        ),
      );
    }

    // Show list or grid
    return EvaluationList(
      evaluations: state.evaluations,
      isGridView: _isGridView,
      isLoading: state.isLoading,
      hasMore: state.hasMore,
      onTap: _onEditEvaluation,
      onEdit: _onEditEvaluation,
      onDelete: _onDeleteEvaluation,
      onExport: _onExportEvaluation,
    );
  }
}
