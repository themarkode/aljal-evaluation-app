import 'dart:io';
import 'package:aljal_evaluation/data/models/pages_models/floor_model.dart';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;
import '../models/evaluation_model.dart';

class WordGenerationService {
  Future<File> generateWordDocument(EvaluationModel evaluation) async {
    try {
      // Load template from assets
      ByteData templateData = await rootBundle.load('assets/word_template/template.docx');
      List<int> templateBytes = templateData.buffer.asUint8List();
      
      // Extract ZIP archive
      Archive archive = ZipDecoder().decodeBytes(templateBytes);
      
      // Find and modify document.xml
      ArchiveFile? documentXml = _findFile(archive, 'word/document.xml');
      if (documentXml == null) {
        throw Exception('Could not find document.xml in template');
      }
      
      // Parse XML
      String xmlContent = String.fromCharCodes(documentXml.content);
      XmlDocument xmlDoc = XmlDocument.parse(xmlContent);
      
      // Replace all content types
      _replaceTextFields(xmlDoc, evaluation);
      _replaceRepeatingSection(xmlDoc, evaluation);
      await _replaceImages(xmlDoc, evaluation, archive);
      _replaceHyperlinks(xmlDoc, evaluation);
      
      // Convert back to string
      String modifiedXml = xmlDoc.toXmlString(pretty: false);
      
      // Create new archive with images
      Archive newArchive = await _createModifiedArchive(archive, modifiedXml);
      
      // Save file
      List<int> newDocxBytes = ZipEncoder().encode(newArchive)!;
      Directory appDir = await getApplicationDocumentsDirectory();
      String fileName = _generateFileName(evaluation);
      File outputFile = File('${appDir.path}/$fileName');
      await outputFile.writeAsBytes(newDocxBytes);
      
      return outputFile;
    } catch (e) {
      throw Exception('Failed to generate Word document: $e');
    }
  }

  // Replace text content controls
  void _replaceTextFields(XmlDocument xmlDoc, EvaluationModel evaluation) {
    for (XmlElement element in xmlDoc.findAllElements('w:sdt')) {
      XmlElement? tagElement = element
          .findElements('w:sdtPr')
          .firstOrNull
          ?.findElements('w:tag')
          .firstOrNull;
      
      if (tagElement != null) {
        String? tagValue = tagElement.getAttribute('w:val');
        String? replacementText = _getReplacementText(tagValue, evaluation);
        
        if (replacementText != null) {
          _replaceContentControlText(element, replacementText);
        }
      }
    }
  }

  // Replace repeating section for floors table
  void _replaceRepeatingSection(XmlDocument xmlDoc, EvaluationModel evaluation) {
    if (evaluation.floors == null || evaluation.floors!.isEmpty) return;

    for (XmlElement element in xmlDoc.findAllElements('w:sdt')) {
      XmlElement? tagElement = element
          .findElements('w:sdtPr')
          .firstOrNull
          ?.findElements('w:tag')
          .firstOrNull;
      
      String? tagValue = tagElement?.getAttribute('w:val');
      
      if (tagValue == 'جدول_الأدوار') {
        _generateFloorRows(element, evaluation.floors!);
      }
    }
  }

  // Generate floor rows for repeating section
  void _generateFloorRows(XmlElement repeatingSection, List<FloorModel> floors) {
    // Find the template row within the repeating section
    XmlElement? templateRow = repeatingSection.findAllElements('w:tr').firstOrNull;
    if (templateRow == null) return;

    XmlElement? parentTable = templateRow.parent;
    if (parentTable == null) return;

    // Remove the template row
    templateRow.remove();

    // Create new rows for each floor
    for (FloorModel floor in floors) {
      XmlElement newRow = templateRow.copy();
      
      // Find content controls within this row and replace them
      for (XmlElement sdt in newRow.findAllElements('w:sdt')) {
        XmlElement? rowTagElement = sdt
            .findElements('w:sdtPr')
            .firstOrNull
            ?.findElements('w:tag')
            .firstOrNull;
        
        String? rowTagValue = rowTagElement?.getAttribute('w:val');
        
        if (rowTagValue == 'رقم_الدور') {
          _replaceContentControlText(sdt, floor.floorName ?? '');
        } else if (rowTagValue == 'تفاصيل_الدور') {
          _replaceContentControlText(sdt, floor.floorDetails ?? '');
        }
      }
      
      parentTable.children.add(newRow);
    }
  }

