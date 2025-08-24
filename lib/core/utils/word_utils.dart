import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:aljal_evaluation/data/models/pages_models/general_info_model.dart';

/// Advanced Arabic Word Document Generator
/// Handles DOCX templates with Content Controls for Arabic real estate evaluation forms
class WordUtils {
  /// Main method to generate Word document from template and form data
  static Future<String?> generateGeneralInfoDoc({
    required GeneralInfoModel model,
  }) async {
    try {
      print("🚀 Starting document generation...");

      // Step 1: Load template
      final templateData = await _loadTemplate();

      // Step 2: Parse DOCX structure
      final archive = ZipDecoder().decodeBytes(templateData);

      // Step 3: Extract and modify document.xml
      final modifiedArchive = await _processDocument(archive, model);

      // Step 4: Generate new DOCX file
      final outputPath = await _saveDocument(modifiedArchive, model);

      // Step 5: Open the document
      await _openDocument(outputPath);

      print("✅ Document generated successfully: $outputPath");
      return outputPath;
    } catch (e, stackTrace) {
      print("❌ Failed to generate Word document: $e");
      print("Stack trace: $stackTrace");
      return null;
    }
  }

  /// Load template from assets
  static Future<Uint8List> _loadTemplate() async {
    try {
      final ByteData templateData =
          await rootBundle.load('assets/word_template/template.docx');
      return templateData.buffer.asUint8List();
    } catch (e) {
      throw Exception('Failed to load template: $e');
    }
  }

  /// Process document.xml and replace content controls
  static Future<Archive> _processDocument(
      Archive archive, GeneralInfoModel model) async {
    // Find document.xml
    ArchiveFile? documentXml;
    for (final file in archive) {
      if (file.name == 'word/document.xml') {
        documentXml = file;
        break;
      }
    }

    if (documentXml == null) {
      throw Exception('document.xml not found in template');
    }

    // Parse XML
    final String xmlContent = utf8.decode(documentXml.content as List<int>);
    final XmlDocument doc = XmlDocument.parse(xmlContent);

    // Prepare replacement data
    final replacements = _buildReplacementMap(model);

    // Replace content controls
    _replaceContentControls(doc, replacements);

    // Create new archive with modified document.xml
    final Archive newArchive = Archive();

    // Copy all files except document.xml
    for (final file in archive) {
      if (file.name != 'word/document.xml') {
        newArchive.addFile(ArchiveFile(
          file.name,
          file.size,
          file.content,
        ));
      }
    }

    // Add modified document.xml with proper UTF-8 encoding for Arabic
    final String newXmlContent = doc.toXmlString(pretty: false);
    final List<int> xmlBytes = utf8.encode(newXmlContent);
    newArchive.addFile(ArchiveFile(
      'word/document.xml',
      xmlBytes.length,
      xmlBytes,
    ));

    return newArchive;
  }

