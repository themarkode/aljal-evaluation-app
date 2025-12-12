import 'dart:convert';
import 'dart:io';
import 'package:aljal_evaluation/data/models/pages_models/floor_model.dart';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;
import '../models/evaluation_model.dart';

class WordGenerationService {
  // Store downloaded images to add to archive
  final Map<String, List<int>> _downloadedImages = {};
  // Store image relationship IDs for later use
  final Map<String, String> _imageRelationshipIds = {};
  // Map content control tags to new image filenames
  final Map<String, String> _tagToImageMap = {};
  
  Future<File> generateWordDocument(EvaluationModel evaluation) async {
    try {
      print('📄 WordGen: Starting document generation...');
      _downloadedImages.clear();
      _imageRelationshipIds.clear();
      _tagToImageMap.clear();
      
      // Load template from assets
      print('📄 WordGen: Loading template from assets...');
      ByteData templateData =
          await rootBundle.load('assets/word_template/template.docx');
      List<int> templateBytes = templateData.buffer.asUint8List();
      print('📄 WordGen: Template loaded, size: ${templateBytes.length} bytes');

      // Extract ZIP archive
      print('📄 WordGen: Extracting ZIP archive...');
      Archive archive = ZipDecoder().decodeBytes(templateBytes);
      print('📄 WordGen: Archive extracted, files: ${archive.length}');

      // Find and modify document.xml
      ArchiveFile? documentXml = _findFile(archive, 'word/document.xml');
      if (documentXml == null) {
        throw Exception('Could not find document.xml in template');
      }
      print('📄 WordGen: Found document.xml');

      // Parse XML - MUST decode as UTF-8 for Arabic text!
      String xmlContent = utf8.decode(documentXml.content);
      XmlDocument xmlDoc = XmlDocument.parse(xmlContent);
      print('📄 WordGen: XML parsed successfully');

      // Download images first
      print('📄 WordGen: Downloading images...');
      await _downloadAndPrepareImages(evaluation, archive);
      
      // Generate relationship IDs for new images BEFORE modifying XML
      ArchiveFile? relsFile = _findFile(archive, 'word/_rels/document.xml.rels');
      if (relsFile != null && _downloadedImages.isNotEmpty) {
        String relsContent = utf8.decode(relsFile.content);
        _generateImageRelationshipIds(relsContent);
      }
      
      // Replace all content types
      print('📄 WordGen: Replacing text fields...');
      _replaceTextFields(xmlDoc, evaluation);
      
      print('📄 WordGen: Replacing repeating sections...');
      _replaceRepeatingSection(xmlDoc, evaluation);
      
      // Update image references in document XML using new relationship IDs
      print('📄 WordGen: Updating image references...');
      _updateImageReferences(xmlDoc);
      
      print('📄 WordGen: Replacing hyperlinks...');
      _replaceHyperlinks(xmlDoc, evaluation);

      // Convert back to string
      String modifiedXml = xmlDoc.toXmlString(pretty: false);
      print('📄 WordGen: Modified XML created');

      // Create new archive with images
      print('📄 WordGen: Creating new archive with images...');
      Archive newArchive = await _createModifiedArchive(archive, modifiedXml);

      // Save file - use external storage for better accessibility
      print('📄 WordGen: Encoding ZIP...');
      List<int>? newDocxBytes = ZipEncoder().encode(newArchive);
      if (newDocxBytes == null) {
        throw Exception('Failed to encode ZIP archive');
      }
      print('📄 WordGen: ZIP encoded, size: ${newDocxBytes.length} bytes');
      
      // Try external storage first, fall back to app documents
      Directory? outputDir;
      try {
        outputDir = await getExternalStorageDirectory();
        print('📄 WordGen: Using external storage: ${outputDir?.path}');
      } catch (e) {
        print('📄 WordGen: External storage not available: $e');
      }
      
      if (outputDir == null) {
        outputDir = await getApplicationDocumentsDirectory();
        print('📄 WordGen: Using app documents: ${outputDir.path}');
      }
      
      String fileName = _generateFileName(evaluation);
      String filePath = '${outputDir.path}/$fileName';
      print('📄 WordGen: Saving to: $filePath');
      
      File outputFile = File(filePath);
      await outputFile.writeAsBytes(newDocxBytes);
      
      // Verify file exists
      bool exists = await outputFile.exists();
      int fileSize = exists ? await outputFile.length() : 0;
      print('📄 WordGen: File saved - exists: $exists, size: $fileSize bytes');

      if (!exists || fileSize == 0) {
        throw Exception('File was not saved properly');
      }

      print('✅ WordGen: Document generated successfully at: $filePath');
      return outputFile;
    } catch (e, stackTrace) {
      print('❌ WordGen: Error generating document: $e');
      print('❌ WordGen: Stack trace: $stackTrace');
      throw Exception('Failed to generate Word document: $e');
    }
  }
  
