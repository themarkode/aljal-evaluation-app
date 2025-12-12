import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/routing/route_names.dart';
import 'package:aljal_evaluation/core/routing/route_arguments.dart';
import 'package:aljal_evaluation/core/utils/ui_helpers.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_list_provider.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/organisms/evaluation_list.dart';
import 'package:aljal_evaluation/presentation/widgets/organisms/evaluation_list_toolbar.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/loading_indicator.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/empty_state.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_button.dart';
import 'package:aljal_evaluation/data/models/evaluation_model.dart';
import 'package:aljal_evaluation/data/services/word_generation_service.dart';

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
    // Reset the provider state to clear any previously loaded evaluation data
    ref.read(evaluationNotifierProvider.notifier).resetEvaluation();
    
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
    print('🖊️ Edit clicked:');
    print('   - evaluationId: ${evaluation.evaluationId}');
    print('   - has generalInfo: ${evaluation.generalInfo != null}');
    if (evaluation.generalInfo != null) {
      print('   - clientName: ${evaluation.generalInfo?.clientName}');
    }
    
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
        message: 'جاري إنشاء مستند Word...',
      );

      // Generate Word document
      final wordService = WordGenerationService();
      final file = await wordService.generateWordDocument(evaluation);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Show bottom sheet with options
        _showDocumentOptionsSheet(file);
      }
    } catch (e) {
      print('❌ Export error: $e');
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        UIHelpers.showErrorSnackBar(
          context,
          'فشل إنشاء المستند: $e',
        );
      }
    }
  }

  void _showDocumentOptionsSheet(File file) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'تم إنشاء المستند بنجاح!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              file.path.split('/').last,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        await Share.shareXFiles(
                          [XFile(file.path)],
                          text: 'تقرير التقييم العقاري',
                        );
                      } catch (e) {
                        if (mounted) {
                          UIHelpers.showErrorSnackBar(
                            context,
                            'فشل مشاركة الملف: $e',
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        await OpenFile.open(file.path);
                      } catch (e) {
                        if (mounted) {
                          UIHelpers.showErrorSnackBar(
                            context,
                            'فشل فتح الملف: $e',
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('فتح'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
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
        // Beautiful floating action button
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _onAddNew,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'إنشاء نموذج جديد',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Logo container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.gold.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Image.asset(
                'assets/images/Al_Jal_Logo.png',
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.business_rounded,
                    color: AppColors.gold,
                    size: 32,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Title and count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الجال للتقييم العقاري',
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count تقرير',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.navyDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'التقارير المحفوظة',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
