/// Asset paths for images, icons, and fonts
class AssetPaths {
  AssetPaths._();

  // ============================================================
  // BASE PATHS
  // ============================================================

  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _fonts = 'assets/fonts';
  static const String _wordTemplate = 'assets/word_template';

  // ============================================================
  // IMAGES
  // ============================================================

  // Company logo
  static const String logoImage = '$_images/logo.png';
  static const String logoWithText = '$_images/logo_with_text.png';

  // Placeholders
  static const String imagePlaceholder = '$_images/image_placeholder.png';
  static const String propertyPlaceholder = '$_images/property_placeholder.png';

  // Empty states
  static const String emptyStateImage = '$_images/empty_state.png';
  static const String noResultsImage = '$_images/no_results.png';

  // ============================================================
  // ICONS
  // ============================================================

  // Navigation icons
  static const String gridViewIcon = '$_icons/grid_view.svg';
  static const String listViewIcon = '$_icons/list_view.svg';
  static const String filterIcon = '$_icons/filter.svg';
  static const String searchIcon = '$_icons/search.svg';

  // Action icons
  static const String addIcon = '$_icons/add.svg';
  static const String editIcon = '$_icons/edit.svg';
  static const String deleteIcon = '$_icons/delete.svg';
  static const String moreIcon = '$_icons/more.svg';
  static const String closeIcon = '$_icons/close.svg';
  static const String checkIcon = '$_icons/check.svg';
  static const String infoIcon = '$_icons/info.svg';

  // Navigation arrows
  static const String arrowLeftIcon = '$_icons/arrow_left.svg';
  static const String arrowRightIcon = '$_icons/arrow_right.svg';
  static const String arrowUpIcon = '$_icons/arrow_up.svg';
  static const String arrowDownIcon = '$_icons/arrow_down.svg';
  static const String chevronLeftIcon = '$_icons/chevron_left.svg';
  static const String chevronRightIcon = '$_icons/chevron_right.svg';
  static const String chevronUpIcon = '$_icons/chevron_up.svg';
  static const String chevronDownIcon = '$_icons/chevron_down.svg';

  // Form icons
  static const String calendarIcon = '$_icons/calendar.svg';
  static const String uploadIcon = '$_icons/upload.svg';
  static const String cameraIcon = '$_icons/camera.svg';
  static const String imageIcon = '$_icons/image.svg';
  static const String documentIcon = '$_icons/document.svg';

  // Status icons
  static const String successIcon = '$_icons/success.svg';
  static const String errorIcon = '$_icons/error.svg';
  static const String warningIcon = '$_icons/warning.svg';

  // Export icons
  static const String wordIcon = '$_icons/word.svg';
  static const String pdfIcon = '$_icons/pdf.svg';
  static const String exportIcon = '$_icons/export.svg';

  // ============================================================
  // FONTS
  // ============================================================

  static const String interFont = '$_fonts/Inter-VariableFont_opsz,wght.ttf';
  static const String interItalicFont =
      '$_fonts/Inter-Italic-VariableFont_opsz,wght.ttf';

  // ============================================================
  // WORD TEMPLATE
  // ============================================================

  static const String wordTemplate = '$_wordTemplate/template.docx';
}
