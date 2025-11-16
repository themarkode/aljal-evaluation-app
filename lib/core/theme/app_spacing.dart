import 'package:flutter/material.dart';

/// App spacing constants based on 8px grid system
class AppSpacing {
  AppSpacing._();

  // Base unit: 8px
  static const double baseUnit = 8.0;

  // ============================================================
  // SPACING SCALE - Multiples of 8px
  // ============================================================

  static const double xs = baseUnit * 0.5; // 4px
  static const double sm = baseUnit * 1; // 8px
  static const double md = baseUnit * 2; // 16px
  static const double lg = baseUnit * 3; // 24px
  static const double xl = baseUnit * 4; // 32px
  static const double xxl = baseUnit * 5; // 40px
  static const double xxxl = baseUnit * 6; // 48px

  // ============================================================
  // SEMANTIC SPACING - Purpose-based naming
  // ============================================================

  // Padding
  static const double paddingXS = xs;
  static const double paddingSM = sm;
  static const double paddingMD = md;
  static const double paddingLG = lg;
  static const double paddingXL = xl;

  // Margins
  static const double marginXS = xs;
  static const double marginSM = sm;
  static const double marginMD = md;
  static const double marginLG = lg;
  static const double marginXL = xl;

  // Gaps (for Flex widgets)
  static const double gapXS = xs;
  static const double gapSM = sm;
  static const double gapMD = md;
  static const double gapLG = lg;
  static const double gapXL = xl;

  // ============================================================
  // COMPONENT-SPECIFIC SPACING
  // ============================================================

  // Form fields
  static const double fieldVerticalSpacing = md; // 16px between fields
  static const double fieldHorizontalPadding = md; // 16px inside fields
  static const double fieldVerticalPadding = sm; // 8px inside fields

  // Buttons
  static const double buttonHorizontalPadding = xl; // 32px
  static const double buttonVerticalPadding = md; // 16px
  static const double buttonSpacing = md; // 16px between buttons

  // Cards
  static const double cardPadding = lg; // 24px
  static const double cardMargin = md; // 16px
  static const double cardSpacing = md; // 16px between cards

  // Sections
  static const double sectionPadding = lg; // 24px
  static const double sectionMargin = lg; // 24px
  static const double sectionSpacing = xl; // 32px between sections

  // Screen padding
  static const double screenPaddingMobile = md; // 16px
  static const double screenPaddingTablet = lg; // 24px
  static const double screenPaddingDesktop = xl; // 32px

  // List items
  static const double listItemPadding = md; // 16px
  static const double listItemSpacing = sm; // 8px between items

  // Icons
  static const double iconSpacing = sm; // 8px around icons
  static const double iconSize = lg; // 24px default icon size
  static const double iconSizeSM = md; // 16px small icon
  static const double iconSizeLG = xl; // 32px large icon

  // Borders
  static const double borderRadiusSM = xs; // 4px
  static const double borderRadiusMD = sm; // 8px
  static const double borderRadiusLG = md; // 16px
  static const double borderRadiusXL = lg; // 24px

  static const double borderWidth = 1.0;
  static const double borderWidthThick = 2.0;

  // ============================================================
  // EDGE INSETS - Pre-built padding/margin values
  // ============================================================

  // All sides equal
  static const EdgeInsets allXS = EdgeInsets.all(xs);
  static const EdgeInsets allSM = EdgeInsets.all(sm);
  static const EdgeInsets allMD = EdgeInsets.all(md);
  static const EdgeInsets allLG = EdgeInsets.all(lg);
  static const EdgeInsets allXL = EdgeInsets.all(xl);

  // Horizontal
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);

  // Vertical
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);

  // Screen padding
  static const EdgeInsets screenPaddingMobileInsets =
      EdgeInsets.all(screenPaddingMobile);
  static const EdgeInsets screenPaddingTabletInsets =
      EdgeInsets.all(screenPaddingTablet);
  static const EdgeInsets screenPaddingDesktopInsets =
      EdgeInsets.all(screenPaddingDesktop);

  // Form field padding
  static const EdgeInsets fieldPadding = EdgeInsets.symmetric(
    horizontal: fieldHorizontalPadding,
    vertical: fieldVerticalPadding,
  );

  // Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: buttonHorizontalPadding,
    vertical: buttonVerticalPadding,
  );

  // Card padding
  static const EdgeInsets cardPaddingInsets = EdgeInsets.all(cardPadding);

  // Section padding
  static const EdgeInsets sectionPaddingInsets = EdgeInsets.all(sectionPadding);

  // ============================================================
  // SIZED BOXES - Pre-built spacing widgets
  // ============================================================

  // Vertical spacing
  static const SizedBox verticalSpaceXS = SizedBox(height: xs);
  static const SizedBox verticalSpaceSM = SizedBox(height: sm);
  static const SizedBox verticalSpaceMD = SizedBox(height: md);
  static const SizedBox verticalSpaceLG = SizedBox(height: lg);
  static const SizedBox verticalSpaceXL = SizedBox(height: xl);
  static const SizedBox verticalSpaceXXL = SizedBox(height: xxl);

  // Horizontal spacing
  static const SizedBox horizontalSpaceXS = SizedBox(width: xs);
  static const SizedBox horizontalSpaceSM = SizedBox(width: sm);
  static const SizedBox horizontalSpaceMD = SizedBox(width: md);
  static const SizedBox horizontalSpaceLG = SizedBox(width: lg);
  static const SizedBox horizontalSpaceXL = SizedBox(width: xl);
  static const SizedBox horizontalSpaceXXL = SizedBox(width: xxl);

  // ============================================================
  // BORDER RADIUS - Pre-built radius values
  // ============================================================

  static const BorderRadius radiusSM =
      BorderRadius.all(Radius.circular(borderRadiusSM));
  static const BorderRadius radiusMD =
      BorderRadius.all(Radius.circular(borderRadiusMD));
  static const BorderRadius radiusLG =
      BorderRadius.all(Radius.circular(borderRadiusLG));
  static const BorderRadius radiusXL =
      BorderRadius.all(Radius.circular(borderRadiusXL));

  // Top only
  static const BorderRadius radiusTopSM = BorderRadius.only(
    topLeft: Radius.circular(borderRadiusSM),
    topRight: Radius.circular(borderRadiusSM),
  );
  static const BorderRadius radiusTopMD = BorderRadius.only(
    topLeft: Radius.circular(borderRadiusMD),
    topRight: Radius.circular(borderRadiusMD),
  );
  static const BorderRadius radiusTopLG = BorderRadius.only(
    topLeft: Radius.circular(borderRadiusLG),
    topRight: Radius.circular(borderRadiusLG),
  );

  // Bottom only
  static const BorderRadius radiusBottomSM = BorderRadius.only(
    bottomLeft: Radius.circular(borderRadiusSM),
    bottomRight: Radius.circular(borderRadiusSM),
  );
  static const BorderRadius radiusBottomMD = BorderRadius.only(
    bottomLeft: Radius.circular(borderRadiusMD),
    bottomRight: Radius.circular(borderRadiusMD),
  );
  static const BorderRadius radiusBottomLG = BorderRadius.only(
    bottomLeft: Radius.circular(borderRadiusLG),
    bottomRight: Radius.circular(borderRadiusLG),
  );
}
