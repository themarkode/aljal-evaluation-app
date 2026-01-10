/// App-wide constants
class AppConstants {
  AppConstants._();

  // ============================================================
  // APP INFO
  // ============================================================

  static const String appName = 'Al-Jal Evaluation';
  static const String appNameArabic = 'تقييم الجال';
  static const String companyName = 'Al-Jal';

  // ============================================================
  // FORM NAVIGATION
  // ============================================================

  /// Total number of form steps
  static const int totalFormSteps = 9;

  /// Form step titles in Arabic
  static const List<String> formStepTitles = [
    'معلومات عامة', // Step 1
    'معلومات عامة للعقار', // Step 1.1
    'وصف العقار', // Step 1.2
    'الوصف العام للعقار', // Step 1.3
    'تفاصيل المنطقة المحيطة بالعقار', // Step 1.4
    'ملاحظات الدخل', // Step 1.5
    'المخطط ورفع القياس بالموقع', // Step 1.6
    'صور وموقع العقار', // Step 1.7
    'بيانات إضافية', // Step 1.8
  ];

  // ============================================================
  // EVALUATION STATUS
  // ============================================================

  static const String statusDraft = 'draft';
  static const String statusCompleted = 'completed';
  static const String statusArchived = 'archived';

  // ============================================================
  // PAGINATION
  // ============================================================

  static const int defaultPageSize = 10;
  static const int maxPageSize = 20;

  // ============================================================
  // IMAGE
  // ============================================================

  static const int maxImageSizeMB = 10;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;
  static const List<String> allowedImageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp'
  ];
  static const int imageCompressionQuality = 85;
  static const int maxImageDimension = 1920;

  // ============================================================
  // WORD DOCUMENT
  // ============================================================

  static const String wordTemplateAssetPath =
      'assets/word_template/template.docx';
  static const String wordFileExtension = '.docx';

  // ============================================================
  // DATE FORMAT
  // ============================================================

  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // ============================================================
  // VALIDATION
  // ============================================================

  static const int minFloorCount = 1;
  static const int maxFloorCount = 50;
  static const double minAreaSize = 0.1;
  static const double maxAreaSize = 999999.99;
  static const double minTotalValue = 0.01;
  static const double maxTotalValue = 999999999.99;

  // ============================================================
  // UI
  // ============================================================

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration dialogAnimationDuration = Duration(milliseconds: 200);

  static const double validationDotSize = 8.0;
  static const double minButtonWidth = 120.0;

  // ============================================================
  // UI DIMENSIONS (Centralized for consistency)
  // ============================================================

  /// Logo sizes
  static const double logoSizeSmall = 36.0;
  static const double logoSizeMedium = 50.0;
  static const double logoSizeLarge = 60.0;
  static const double logoFallbackIconSmall = 22.0;
  static const double logoFallbackIconMedium = 28.0;
  static const double logoFallbackIconLarge = 32.0;

  /// AppBar dimensions
  static const double appBarToolbarHeight = 70.0;
  static const double appBarLeadingWidth = 52.0;
  static const double appBarLogoPaddingRight = 16.0;
  static const double appBarMenuPaddingLeft = 16.0;

  /// Menu button dimensions
  static const double menuButtonSize = 44.0;
  static const double menuButtonIconSize = 26.0;
  static const double menuButtonBorderRadius = 12.0;

  /// Validation dot
  static const double validationDotPadding = 22.5;

  // ============================================================
  // PHONE NUMBER
  // ============================================================

  static const String kuwaitCountryCode = '+965';
  static const int kuwaitPhoneLength = 8;

  // ============================================================
  // ERROR MESSAGES (Arabic)
  // ============================================================

  static const String errorRequired = 'هذا الحقل مطلوب';
  static const String errorInvalidEmail = 'البريد الإلكتروني غير صحيح';
  static const String errorInvalidPhone = 'رقم الهاتف غير صحيح';
  static const String errorInvalidNumber = 'الرقم غير صحيح';
  static const String errorMinValue = 'القيمة أقل من الحد الأدنى';
  static const String errorMaxValue = 'القيمة أكبر من الحد الأقصى';
  static const String errorFileSizeExceeded = 'حجم الملف كبير جداً';
  static const String errorInvalidFileType = 'نوع الملف غير مدعوم';
  static const String errorNetworkFailure = 'فشل الاتصال بالإنترنت';
  static const String errorUnknown = 'حدث خطأ غير متوقع';

  // ============================================================
  // SUCCESS MESSAGES (Arabic)
  // ============================================================

  static const String successSaved = 'تم الحفظ بنجاح';
  static const String successDeleted = 'تم الحذف بنجاح';
  static const String successUpdated = 'تم التحديث بنجاح';
  static const String successCompleted = 'تمت العملية بنجاح';
  static const String successGenerated = 'تم إنشاء الملف بنجاح';

  // ============================================================
  // CONFIRMATION MESSAGES (Arabic)
  // ============================================================

  static const String confirmDelete = 'حذف التقرير!';
  static const String confirmDeleteMessage =
      'هل انت متأكد من الرغبة في حذف التقرير؟ التقارير المحذوفة لا يمكن استردادها';
  static const String confirmDeleteButton = 'تأكيد';
  static const String confirmCancelButton = 'رجوع';

  static const String confirmExit = 'مغادرة التقييم';
  static const String confirmExitMessage =
      'هل تريد حفظ التغييرات قبل المغادرة؟';
  static const String confirmSaveButton = 'حفظ';
  static const String confirmDiscardButton = 'تجاهل';

  // ============================================================
  // BUTTON LABELS (Arabic)
  // ============================================================

  static const String buttonNext = 'التالي';
  static const String buttonPrevious = 'السابق';
  static const String buttonSave = 'حفظ';
  static const String buttonCancel = 'إلغاء';
  static const String buttonDelete = 'حذف';
  static const String buttonEdit = 'تعديل';
  static const String buttonAdd = 'إضافة';
  static const String buttonComplete = 'تخطي';
  static const String buttonExport = 'مستند Word';
  static const String buttonSearch = 'بحث';
  static const String buttonFilter = 'فلتر';
  static const String buttonApply = 'تطبيق';
  static const String buttonReset = 'إعادة ضبط';
  static const String buttonClose = 'إغلاق';
  static const String buttonConfirm = 'تأكيد';

  // ============================================================
  // PLACEHOLDER TEXT (Arabic)
  // ============================================================

  static const String placeholderSearch = 'بحث...';
  static const String placeholderSelectOption = 'اختر من القائمة';
  static const String placeholderEnterText = 'أدخل النص...';
  static const String placeholderSelectDate = 'اختر التاريخ';
  static const String placeholderAddImage = 'إضافة صورة';
  static const String placeholderNoData = 'لا توجد بيانات';
  static const String placeholderNoResults = 'لا توجد نتائج';
  static const String placeholderLoading = 'جاري التحميل...';

  // ============================================================
  // FIREBASE COLLECTIONS
  // ============================================================

  static const String collectionEvaluations = 'evaluations';
  static const String storagePathEvaluationImages = 'evaluation_images';
}