  // Download images and create new image files for each placeholder
  Future<void> _downloadAndPrepareImages(EvaluationModel evaluation, Archive archive) async {
    if (evaluation.propertyImages == null) {
      print('📄 WordGen: No property images to process');
      return;
    }

    // Map: content control tag -> (new image filename, URL)
    // Each content control tag gets its own unique image file
    // Include multiple variations of tag names to handle different template formats
    Map<String, MapEntry<String, String?>> tagToImageUrl = {
      // Location map image - different possible tag names
      'صور_لموقع_العقار_حسب_المخطط_العام_لبلدية_الكويت': MapEntry('new_image_1.jpg', evaluation.propertyImages!.propertyLocationMapImageUrl),
      'صور_لموقع_العقار': MapEntry('new_image_1.jpg', evaluation.propertyImages!.propertyLocationMapImageUrl),
      
      // Property image
      'صورة_للعقار': MapEntry('new_image_2.jpg', evaluation.propertyImages!.propertyImageUrl),
      'صوره_للعقار': MapEntry('new_image_2.jpg', evaluation.propertyImages!.propertyImageUrl),
      
      // Various property images 1 - multiple possible tag formats
      '1_صور_مختلفة_للعقار': MapEntry('new_image_3.jpg', evaluation.propertyImages!.propertyVariousImages1Url),
      'صور_مختلفة_للعقار_1': MapEntry('new_image_3.jpg', evaluation.propertyImages!.propertyVariousImages1Url),
      'صور_مختلفة_للعقار1': MapEntry('new_image_3.jpg', evaluation.propertyImages!.propertyVariousImages1Url),
      'صور_مختلفه_للعقار_1': MapEntry('new_image_3.jpg', evaluation.propertyImages!.propertyVariousImages1Url),
      'صور_مختلفه_للعقار1': MapEntry('new_image_3.jpg', evaluation.propertyImages!.propertyVariousImages1Url),
      
      // Various property images 2 - multiple possible tag formats
      '2_صور_مختلفة_للعقار': MapEntry('new_image_4.jpg', evaluation.propertyImages!.propertyVariousImages2Url),
      'صور_مختلفة_للعقار_2': MapEntry('new_image_4.jpg', evaluation.propertyImages!.propertyVariousImages2Url),
      'صور_مختلفة_للعقار2': MapEntry('new_image_4.jpg', evaluation.propertyImages!.propertyVariousImages2Url),
      'صور_مختلفه_للعقار_2': MapEntry('new_image_4.jpg', evaluation.propertyImages!.propertyVariousImages2Url),
      'صور_مختلفه_للعقار2': MapEntry('new_image_4.jpg', evaluation.propertyImages!.propertyVariousImages2Url),
      
      // Satellite image
      'صورة_لموقع_العقار_من_القمر_الصناعي': MapEntry('new_image_5.jpg', evaluation.propertyImages!.satelliteLocationImageUrl),
      'صوره_لموقع_العقار_من_القمر_الصناعي': MapEntry('new_image_5.jpg', evaluation.propertyImages!.satelliteLocationImageUrl),
      
      // Civil plot map
      'صور_لموقع_القطعة_المدنية_حسب_المخطط_العام_لبلدية_الكويت': MapEntry('new_image_6.jpg', evaluation.propertyImages!.civilPlotMapImageUrl),
      'صور_لموقع_القطعه_المدنيه': MapEntry('new_image_6.jpg', evaluation.propertyImages!.civilPlotMapImageUrl),
    };

    // Log existing template images
    for (ArchiveFile file in archive) {
      if (file.name.startsWith('word/media/')) {
        print('📄 WordGen: Found template image: ${file.name}');
      }
    }

    // Download each image and store with new unique filenames
    int downloadedCount = 0;
    for (var entry in tagToImageUrl.entries) {
      String tag = entry.key;
      String newImageName = entry.value.key;
      String? imageUrl = entry.value.value;
      
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          print('📄 WordGen: Downloading $newImageName for tag "$tag"');
          http.Response response = await http.get(Uri.parse(imageUrl));
          
          if (response.statusCode == 200) {
            _downloadedImages['word/media/$newImageName'] = response.bodyBytes;
            _tagToImageMap[tag] = newImageName;  // Map tag to image filename
            print('📄 WordGen: ✓ Downloaded ${response.bodyBytes.length} bytes as $newImageName');
            downloadedCount++;
          } else {
            print('📄 WordGen: ✗ Failed: HTTP ${response.statusCode}');
          }
        } catch (e) {
          print('📄 WordGen: ✗ Error: $e');
        }
      }
    }
    
    print('📄 WordGen: Downloaded $downloadedCount new images');
    print('📄 WordGen: Tag to image map: $_tagToImageMap');
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
  void _replaceRepeatingSection(
      XmlDocument xmlDoc, EvaluationModel evaluation) {
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
  void _generateFloorRows(
      XmlElement repeatingSection, List<FloorModel> floors) {
    // Find the template row within the repeating section
    final rows = repeatingSection.findAllElements('w:tr').toList();
    if (rows.isEmpty) return;

    XmlElement templateRow = rows.first;

    // Find the parent table by looking for w:tbl element
    XmlElement? parentTable;

    // Fix: Change XmlElement to XmlNode and add type check
    for (XmlNode ancestor in repeatingSection.ancestors) {
      if (ancestor is XmlElement && ancestor.name.local == 'tbl') {
        parentTable = ancestor;
        break;
      }
    }

    if (parentTable == null) {
      // If no table found in ancestors, look for it as a child
      final tables = repeatingSection.findAllElements('w:tbl').toList();
      if (tables.isNotEmpty) {
        parentTable = tables.first;
      }
    }

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

  // Replace hyperlinks
  void _replaceHyperlinks(XmlDocument xmlDoc, EvaluationModel evaluation) {
    if (evaluation.propertyImages?.locationAddressText != null) {
      String addressText = evaluation.propertyImages!.locationAddressText!;
      String addressLink =
          evaluation.propertyImages?.locationAddressLink ?? '#';

      _createHyperlink(xmlDoc, 'موقع_العقار', addressText, addressLink);
    }
  }


  // Create hyperlink
  void _createHyperlink(
      XmlDocument xmlDoc, String tagName, String text, String url) {
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

  String? _getReplacementText(String? tagValue, EvaluationModel evaluation) {
    if (tagValue == null) return null;

    switch (tagValue) {
      // General Info - معلومات عامة
      case 'اسم_الجهة_الطالبة_للتقييم':
        return evaluation.generalInfo?.requestorName;
      case 'العميل':
        return evaluation.generalInfo?.clientName;
      case 'المالك':
        return evaluation.generalInfo?.ownerName;
      case 'رقم_العميل':
        return evaluation.generalInfo?.clientPhone;
      case 'رقم_حارس_العقار':
        return evaluation.generalInfo?.guardPhone;
      case 'رقم_مسؤول_الموقع':
        return evaluation.generalInfo?.siteManagerPhone;
      case 'تاريخ_طلب_التقييم':
        return _formatDate(evaluation.generalInfo?.requestDate);
      case 'تاريخ_إصدار_التقييم':
        return _formatDate(evaluation.generalInfo?.issueDate);
      case 'تاريخ_الكشف':
        return _formatDate(evaluation.generalInfo?.inspectionDate);

      // General Property Info - معلومات عامة للعقار
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
      case 'الرقم_الآلي':
        return evaluation.generalPropertyInfo?.autoNumber;
      case 'رقم_المنزل':
        return evaluation.generalPropertyInfo?.houseNumber;
      case 'عدد_الشوارع':
        return evaluation.generalPropertyInfo?.streetCount?.toString();
      case 'مواقف_السيارات':
        return evaluation.generalPropertyInfo?.parkingCount?.toString();
      case 'ملاحظات_أرض_العقار':
        return evaluation.generalPropertyInfo?.landNotes;
      case 'اتجاه_واجهة_القسيمة':
        return evaluation.generalPropertyInfo?.landFacing;
      case 'شكل_وتضاريس_الأرض':
        return evaluation.generalPropertyInfo?.landShape;

      // Property Description - وصف العقار
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
      case 'نسبة_البناء':
        return evaluation.propertyDescription?.buildingRatio?.toString();
      case 'الواجهات_الخارجية':
        return evaluation.propertyDescription?.exteriorFacades;
      case 'ملاحظات_الصيانة':
        return evaluation.propertyDescription?.maintenanceNotes;

      // Floors - الوصف العام للعقار
      case 'عدد_الأدوار':
        return evaluation.floorsCount?.toString();

      // Area Details - تفاصيل المنطقة المحيطة بالعقار
      case 'الشوارع_والبنية_التحتية':
        return evaluation.areaDetails?.streetsAndInfrastructure;
      case 'أنواع_العقارات_بالمنطقة':
        return evaluation.areaDetails?.areaPropertyTypes;
      case 'مداخل_ومخارج_المنطقة':
        return evaluation.areaDetails?.areaEntrancesExits;
      case 'التوجه_العام_بالمنطقة':
        return evaluation.areaDetails?.generalAreaDirection;
      case 'معدل_الإيجارات_بالمنطقة':
        return evaluation.areaDetails?.areaRentalRates;
      case 'نوع_المستأجرين_بالعقارات_المجاورة':
        return evaluation.areaDetails?.neighboringTenantTypes;
      case 'معدلات_الشواغر_بالمنطقة':
        return evaluation.areaDetails?.areaVacancyRates;

      // Income Notes - ملاحظات الدخل
      case 'نوع_المستأجرين':
        return evaluation.incomeNotes?.tenantType;
      case 'عدد_الوحدات':
        return evaluation.incomeNotes?.unitCount?.toString();
      case 'تفاصيل_الدخل':
        return evaluation.incomeNotes?.incomeDetails;
      case 'وصف_الوحدات':
        return evaluation.incomeNotes?.unitDescription;
      case 'نوع_الوحدات':
        return evaluation.incomeNotes?.unitType;
      case 'نسبة_الشواغر':
        return evaluation.incomeNotes?.vacancyRate?.toString();
      case 'التأكد_من_القيمة_الإيجارية_للوحدات':
        return evaluation.incomeNotes?.rentalValueVerification;

      // Site Plans - المخطط ورفع القياس بالموقع
      case 'ملاحظات_عامة':
        return evaluation.sitePlans?.generalNotes;
      case 'مقارنة_المخطط_المعتمد_بالموقع':
        return evaluation.sitePlans?.approvedPlanComparison;
      case 'رقم_المقاسات_بالموقع':
        return evaluation.sitePlans?.siteMeasurementNumbers;
      case 'ملاحظات_المخالفات':
        return evaluation.sitePlans?.violationNotes;

      // Additional Data - بيانات إضافية
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
      case 'تاريخ_إصدار_التقييم_النهائي':
        return _formatDate(evaluation.additionalData?.evaluationIssueDate);

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

  // Generate relationship IDs for new images BEFORE modifying XML
  void _generateImageRelationshipIds(String relsXml) {
    // Find the highest existing rId
    RegExp rIdPattern = RegExp(r'Id="rId(\d+)"');
    Iterable<Match> matches = rIdPattern.allMatches(relsXml);
    int maxRId = 0;
    for (Match match in matches) {
      int rId = int.parse(match.group(1)!);
      if (rId > maxRId) maxRId = rId;
    }
    
    // Generate relationship IDs for each new image
    int imageIndex = 1;
    for (String imagePath in _downloadedImages.keys) {
      String imageName = imagePath.split('/').last;
      int newRId = maxRId + imageIndex;
      _imageRelationshipIds[imageName] = 'rId$newRId';
      print('📄 WordGen: Will create relationship rId$newRId for $imageName');
      imageIndex++;
    }
  }
  
  // Update image references in content controls to use new relationship IDs
  void _updateImageReferences(XmlDocument xmlDoc) {
    // First, log ALL content control tags that have images
    print('📄 WordGen: Scanning for image content controls...');
    for (XmlElement sdt in xmlDoc.findAllElements('w:sdt')) {
      XmlElement? tagElement = sdt
          .findElements('w:sdtPr')
          .firstOrNull
          ?.findElements('w:tag')
          .firstOrNull;
      
      String? tagValue = tagElement?.getAttribute('w:val');
      
      // Check if this content control contains an image
      bool hasImage = sdt.findAllElements('a:blip').isNotEmpty;
      if (hasImage) {
        print('📄 WordGen: Found image content control with tag: "$tagValue"');
      }
    }
    
    // Now update image references
    for (XmlElement sdt in xmlDoc.findAllElements('w:sdt')) {
      XmlElement? tagElement = sdt
          .findElements('w:sdtPr')
          .firstOrNull
          ?.findElements('w:tag')
          .firstOrNull;
      
      String? tagValue = tagElement?.getAttribute('w:val');
      if (tagValue == null) continue;
      
      // Check if this tag has a corresponding new image (try exact match first)
      String? newImageFilename = _tagToImageMap[tagValue];
      
      // If not found, try matching with flexible patterns
      if (newImageFilename == null) {
        // Normalize tag for comparison (remove extra spaces/underscores, normalize Arabic letters)
        String normalizedTag = tagValue
            .replaceAll('ه', 'ة')  // Normalize ه to ة
            .replaceAll('ي', 'ى')  // Normalize ي to ى
            .replaceAll(' ', '_')
            .toLowerCase();
        
        for (var entry in _tagToImageMap.entries) {
          String normalizedKey = entry.key
              .replaceAll('ه', 'ة')
              .replaceAll('ي', 'ى')
              .replaceAll(' ', '_')
              .toLowerCase();
          
          // Try if the template tag contains our key or vice versa
          if (normalizedTag.contains(normalizedKey) || 
              normalizedKey.contains(normalizedTag) ||
              tagValue.contains(entry.key) || 
              entry.key.contains(tagValue)) {
            newImageFilename = entry.value;
            print('📄 WordGen: Fuzzy match: template "$tagValue" matched with "${entry.key}"');
            break;
          }
          
          // Also check for partial matches with key parts
          if (tagValue.contains('مختلفة') || tagValue.contains('مختلفه')) {
            if (tagValue.contains('1') && entry.key.contains('1')) {
              newImageFilename = entry.value;
              print('📄 WordGen: Partial match (1): template "$tagValue" matched with "${entry.key}"');
              break;
            }
            if (tagValue.contains('2') && entry.key.contains('2')) {
              newImageFilename = entry.value;
              print('📄 WordGen: Partial match (2): template "$tagValue" matched with "${entry.key}"');
              break;
            }
          }
        }
      }
      
      if (newImageFilename == null) continue;
      
      String? newRId = _imageRelationshipIds[newImageFilename];
      if (newRId == null) continue;
      
      print('📄 WordGen: Updating image for tag "$tagValue" to use $newRId');
      
      // Find the blip element and update its embed attribute
      for (XmlElement blip in sdt.findAllElements('a:blip')) {
        String? currentEmbed = blip.getAttribute('r:embed');
        print('📄 WordGen:   - Changing r:embed from "$currentEmbed" to "$newRId"');
        blip.setAttribute('r:embed', newRId);
      }
    }
  }

  Future<Archive> _createModifiedArchive(
      Archive originalArchive, String modifiedXml) async {
    Archive newArchive = Archive();

    // Convert XML to UTF-8 bytes (important for Arabic text!)
    List<int> xmlBytes = utf8.encode(modifiedXml);
    
    // Build updated relationships XML
    String? updatedRelsXml;
    ArchiveFile? relsFile = _findFile(originalArchive, 'word/_rels/document.xml.rels');
    if (relsFile != null && _downloadedImages.isNotEmpty) {
      String relsContent = utf8.decode(relsFile.content);
      
      // Build new relationships
      StringBuffer newRels = StringBuffer();
      for (String imagePath in _downloadedImages.keys) {
        String imageName = imagePath.split('/').last;
        String? rId = _imageRelationshipIds[imageName];
        if (rId != null) {
          newRels.writeln(
            '<Relationship Id="$rId" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/$imageName"/>'
          );
        }
      }
      
      updatedRelsXml = relsContent.replaceFirst(
        '</Relationships>', 
        '${newRels.toString()}</Relationships>'
      );
    }
    
    // Update Content_Types to include jpg if needed
    String? updatedContentTypes;
    ArchiveFile? contentTypesFile = _findFile(originalArchive, '[Content_Types].xml');
    if (contentTypesFile != null && _downloadedImages.isNotEmpty) {
      String contentTypesContent = utf8.decode(contentTypesFile.content);
      if (!contentTypesContent.contains('Extension="jpg"')) {
        updatedContentTypes = contentTypesContent.replaceFirst(
          '</Types>',
          '<Default Extension="jpg" ContentType="image/jpeg"/></Types>'
        );
      }
    }

    for (ArchiveFile file in originalArchive) {
      if (file.name == 'word/document.xml') {
        // Replace document.xml with modified version
        newArchive.addFile(ArchiveFile(
          file.name,
          xmlBytes.length,
          xmlBytes,
        ));
      } else if (file.name == 'word/_rels/document.xml.rels' && updatedRelsXml != null) {
        // Replace relationships file with updated version
        List<int> relsBytes = utf8.encode(updatedRelsXml);
        newArchive.addFile(ArchiveFile(
          file.name,
          relsBytes.length,
          relsBytes,
        ));
        print('📄 WordGen: Updated relationships file');
      } else if (file.name == '[Content_Types].xml' && updatedContentTypes != null) {
        // Replace content types file
        List<int> ctBytes = utf8.encode(updatedContentTypes);
        newArchive.addFile(ArchiveFile(
          file.name,
          ctBytes.length,
          ctBytes,
        ));
        print('📄 WordGen: Updated Content_Types.xml');
      } else {
        // Keep original file
        newArchive.addFile(file);
      }
    }
    
    // Add NEW image files to the archive
    for (var entry in _downloadedImages.entries) {
      print('📄 WordGen: Adding new image: ${entry.key} (${entry.value.length} bytes)');
      newArchive.addFile(ArchiveFile(
        entry.key,
        entry.value.length,
        entry.value,
      ));
    }

    return newArchive;
  }

  String _generateFileName(EvaluationModel evaluation) {
    // Use safe English filename with timestamp
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    
    // Use evaluation ID if available, otherwise use timestamp
    String id = evaluation.evaluationId ?? 'evaluation';
    // Remove any unsafe characters
    id = id.replaceAll(RegExp(r'[^\w]'), '_');
    
    return 'AlJal_Evaluation_${id}_$timestamp.docx';
  }
}
