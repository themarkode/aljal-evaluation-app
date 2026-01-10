import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/data/models/evaluation_model.dart';
import 'package:aljal_evaluation/presentation/shared/responsive/responsive_builder.dart';
import '../molecules/evaluation_card.dart';
import '../atoms/loading_indicator.dart';
import '../atoms/empty_state.dart';

/// Evaluation list organism - displays evaluations in list or grid view
class EvaluationList extends StatelessWidget {
  final List<EvaluationModel> evaluations;
  final bool isLoading;
  final bool isGridView;
  final void Function(EvaluationModel)? onTap;
  final void Function(EvaluationModel)? onEdit;
  final void Function(EvaluationModel)? onDelete;
  final void Function(EvaluationModel)? onExport;
  final void Function(EvaluationModel)? onRestore;
  final VoidCallback? onLoadMore;
  final Future<void> Function()? onRefresh;
  final bool hasMore;
  final ScrollController? scrollController;

  const EvaluationList({
    super.key,
    required this.evaluations,
    this.isLoading = false,
    this.isGridView = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onExport,
    this.onRestore,
    this.onLoadMore,
    this.onRefresh,
    this.hasMore = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (isLoading && evaluations.isEmpty) {
      return const Center(
        child: LoadingIndicator(),
      );
    }

    // Empty state
    if (evaluations.isEmpty) {
      return EmptyState(
        icon: Icons.description_outlined,
        title: 'لا توجد تقارير',
        subtitle: 'ابدأ بإنشاء تقرير جديد',
      );
    }

    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (isGridView) {
          // Grid icon selected → shows card-based layout
          return _buildCardView();
        } else {
          // List icon selected → shows table-like rows
          return _buildTableView();
        }
      },
    );
  }

  // Bottom padding to allow content to be visible above FAB
  static const double _fabOverscrollPadding = 100.0;

  Widget _buildCardView() {
    final listView = ListView.separated(
      controller: scrollController,
      // BouncingScrollPhysics allows overscroll at top AND bottom
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      // Add bottom padding so last items can be scrolled above the FAB
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: _fabOverscrollPadding, // Extra space for FAB
      ),
      itemCount: evaluations.length + (hasMore ? 1 : 0),
      separatorBuilder: (context, index) => AppSpacing.verticalSpaceSM,
      itemBuilder: (context, index) {
        // Load more indicator
        if (index >= evaluations.length) {
          return _buildLoadMoreIndicator();
        }

        final evaluation = evaluations[index];
        return EvaluationCard(
          evaluation: evaluation,
          onTap: () => onTap?.call(evaluation),
          onEdit: () => onEdit?.call(evaluation),
          onDelete: () => onDelete?.call(evaluation),
          onExport: () => onExport?.call(evaluation),
          onRestore: () => onRestore?.call(evaluation),
        );
      },
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        color: AppColors.primary,
        backgroundColor: AppColors.white,
        strokeWidth: 2.5,
        displacement: 50,
        edgeOffset: 0,
        child: listView,
      );
    }
    return listView;
  }

  // Column widths for table
  static const double _colNumberWidth = 48;
  static const double _colClientWidth = 120;
  static const double _colLocationWidth = 140;
  static const double _colDateWidth = 100;
  static const double _colOptionsWidth = 50;
  static const double _tableMinWidth = _colNumberWidth + _colClientWidth + _colLocationWidth + _colDateWidth + _colOptionsWidth;

  /// Table-like view with headers and rows
  Widget _buildTableView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use screen width or minimum table width, whichever is larger
        final tableWidth = constraints.maxWidth > _tableMinWidth 
            ? constraints.maxWidth 
            : _tableMinWidth;

        final tableContent = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Column(
              children: [
                // Table Header
                _buildTableHeader(tableWidth),
                // Divider
                Divider(height: 1, color: AppColors.border),
                // Table Rows
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    // BouncingScrollPhysics allows overscroll at top AND bottom
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    // Add bottom padding so last items can be scrolled above the FAB
                    padding: EdgeInsets.only(bottom: _fabOverscrollPadding),
                    itemCount: evaluations.length + (hasMore ? 1 : 0),
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: AppColors.border.withOpacity(0.5),
                    ),
                    itemBuilder: (context, index) {
                      if (index >= evaluations.length) {
                        return _buildLoadMoreIndicator();
                      }
                      return _buildTableRow(index, evaluations[index], tableWidth);
                    },
                  ),
                ),
              ],
            ),
          ),
        );

        if (onRefresh != null) {
          return RefreshIndicator(
            onRefresh: onRefresh!,
            color: AppColors.primary,
            backgroundColor: AppColors.white,
            strokeWidth: 2.5,
            displacement: 50,
            edgeOffset: 0,
            child: tableContent,
          );
        }
        return tableContent;
      },
    );
  }

  Widget _buildTableHeader(double tableWidth) {
    return Container(
      width: tableWidth,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
      ),
      child: Row(
        children: [
          // Row number (integrated with status)
          SizedBox(
            width: _colNumberWidth,
            child: Text(
              '#',
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Client name
          Expanded(
            flex: 3,
            child: Text(
              'العميل',
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Area / Plot / Parcel
          Expanded(
            flex: 3,
            child: Text(
              'م / ق / س',
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Date
          Expanded(
            flex: 2,
            child: Text(
              'التاريخ',
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Options (empty header)
          SizedBox(
            width: _colOptionsWidth,
            child: Text(
              '',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(int index, EvaluationModel evaluation, double tableWidth) {
    // Get data from evaluation
    final clientName = evaluation.generalInfo?.clientName ?? 'بدون اسم';
    final area = evaluation.generalPropertyInfo?.area ?? '';
    final plotNumber = evaluation.generalPropertyInfo?.plotNumber ?? '';
    final parcelNumber = evaluation.generalPropertyInfo?.parcelNumber ?? '';
    final locationText = area.isNotEmpty || plotNumber.isNotEmpty || parcelNumber.isNotEmpty
        ? '${area.isNotEmpty ? area : '-'} / ${plotNumber.isNotEmpty ? plotNumber : '-'} / ${parcelNumber.isNotEmpty ? parcelNumber : '-'}'
        : 'غير محدد';
    final date = evaluation.createdAt != null
        ? DateFormat('dd/MM/yyyy').format(evaluation.createdAt!)
        : '-';
    final status = evaluation.status ?? 'draft';

    return InkWell(
      onTap: () => onTap?.call(evaluation),
      child: Container(
        width: tableWidth,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            // Row number with integrated status badge
            SizedBox(
              width: _colNumberWidth,
              child: Center(
                child: _buildStatusBadge(index + 1, status),
              ),
            ),
            // Client name
            Expanded(
              flex: 3,
              child: Text(
                clientName,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Governorate + Plot
            Expanded(
              flex: 3,
              child: Text(
                locationText,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Date
            Expanded(
              flex: 2,
              child: Text(
                date,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Options menu (three dots)
            SizedBox(
              width: _colOptionsWidth,
              child: Center(
                child: _buildOptionsMenu(evaluation),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsMenu(EvaluationModel evaluation) {
    final isDeleted = evaluation.status == 'deleted';
    
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call(evaluation);
            break;
          case 'export':
            onExport?.call(evaluation);
            break;
          case 'delete':
            onDelete?.call(evaluation);
            break;
          case 'restore':
            onRestore?.call(evaluation);
            break;
        }
      },
      padding: EdgeInsets.zero,
      icon: Icon(
        Icons.more_vert_rounded,
        size: 20,
        color: AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      itemBuilder: (context) => [
        // Show restore option for deleted items
        if (isDeleted)
          PopupMenuItem<String>(
            value: 'restore',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restore_rounded,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                Text(
                  'استعادة',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        // Edit option (not for deleted items)
        if (!isDeleted)
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: Colors.black,
                ),
                const SizedBox(width: 12),
                Text(
                  'تعديل',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'export',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_rounded,
                size: 18,
                color: const Color(0xFF2B579A), // Word blue
              ),
              const SizedBox(width: 12),
              Text(
                'Word',
                style: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFF2B579A),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDeleted ? Icons.delete_forever_rounded : Icons.delete_rounded,
                size: 18,
                color: AppColors.error,
              ),
              const SizedBox(width: 12),
              Text(
                isDeleted ? 'حذف نهائي' : 'حذف',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a colored badge with the row number inside
  /// Colors: Green = completed, Yellow/Amber = draft, Red = deleted
  Widget _buildStatusBadge(int rowNumber, String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = const Color(0xFF22C55E); // Modern green
        textColor = Colors.white;
        break;
      case 'draft':
        backgroundColor = const Color(0xFFFBBF24); // Warm amber/yellow
        textColor = const Color(0xFF78350F); // Dark amber for contrast
        break;
      case 'deleted':
        backgroundColor = const Color(0xFFEF4444); // Modern red
        textColor = Colors.white;
        break;
      default:
        backgroundColor = AppColors.midGray;
        textColor = AppColors.textPrimary;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$rowNumber',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Center(
      child: Padding(
        padding: AppSpacing.allMD,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LoadingIndicator.small(),
            AppSpacing.verticalSpaceXS,
            const Text('جاري تحميل المزيد...'),
          ],
        ),
      ),
    );
  }
}
