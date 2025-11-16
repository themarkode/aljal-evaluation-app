/// Dropdown options for form fields based on Figma design
class DropdownOptions {
  DropdownOptions._();

  // ============================================================
  // صفحة 1.1 -- معلومات عامة للعقار
  // ============================================================

  /// Governorate options - اسم المحافظة
  static const List<String> governorates = [
    'الاحمدي',
    'العاصمة',
    'الجهراء',
    'الفروانية',
    'حولي',
    'مبارك الكبير',
  ];

  /// Property type options - نوع العقار
  static const List<String> propertyTypes = [
    'بناية استثماري',
    'منزل سكني',
    'قسيمة صناعية',
    'قسيمة حرفية',
    'قسيمة مخازن',
    'جاخور',
    'شاليه (استراحة عائلية)',
    'أرض فضاء (سكن خاص)',
    'أرض فضاء (استثماري)',
    'أرض فضاء (صناعي)',
    'أرض فضاء (استراحة عائلية)',
    'أرض فضاء (جاخور)',
    'معارض تجارية',
  ];

  // ============================================================
  // صفحة 1.2 -- وصف العقار
  // ============================================================

  /// Exterior cladding options - التكسية الخارجية
  static const List<String> exteriorCladding = [
    'سيجما',
    'رخام',
    'صبغ',
    'حجر',
    'زجاج',
    'الكابوند',
  ];

  /// Air conditioning type options - نوع التكييف
  static const List<String> airConditioningTypes = [
    'سنترال',
    'شباك',
    'وحدات',
    'وحدات + شباك',
    'سنترال + وحدات',
  ];

  /// Property condition options - حالة العقار
  static const List<String> propertyConditions = [
    'ممتاز',
    'جيد جداً',
    'جيدة',
    'متوسط',
    'قديم',
  ];

  /// Finishing type options - نوع التشطيب
  static const List<String> finishingTypes = [
    'عادي',
    'ديلوكس',
    'متوسط',
    'جيد',
  ];

  /// Public services options - الخدمات والمرافق العامة
  static const List<String> publicServices = [
    'متوفرة',
    'غير متوفرة',
  ];

  // ============================================================
  // صفحة 1.8 -- بيانات إضافية
  // ============================================================

  /// Evaluation purpose options - الغرض من التقييم
  static const List<String> evaluationPurposes = [
    'التمويل والرهن العقاري',
    'الميزانية',
    'وزارة العدل',
    'معرفة القيمة السوقية للعقار',
    'الورثة',
  ];

  /// Building system options - نظام البناء
  static const List<String> buildingSystems = [
    'الاستثماري',
    'السكني',
    'الصناعي',
    'الزراعي',
    'المعارض التجارية',
  ];

  /// Building ratio options - النسبة
  static const List<String> buildingRatios = [
    '10%',
    '80%',
    '210%',
    '250%',
    '400%',
  ];

  /// According to options - حسب
  static const List<String> accordingToOptions = [
    'حسب الرخصة رقم 000 والصادرة بتاريخ 000',
    'حسب النظم المتبعة في بلدية الكويت',
  ];
}