  /// Build replacement map from model data
  static Map<String, String> _buildReplacementMap(GeneralInfoModel model) {
    return {
      // Basic Information (matching your template's exact tags)
      'اسم_الجهة_الطالبة_للتقييم': model.requestorName,
      'العميل': model.clientName,
      'المالك': model.ownerName,
      'رقم_العميل': model.clientPhone,
      'رقم_حارس_العقار': model.guardPhone,
      'رقم_مسؤول_الموقع': model.siteManagerPhone,

      // Dates (formatted for Arabic display)
      'تاريخ_طلب_التقييم': _formatArabicDate(model.requestDate),
      'تاريخ_اصدار_التقييم': _formatArabicDate(model.issueDate),
      'تاريخ_الكشف': _formatArabicDate(model.inspectionDate),

      // Template fields that already exist (based on your debug output)
      'اسم_المحافظة': 'محافظة الكويت',
      'اسم_المنطقة': 'منطقة الكويت',
      'نظام_البناء': 'نظام البناء المعمول به',

      // Additional fields that might be in your template
      'رقم_القطعة': '123',
      'رقم_القسيمة': '456',
      'رقم_المخطط': '789',
      'رقم_الوثيقة': '101112',
      'تاريخ_الوثيقة': _formatArabicDate(DateTime.now()),
      'المساحة_م2': '500',
      'نوع_العقار': 'عقار تجاري',

      // Default values for technical fields
      'الغرض_من_التقييم': 'تقييم عقاري لأغراض البيع',
      'الرأي_التنظيمي': 'العقار يخضع لنظام البناء المعمول به',
      'نسبة_البناء': '60%',
      'عدد_الأدوار': '3 أدوار',
      'التكسية_الخارجية': 'حجر طبيعي',
      'نوع_التشطيب': 'تشطيب فاخر',
      'عدد_المصاعد': '2',
      'عدد_السلالم_المتحركة': '0',
      'حالة_العقار': 'ممتازة',
      'عمر_العقار': '5 سنوات',
      'الخدمات_والمرافق_العامة': 'جميع الخدمات متوفرة',
      'الشوارع_والبنية_التحتية': 'شوارع معبدة ومضاءة',
      'أنواع_العقارات_بالمنطقة': 'عقارات تجارية وسكنية',
      'مداخل_ومخارج_المنطقة': 'متعددة ومناسبة',
      'نوع_المستأجرين': 'شركات ومحلات تجارية',
      'التوجه_العام_بالمنطقة': 'شمالي',
      'نوع_المستأجرين_بالعقارات_المجاورة': 'مختلط',
      'معدل_الإيجارات_بالمنطقة': '50 دينار/م²',

      // Evaluation section
      'تقدير_العقار': '500,000 دينار كويتي',
      'ملاحظة': 'تم التقييم وفقاً للمعايير المهنية المعتمدة',

      // Additional fields that might exist in template
      'تاريخ_الوثيقة': _formatArabicDate(DateTime.now()),
      'اسم_المقيم': 'مكتب الجال للتقييم العقاري',
      'رقم_الترخيص': 'TR-2024-001',
    };
  }

