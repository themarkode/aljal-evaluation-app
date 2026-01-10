import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/routing/route_names.dart';

/// Centralized App Header Widget
/// Use this for consistent headers across all screens
/// 
/// Layout (RTL):
/// - Logo (right side) - Tapping navigates to homepage by default
/// - Title (center)
/// - Menu button (left side)
class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onMenuTap;
  final VoidCallback? onLogoTap;
  final Widget? trailing;
  final bool showMenu;
  final bool showLogo;
  /// If true, logo tap navigates to homepage (default: true)
  final bool logoNavigatesToHome;
  
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onMenuTap,
    this.onLogoTap,
    this.trailing,
    this.showMenu = true,
    this.showLogo = true,
    this.logoNavigatesToHome = true,
  });

  void _handleLogoTap(BuildContext context) {
    if (onLogoTap != null) {
      onLogoTap!();
    } else if (logoNavigatesToHome) {
      // Navigate to homepage and clear all routes
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteNames.evaluationList,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo (right side in RTL) - Tapping navigates to homepage
            if (showLogo)
              GestureDetector(
                onTap: () => _handleLogoTap(context),
                child: Image.asset(
                  'assets/images/Al_Jal_Logo.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.business_rounded,
                      color: AppColors.primary,
                      size: 40,
                    );
                  },
                ),
              )
            else
              const SizedBox(width: 50),

            // Title and subtitle (center)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            // Menu button or trailing widget (left side in RTL)
            if (trailing != null)
              trailing!
            else if (showMenu)
              Builder(
                builder: (context) => GestureDetector(
                  onTap: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
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
              )
            else
              const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }
}

