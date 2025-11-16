import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../atoms/section_header.dart';

/// Collapsible section with header and content
class CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final void Function(bool)? onExpansionChanged;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = true,
    this.onExpansionChanged,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        SectionHeader(
          title: widget.title,
          isCollapsed: !_isExpanded,
          onTap: _toggleExpansion,
        ),

        // Content (animated)
        AnimatedCrossFade(
          firstChild: Padding(
            padding: AppSpacing.verticalMD, // ✅ Changed from verticalSpaceMD
            child: widget.child,
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: _isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
