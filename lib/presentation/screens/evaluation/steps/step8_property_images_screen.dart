import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/routing/route_names.dart';
import 'package:aljal_evaluation/core/routing/route_arguments.dart';
import 'package:aljal_evaluation/presentation/providers/evaluation_provider.dart';
import 'package:aljal_evaluation/presentation/widgets/atoms/custom_text_field.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/form_navigation_buttons.dart';
import 'package:aljal_evaluation/presentation/widgets/molecules/step_navigation_dropdown.dart';
import 'package:aljal_evaluation/data/models/pages_models/image_model.dart';
import 'package:aljal_evaluation/data/services/image_service.dart';

/// Step 8: Property Images Screen
class Step8PropertyImagesScreen extends ConsumerStatefulWidget {
  final String? evaluationId;

  const Step8PropertyImagesScreen({
    super.key,
    this.evaluationId,
  });

  @override
  ConsumerState<Step8PropertyImagesScreen> createState() =>
      _Step8PropertyImagesScreenState();
}

class _Step8PropertyImagesScreenState
    extends ConsumerState<Step8PropertyImagesScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImageService _imageService = ImageService();
  final ImagePicker _imagePicker = ImagePicker();

  // Image URLs
  String? _propertyLocationMapImageUrl;
  String? _propertyImageUrl;
  String? _propertyVariousImages1Url;
  String? _propertyVariousImages2Url;
  String? _satelliteLocationImageUrl;
  String? _civilPlotMapImageUrl;

  // Loading states for each image
  bool _isUploadingPropertyLocationMap = false;
  bool _isUploadingPropertyImage = false;
  bool _isUploadingPropertyVariousImages1 = false;
  bool _isUploadingPropertyVariousImages2 = false;
  bool _isUploadingSatelliteLocation = false;
  bool _isUploadingCivilPlotMap = false;

  // Upload progress for each image
  double _progressPropertyLocationMap = 0.0;
  double _progressPropertyImage = 0.0;
  double _progressPropertyVariousImages1 = 0.0;
  double _progressPropertyVariousImages2 = 0.0;
  double _progressSatelliteLocation = 0.0;
  double _progressCivilPlotMap = 0.0;

  // Controllers for text fields
  late TextEditingController _locationAddressTextController;
  late TextEditingController _locationAddressLinkController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _locationAddressTextController = TextEditingController();
    _locationAddressLinkController = TextEditingController();

    // Load existing data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final evaluation = ref.read(evaluationNotifierProvider);
    final propertyImages = evaluation.propertyImages;

    if (propertyImages != null) {
      setState(() {
        _propertyLocationMapImageUrl =
            propertyImages.propertyLocationMapImageUrl;
        _propertyImageUrl = propertyImages.propertyImageUrl;
        _propertyVariousImages1Url = propertyImages.propertyVariousImages1Url;
        _propertyVariousImages2Url = propertyImages.propertyVariousImages2Url;
        _satelliteLocationImageUrl = propertyImages.satelliteLocationImageUrl;
        _civilPlotMapImageUrl = propertyImages.civilPlotMapImageUrl;
      });

      _locationAddressTextController.text =
          propertyImages.locationAddressText ?? '';
      _locationAddressLinkController.text =
          propertyImages.locationAddressLink ?? '';
    }
  }

  @override
  void dispose() {
    _locationAddressTextController.dispose();
    _locationAddressLinkController.dispose();
    super.dispose();
  }

  // Show image source selection dialog
  Future<void> _showImageSourceDialog({
    required String imageType,
    required Function(String) onUploadComplete,
    required Function(bool) setUploading,
    required Function(double) setProgress,
  }) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر مصدر الصورة',
                style: AppTypography.heading.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('التقاط صورة بالكاميرا'),
                subtitle: const Text('استخدم الكاميرا لالتقاط صورة جديدة'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(
                    imageType: imageType,
                    onUploadComplete: onUploadComplete,
                    setUploading: setUploading,
                    setProgress: setProgress,
                    source: ImageSource.camera,
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library, color: AppColors.success),
                ),
                title: const Text('اختيار من المعرض'),
                subtitle: const Text('اختر صورة من معرض الصور'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(
                    imageType: imageType,
                    onUploadComplete: onUploadComplete,
                    setUploading: setUploading,
                    setProgress: setProgress,
                    source: ImageSource.gallery,
                  );
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage({
    required String imageType,
    required Function(String) onUploadComplete,
    required Function(bool) setUploading,
    required Function(double) setProgress,
    required ImageSource source,
  }) async {
    try {
      // Pick image from specified source
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85, // Compress slightly for camera images
        maxWidth: 1920,   // Limit size for camera images
        maxHeight: 1920,
      );

      if (pickedFile == null) return;

      setUploading(true);
      setProgress(0.0);

      // Get evaluation ID - ensure it exists or create one
      final evaluation = ref.read(evaluationNotifierProvider);
      String? evaluationId = evaluation.evaluationId;
      
      // If no evaluation ID exists, save the evaluation first to get a proper ID
      if (evaluationId == null || evaluationId.isEmpty) {
        try {
          final savedId = await ref.read(evaluationNotifierProvider.notifier).saveEvaluation();
          evaluationId = savedId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
        } catch (e) {
          // If save fails, use temporary ID (timestamp in milliseconds - no spaces)
          evaluationId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        }
      }

      // Upload to Firebase Storage
      String downloadUrl = await _imageService.uploadImage(
        imageFile: File(pickedFile.path),
        evaluationId: evaluationId,
        imageType: imageType,
        onProgress: (progress) {
          setState(() {
            setProgress(progress);
          });
        },
      );

      // Update UI with download URL
      setState(() {
        onUploadComplete(downloadUrl);
        setUploading(false);
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفع الصورة بنجاح'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setUploading(false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل رفع الصورة: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveAndContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create ImageModel
      final images = ImageModel(
        propertyLocationMapImageUrl: _propertyLocationMapImageUrl,
        propertyImageUrl: _propertyImageUrl,
        propertyVariousImages1Url: _propertyVariousImages1Url,
        propertyVariousImages2Url: _propertyVariousImages2Url,
        satelliteLocationImageUrl: _satelliteLocationImageUrl,
        civilPlotMapImageUrl: _civilPlotMapImageUrl,
        locationAddressText: _locationAddressTextController.text.trim().isEmpty
            ? null
            : _locationAddressTextController.text.trim(),
        locationAddressLink: _locationAddressLinkController.text.trim().isEmpty
            ? null
            : _locationAddressLinkController.text.trim(),
      );

      // Update state
      ref
          .read(evaluationNotifierProvider.notifier)
          .updatePropertyImages(images);

      // Navigate to Step 9
      Navigator.pushReplacementNamed(
        context,
        RouteNames.formStep9,
        arguments: FormStepArguments.forStep(
          step: 9,
          evaluationId: widget.evaluationId,
        ),
      );
    }
  }

  void _goBack() {
    Navigator.pushReplacementNamed(
      context,
      RouteNames.formStep7,
      arguments: FormStepArguments.forStep(
        step: 7,
        evaluationId: widget.evaluationId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: Row(
            children: [
              Expanded(
                child: StepNavigationDropdown(
                  currentStep: 8,
                  evaluationId: widget.evaluationId,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.evaluationList,
                  (route) => false,
                ),
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
            ],
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.screenPaddingMobileInsets,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildImagePickerWidget(
                            label:
                                'صور لموقع العقار حسب المخطط العام لبلدية الكويت',
                            imageUrl: _propertyLocationMapImageUrl,
                            isUploading: _isUploadingPropertyLocationMap,
                            uploadProgress: _progressPropertyLocationMap,
                            onPickImage: () => _showImageSourceDialog(
                              imageType: 'property_location_map',
                              onUploadComplete: (url) =>
                                  _propertyLocationMapImageUrl = url,
                              setUploading: (uploading) =>
                                  _isUploadingPropertyLocationMap = uploading,
                              setProgress: (progress) =>
                                  _progressPropertyLocationMap = progress,
                            ),
                          ),
                          AppSpacing.verticalSpaceMD,
                          _buildImagePickerWidget(
                            label: 'صورة للعقار',
                            imageUrl: _propertyImageUrl,
                            isUploading: _isUploadingPropertyImage,
                            uploadProgress: _progressPropertyImage,
                            onPickImage: () => _showImageSourceDialog(
                              imageType: 'property_image',
                              onUploadComplete: (url) =>
                                  _propertyImageUrl = url,
                              setUploading: (uploading) =>
                                  _isUploadingPropertyImage = uploading,
                              setProgress: (progress) =>
                                  _progressPropertyImage = progress,
                            ),
                          ),
                          AppSpacing.verticalSpaceMD,
                          _buildLocationAddressTextFieldField(),
                          AppSpacing.verticalSpaceMD,
                          _buildLocationAddressLinkField(),
                          AppSpacing.verticalSpaceMD,
                          // Other images section
                          Text(
                            'صور أخرى',
                            style: AppTypography.heading.copyWith(fontSize: 18),
                          ),
                          AppSpacing.verticalSpaceSM,
                          _buildImagePickerWidget(
                            label: 'صور مختلفة للعقار 1',
                            imageUrl: _propertyVariousImages1Url,
                            isUploading: _isUploadingPropertyVariousImages1,
                            uploadProgress: _progressPropertyVariousImages1,
                            onPickImage: () => _showImageSourceDialog(
                              imageType: 'property_various_1',
                              onUploadComplete: (url) =>
                                  _propertyVariousImages1Url = url,
                              setUploading: (uploading) =>
                                  _isUploadingPropertyVariousImages1 =
                                      uploading,
                              setProgress: (progress) =>
                                  _progressPropertyVariousImages1 = progress,
                            ),
                          ),
                          AppSpacing.verticalSpaceMD,
                          _buildImagePickerWidget(
                            label: 'صور مختلفة للعقار 2',
                            imageUrl: _propertyVariousImages2Url,
                            isUploading: _isUploadingPropertyVariousImages2,
                            uploadProgress: _progressPropertyVariousImages2,
                            onPickImage: () => _showImageSourceDialog(
                              imageType: 'property_various_2',
                              onUploadComplete: (url) =>
                                  _propertyVariousImages2Url = url,
                              setUploading: (uploading) =>
                                  _isUploadingPropertyVariousImages2 =
                                      uploading,
                              setProgress: (progress) =>
                                  _progressPropertyVariousImages2 = progress,
                            ),
                          ),
                          AppSpacing.verticalSpaceMD,
                          _buildImagePickerWidget(
                            label:
                                'صورة لموقع العقار من القمر الصناعي (google earth)',
                            imageUrl: _satelliteLocationImageUrl,
                            isUploading: _isUploadingSatelliteLocation,
                            uploadProgress: _progressSatelliteLocation,
                            onPickImage: () => _showImageSourceDialog(
                              imageType: 'satellite_location',
                              onUploadComplete: (url) =>
                                  _satelliteLocationImageUrl = url,
                              setUploading: (uploading) =>
                                  _isUploadingSatelliteLocation = uploading,
                              setProgress: (progress) =>
                                  _progressSatelliteLocation = progress,
                            ),
                          ),
                          AppSpacing.verticalSpaceMD,
                          _buildImagePickerWidget(
                            label:
                                'صور لموقع القطعة المدنية حسب المخطط العام لبلدية الكويت',
                            imageUrl: _civilPlotMapImageUrl,
                            isUploading: _isUploadingCivilPlotMap,
                            uploadProgress: _progressCivilPlotMap,
                            onPickImage: () => _showImageSourceDialog(
                              imageType: 'civil_plot_map',
                              onUploadComplete: (url) =>
                                  _civilPlotMapImageUrl = url,
                              setUploading: (uploading) =>
                                  _isUploadingCivilPlotMap = uploading,
                              setProgress: (progress) =>
                                  _progressCivilPlotMap = progress,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Navigation buttons
                FormNavigationButtons(
                  currentStep: 8,
                  onNext: _saveAndContinue,
                  onPrevious: _goBack,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Image picker widget with upload state
  Widget _buildImagePickerWidget({
    required String label,
    required String? imageUrl,
    required bool isUploading,
    required double uploadProgress,
    required VoidCallback onPickImage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.fieldTitle,
        ),
        AppSpacing.verticalSpaceXS,
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppSpacing.radiusMD,
            border: Border.all(
              color: AppColors.border,
              width: AppSpacing.borderWidth,
            ),
          ),
          child: isUploading
              ? _buildUploadingState(uploadProgress)
              : imageUrl != null && imageUrl.isNotEmpty
                  ? _buildImagePreview(imageUrl, onPickImage)
                  : _buildEmptyState(label, onPickImage),
        ),
      ],
    );
  }

  // Upload loading state
  Widget _buildUploadingState(double progress) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          value: progress,
          color: AppColors.primary,
        ),
        AppSpacing.verticalSpaceSM,
        Text(
          '${(progress * 100).toStringAsFixed(0)}%',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.verticalSpaceXS,
        Text(
          'جاري رفع الصورة...',
          style: AppTypography.helperText,
        ),
      ],
    );
  }

  // Image preview with change option
  Widget _buildImagePreview(String imageUrl, VoidCallback onPickImage) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: AppSpacing.radiusMD,
          child: Image.network(
            imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    AppSpacing.verticalSpaceXS,
                    Text(
                      'فشل تحميل الصورة',
                      style: AppTypography.helperText.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: IconButton(
            onPressed: onPickImage,
            icon: const Icon(Icons.edit),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Empty state - no image selected
  Widget _buildEmptyState(String label, VoidCallback onPickImage) {
    return InkWell(
      onTap: onPickImage,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            label,
            style: AppTypography.addImageText,
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            'انقر لاختيار صورة',
            style: AppTypography.helperText.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationAddressTextFieldField() {
    return CustomTextField(
      controller: _locationAddressTextController,
      label: 'عنوان الموقع',
      hint: 'عنوان الموقع',
    );
  }

  Widget _buildLocationAddressLinkField() {
    return CustomTextField(
      controller: _locationAddressLinkController,
      label: 'رابط الموقع',
      hint: 'رابط الموقع',
    );
  }
}
