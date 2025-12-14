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
import 'package:aljal_evaluation/presentation/widgets/atoms/loading_indicator.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/empty_state.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_button.dart';
import 'package:aljal_evaluation/data/models/evaluation_model.dart';
import 'package:aljal_evaluation/data/services/word_generation_service.dart';

/// Status filter for evaluations
enum StatusFilter { all, completed, draft, deleted }

/// Main evaluation list screen - the home screen of the app
/// Displays all evaluations with search, filter, and actions
class EvaluationListScreen extends ConsumerStatefulWidget {
  const EvaluationListScreen({super.key});

  @override
  ConsumerState<EvaluationListScreen> createState() =>
      _EvaluationListScreenState();
}

class _EvaluationListScreenState extends ConsumerState<EvaluationListScreen>
    with SingleTickerProviderStateMixin {
  bool _isGridView = false;
  bool _isSearchExpanded = false;
  bool _isHeaderVisible = true;
  StatusFilter _statusFilter = StatusFilter.all;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  double _lastScrollPosition = 0;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();

    // Header animation controller
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _headerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _headerAnimationController.value = 1; // Start visible

    // Scroll listener for hiding/showing header
    _scrollController.addListener(_onScroll);

    // Search focus listener
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
        setState(() => _isSearchExpanded = false);
      }
    });

    // Load evaluations on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(evaluationListNotifierProvider.notifier)
          .loadEvaluations(refresh: true);
    });
  }

  void _onScroll() {
    final currentScroll = _scrollController.offset;
    final scrollDelta = currentScroll - _lastScrollPosition;

    // Only trigger hide/show after a minimum scroll delta
    if (scrollDelta.abs() > 10) {
      if (scrollDelta > 0 && _isHeaderVisible && currentScroll > 50) {
        // Scrolling down - hide header
        setState(() => _isHeaderVisible = false);
        _headerAnimationController.reverse();
      } else if (scrollDelta < 0 && !_isHeaderVisible) {
        // Scrolling up - show header
        setState(() => _isHeaderVisible = true);
        _headerAnimationController.forward();
      }
      _lastScrollPosition = currentScroll;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(evaluationListNotifierProvider.notifier).searchByClient(query);
  }

  void _onAddNew() {
    ref.read(evaluationNotifierProvider.notifier).resetEvaluation();
    Navigator.pushNamed(
      context,
      RouteNames.formStep1,
      arguments: FormStepArguments.forStep(
        step: 1,
        evaluationId: null,
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
          UIHelpers.showSuccessSnackBar(context, 'تم حذف التقرير بنجاح');
        }
      } catch (e) {
        if (mounted) {
          UIHelpers.showErrorSnackBar(context, 'فشل حذف التقرير: $e');
        }
      }
    }
  }

  Future<void> _onExportEvaluation(EvaluationModel evaluation) async {
    try {
      UIHelpers.showLoadingDialog(context, message: 'جاري إنشاء مستند Word...');

      final wordService = WordGenerationService();
      final file = await wordService.generateWordDocument(evaluation);

      if (mounted) {
        Navigator.pop(context);
        _showDocumentOptionsSheet(file);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        UIHelpers.showErrorSnackBar(context, 'فشل إنشاء المستند: $e');
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
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'تم إنشاء المستند بنجاح!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              file.path.split('/').last,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                              context, 'فشل مشاركة الملف: $e');
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
                              context, 'فشل فتح الملف: $e');
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

  List<EvaluationModel> _getFilteredEvaluations(List<EvaluationModel> evaluations) {
    switch (_statusFilter) {
      case StatusFilter.completed:
        return evaluations.where((e) => e.status == 'completed').toList();
      case StatusFilter.draft:
        return evaluations.where((e) => e.status == 'draft' || e.status == null).toList();
      case StatusFilter.deleted:
        return evaluations.where((e) => e.status == 'deleted').toList();
      case StatusFilter.all:
        return evaluations;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(evaluationListNotifierProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Animated Header
              AnimatedBuilder(
                animation: _headerAnimation,
                builder: (context, child) {
                  return ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: _headerAnimation.value,
                      child: Opacity(
                        opacity: _headerAnimation.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: isMobile
                    ? _buildMobileHeader(state)
                    : _buildTabletHeader(state),
              ),

              // Evaluations list or grid
              Expanded(
                child: _buildContent(state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mobile Header Layout
  Widget _buildMobileHeader(EvaluationListState state) {
    final count = state.evaluations.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Logo (right) + Plus button & Title (left)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Plus button + Title
              Row(
                children: [
                  // Plus button
                  GestureDetector(
                    onTap: _onAddNew,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التقارير',
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$count تقرير محفوظ',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Logo
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.asset(
                    'assets/images/Al_Jal_Logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.business_rounded,
                        color: AppColors.primary,
                        size: 28,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 2: Search + View toggles + Filter
          _buildMobileToolbar(),

          const SizedBox(height: 12),

          // Row 3: Status filter buttons
          _buildStatusFilters(),
        ],
      ),
    );
  }

  /// Mobile Toolbar with animated search
  Widget _buildMobileToolbar() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _isSearchExpanded
          ? _buildExpandedSearch()
          : _buildCollapsedToolbar(),
    );
  }

  Widget _buildCollapsedToolbar() {
    return Row(
      children: [
        // Search button (compact)
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _isSearchExpanded = true);
              Future.delayed(const Duration(milliseconds: 100), () {
                _searchFocusNode.requestFocus();
              });
            },
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.textSecondary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'بحث...',
            style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // List view button
        _buildIconButton(
          icon: Icons.view_list_rounded,
          isActive: !_isGridView,
          onTap: () => setState(() => _isGridView = false),
        ),

        const SizedBox(width: 6),

        // Grid view button
        _buildIconButton(
          icon: Icons.grid_view_rounded,
          isActive: _isGridView,
          onTap: () => setState(() => _isGridView = true),
        ),

        const SizedBox(width: 6),

        // Filter button
        _buildIconButton(
          icon: Icons.tune_rounded,
          isActive: false,
          onTap: () {
            // TODO: Implement filter bottom sheet
          },
        ),
      ],
    );
  }

  Widget _buildExpandedSearch() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearch,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'ابحث عن تقرير...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // Close button
          GestureDetector(
            onTap: () {
              _searchController.clear();
              _onSearch('');
              setState(() => _isSearchExpanded = false);
              _searchFocusNode.unfocus();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : AppColors.textSecondary,
          size: 22,
        ),
      ),
    );
  }

  /// Status filter buttons
  Widget _buildStatusFilters() {
    return Row(
      children: [
        _buildStatusChip(
          label: 'الكل',
          filter: StatusFilter.all,
        ),
        const SizedBox(width: 8),
        _buildStatusChip(
          label: 'مكتملة',
          filter: StatusFilter.completed,
          color: AppColors.success,
        ),
        const SizedBox(width: 8),
        _buildStatusChip(
          label: 'مسودة',
          filter: StatusFilter.draft,
          color: AppColors.warning,
        ),
        const SizedBox(width: 8),
        _buildStatusChip(
          label: 'محذوفة',
          filter: StatusFilter.deleted,
          color: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildStatusChip({
    required String label,
    required StatusFilter filter,
    Color? color,
  }) {
    final isActive = _statusFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _statusFilter = filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? (color ?? AppColors.primary).withOpacity(0.15)
                : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? (color ?? AppColors.primary)
                  : AppColors.border,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isActive
                    ? (color ?? AppColors.primary)
                    : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Tablet/Desktop Header Layout
  Widget _buildTabletHeader(EvaluationListState state) {
    final count = state.evaluations.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Create button (left) + Logo (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Create new button
              GestureDetector(
                onTap: _onAddNew,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
          Text(
                        'انشئ نموذج جديد',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Logo
              Container(
            width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.asset(
                    'assets/images/Al_Jal_Logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.business_rounded,
                        color: AppColors.primary,
                        size: 32,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Row 2: Reports count + Search + View toggles + Filter
          Row(
            children: [
              // Reports count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(
                      'التقارير',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$count',
                        style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Search
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: AppColors.textSecondary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearch,
                          style: AppTypography.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'بحث...',
                            hintStyle: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Grid view
              _buildIconButton(
                icon: Icons.grid_view_rounded,
                isActive: _isGridView,
                onTap: () => setState(() => _isGridView = true),
              ),

              const SizedBox(width: 8),

              // List view
              _buildIconButton(
                icon: Icons.view_list_rounded,
                isActive: !_isGridView,
                onTap: () => setState(() => _isGridView = false),
              ),

              const SizedBox(width: 8),

              // Filter
              _buildIconButton(
                icon: Icons.tune_rounded,
                isActive: false,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 3: Status filters
          _buildStatusFilters(),
        ],
      ),
    );
  }

  Widget _buildContent(EvaluationListState state) {
    // Filter evaluations by status
    final filteredEvaluations = _getFilteredEvaluations(state.evaluations);

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
            const Icon(Icons.error_outline, color: AppColors.error, size: 60),
            AppSpacing.verticalSpaceMD,
            Text(
              'حدث خطأ: ${state.error}',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
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
    if (filteredEvaluations.isEmpty) {
      String emptyTitle;
      String? emptySubtitle;

      if (state.searchQuery.isNotEmpty) {
        emptyTitle = 'لا توجد نتائج للبحث';
      } else if (_statusFilter != StatusFilter.all) {
        emptyTitle = 'لا توجد تقارير ${_getStatusLabel(_statusFilter)}';
      } else {
        emptyTitle = 'لا توجد تقارير حتى الآن';
        emptySubtitle = 'ابدأ بإنشاء تقرير جديد';
      }

      return Center(
        child: EmptyState(
          icon: Icons.description_outlined,
          title: emptyTitle,
          subtitle: emptySubtitle,
          action: state.searchQuery.isEmpty && _statusFilter == StatusFilter.all
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
      evaluations: filteredEvaluations,
      isGridView: _isGridView,
      isLoading: state.isLoading,
      hasMore: state.hasMore,
      onTap: _onEditEvaluation,
      onEdit: _onEditEvaluation,
      onDelete: _onDeleteEvaluation,
      onExport: _onExportEvaluation,
      scrollController: _scrollController,
    );
  }

  String _getStatusLabel(StatusFilter filter) {
    switch (filter) {
      case StatusFilter.completed:
        return 'مكتملة';
      case StatusFilter.draft:
        return 'مسودة';
      case StatusFilter.deleted:
        return 'محذوفة';
      case StatusFilter.all:
        return '';
    }
  }
}
