import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Custom searchable dropdown with filtering support and RTL support
/// 
/// Set [allowCustomValue] to true to let users type custom values
/// that are not in the predefined [items] list.
class CustomSearchableDropdown extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? value;
  final List<String> items;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final bool enabled;
  final bool showValidationDot;
  final bool isRequired;
  /// If true, allows user to enter custom values not in the list
  final bool allowCustomValue;

  const CustomSearchableDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.showValidationDot = false,
    this.isRequired = false,
    this.allowCustomValue = false,
  });

  @override
  State<CustomSearchableDropdown> createState() =>
      _CustomSearchableDropdownState();
}

class _CustomSearchableDropdownState extends State<CustomSearchableDropdown> {
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _textFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  List<String> _filteredItems = [];
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.value ?? '');
    _filteredItems = widget.items;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(CustomSearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller when value changes externally
    if (widget.value != oldWidget.value) {
      _textController.text = widget.value ?? '';
    }
    // Update filtered items when items list changes
    if (widget.items != oldWidget.items) {
      _filteredItems = widget.items;
      // Clear selection if current value is not in new items
      // BUT only if custom values are NOT allowed
      if (!widget.allowCustomValue && widget.value != null && !widget.items.contains(widget.value)) {
        _textController.clear();
        widget.onChanged?.call(null);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && widget.enabled) {
      _showOverlay();
    } else {
      // Delay to allow tap on item to register
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_focusNode.hasFocus) {
          _removeOverlay();
          // If custom values are allowed and user typed something, save it
          if (widget.allowCustomValue && _textController.text.isNotEmpty) {
            final typedText = _textController.text.trim();
            if (typedText.isNotEmpty && typedText != widget.value) {
              widget.onChanged?.call(typedText);
            }
          }
        }
      });
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.contains(query))
            .toList();
      }
    });
    // Update overlay with new filtered items
    _overlayEntry?.markNeedsBuild();
  }

  void _showOverlay() {
    if (_isOpen) return;
    _isOpen = true;
    _filteredItems = widget.items;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (!_isOpen) return;
    _isOpen = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectItem(String item) {
    _textController.text = item;
    widget.onChanged?.call(item);
    _focusNode.unfocus();
    _removeOverlay();
  }

  /// Widget shown when no results match the search query
  Widget _buildNoResultsWidget() {
    final typedText = _textController.text.trim();
    
    // If custom values are allowed and user typed something, show option to add it
    if (widget.allowCustomValue && typedText.isNotEmpty) {
      return InkWell(
        onTap: () => _selectItem(typedText),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'إضافة "$typedText"',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Default: show no results message
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'لا توجد نتائج',
        style: AppTypography.placeholder,
        textAlign: TextAlign.center,
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox? textFieldBox = _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    final textFieldHeight = textFieldBox?.size.height ?? 56;
    final textFieldWidth = textFieldBox?.size.width ?? MediaQuery.of(context).size.width - 32;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Full screen tap detector to close dropdown when tapping outside
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _focusNode.unfocus();
                _removeOverlay();
              },
            ),
          ),
          // The dropdown list
          Positioned(
            width: textFieldWidth,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, textFieldHeight), // No gap - directly below the text field
              child: Material(
                elevation: 4,
                borderRadius: AppSpacing.radiusMD,
                color: AppColors.white,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: AppSpacing.radiusMD,
                  ),
                  child: _filteredItems.isEmpty
                      ? _buildNoResultsWidget()
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final isSelected = item == widget.value;
                            return InkWell(
                              onTap: () => _selectItem(item),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.1)
                                      : null,
                                  border: index < _filteredItems.length - 1
                                      ? Border(
                                          bottom: BorderSide(
                                            color: AppColors.border.withOpacity(0.5),
                                          ),
                                        )
                                      : null,
                                ),
                                child: Text(
                                  item,
                                  style: AppTypography.dropdownOptions.copyWith(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label with validation dot
        if (widget.label != null) ...[
          Row(
            children: [
              // Label text (appears on RIGHT in RTL)
              Text(
                widget.label!,
                style: AppTypography.fieldTitle,
              ),
              // Required indicator
              if (widget.isRequired)
                Text(
                  ' *',
                  style: AppTypography.fieldTitle.copyWith(
                    color: AppColors.error,
                  ),
                ),
              // Spacer to push dot to the left in RTL
              const Spacer(),
              // Validation dot (appears on LEFT in RTL)
              if (widget.showValidationDot) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.validationDot,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 22.5), // Space from left edge in RTL
              ],
            ],
          ),
          AppSpacing.verticalSpaceXS,
        ],

        // Searchable field
        CompositedTransformTarget(
          link: _layerLink,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: TextFormField(
              key: _textFieldKey,
              controller: _textController,
              focusNode: _focusNode,
              enabled: widget.enabled,
              validator: widget.validator,
              onChanged: _filterItems,
              style: AppTypography.dropdownOptions,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTypography.placeholder,
                filled: true,
                fillColor: widget.enabled ? AppColors.white : AppColors.lightGray,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Clear button (only show when there's text)
                    if (_textController.text.isNotEmpty && widget.enabled)
                      IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          _textController.clear();
                          _filterItems('');
                          widget.onChanged?.call(null);
                        },
                      ),
                    // Dropdown arrow
                    IconButton(
                      icon: Icon(
                        _isOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: widget.enabled
                          ? () {
                              if (_isOpen) {
                                _focusNode.unfocus();
                              } else {
                                _focusNode.requestFocus();
                              }
                            }
                          : null,
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.radiusMD,
                  borderSide: BorderSide(
                    color: AppColors.border,
                    width: AppSpacing.borderWidth,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.radiusMD,
                  borderSide: BorderSide(
                    color: AppColors.border,
                    width: AppSpacing.borderWidth,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.radiusMD,
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: AppSpacing.borderWidthThick,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.radiusMD,
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: AppSpacing.borderWidth,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.radiusMD,
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: AppSpacing.borderWidthThick,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.radiusMD,
                  borderSide: BorderSide(
                    color: AppColors.midGray,
                    width: AppSpacing.borderWidth,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

