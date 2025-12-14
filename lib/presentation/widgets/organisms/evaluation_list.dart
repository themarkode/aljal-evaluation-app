import 'package:flutter/material.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
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
  final VoidCallback? onLoadMore;
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
    this.onLoadMore,
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
          return _buildGridView(deviceType);
        } else {
          return _buildListView();
        }
      },
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      controller: scrollController,
      padding: AppSpacing.allMD,
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
        );
      },
    );
  }

  Widget _buildGridView(DeviceType deviceType) {
    int crossAxisCount;
    switch (deviceType) {
      case DeviceType.mobile:
        crossAxisCount = 1;
        break;
      case DeviceType.tablet:
        crossAxisCount = 2;
        break;
      case DeviceType.desktop:
        crossAxisCount = 3;
        break;
    }

    return GridView.builder(
      controller: scrollController,
      padding: AppSpacing.allMD,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.5,
      ),
      itemCount: evaluations.length + (hasMore ? 1 : 0),
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
        );
      },
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
