import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aljal_evaluation/data/models/pages_models/general_info_model.dart';
import 'package:aljal_evaluation/data/services/general_info_service.dart';
import 'package:aljal_evaluation/core/utils/word_utils.dart';
import 'package:intl/intl.dart';

class GeneralInfoFormScreen extends StatefulWidget {
  const GeneralInfoFormScreen({super.key});

  @override
  State<GeneralInfoFormScreen> createState() => _GeneralInfoFormScreenState();
}

class _GeneralInfoFormScreenState extends State<GeneralInfoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isGeneratingDocument = false;

  // Controllers for the form fields
  final requestorNameController = TextEditingController();
  final clientNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final clientPhoneController = TextEditingController();
  final guardPhoneController = TextEditingController();
  final siteManagerPhoneController = TextEditingController();

  // Date fields
  DateTime? requestDate;
  DateTime? issueDate;
  DateTime? inspectionDate;

  @override
  void initState() {
    super.initState();
    // Set default dates
    final now = DateTime.now();
    requestDate = now;
    issueDate = now;
    inspectionDate = now;
  }

  @override
  void dispose() {
    // Clean up controllers
    requestorNameController.dispose();
    clientNameController.dispose();
    ownerNameController.dispose();
    clientPhoneController.dispose();
    guardPhoneController.dispose();
    siteManagerPhoneController.dispose();
    super.dispose();
  }

  /// Select date with Arabic support
  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      // Remove Arabic locale for now
      helpText: 'اختر التاريخ',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );
    if (picked != null) {
      setState(() {
        onDateSelected(picked);
      });
    }
  }

  /// Submit form to Firestore
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newForm = GeneralInfoModel(
        requestorName: requestorNameController.text.trim(),
        clientName: clientNameController.text.trim(),
        ownerName: ownerNameController.text.trim(),
        requestDate: requestDate!,
        issueDate: issueDate!,
        inspectionDate: inspectionDate!,
        clientPhone: clientPhoneController.text.trim(),
        guardPhone: guardPhoneController.text.trim(),
        siteManagerPhone: siteManagerPhoneController.text.trim(),
      );

      await GeneralInfoService.addGeneralInfo(
        newForm,
        'eval-${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم حفظ النموذج بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ في حفظ النموذج: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Generate Word document
  Future<void> _exportToWord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGeneratingDocument = true);

    try {
      final formData = GeneralInfoModel(
        requestorName: requestorNameController.text.trim(),
        clientName: clientNameController.text.trim(),
        ownerName: ownerNameController.text.trim(),
        requestDate: requestDate!,
        issueDate: issueDate!,
        inspectionDate: inspectionDate!,
        clientPhone: clientPhoneController.text.trim(),
        guardPhone: guardPhoneController.text.trim(),
        siteManagerPhone: siteManagerPhoneController.text.trim(),
      );

      print("🚀 Starting Word document generation...");
      final result = await WordUtils.generateGeneralInfoDoc(model: formData);

      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ تم إنشاء وثيقة Word بنجاح!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ فشل في إنشاء الوثيقة'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print("❌ Error in _exportToWord: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ في إنشاء الوثيقة: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingDocument = false);
      }
    }
  }

  /// Debug: List all content controls in template
  Future<void> _debugTemplate() async {
    try {
      print("🔍 Debugging template content controls...");
      final controls = await WordUtils.listContentControls();

      print("📋 Found ${controls.length} content controls:");
      for (int i = 0; i < controls.length; i++) {
        final control = controls[i];
        print("${i + 1}. ${control.toString()}");
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('معلومات القالب'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('تم العثور على ${controls.length} عنصر تحكم'),
                  const SizedBox(height: 10),
                  ...controls.take(10).map((control) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          'Tag: ${control.tag ?? "لا يوجد"}\nTitle: ${control.title ?? "لا يوجد"}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      )),
                  if (controls.length > 10)
                    Text('... و ${controls.length - 10} عنصر آخر'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("❌ Error debugging template: $e");
    }
  }

  /// Clear all form fields
  void _clearForm() {
    requestorNameController.clear();
    clientNameController.clear();
    ownerNameController.clear();
    clientPhoneController.clear();
    guardPhoneController.clear();
    siteManagerPhoneController.clear();

    setState(() {
      final now = DateTime.now();
      requestDate = now;
      issueDate = now;
      inspectionDate = now;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'نموذج المعلومات العامة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearForm,
            tooltip: 'مسح النموذج',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _debugTemplate,
            tooltip: 'اختبار القالب',
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Header section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info,
                              color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'معلومات أساسية',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),

                      // Name fields
                      _buildTextFormField(
                        controller: requestorNameController,
                        label: 'اسم الجهة الطالبة للتقييم',
                        icon: Icons.business,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'هذا الحقل مطلوب' : null,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              controller: clientNameController,
                              label: 'العميل',
                              icon: Icons.person,
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'هذا الحقل مطلوب'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextFormField(
                              controller: ownerNameController,
                              label: 'المالك',
                              icon: Icons.person_outline,
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'هذا الحقل مطلوب'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Contact information
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.phone,
                              color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'معلومات الاتصال',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildTextFormField(
                        controller: clientPhoneController,
                        label: 'رقم العميل',
                        icon: Icons.phone_android,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: guardPhoneController,
                        label: 'رقم حارس العقار',
                        icon: Icons.security,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: siteManagerPhoneController,
                        label: 'رقم مسؤول الموقع',
                        icon: Icons.engineering,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Dates section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'التواريخ المهمة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildDatePicker(
                        'تاريخ طلب التقييم',
                        requestDate,
                        (date) => requestDate = date,
                        Icons.request_page,
                      ),
                      const SizedBox(height: 8),
                      _buildDatePicker(
                        'تاريخ إصدار التقييم',
                        issueDate,
                        (date) => issueDate = date,
                        Icons.publish,
                      ),
                      const SizedBox(height: 8),
                      _buildDatePicker(
                        'تاريخ الكشف',
                        inspectionDate,
                        (date) => inspectionDate = date,
                        Icons.search,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _submitForm,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(
                                  _isLoading ? 'جاري الحفظ...' : 'حفظ النموذج'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: (_isGeneratingDocument || _isLoading)
                                  ? null
                                  : _exportToWord,
                              icon: _isGeneratingDocument
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.description),
                              label: Text(_isGeneratingDocument
                                  ? 'جاري الإنشاء...'
                                  : 'إنشاء وثيقة Word'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Debug button (only show in debug mode)
                      if (true) // Change kDebugMode to true for now
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _debugTemplate,
                            icon: const Icon(Icons.bug_report),
                            label: const Text('اختبار قالب Word'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Instructions
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'تعليمات',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• املأ جميع الحقول المطلوبة\n'
                        '• تأكد من صحة أرقام الهواتف\n'
                        '• اختر التواريخ المناسبة\n'
                        '• اضغط "حفظ النموذج" لحفظ البيانات\n'
                        '• اضغط "إنشاء وثيقة Word" لتوليد التقييم',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build text form field with consistent styling
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  /// Build date picker with consistent styling
  Widget _buildDatePicker(
    String label,
    DateTime? date,
    Function(DateTime) onDateSelected,
    IconData icon,
  ) {
    final formatted = date != null ? DateFormat('yyyy/MM/dd').format(date) : '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        formatted.isNotEmpty ? formatted : 'اختر التاريخ',
        style: TextStyle(
          color: formatted.isNotEmpty ? Colors.black87 : Colors.grey,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: () => _selectDate(context, date, onDateSelected),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      tileColor: Colors.grey.shade50,
    );
  }
}
