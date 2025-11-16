import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';

/// Group of form fields with consistent spacing
class FormFieldGroup extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const FormFieldGroup({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = AppSpacing.fieldVerticalSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: _buildChildrenWithSpacing(),
    );
  }

  List<Widget> _buildChildrenWithSpacing() {
    final List<Widget> spacedChildren = [];

    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);

      // Add spacing between children (except after the last one)
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }

    return spacedChildren;
  }
}