  /// Format date for Arabic display (fixed - no locale issues)
  static String _formatArabicDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date); // Remove Arabic locale
  }

  /// Replace content controls in the XML document
  static void _replaceContentControls(
      XmlDocument doc, Map<String, String> replacements) {
    // Find all content control elements
    final contentControls = doc.findAllElements('w:sdt');

    int replacedCount = 0;

    for (final control in contentControls) {
      try {
        // Find the tag element
        final propertiesElement = control.findElements('w:sdtPr');
        if (propertiesElement.isEmpty) continue;

        // Try to get tag value
        String? tagValue;
        final tagElements = propertiesElement.first.findElements('w:tag');
        if (tagElements.isNotEmpty) {
          tagValue = tagElements.first.getAttribute('w:val');
        }

        // Try to get title value if no tag
        String? titleValue;
        if (tagValue == null) {
          final aliasElements = propertiesElement.first.findElements('w:alias');
          if (aliasElements.isNotEmpty) {
            titleValue = aliasElements.first.getAttribute('w:val');
          }
        }

        // Determine which key to use for replacement
        final key = tagValue ?? titleValue;

        if (key != null && replacements.containsKey(key)) {
          // Find the content element and replace text
          final contentElements = control.findElements('w:sdtContent');
          if (contentElements.isNotEmpty) {
            final contentElement = contentElements.first;
            final textElements = contentElement.findAllElements('w:t');

            if (textElements.isNotEmpty) {
              // Replace text in the first text element and clear others
              bool firstElement = true;
              for (final textElement in textElements) {
                if (firstElement) {
                  textElement.innerText = replacements[key]!;
                  firstElement = false;
                  replacedCount++;
                } else {
                  textElement.innerText = '';
                }
              }
            }
          }
        }
      } catch (e) {
        // Skip malformed content controls
        print("⚠️ Skipping malformed content control: $e");
        continue;
      }
    }

    print("✅ Replaced $replacedCount content controls");
  }

  /// Save the generated document
  static Future<String> _saveDocument(
      Archive archive, GeneralInfoModel model) async {
    final List<int> docxBytes = ZipEncoder().encode(archive)!;

    // Create filename with client name and timestamp
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final clientName = model.clientName
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w\u0600-\u06FF_]'), '');
    final fileName = 'تقييم_عقاري_${clientName}_$timestamp.docx';

    // Get documents directory
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String outputPath = '${appDocDir.path}/$fileName';

    // Write file
    final File outputFile = File(outputPath);
    await outputFile.writeAsBytes(docxBytes);

    return outputPath;
  }

  /// Open the generated document
  static Future<void> _openDocument(String filePath) async {
    try {
      // Request storage permission
      await Permission.storage.request();

      // Open the file
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        print("⚠️ Could not open file: ${result.message}");
      }
    } catch (e) {
      print("⚠️ Error opening document: $e");
    }
  }

  /// Utility method to list all content controls in the template (for debugging)
  static Future<List<ContentControlInfo>> listContentControls() async {
    try {
      final templateData = await _loadTemplate();
      final Archive archive = ZipDecoder().decodeBytes(templateData);

      ArchiveFile? documentXml;
      for (final file in archive) {
        if (file.name == 'word/document.xml') {
          documentXml = file;
          break;
        }
      }

      if (documentXml == null) return [];

      final String xmlContent = utf8.decode(documentXml.content as List<int>);
      final XmlDocument doc = XmlDocument.parse(xmlContent);
      final contentControls = doc.findAllElements('w:sdt');

      final List<ContentControlInfo> controls = [];

      for (final control in contentControls) {
        try {
          final propertiesElement = control.findElements('w:sdtPr');
          if (propertiesElement.isEmpty) continue;

          String? tag;
          final tagElements = propertiesElement.first.findElements('w:tag');
          if (tagElements.isNotEmpty) {
            tag = tagElements.first.getAttribute('w:val');
          }

          String? title;
          final aliasElements = propertiesElement.first.findElements('w:alias');
          if (aliasElements.isNotEmpty) {
            title = aliasElements.first.getAttribute('w:val');
          }

          String currentText = '';
          final contentElements = control.findElements('w:sdtContent');
          if (contentElements.isNotEmpty) {
            final textElements = contentElements.first.findAllElements('w:t');
            for (final textElement in textElements) {
              currentText += textElement.innerText;
            }
          }

          controls.add(ContentControlInfo(
            tag: tag,
            title: title,
            currentText: currentText.trim(),
          ));
        } catch (e) {
          continue;
        }
      }

      return controls;
    } catch (e) {
      print("❌ Error listing content controls: $e");
      return [];
    }
  }

  /// Generate a comprehensive evaluation report with all fields
  static Future<String?> generateFullEvaluationReport({
    required GeneralInfoModel basicInfo,
    Map<String, String>? additionalFields,
  }) async {
    try {
      print("🚀 Generating full evaluation report...");

      final templateData = await _loadTemplate();
      final archive = ZipDecoder().decodeBytes(templateData);

      // Get all replacements
      final replacements = _buildReplacementMap(basicInfo);

      // Add additional fields if provided
      if (additionalFields != null) {
        replacements.addAll(additionalFields);
      }

      // Process document
      final modifiedArchive = await _processDocument(archive, basicInfo);

      // Save and open
      final outputPath = await _saveDocument(modifiedArchive, basicInfo);
      await _openDocument(outputPath);

      print("✅ Full evaluation report generated: $outputPath");
      return outputPath;
    } catch (e) {
      print("❌ Failed to generate full evaluation report: $e");
      return null;
    }
  }
}

/// Data class to hold content control information
class ContentControlInfo {
  final String? tag;
  final String? title;
  final String currentText;

  ContentControlInfo({
    this.tag,
    this.title,
    required this.currentText,
  });

  @override
  String toString() {
    return 'ContentControl(tag: "$tag", title: "$title", text: "${currentText.length > 50 ? '${currentText.substring(0, 50)}...' : currentText}")';
  }
}
