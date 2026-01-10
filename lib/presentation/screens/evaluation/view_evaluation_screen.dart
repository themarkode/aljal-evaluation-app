import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/routing/route_names.dart';
import 'package:aljal_evaluation/core/routing/route_arguments.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/collapsible_section.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/loading_indicator.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/empty_state.dart';

/// View-only screen for displaying evaluation details
/// This screen shows all evaluation data in read-only mode
class ViewEvaluationScreen extends ConsumerStatefulWidget {
  final String? evaluationId;

  const ViewEvaluationScreen({
    super.key,
    this.evaluationId,
  });

  @override
  ConsumerState<ViewEvaluationScreen> createState() =>
      _ViewEvaluationScreenState();
}

class _ViewEvaluationScreenState extends ConsumerState<ViewEvaluationScreen> {
  @override
  void initState() {
    super.initState();
    // Load evaluation data if ID is provided
    if (widget.evaluationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await ref
              .read(evaluationNotifierProvider.notifier)
              .loadEvaluation(widget.evaluationId!);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فشل تحميل البيانات: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final evaluation = ref.watch(evaluationNotifierProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'عرض التقييم',
                style: AppTypography.heading,
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.evaluationList,
                  (route) => false,
                ),
                child: Image.asset(
                  'assets/images/Al_Jal_Logo.png',
                  height: 40,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.business, size: 40);
                  },
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () {
                // Navigate to edit mode
                Navigator.pushReplacementNamed(
                  context,
                  RouteNames.editEvaluation,
                  arguments: EvaluationArguments(
                    evaluationId: widget.evaluationId,
                  ),
                );
              },
              tooltip: 'تعديل',
            ),
          ],
        ),
        body: SafeArea(
          child: evaluation.generalInfo == null
              ? const Center(
                  child: LoadingIndicator(),
                )
              : SingleChildScrollView(
                  padding: AppSpacing.screenPaddingMobileInsets,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step 1: General Info
                      if (evaluation.generalInfo != null)
                        CollapsibleSection(
                          title: 'معلومات عامة',
                          initiallyExpanded: true,
                          child: _buildGeneralInfoSection(evaluation),
                        ),
                      AppSpacing.verticalSpaceMD,

                      // Step 2: General Property Info
                      if (evaluation.generalPropertyInfo != null)
                        CollapsibleSection(
                          title: 'معلومات عامة للعقار',
                          initiallyExpanded: false,
                          child: _buildGeneralPropertyInfoSection(evaluation),
                        ),
                      AppSpacing.verticalSpaceMD,

                      // Step 3: Property Description
                      if (evaluation.propertyDescription != null)
                        CollapsibleSection(
                          title: 'وصف العقار',
                          initiallyExpanded: false,
                          child: _buildPropertyDescriptionSection(evaluation),
                        ),
                      AppSpacing.verticalSpaceMD,

                      // Step 4: Floors
                      if (evaluation.floors != null &&
                          evaluation.floors!.isNotEmpty)
                        CollapsibleSection(
                          title:
                              'الأدوار (${evaluation.floorsCount ?? evaluation.floors!.length})',
                          initiallyExpanded: false,
                          child: _buildFloorsSection(evaluation),
                        ),
                      AppSpacing.verticalSpaceMD,

                      // Step 5: Area Details
                      if (evaluation.areaDetails != null)
                        CollapsibleSection(
                          title: 'تفاصيل المنطقة المحيطه بالعقار',
                          initiallyExpanded: false,
                          child: _buildAreaDetailsSection(evaluation),
                        ),
                      AppSpacing.verticalSpaceMD,

                      // Step 6: Income Notes
                      if (evaluation.incomeNotes != null)
                        CollapsibleSection(
                          title: 'ملاحظات الدخل',
                          initiallyExpanded: false,
                          child: _buildIncomeNotesSection(evaluation),
                        ),
                      AppSpacing.verticalSpaceMD,

                      // Step 7: Site Plans
                      if (evaluation.sitePlans != null)
                        CollapsibleSection(
                          title: 'المخطط ورفع القياس بالموقع',
                          initiallyExpanded: false,
                          child: _buildSitePlansSection(evaluation),
                        ),
                      AppSpacing.verticalSpaceMD,

                      // Step 8: Property Images
                      if (evaluation.propertyImages != null)
                        CollapsibleSection(
                          title: 'صور وموقع العقار',
                          initiallyExpanded: false,
                          child: _buildPropertyImagesSection(evaluation),
                        ),
                      AppSpacing.verticalSpaceMD,

                      // Step 9: Additional Data
                      if (evaluation.additionalData != null)
                        CollapsibleSection(
                          title: 'بيانات إضافية',
                          initiallyExpanded: false,
                          child: _buildAdditionalDataSection(evaluation),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildGeneralInfoSection(evaluation) {
    final info = evaluation.generalInfo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('اسم الجهة الطالبة للتقييم', info?.requestorName),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('العميل', info?.clientName),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('المالك', info?.ownerName),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('رقم العميل', info?.clientPhone),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('رقم حارس العقار', info?.guardPhone),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('رقم مسؤول الموقع', info?.siteManagerPhone),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('تاريخ طلب التقييم', info?.requestDate?.toString()),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('تاريخ إصدار التقييم', info?.issueDate?.toString()),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('تاريخ الكشف', info?.inspectionDate?.toString()),
      ],
    );
  }

  Widget _buildGeneralPropertyInfoSection(evaluation) {
    final info = evaluation.generalPropertyInfo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('المحافظة', info?.governorate),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('المنطقة', info?.area),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('رقم القطعة', info?.plotNumber),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('رقم القسيمة', info?.parcelNumber),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('نوع العقار', info?.propertyType),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('المساحة (م²)', info?.areaSize?.toString()),
      ],
    );
  }

  Widget _buildPropertyDescriptionSection(evaluation) {
    final desc = evaluation.propertyDescription;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('حالة العقار', desc?.propertyCondition),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('نوع التشطيب', desc?.finishingType),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('عمر العقار', desc?.propertyAge),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('نوع التكييف', desc?.airConditioningType),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('التكسية الخارجية', desc?.exteriorCladding),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('عدد المصاعد', desc?.elevatorCount?.toString()),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('عدد السلالم المتحركة', desc?.escalatorCount?.toString()),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('الخدمات والمرافق العامة', desc?.publicServices),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('أنواع العقارات المجاورة', desc?.neighboringPropertyTypes),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('نسبة البناء', desc?.buildingRatio?.toString()),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('الواجهات الخارجية', desc?.exteriorFacades),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('ملاحظات الصيانة', desc?.maintenanceNotes),
      ],
    );
  }

  Widget _buildFloorsSection(evaluation) {
    if (evaluation.floors == null || evaluation.floors!.isEmpty) {
      return const EmptyState(
        icon: Icons.layers_outlined,
        title: 'لا توجد أدوار',
        subtitle: 'لم يتم إضافة أي أدوار',
      );
    }

    return Column(
      children: evaluation.floors!.asMap().entries.map((entry) {
        final index = entry.key;
        final floor = entry.value;
        return Container(
          margin: EdgeInsets.only(
              bottom:
                  index < evaluation.floors!.length - 1 ? AppSpacing.md : 0),
          padding: AppSpacing.allMD,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.radiusMD,
            border: Border.all(
                color: AppColors.border, width: AppSpacing.borderWidth),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الدور ${index + 1}',
                style: AppTypography.fieldTitle,
              ),
              AppSpacing.verticalSpaceSM,
              _buildInfoRow('اسم الدور', floor.floorName),
              AppSpacing.verticalSpaceXS,
              _buildInfoRow('تفاصيل الدور', floor.floorDetails),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAreaDetailsSection(evaluation) {
    final details = evaluation.areaDetails;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
            'الشوارع والبنية التحتية', details?.streetsAndInfrastructure),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('أنواع العقارات بالمنطقة', details?.areaPropertyTypes),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('معدل الإيجارات', details?.areaRentalRates),
      ],
    );
  }

  Widget _buildIncomeNotesSection(evaluation) {
    final notes = evaluation.incomeNotes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('نوع المستأجرين', notes?.tenantType),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('عدد الوحدات', notes?.unitCount?.toString()),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('نوع الوحدات', notes?.unitType),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('تفاصيل الدخل', notes?.incomeDetails),
      ],
    );
  }

  Widget _buildSitePlansSection(evaluation) {
    final plans = evaluation.sitePlans;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('ملاحظات عامة', plans?.generalNotes),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('مقارنة المخطط المعتمد', plans?.approvedPlanComparison),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('رقم المقاسات', plans?.siteMeasurementNumbers),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('ملاحظات المخالفات', plans?.violationNotes),
      ],
    );
  }

  Widget _buildPropertyImagesSection(evaluation) {
    final images = evaluation.propertyImages;
    // TODO: Display images in a grid when image URLs are available
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images?.images != null && images!.images!.isNotEmpty)
          Text(
            'عدد الصور: ${images.images!.length}',
            style: AppTypography.bodyMedium,
          )
        else
          const EmptyState(
            icon: Icons.image_outlined,
            title: 'لا توجد صور',
            subtitle: 'لم يتم إضافة أي صور',
          ),
      ],
    );
  }

  Widget _buildAdditionalDataSection(evaluation) {
    final data = evaluation.additionalData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('الغرض من التقييم', data?.evaluationPurpose),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('نظام البناء', data?.buildingSystem),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('القيمة الإجمالية', data?.totalValue?.toString()),
        AppSpacing.verticalSpaceSM,
        _buildInfoRow('تاريخ الإصدار', data?.evaluationIssueDate?.toString()),
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTypography.fieldTitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        AppSpacing.horizontalSpaceSM,
        Expanded(
          flex: 3,
          child: Text(
            value ?? 'غير محدد',
            style: AppTypography.bodyLarge,
            textDirection: TextDirection.rtl,
          ),
        ),
      ],
    );
  }
}
