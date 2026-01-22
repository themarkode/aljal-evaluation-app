import 'package:flutter/material.dart';
import 'package:aljal_evaluation/core/theme/app_colors.dart';
import 'package:aljal_evaluation/core/theme/app_spacing.dart';
import 'package:aljal_evaluation/core/theme/app_typography.dart';
import 'package:aljal_evaluation/core/constants/app_constants.dart';

/// Dialog for entering password to approve/unapprove evaluations
class ApprovalPasswordDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmButtonText;
  final VoidCallback onConfirm;

  const ApprovalPasswordDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmButtonText,
    required this.onConfirm,
  });

  /// Show the dialog and return true if password is correct
  /// [correctPassword] - the password to check against (defaults to approval password)
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmButtonText,
    required String correctPassword,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ApprovalPasswordDialogContent(
        title: title,
        message: message,
        confirmButtonText: confirmButtonText,
        correctPassword: correctPassword,
      ),
    );
    return result ?? false;
  }

  @override
  State<ApprovalPasswordDialog> createState() => _ApprovalPasswordDialogState();
}

class _ApprovalPasswordDialogState extends State<ApprovalPasswordDialog> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Use static show method instead
  }
}

/// Internal dialog content widget
class _ApprovalPasswordDialogContent extends StatefulWidget {
  final String title;
  final String message;
  final String confirmButtonText;
  final String correctPassword;

  const _ApprovalPasswordDialogContent({
    required this.title,
    required this.message,
    required this.confirmButtonText,
    required this.correctPassword,
  });

  @override
  State<_ApprovalPasswordDialogContent> createState() =>
      _ApprovalPasswordDialogContentState();
}

class _ApprovalPasswordDialogContentState
    extends State<_ApprovalPasswordDialogContent> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _verifyPassword() {
    setState(() => _errorMessage = null);

    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text == widget.correctPassword) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _errorMessage = AppConstants.wrongPassword);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: AppSpacing.allLG,
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    AppSpacing.horizontalSpaceMD,
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                AppSpacing.verticalSpaceMD,

                // Message
                Text(
                  widget.message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                AppSpacing.verticalSpaceLG,

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: AppConstants.passwordHint,
                    hintText: AppConstants.passwordHint,
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    errorText: _errorMessage,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppConstants.errorRequired;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _verifyPassword(),
                ),

                AppSpacing.verticalSpaceLG,

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppColors.border),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppConstants.buttonCancel,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.horizontalSpaceMD,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _verifyPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.confirmButtonText,
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
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
}
