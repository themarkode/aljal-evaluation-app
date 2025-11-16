import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Custom image picker widget with preview
class CustomImagePicker extends StatelessWidget {
  final String? label;
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;
  final bool enabled;
  final bool showValidationDot;
  final bool isRequired;
  final String? errorText;
  final double height;

  const CustomImagePicker({
    super.key,
    this.label,
    this.imageFile,
    this.imageUrl,
    required this.onPickImage,
    this.onRemoveImage,
    this.enabled = true,
    this.showValidationDot = false,
    this.isRequired = false,
    this.errorText,
    this.height = 200,
  });

  bool get hasImage => imageFile != null || imageUrl != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label with validation dot
        if (label != null) ...[
          Row(
            children: [
              // Validation dot
              if (showValidationDot) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.validationDot,
                    shape: BoxShape.circle,
                  ),
                ),
                AppSpacing.horizontalSpaceXS,
              ],
              // Label text
              Expanded(
                child: Text(
                  label!,
                  style: AppTypography.fieldTitle,
                ),
              ),
              // Required indicator
              if (isRequired)
                Text(
                  ' *',
                  style: AppTypography.fieldTitle.copyWith(
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
          AppSpacing.verticalSpaceXS,
        ],

        // Image picker container
        InkWell(
          onTap: enabled ? onPickImage : null,
          borderRadius: AppSpacing.radiusMD,
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: enabled ? AppColors.white : AppColors.lightGray,
              borderRadius: AppSpacing.radiusMD,
              border: Border.all(
                color: errorText != null ? AppColors.error : AppColors.border,
                width: AppSpacing.borderWidth,
              ),
            ),
            child: hasImage ? _buildImagePreview() : _buildPlaceholder(),
          ),
        ),

        // Error text
        if (errorText != null) ...[
          AppSpacing.verticalSpaceXS,
          Text(
            errorText!,
            style: AppTypography.errorText,
          ),
        ],
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        // Image
        ClipRRect(
          borderRadius: AppSpacing.radiusMD,
          child: imageFile != null
              ? Image.file(
                  imageFile!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                )
              : imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.error,
                            color: AppColors.error,
                            size: 48,
                          ),
                        );
                      },
                    )
                  : const SizedBox.shrink(),
        ),

        // Remove button
        if (onRemoveImage != null && enabled)
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: onRemoveImage,
              child: Container(
                padding: AppSpacing.allXS,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 64,
          color: enabled ? AppColors.primary : AppColors.midGray,
        ),
        AppSpacing.verticalSpaceSM,
        Text(
          'إضافة صورة',
          style: AppTypography.addImageText.copyWith(
            color: enabled ? AppColors.textSecondary : AppColors.midGray,
          ),
        ),
      ],
    );
  }
}