  // Replace images with actual image data
  Future<void> _replaceImages(XmlDocument xmlDoc, EvaluationModel evaluation, Archive archive) async {
    if (evaluation.propertyImages == null) return;
    
    Map<String, String?> imageMapping = {
      'صور_لموقع_العقار_حسب_المخطط_العام_لبلدية_الكويت': evaluation.propertyImages!.propertyLocationMapImageUrl,
      'صورة_للعقار': evaluation.propertyImages!.propertyImageUrl,
      '1_صور_مختلفة_للعقار': evaluation.propertyImages!.propertyVariousImages1Url,
      '2_صور_مختلفة_للعقار': evaluation.propertyImages!.propertyVariousImages2Url,
      'صورة_لموقع_العقار_من_القمر_الصناعي': evaluation.propertyImages!.satelliteLocationImageUrl,
      'صور_لموقع_القطعة_المدنية_حسب_المخطط_العام_لبلدية_الكويت': evaluation.propertyImages!.civilPlotMapImageUrl,
    };
    
    for (String tagName in imageMapping.keys) {
      String? imageUrl = imageMapping[tagName];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _insertImageIntoContentControl(xmlDoc, tagName, imageUrl);
      }
    }
  }

  // Replace hyperlinks 
  void _replaceHyperlinks(XmlDocument xmlDoc, EvaluationModel evaluation) {
    if (evaluation.propertyImages?.locationAddressText != null) {
      String addressText = evaluation.propertyImages!.locationAddressText!;
      String addressLink = evaluation.propertyImages?.locationAddressLink ?? '#';
      
      _createHyperlink(xmlDoc, 'موقع_العقار', addressText, addressLink);
    }
  }

  // Insert image into content control
  Future<void> _insertImageIntoContentControl(XmlDocument xmlDoc, String tagName, String imageUrl) async {
    try {
      // Download image
      http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) return;

      List<int> imageBytes = response.bodyBytes;
      
      // Find the picture content control
      for (XmlElement element in xmlDoc.findAllElements('w:sdt')) {
        XmlElement? tagElement = element
            .findElements('w:sdtPr')
            .firstOrNull
            ?.findElements('w:tag')
            .firstOrNull;
        
        if (tagElement?.getAttribute('w:val') == tagName) {
          // This is simplified - full implementation requires:
          // 1. Adding image to archive
          // 2. Creating relationships
          // 3. Generating proper image XML
          // For now, we'll just add a placeholder
          _replaceContentControlText(element, '[Image: $tagName]');
        }
      }
    } catch (e) {
      // Handle image download/insertion error
      print('Failed to insert image for $tagName: $e');
    }
  }

  // Create hyperlink
  void _createHyperlink(XmlDocument xmlDoc, String tagName, String text, String url) {
    for (XmlElement element in xmlDoc.findAllElements('w:sdt')) {
      XmlElement? tagElement = element
          .findElements('w:sdtPr')
          .firstOrNull
          ?.findElements('w:tag')
          .firstOrNull;
      
      if (tagElement?.getAttribute('w:val') == tagName) {
        // Simplified hyperlink creation
        _replaceContentControlText(element, '$text ($url)');
      }
    }
  }

  // Get replacement text based on tag
  String? _getReplacementText(String? tagValue, EvaluationModel evaluation) {
    if (tagValue == null) return null;
    
    switch (tagValue) {
      // General Info
      case 'اسم_الجهة_الطالبة_للتقييم':
        return evaluation.generalInfo?.requestorName;
      case 'العميل':
        return evaluation.generalInfo?.clientName;
      case 'المالك':
        return evaluation.generalInfo?.ownerName;
      case 'تاريخ_طلب_التقييم':
        return _formatDate(evaluation.generalInfo?.requestDate);
      case 'تاريخ_إصدار_التقييم':
        return _formatDate(evaluation.generalInfo?.issueDate);
      case 'تاريخ_الكشف':
        return _formatDate(evaluation.generalInfo?.inspectionDate);
        
      // General Property Info
      case 'اسم_المحافظة':
        return evaluation.generalPropertyInfo?.governorate;
      case 'اسم_المنطقة':
        return evaluation.generalPropertyInfo?.area;
      case 'رقم_القطعة':
        return evaluation.generalPropertyInfo?.plotNumber;
      case 'رقم_القسيمة':
        return evaluation.generalPropertyInfo?.parcelNumber;
      case 'رقم_المخطط':
        return evaluation.generalPropertyInfo?.planNumber;
      case 'رقم_الوثيقة':
        return evaluation.generalPropertyInfo?.documentNumber;
      case 'تاريخ_الوثيقة':
        return _formatDate(evaluation.generalPropertyInfo?.documentDate);
      case 'المساحة_م2':
        return evaluation.generalPropertyInfo?.areaSize?.toString();
      case 'نوع_العقار':
        return evaluation.generalPropertyInfo?.propertyType;
        
      // Floors
      case 'عدد_الأدوار':
        return evaluation.floorsCount?.toString();
        
      // Property Description
      case 'حالة_العقار':
        return evaluation.propertyDescription?.propertyCondition;
      case 'نوع_التشطيب':
        return evaluation.propertyDescription?.finishingType;
      case 'عمر_العقار':
        return evaluation.propertyDescription?.propertyAge;
      case 'نوع_التكييف':
        return evaluation.propertyDescription?.airConditioningType;
      case 'التكسية_الخارجية':
        return evaluation.propertyDescription?.exteriorCladding;
      case 'عدد_المصاعد':
        return evaluation.propertyDescription?.elevatorCount?.toString();
      case 'عدد_السلالم_المتحركة':
        return evaluation.propertyDescription?.escalatorCount?.toString();
      case 'الخدمات_والمرافق_العامة':
        return evaluation.propertyDescription?.publicServices;
      case 'أنواع_العقارات_المجاورة':
        return evaluation.propertyDescription?.neighboringPropertyTypes;
        
      // Additional Data
      case 'الغرض_من_التقييم':
        return evaluation.additionalData?.evaluationPurpose;
      case 'نظام_البناء':
        return evaluation.additionalData?.buildingSystem;
      case 'النسبة':
        return evaluation.additionalData?.buildingRatio;
      case 'حسب':
        return evaluation.additionalData?.accordingTo;
      case 'القيمة_الإجمالية':
        return evaluation.additionalData?.totalValue?.toString();
        
      default:
        return null;
    }
  }

  // Helper methods
  void _replaceContentControlText(XmlElement element, String text) {
    XmlElement? textElement = element.findAllElements('w:t').firstOrNull;
    if (textElement != null) {
      textElement.innerText = text;
    }
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.day}/${date.month}/${date.year}';
  }

  ArchiveFile? _findFile(Archive archive, String fileName) {
    for (ArchiveFile file in archive) {
      if (file.name == fileName) return file;
    }
    return null;
  }

  Future<Archive> _createModifiedArchive(Archive originalArchive, String modifiedXml) async {
    Archive newArchive = Archive();
    
    for (ArchiveFile file in originalArchive) {
      if (file.name == 'word/document.xml') {
        newArchive.addFile(ArchiveFile(
          file.name,
          modifiedXml.length,
          modifiedXml.codeUnits,
        ));
      } else {
        newArchive.addFile(file);
      }
    }
    
    return newArchive;
  }

  String _generateFileName(EvaluationModel evaluation) {
    String clientName = evaluation.generalInfo?.clientName ?? 'evaluation';
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '${clientName}_$timestamp.docx';
  }
}