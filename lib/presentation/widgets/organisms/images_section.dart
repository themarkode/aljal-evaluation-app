import 'dart:io';
import 'package:flutter/material.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import '../atoms/custom_image_picker.dart';
import '../molecules/image_gallery.dart';

/// Images section organism - manages multiple images
class ImagesSection extends StatelessWidget {
  final List<File>? imageFiles;
  final List<String>? imageUrls;
  final VoidCallback? onAddImage;
  final void Function(int index)? onImageRemove;
  final void Function(int index)? onImageTap;
  final int maxImages;
  final String? title;
  final String? subtitle;

  const ImagesSection({
    super.key,
    this.imageFiles,
    this.imageUrls,
    this.onAddImage,
    this.onImageRemove,
    this.onImageTap,
    this.maxImages = 20,
    this.title,
    this.subtitle,
  });

  int get totalImages {
    return (imageFiles?.length ?? 0) + (imageUrls?.length ?? 0);
  }

  bool get canAddMore => totalImages < maxImages;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        if (title != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      style: AppTypography.fieldTitle,
                      textDirection: TextDirection.rtl,
                    ),
                    if (subtitle != null) ...[
                      AppSpacing.verticalSpaceXS,
                      Text(
                        subtitle!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '$totalImages / $maxImages',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceMD,
        ],

        // Image gallery
        if (totalImages > 0) ...[
          ImageGallery(
            imageFiles: imageFiles,
            imageUrls: imageUrls,
            onImageTap: onImageTap,
            onImageRemove: onImageRemove,
            canRemove: true,
            crossAxisCount: 3,
          ),
          AppSpacing.verticalSpaceMD,
        ],

        // Add image button
        if (canAddMore)
          CustomImagePicker(
            label: totalImages == 0 ? 'إضافة صور' : null,
            onPickImage: onAddImage ?? () {},
            height: 150,
          )
        else
          Container(
            padding: AppSpacing.allSM,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppSpacing.radiusMD,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                AppSpacing.horizontalSpaceXS,
                Expanded(
                  child: Text(
                    'تم الوصول للحد الأقصى من الصور ($maxImages صورة)',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),

        // Helper text
        if (totalImages == 0 && canAddMore) ...[
          AppSpacing.verticalSpaceSM,
          Text(
            'يمكنك إضافة حتى $maxImages صورة',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ],
    );
  }
}
