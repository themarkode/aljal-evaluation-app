import 'dart:io';
import 'package:flutter/material.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';

/// Image gallery widget for displaying multiple images in a grid
class ImageGallery extends StatelessWidget {
  final List<File>? imageFiles;
  final List<String>? imageUrls;
  final void Function(int index)? onImageTap;
  final void Function(int index)? onImageRemove;
  final bool canRemove;
  final int crossAxisCount;

  const ImageGallery({
    super.key,
    this.imageFiles,
    this.imageUrls,
    this.onImageTap,
    this.onImageRemove,
    this.canRemove = true,
    this.crossAxisCount = 3,
  });

  int get totalImages {
    return (imageFiles?.length ?? 0) + (imageUrls?.length ?? 0);
  }

  Widget _buildImage(int index) {
    final fileCount = imageFiles?.length ?? 0;

    if (index < fileCount) {
      // Display local file
      return Image.file(
        imageFiles![index],
        fit: BoxFit.cover,
      );
    } else {
      // Display network image
      final urlIndex = index - fileCount;
      return Image.network(
        imageUrls![urlIndex],
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
              size: 32,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (totalImages == 0) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1,
      ),
      itemCount: totalImages,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => onImageTap?.call(index),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              ClipRRect(
                borderRadius: AppSpacing.radiusMD,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.border,
                      width: AppSpacing.borderWidth,
                    ),
                    borderRadius: AppSpacing.radiusMD,
                  ),
                  child: _buildImage(index),
                ),
              ),

              // Remove button
              if (canRemove && onImageRemove != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => onImageRemove?.call(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
