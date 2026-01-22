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
import 'package:aljal_evaluation/core/constants/app_constants.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_list_provider.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/organisms/evaluation_list.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/loading_indicator.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/empty_state.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_button.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/approval_password_dialog.dart';
import 'package:aljal_evaluation/data/models/evaluation_model.dart';
import 'package:aljal_evaluation/data/services/word_generation_service.dart';
import 'package:aljal_evaluation/presentation/widgets/organisms/app_drawer.dart';

/// Status filter for evaluations
enum StatusFilter { all, completed, draft, approved, deleted }

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
  bool _isSearchExpanded = false;
  bool _isHeaderVisible = true;
  StatusFilter _statusFilter = StatusFilter.all;
  
  // Date range filter
  DateTime? _startDate;
  DateTime? _endDate;

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

    // Start real-time sync for automatic updates across devices
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(evaluationListNotifierProvider.notifier).startRealtimeSync();
    });
  }

  void _onScroll() {
    final currentScroll = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final scrollDelta = currentScroll - _lastScrollPosition;

    // Ignore invalid scroll positions
    if (currentScroll < 0) return;

    // Load more when near the bottom (200 pixels from bottom)
    if (maxScroll > 0 && currentScroll >= maxScroll - 200) {
      _loadMore();
    }

    // Only trigger hide/show after a minimum scroll delta (increased threshold)
    if (scrollDelta.abs() > 20) {
      if (scrollDelta > 0 && _isHeaderVisible && currentScroll > 80) {
        // Scrolling DOWN (finger swipes UP, content moves up) → HIDE header
        setState(() => _isHeaderVisible = false);
        _headerAnimationController.reverse();
      } else if (scrollDelta < 0 && !_isHeaderVisible && currentScroll < maxScroll - 50) {
        // Scrolling UP (finger swipes DOWN, content moves down) → SHOW header
        // Only show if not at the very bottom (to avoid bounce triggering it)
        setState(() => _isHeaderVisible = true);
        _headerAnimationController.forward();
      }
      _lastScrollPosition = currentScroll;
    }
    
    // Always show header when at the very top
    if (currentScroll <= 5 && !_isHeaderVisible) {
      setState(() => _isHeaderVisible = true);
      _headerAnimationController.forward();
      _lastScrollPosition = currentScroll;
    }
  }

  void _loadMore() {
    final state = ref.read(evaluationListNotifierProvider);
    if (state.hasMore && !state.isLoading) {
      ref.read(evaluationListNotifierProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    // Stop real-time sync when leaving the screen
    ref.read(evaluationListNotifierProvider.notifier).stopRealtimeSync();
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
    // If evaluation is approved, open in view-only mode (same form but fields disabled)
    Navigator.pushNamed(
      context,
      RouteNames.formStep1,
      arguments: FormStepArguments.forStep(
        step: 1,
        evaluationId: evaluation.evaluationId,
        isViewOnly: evaluation.status == 'approved',
      ),
    );
  }

  Future<void> _onDeleteEvaluation(EvaluationModel evaluation) async {
    final isAlreadyDeleted = evaluation.status == 'deleted';
    
    if (isAlreadyDeleted) {
      // Second delete - show permanent delete confirmation
      final confirmed = await _showPermanentDeleteDialog();
      
      if (confirmed == true) {
        try {
          await ref
              .read(evaluationListNotifierProvider.notifier)
              .permanentlyDeleteEvaluation(evaluation.evaluationId!);

          if (mounted) {
            UIHelpers.showSuccessSnackBar(context, 'تم حذف التقرير نهائياً');
          }
        } catch (e) {
          if (mounted) {
            UIHelpers.showErrorSnackBar(context, 'فشل حذف التقرير: $e');
          }
        }
      }
    } else {
      // First delete - soft delete (move to deleted section)
      final confirmed = await _showSoftDeleteDialog();
      
      if (confirmed == true) {
        try {
          await ref
              .read(evaluationListNotifierProvider.notifier)
              .softDeleteEvaluation(evaluation.evaluationId!);

          if (mounted) {
            UIHelpers.showSuccessSnackBar(
              context, 
              'تم نقل التقرير إلى المحذوفات',
            );
          }
        } catch (e) {
          if (mounted) {
            UIHelpers.showErrorSnackBar(context, 'فشل حذف التقرير: $e');
          }
        }
      }
    }
  }
  
  /// Show dialog for soft delete (first delete)
  Future<bool?> _showSoftDeleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              const Text('نقل إلى المحذوفات'),
            ],
          ),
          content: const Text(
            'سيتم نقل هذا التقرير إلى قسم المحذوفات.\n\nيمكنك استعادته لاحقاً أو حذفه نهائياً من قسم المحذوفات.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('نقل للمحذوفات'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Show dialog for permanent delete (second delete)
  Future<bool?> _showPermanentDeleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              const Text('تأكيد الحذف النهائي'),
            ],
          ),
          content: const Text(
            'هل أنت متأكد من حذف هذا التقرير نهائياً؟\n\n⚠️ لا يمكن التراجع عن هذا الإجراء!',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('حذف نهائياً'),
            ),
          ],
        ),
      ),
    );
  }

  /// Restore a soft-deleted evaluation back to draft status
  Future<void> _onRestoreEvaluation(EvaluationModel evaluation) async {
    try {
      await ref
          .read(evaluationListNotifierProvider.notifier)
          .restoreEvaluation(evaluation.evaluationId!);

      if (mounted) {
        UIHelpers.showSuccessSnackBar(
          context, 
          'تم استعادة التقرير بنجاح',
        );
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.showErrorSnackBar(context, 'فشل استعادة التقرير: $e');
      }
    }
  }

  /// Approve an evaluation - requires password
  Future<void> _onApproveEvaluation(EvaluationModel evaluation) async {
    final confirmed = await ApprovalPasswordDialog.show(
      context,
      title: AppConstants.approveDialogTitle,
      message: AppConstants.approveDialogMessage,
      confirmButtonText: AppConstants.menuApprove,
      correctPassword: AppConstants.approvalPassword,
    );

    if (confirmed) {
      try {
        await ref
            .read(evaluationListNotifierProvider.notifier)
            .approveEvaluation(evaluation.evaluationId!);

        if (mounted) {
          UIHelpers.showSuccessSnackBar(context, 'تم اعتماد التقرير بنجاح');
        }
      } catch (e) {
        if (mounted) {
          UIHelpers.showErrorSnackBar(context, 'فشل اعتماد التقرير: $e');
        }
      }
    }
  }

  /// Unapprove an evaluation - requires password
  Future<void> _onUnapproveEvaluation(EvaluationModel evaluation) async {
    final confirmed = await ApprovalPasswordDialog.show(
      context,
      title: AppConstants.unapproveDialogTitle,
      message: AppConstants.unapproveDialogMessage,
      confirmButtonText: AppConstants.menuUnapprove,
      correctPassword: AppConstants.unapprovalPassword,
    );

    if (confirmed) {
      try {
        await ref
            .read(evaluationListNotifierProvider.notifier)
            .unapproveEvaluation(evaluation.evaluationId!);

        if (mounted) {
          UIHelpers.showSuccessSnackBar(context, 'تم إلغاء اعتماد التقرير بنجاح');
        }
      } catch (e) {
        if (mounted) {
          UIHelpers.showErrorSnackBar(context, 'فشل إلغاء اعتماد التقرير: $e');
        }
      }
    }
  }

  /// Show filter bottom sheet for date range selection
  void _showFilterBottomSheet() {
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 
                     MediaQuery.of(context).viewPadding.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تصفية حسب التاريخ',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Start Date
                Text(
                  'من تاريخ',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDateSelector(
                  date: tempStartDate,
                  hint: 'اختر تاريخ البداية',
                  onTap: () async {
                    // Use centralized date picker from UIHelpers
                    final picked = await UIHelpers.showDatePickerDialog(
                      context,
                      initialDate: tempStartDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setModalState(() => tempStartDate = picked);
                    }
                  },
                  onClear: () => setModalState(() => tempStartDate = null),
                ),
                const SizedBox(height: 16),
                
                // End Date
                Text(
                  'إلى تاريخ',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDateSelector(
                  date: tempEndDate,
                  hint: 'اختر تاريخ النهاية',
                  onTap: () async {
                    // Use centralized date picker from UIHelpers
                    final picked = await UIHelpers.showDatePickerDialog(
                      context,
                      initialDate: tempEndDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setModalState(() => tempEndDate = picked);
                    }
                  },
                  onClear: () => setModalState(() => tempEndDate = null),
                ),
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    // Clear filter button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                          });
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.textSecondary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'مسح الفلتر',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Apply filter button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _startDate = tempStartDate;
                            _endDate = tempEndDate;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('تطبيق'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build date selector widget
  Widget _buildDateSelector({
    required DateTime? date,
    required String hint,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final formattedDate = date != null
        ? '${date.day}/${date.month}/${date.year}'
        : null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null ? AppColors.primary : AppColors.border,
            width: date != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: date != null ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                formattedDate ?? hint,
                style: AppTypography.bodyMedium.copyWith(
                  color: date != null ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await ref
        .read(evaluationListNotifierProvider.notifier)
        .loadEvaluations(refresh: true);
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
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewPadding.bottom + 24,
        ),
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

  List<EvaluationModel> _getFilteredEvaluations(
      List<EvaluationModel> evaluations) {
    // First filter by status
    List<EvaluationModel> filtered;
    switch (_statusFilter) {
      case StatusFilter.completed:
        filtered = evaluations.where((e) => e.status == 'completed').toList();
        break;
      case StatusFilter.draft:
        filtered = evaluations
            .where((e) => e.status == 'draft' || e.status == null)
            .toList();
        break;
      case StatusFilter.approved:
        filtered = evaluations.where((e) => e.status == 'approved').toList();
        break;
      case StatusFilter.deleted:
        filtered = evaluations.where((e) => e.status == 'deleted').toList();
        break;
      case StatusFilter.all:
        filtered = evaluations;
        break;
    }
    
    // Then filter by date range
    if (_startDate != null || _endDate != null) {
      filtered = filtered.where((e) {
        final evalDate = e.createdAt;
        if (evalDate == null) return false;
        
        // Check start date
        if (_startDate != null) {
          final startOfDay = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
          if (evalDate.isBefore(startOfDay)) return false;
        }
        
        // Check end date
        if (_endDate != null) {
          final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
          if (evalDate.isAfter(endOfDay)) return false;
        }
        
        return true;
      }).toList();
    }
    
    return filtered;
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
        drawer: const AppDrawer(),
        floatingActionButton: _buildFAB(isMobile: isMobile),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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

  /// Floating Action Button for adding new form
  /// Mobile: Just "+" icon
  /// Tablet: "+" with text "إضافة تقرير جديد"
  Widget _buildFAB({required bool isMobile}) {
    if (isMobile) {
      return FloatingActionButton(
        onPressed: _onAddNew,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        child: const Icon(Icons.add_rounded, size: 28),
      );
    } else {
      return FloatingActionButton.extended(
        onPressed: _onAddNew,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: Text(
          'إضافة تقرير جديد',
          style: AppTypography.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
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
          // Row 1: Logo (right) + Title (center) + Menu (left)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo (right side in RTL) - Tap to refresh
              GestureDetector(
                onTap: _onRefresh,
                child: Image.asset(
                  'assets/images/Al_Jal_Logo.png',
                  width: 50,
                  height: 50,
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
              // Title (center)
              Column(
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
              // Menu button (left side in RTL)
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      color: AppColors.navy,
                      size: 26,
                    ),
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
      child:
          _isSearchExpanded ? _buildExpandedSearch() : _buildCollapsedToolbar(),
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

        // Grid view button
        _buildIconButton(
          icon: Icons.grid_view_rounded,
          isActive: ref.watch(isGridViewProvider),
          onTap: () => ref.read(isGridViewProvider.notifier).state = true,
        ),

        const SizedBox(width: 6),

        // List view button
        _buildIconButton(
          icon: Icons.view_list_rounded,
          isActive: !ref.watch(isGridViewProvider),
          onTap: () => ref.read(isGridViewProvider.notifier).state = false,
        ),

        const SizedBox(width: 6),

        // Filter button
        _buildIconButton(
          icon: Icons.tune_rounded,
          isActive: _startDate != null || _endDate != null,
          onTap: _showFilterBottomSheet,
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
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date filter indicator (when active)
        if (_startDate != null || _endDate != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDateFilterChip(),
          ),
        // Status chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
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
                label: 'معتمدة',
                filter: StatusFilter.approved,
                color: Colors.black,
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
          ),
        ),
      ],
    );
  }
  
  /// Build date filter chip showing active filter
  Widget _buildDateFilterChip() {
    String text = '';
    if (_startDate != null && _endDate != null) {
      text = 'من ${_startDate!.day}/${_startDate!.month}/${_startDate!.year} إلى ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';
    } else if (_startDate != null) {
      text = 'من ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}';
    } else if (_endDate != null) {
      text = 'حتى ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.date_range_rounded,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
            },
            child: Icon(
              Icons.close_rounded,
              color: AppColors.primary,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required StatusFilter filter,
    Color? color,
  }) {
    final isActive = _statusFilter == filter;

    return GestureDetector(
      onTap: () => setState(() => _statusFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive
              ? (color ?? AppColors.primary).withOpacity(0.15)
              : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? (color ?? AppColors.primary) : AppColors.border,
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
    );
  }

  /// Tablet/Desktop Header Layout - Consistent with Mobile
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
          // Row 1: Logo (right) + Title (center) + Menu (left) - Same as mobile
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo (right side in RTL) - Tap to refresh
              GestureDetector(
                onTap: _onRefresh,
                child: Image.asset(
                  'assets/images/Al_Jal_Logo.png',
                  width: 60,
                  height: 60,
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
              // Title (center)
              Column(
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
              // Menu button (left side in RTL)
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      color: AppColors.navy,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Row 2: Search + View toggles + Filter
          Row(
            children: [
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
                      Icon(Icons.search,
                          color: AppColors.textSecondary, size: 22),
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
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
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
                isActive: ref.watch(isGridViewProvider),
                onTap: () => ref.read(isGridViewProvider.notifier).state = true,
              ),

              const SizedBox(width: 8),

              // List view
              _buildIconButton(
                icon: Icons.view_list_rounded,
                isActive: !ref.watch(isGridViewProvider),
                onTap: () => ref.read(isGridViewProvider.notifier).state = false,
              ),

              const SizedBox(width: 8),

              // Filter
              _buildIconButton(
                icon: Icons.tune_rounded,
                isActive: _startDate != null || _endDate != null,
                onTap: _showFilterBottomSheet,
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

      // Wrap in SingleChildScrollView to prevent overflow when keyboard is open
      return SingleChildScrollView(
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
      isGridView: ref.watch(isGridViewProvider),
      isLoading: state.isLoading,
      hasMore: state.hasMore,
      onTap: _onEditEvaluation,
      onEdit: _onEditEvaluation,
      onDelete: _onDeleteEvaluation,
      onExport: _onExportEvaluation,
      onRestore: _onRestoreEvaluation,
      onApprove: _onApproveEvaluation,
      onUnapprove: _onUnapproveEvaluation,
      onRefresh: _onRefresh,
      scrollController: _scrollController,
    );
  }

  String _getStatusLabel(StatusFilter filter) {
    switch (filter) {
      case StatusFilter.completed:
        return 'مكتملة';
      case StatusFilter.draft:
        return 'مسودة';
      case StatusFilter.approved:
        return 'معتمدة';
      case StatusFilter.deleted:
        return 'محذوفة';
      case StatusFilter.all:
        return '';
    }
  }
}
