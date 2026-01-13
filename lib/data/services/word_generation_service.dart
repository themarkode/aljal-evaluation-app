import 'dart:convert';
import 'dart:io';
import 'package:aljal_evaluation/data/models/pages_models/building_land_cost_model.dart';
import 'package:aljal_evaluation/data/models/pages_models/economic_income_model.dart';
import 'package:aljal_evaluation/data/models/pages_models/floor_model.dart';
import 'package:archive/archive.dart';
import 'package:tafkeet/tafkeet.dart';
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
  // Store modified header/footer XML content
  final Map<String, String> _modifiedHeadersFooters = {};

  Future<File> generateWordDocument(EvaluationModel evaluation) async {
    try {
      _downloadedImages.clear();
      _imageRelationshipIds.clear();
      _tagToImageMap.clear();
      _modifiedHeadersFooters.clear();

      // Load template from assets
      ByteData templateData =
          await rootBundle.load('assets/word_template/template.docx');
      List<int> templateBytes = templateData.buffer.asUint8List();

      // Extract ZIP archive
      Archive archive = ZipDecoder().decodeBytes(templateBytes);

      // Find and modify document.xml
      ArchiveFile? documentXml = _findFile(archive, 'word/document.xml');
      if (documentXml == null) {
        throw Exception('Could not find document.xml in template');
      }

      // Parse XML - MUST decode as UTF-8 for Arabic text!
      String xmlContent = utf8.decode(documentXml.content);
      XmlDocument xmlDoc = XmlDocument.parse(xmlContent);

      // Download images first
      await _downloadAndPrepareImages(evaluation, archive);

      // Generate relationship IDs for new images BEFORE modifying XML
      ArchiveFile? relsFile =
          _findFile(archive, 'word/_rels/document.xml.rels');
      if (relsFile != null && _downloadedImages.isNotEmpty) {
        String relsContent = utf8.decode(relsFile.content);
        _generateImageRelationshipIds(relsContent);
      }

      // Replace all content types in document.xml
      _replaceTextFields(xmlDoc, evaluation);
      _replaceRepeatingSection(xmlDoc, evaluation);

      // Update image references in document XML using new relationship IDs
      _updateImageReferences(xmlDoc);
      _replaceHyperlinks(xmlDoc, evaluation, archive);

      // Convert back to string
      String modifiedXml = xmlDoc.toXmlString(pretty: false);

      // Replace location placeholder URL in the document XML (Word stores it inline)
      String? locationUrl = evaluation.propertyImages?.locationAddressLink;
      if (locationUrl != null && locationUrl.isNotEmpty) {
        // Replace ALL case variations of the placeholder
        modifiedXml = modifiedXml
            .replaceAll('https://LOCATION_PLACEHOLDER/', locationUrl)
            .replaceAll('https://LOCATION_PLACEHOLDER', locationUrl)
            .replaceAll('http://LOCATION_PLACEHOLDER/', locationUrl)
            .replaceAll('http://LOCATION_PLACEHOLDER', locationUrl)
            .replaceAll('LOCATION_PLACEHOLDER/', locationUrl)
            .replaceAll('LOCATION_PLACEHOLDER', locationUrl)
            .replaceAll('https://location_placeholder/', locationUrl)
            .replaceAll('https://location_placeholder', locationUrl)
            .replaceAll('http://location_placeholder/', locationUrl)
            .replaceAll('http://location_placeholder', locationUrl)
            .replaceAll('location_placeholder/', locationUrl)
            .replaceAll('location_placeholder', locationUrl);
      }

      // Process header and footer files (header1.xml, footer1.xml, etc.)
      _processHeadersAndFooters(archive, evaluation);

      // Create new archive with images and modified footers
      Archive newArchive =
          await _createModifiedArchive(archive, modifiedXml, evaluation);

      // Save file
      List<int>? newDocxBytes = ZipEncoder().encode(newArchive);
      if (newDocxBytes == null) {
        throw Exception('Failed to encode ZIP archive');
      }

      // Try external storage first, fall back to app documents
      Directory? outputDir;
      try {
        outputDir = await getExternalStorageDirectory();
      } catch (e) {
        // External storage not available
      }

      outputDir ??= await getApplicationDocumentsDirectory();

      String fileName = _generateFileName(evaluation);
      String filePath = '${outputDir.path}/$fileName';

      File outputFile = File(filePath);
      await outputFile.writeAsBytes(newDocxBytes);

      // Verify file exists
      bool exists = await outputFile.exists();
      int fileSize = exists ? await outputFile.length() : 0;

      if (!exists || fileSize == 0) {
        throw Exception('File was not saved properly');
      }

      return outputFile;
    } catch (e) {
      throw Exception('Failed to generate Word document: $e');
    }
  }

  // Download images and create new image files for each placeholder
  Future<void> _downloadAndPrepareImages(
      EvaluationModel evaluation, Archive archive) async {
    if (evaluation.propertyImages == null) {
      return;
    }

    // Map: content control tag -> (new image filename, URL)
    // Each content control tag gets its own unique image file
    // Include multiple variations of tag names to handle different template formats
    Map<String, MapEntry<String, String?>> tagToImageUrl = {
      // Location map image - different possible tag names
      'صور_لموقع_العقار_حسب_المخطط_العام_لبلدية_الكويت': MapEntry(
          'new_image_1.jpg',
          evaluation.propertyImages!.propertyLocationMapImageUrl),
      'صور_لموقع_العقار': MapEntry('new_image_1.jpg',
          evaluation.propertyImages!.propertyLocationMapImageUrl),

      // Property image
      'صورة_للعقار': MapEntry(
          'new_image_2.jpg', evaluation.propertyImages!.propertyImageUrl),
      'صوره_للعقار': MapEntry(
          'new_image_2.jpg', evaluation.propertyImages!.propertyImageUrl),

      // Various property images 1 - multiple possible tag formats
      '1_صور_مختلفة_للعقار': MapEntry('new_image_3.jpg',
          evaluation.propertyImages!.propertyVariousImages1Url),
      'صور_مختلفة_للعقار_1': MapEntry('new_image_3.jpg',
          evaluation.propertyImages!.propertyVariousImages1Url),
      'صور_مختلفة_للعقار1': MapEntry('new_image_3.jpg',
          evaluation.propertyImages!.propertyVariousImages1Url),
      'صور_مختلفه_للعقار_1': MapEntry('new_image_3.jpg',
          evaluation.propertyImages!.propertyVariousImages1Url),
      'صور_مختلفه_للعقار1': MapEntry('new_image_3.jpg',
          evaluation.propertyImages!.propertyVariousImages1Url),

      // Various property images 2 - multiple possible tag formats
      '2_صور_مختلفة_للعقار': MapEntry('new_image_4.jpg',
          evaluation.propertyImages!.propertyVariousImages2Url),
      'صور_مختلفة_للعقار_2': MapEntry('new_image_4.jpg',
          evaluation.propertyImages!.propertyVariousImages2Url),
      'صور_مختلفة_للعقار2': MapEntry('new_image_4.jpg',
          evaluation.propertyImages!.propertyVariousImages2Url),
      'صور_مختلفه_للعقار_2': MapEntry('new_image_4.jpg',
          evaluation.propertyImages!.propertyVariousImages2Url),
      'صور_مختلفه_للعقار2': MapEntry('new_image_4.jpg',
          evaluation.propertyImages!.propertyVariousImages2Url),

      // Satellite image
      'صورة_لموقع_العقار_من_القمر_الصناعي': MapEntry('new_image_5.jpg',
          evaluation.propertyImages!.satelliteLocationImageUrl),
      'صوره_لموقع_العقار_من_القمر_الصناعي': MapEntry('new_image_5.jpg',
          evaluation.propertyImages!.satelliteLocationImageUrl),

      // Civil plot map
      'صور_لموقع_القطعة_المدنية_حسب_المخطط_العام_لبلدية_الكويت': MapEntry(
          'new_image_6.jpg', evaluation.propertyImages!.civilPlotMapImageUrl),
      'صور_لموقع_القطعه_المدنيه': MapEntry(
          'new_image_6.jpg', evaluation.propertyImages!.civilPlotMapImageUrl),
    };

    // Download all images in PARALLEL for better performance
    // This significantly reduces wait time when multiple images need downloading
    final downloadFutures = <Future<void>>[];

    for (var entry in tagToImageUrl.entries) {
      String tag = entry.key;
      String newImageName = entry.value.key;
      String? imageUrl = entry.value.value;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Add each download to the list of futures
        downloadFutures.add(_downloadSingleImage(tag, newImageName, imageUrl));
      }
    }

    // Wait for ALL downloads to complete simultaneously
    await Future.wait(downloadFutures);
  }

  /// Downloads a single image and stores it for later use
  Future<void> _downloadSingleImage(
      String tag, String newImageName, String imageUrl) async {
    try {
      http.Response response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        _downloadedImages['word/media/$newImageName'] = response.bodyBytes;
        _tagToImageMap[tag] = newImageName;
      }
    } catch (e) {
      // Skip this image if download fails - document will still generate
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

  // Replace repeating sections for all dynamic tables
  void _replaceRepeatingSection(
      XmlDocument xmlDoc, EvaluationModel evaluation) {
    // Collect all repeating sections first to avoid modification during iteration
    List<MapEntry<XmlElement, String>> sectionsToProcess = [];

    for (XmlElement element in xmlDoc.findAllElements('w:sdt')) {
      XmlElement? tagElement = element
          .findElements('w:sdtPr')
          .firstOrNull
          ?.findElements('w:tag')
          .firstOrNull;

      String? tagValue = tagElement?.getAttribute('w:val');
      if (tagValue != null) {
        sectionsToProcess.add(MapEntry(element, tagValue));
      }
    }

    // Process each repeating section
    for (var entry in sectionsToProcess) {
      final element = entry.key;
      final tagValue = entry.value;

      if (tagValue == 'جدول_الأدوار' &&
          evaluation.floors != null &&
          evaluation.floors!.isNotEmpty) {
        _generateFloorRows(element, evaluation.floors!);
      } else if (tagValue == 'جدول_المساحات_الإضافية' &&
          evaluation.buildingLandCost?.additionalAreaCosts != null &&
          evaluation.buildingLandCost!.additionalAreaCosts!.isNotEmpty) {
        _generateAdditionalAreaRows(
            element, evaluation.buildingLandCost!.additionalAreaCosts!);
      } else if (tagValue == 'جدول_وحدات_الدخل_الاقتصادي' &&
          evaluation.economicIncome?.incomeUnits != null &&
          evaluation.economicIncome!.incomeUnits!.isNotEmpty) {
        _generateIncomeUnitRows(
            element, evaluation.economicIncome!.incomeUnits!);
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

    // Find the parent of the repeating section to insert rows in the correct place
    XmlElement? parent = repeatingSection.parent as XmlElement?;
    if (parent == null) return;

    // Find the index of the repeating section in the parent
    int insertIndex = parent.children.indexOf(repeatingSection);
    if (insertIndex == -1) return;

    // Create new rows for each floor and insert them BEFORE the repeating section
    // We insert in reverse order so they end up in correct order
    List<XmlElement> newRows = [];
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

      newRows.add(newRow);
    }

    // Insert all new rows at the position of the repeating section
    for (int i = 0; i < newRows.length; i++) {
      parent.children.insert(insertIndex + i, newRows[i]);
    }

    // Remove the original repeating section (which contains the template)
    repeatingSection.remove();
  }

  // Generate additional area cost rows for repeating section (Step 10)
  void _generateAdditionalAreaRows(
      XmlElement repeatingSection, List<AreaCostEntry> areas) {
    // Find the template row within the repeating section
    final rows = repeatingSection.findAllElements('w:tr').toList();
    if (rows.isEmpty) return;

    XmlElement templateRow = rows.first;

    // Find the parent of the repeating section to insert rows in the correct place
    XmlElement? parent = repeatingSection.parent as XmlElement?;
    if (parent == null) return;

    // Find the index of the repeating section in the parent
    int insertIndex = parent.children.indexOf(repeatingSection);
    if (insertIndex == -1) return;

    // Create new rows for each area and insert them BEFORE the repeating section
    List<XmlElement> newRows = [];
    for (AreaCostEntry area in areas) {
      XmlElement newRow = templateRow.copy();

      // Find content controls within this row and replace them
      for (XmlElement sdt in newRow.findAllElements('w:sdt')) {
        XmlElement? rowTagElement = sdt
            .findElements('w:sdtPr')
            .firstOrNull
            ?.findElements('w:tag')
            .firstOrNull;

        String? rowTagValue = rowTagElement?.getAttribute('w:val');

        if (rowTagValue == 'اسم_المساحة') {
          _replaceContentControlText(sdt, area.areaName ?? '');
        } else if (rowTagValue == 'المساحة') {
          _replaceContentControlText(sdt, _formatNumber(area.area) ?? '');
        } else if (rowTagValue == 'د/م2') {
          _replaceContentControlText(sdt, _formatNumber(area.pricePerM2) ?? '');
        } else if (rowTagValue == 'اجمالي_التكلفة') {
          _replaceContentControlText(sdt, _formatNumber(area.totalCost) ?? '');
        }
      }

      newRows.add(newRow);
    }

    // Insert all new rows at the position of the repeating section
    for (int i = 0; i < newRows.length; i++) {
      parent.children.insert(insertIndex + i, newRows[i]);
    }

    // Remove the original repeating section (which contains the template)
    repeatingSection.remove();
  }

  // Generate economic income unit rows for repeating section (Step 11)
  void _generateIncomeUnitRows(
      XmlElement repeatingSection, List<EconomicIncomeUnit> units) {
    // Find the template row within the repeating section
    final rows = repeatingSection.findAllElements('w:tr').toList();
    if (rows.isEmpty) return;

    XmlElement templateRow = rows.first;

    // Find the parent of the repeating section to insert rows in the correct place
    XmlElement? parent = repeatingSection.parent as XmlElement?;
    if (parent == null) return;

    // Find the index of the repeating section in the parent
    int insertIndex = parent.children.indexOf(repeatingSection);
    if (insertIndex == -1) return;

    // Create new rows for each unit and insert them BEFORE the repeating section
    List<XmlElement> newRows = [];
    for (EconomicIncomeUnit unit in units) {
      XmlElement newRow = templateRow.copy();

      // Find content controls within this row and replace them
      for (XmlElement sdt in newRow.findAllElements('w:sdt')) {
        XmlElement? rowTagElement = sdt
            .findElements('w:sdtPr')
            .firstOrNull
            ?.findElements('w:tag')
            .firstOrNull;

        String? rowTagValue = rowTagElement?.getAttribute('w:val');

        if (rowTagValue == 'العدد') {
          _replaceContentControlText(sdt, unit.unitCount?.toString() ?? '');
        } else if (rowTagValue == 'نوع_الوحدة') {
          _replaceContentControlText(sdt, unit.unitType ?? '');
        } else if (rowTagValue == 'المساحة_م2') {
          _replaceContentControlText(sdt, _formatNumber(unit.unitArea) ?? '');
        } else if (rowTagValue == 'ايجار_اقتصادي') {
          _replaceContentControlText(
              sdt, _formatNumber(unit.economicRent) ?? '');
        } else if (rowTagValue == 'دخل_شهري') {
          _replaceContentControlText(
              sdt, _formatNumber(unit.monthlyIncome) ?? '');
        }
      }

      newRows.add(newRow);
    }

    // Insert all new rows at the position of the repeating section
    for (int i = 0; i < newRows.length; i++) {
      parent.children.insert(insertIndex + i, newRows[i]);
    }

    // Remove the original repeating section (which contains the template)
    repeatingSection.remove();
  }

  // Replace location hyperlink - update both text and URL
  void _replaceHyperlinks(
      XmlDocument xmlDoc, EvaluationModel evaluation, Archive archive) {
    String? addressText = evaluation.propertyImages?.locationAddressText;

    if (addressText == null || addressText.isEmpty) return;

    bool found = false;

    // APPROACH 1: Check content control with tag موقع_العقار
    for (XmlElement sdt in xmlDoc.findAllElements('w:sdt')) {
      XmlElement? tagElement = sdt
          .findElements('w:sdtPr')
          .firstOrNull
          ?.findElements('w:tag')
          .firstOrNull;

      if (tagElement?.getAttribute('w:val') == 'موقع_العقار') {
        List<XmlElement> textElements = sdt.findAllElements('w:t').toList();
        if (textElements.isNotEmpty) {
          textElements.first.innerText = addressText;
          for (int i = 1; i < textElements.length; i++) {
            textElements[i].innerText = '';
          }
          found = true;
          break;
        }
      }
    }

    // APPROACH 2: Find hyperlinks with placeholder text
    if (!found) {
      for (XmlElement hyperlink in xmlDoc.findAllElements('w:hyperlink')) {
        List<XmlElement> textElements =
            hyperlink.findAllElements('w:t').toList();
        String combinedText = textElements.map((e) => e.innerText).join('');

        if (combinedText.contains('موقع_العقار') ||
            combinedText.contains('موقع العقار') ||
            combinedText.contains('موقع')) {
          if (textElements.isNotEmpty) {
            textElements.first.innerText = addressText;
            for (int i = 1; i < textElements.length; i++) {
              textElements[i].innerText = '';
            }
            found = true;
          }
          break;
        }
      }
    }

    // APPROACH 3: Find ANY text containing the placeholder
    if (!found) {
      for (XmlElement textEl in xmlDoc.findAllElements('w:t')) {
        if (textEl.innerText.contains('موقع_العقار') ||
            textEl.innerText.contains('موقع العقار')) {
          textEl.innerText = addressText;
          break;
        }
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
      case 'تاريخ_اصدار_التقييم': // Alternative spelling without hamza
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
      case 'مساحة_الارض_م2': // Used in Step 2, Step 10, and Footer
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
        // Show floor names joined with " + " (e.g., "السرداب + الأرضي")
        if (evaluation.floors != null && evaluation.floors!.isNotEmpty) {
          return evaluation.floors!
              .where((floor) =>
                  floor.floorName != null && floor.floorName!.isNotEmpty)
              .map((floor) => floor.floorName!)
              .join(' + ');
        }
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
      // Note: تاريخ إصدار التقييم is in Step 1 (generalInfo.issueDate), not Step 9
      // Note: القيمة الإجمالية is auto-calculated in Step 11 (economicIncome.finalTotalValue)

      // Building and Land Cost - القيمة بطريقة التكلفة (Step 10)
      case 'مساحة_البناء':
        return _formatNumber(evaluation.buildingLandCost?.buildingArea);
      case 'مساحة_البناء_دم2':
        return _formatNumber(evaluation.buildingLandCost?.buildingAreaPM2);
      case 'تكلفة_مساحة_البناء':
        return _formatNumber(
            evaluation.buildingLandCost?.buildingAreaTotalCost);
      case 'التكلفة_الاجمالية_المباشرة':
        return _formatNumber(evaluation.buildingLandCost?.directTotalCost);
      case 'التكلفة_الغير_مباشرة_نسبة':
        return '${evaluation.buildingLandCost?.indirectCostPercentage ?? 0} ';
      case 'التكلفة_الغير_مباشرة':
        return _formatNumber(evaluation.buildingLandCost?.indirectCostValue);
      case 'تكلفة_البناء_الاجمالية':
        return _formatNumber(evaluation.buildingLandCost?.totalBuildingCost);
      case 'الاستهلاك_نسبة':
        return '${evaluation.buildingLandCost?.depreciationPercentage ?? 0} ';
      case 'الاستهلاك':
        return _formatNumber(evaluation.buildingLandCost?.depreciationValue);
      case 'قيمة_المباني_بعد_خصم_الاستهلاك':
        return _formatNumber(
            evaluation.buildingLandCost?.buildingValueAfterDepreciation);
      // Note: مساحة_الارض_م2 is handled above (shared with Step 2)
      case 'سعر_المتر':
        return _formatNumber(evaluation.buildingLandCost?.landAreaPM2);
      case 'اجمالي_تكلفة_مساحة_الأرض':
        return _formatNumber(evaluation.buildingLandCost?.totalCostOfLandArea);
      case 'القيمة_بطريقة_التكلفة':
        return _formatNumber(evaluation.buildingLandCost?.valueByCostMethod);

      // Economic Income - الدخل الاقتصادي (Step 11)
      case 'الاجمالي_الشهري':
      case 'الإجمالي_الشهري':
        return _formatNumber(evaluation.economicIncome?.monthlyTotalIncome);
      case 'اجمالي_العدد':
        return evaluation.economicIncome?.totalUnitCount.toString();
      case 'الدخل_الاجمالي_السنوي':
        return _formatNumber(evaluation.economicIncome?.annualTotalIncome);
      case 'معدل_الرسملة':
        return '${evaluation.economicIncome?.capitalizationRate ?? 0} ';
      case 'الايجار_الشهري_للعقار':
        return _formatNumber(evaluation.economicIncome?.monthlyPropertyRent);
      case 'القيمة_الإجمالية':
      case 'القيمة_الاجمالية':
        // Now auto-calculated from Economic Income Step 11 with Arabic words
        return _formatNumberWithArabicWords(
            evaluation.economicIncome?.finalTotalValue);

      default:
        return null;
    }
  }

  // Format number with commas
  String? _formatNumber(double? value) {
    if (value == null) return null;
    if (value == 0) return '0';
    return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  // Format number with Arabic words (تفقيط) for Kuwaiti Dinar
  String? _formatNumberWithArabicWords(double? value) {
    if (value == null) return null;
    if (value == 0) return '0 صفر دينار كويتي فقط';

    // Format number with commas
    final formattedNumber = value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    // Convert to Arabic words using tafkeet with Kuwaiti Dinar currency
    try {
      final arabicWords = Tafkeet.convert(
        value,
        lang: Language.ar,
        currency: Currency.KWD, // Kuwaiti Dinar
        suffix: 'فقط',
      );
      return '$formattedNumber $arabicWords';
    } catch (e) {
      // Fallback to just the number if conversion fails
      return formattedNumber;
    }
  }

  // Process footer XML files (footer1.xml, footer2.xml, etc.)
  // Process header and footer XML files (header1.xml, footer1.xml, etc.)
  void _processHeadersAndFooters(Archive archive, EvaluationModel evaluation) {
    for (ArchiveFile file in archive) {
      // Check for both header and footer files
      bool isHeader =
          file.name.startsWith('word/header') && file.name.endsWith('.xml');
      bool isFooter =
          file.name.startsWith('word/footer') && file.name.endsWith('.xml');

      if (isHeader || isFooter) {
        try {
          String content = utf8.decode(file.content);
          XmlDocument xmlDoc = XmlDocument.parse(content);

          // Replace text fields
          _replaceTextFields(xmlDoc, evaluation);

          // Store modified content
          _modifiedHeadersFooters[file.name] =
              xmlDoc.toXmlString(pretty: false);
        } catch (e) {
          // Skip if file can't be processed
        }
      }
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
      imageIndex++;
    }
  }

  // Update image references in content controls to use new relationship IDs
  void _updateImageReferences(XmlDocument xmlDoc) {
    // Update image references
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
            .replaceAll('ه', 'ة') // Normalize ه to ة
            .replaceAll('ي', 'ى') // Normalize ي to ى
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
            break;
          }

          // Also check for partial matches with key parts
          if (tagValue.contains('مختلفة') || tagValue.contains('مختلفه')) {
            if (tagValue.contains('1') && entry.key.contains('1')) {
              newImageFilename = entry.value;
              break;
            }
            if (tagValue.contains('2') && entry.key.contains('2')) {
              newImageFilename = entry.value;
              break;
            }
          }
        }
      }

      if (newImageFilename == null) continue;

      String? newRId = _imageRelationshipIds[newImageFilename];
      if (newRId == null) continue;

      // Find the blip element and update its embed attribute
      for (XmlElement blip in sdt.findAllElements('a:blip')) {
        blip.setAttribute('r:embed', newRId);
      }
    }
  }

  Future<Archive> _createModifiedArchive(Archive originalArchive,
      String modifiedXml, EvaluationModel evaluation) async {
    Archive newArchive = Archive();

    // Convert XML to UTF-8 bytes (important for Arabic text!)
    List<int> xmlBytes = utf8.encode(modifiedXml);

    // Get the location link URL directly from evaluation
    String? locationUrl = evaluation.propertyImages?.locationAddressLink;

    // Build updated relationships XML (for images and hyperlink URL)
    String? updatedRelsXml;

    ArchiveFile? relsFile =
        _findFile(originalArchive, 'word/_rels/document.xml.rels');
    if (relsFile != null) {
      String relsContent = utf8.decode(relsFile.content);

      // Replace the placeholder hyperlink URL with actual location link
      if (locationUrl != null && locationUrl.isNotEmpty) {
        // Use regex to find ANY URL containing "location_placeholder" (case-insensitive)
        // This handles various formats Word might use
        RegExp placeholderPattern = RegExp(
          r'Target="[^"]*location_placeholder[^"]*"',
          caseSensitive: false,
        );

        if (placeholderPattern.hasMatch(relsContent)) {
          relsContent = relsContent.replaceAllMapped(
            placeholderPattern,
            (match) => 'Target="$locationUrl"',
          );
        }

        // Also try simple string replacements as fallback
        relsContent = relsContent
            .replaceAll('https://location_placeholder/', locationUrl)
            .replaceAll('https://location_placeholder', locationUrl)
            .replaceAll('http://location_placeholder/', locationUrl)
            .replaceAll('http://location_placeholder', locationUrl);

        updatedRelsXml = relsContent;
      }

      // Add new image relationships if any
      if (_downloadedImages.isNotEmpty) {
        StringBuffer newRels = StringBuffer();
        for (String imagePath in _downloadedImages.keys) {
          String imageName = imagePath.split('/').last;
          String? rId = _imageRelationshipIds[imageName];
          if (rId != null) {
            newRels.writeln(
                '<Relationship Id="$rId" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/$imageName"/>');
          }
        }

        String baseContent = updatedRelsXml ?? relsContent;
        updatedRelsXml = baseContent.replaceFirst(
            '</Relationships>', '${newRels.toString()}</Relationships>');
      }
    }

    // Update Content_Types to include jpg if needed
    String? updatedContentTypes;
    ArchiveFile? contentTypesFile =
        _findFile(originalArchive, '[Content_Types].xml');
    if (contentTypesFile != null && _downloadedImages.isNotEmpty) {
      String contentTypesContent = utf8.decode(contentTypesFile.content);
      if (!contentTypesContent.contains('Extension="jpg"')) {
        updatedContentTypes = contentTypesContent.replaceFirst('</Types>',
            '<Default Extension="jpg" ContentType="image/jpeg"/></Types>');
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
      } else if (file.name == 'word/_rels/document.xml.rels' &&
          updatedRelsXml != null) {
        // Replace relationships file with updated version
        List<int> relsBytes = utf8.encode(updatedRelsXml);
        newArchive.addFile(ArchiveFile(
          file.name,
          relsBytes.length,
          relsBytes,
        ));
      } else if (file.name == '[Content_Types].xml' &&
          updatedContentTypes != null) {
        // Replace content types file
        List<int> ctBytes = utf8.encode(updatedContentTypes);
        newArchive.addFile(ArchiveFile(
          file.name,
          ctBytes.length,
          ctBytes,
        ));
      } else if (_modifiedHeadersFooters.containsKey(file.name)) {
        // Replace header/footer file with modified version
        List<int> modifiedBytes =
            utf8.encode(_modifiedHeadersFooters[file.name]!);
        newArchive.addFile(ArchiveFile(
          file.name,
          modifiedBytes.length,
          modifiedBytes,
        ));
      } else {
        // Keep original file
        newArchive.addFile(file);
      }
    }

    // Add NEW image files to the archive
    for (var entry in _downloadedImages.entries) {
      newArchive.addFile(ArchiveFile(
        entry.key,
        entry.value.length,
        entry.value,
      ));
    }

    return newArchive;
  }

  String _generateFileName(EvaluationModel evaluation) {
    // Get area name, plot number, and parcel number from evaluation
    final areaName = evaluation.generalPropertyInfo?.area ?? '';
    final plotNumber = evaluation.generalPropertyInfo?.plotNumber ?? '';
    final parcelNumber = evaluation.generalPropertyInfo?.parcelNumber ?? '';

    // Create filename: (اسم المنطقة) قطعة (رقم القطعة) قسيمة (رقم القسيمة)
    String fileName = '$areaName قطعة $plotNumber قسيمة $parcelNumber';

    // Remove any characters that might cause issues with file systems
    fileName = fileName.replaceAll(RegExp(r'[/\\:*?"<>|]'), '');

    // Trim any extra spaces
    fileName = fileName.trim().replaceAll(RegExp(r'\s+'), ' ');

    return '$fileName.docx';
  }
}
