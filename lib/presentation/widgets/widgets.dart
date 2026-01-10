/// Widgets module exports
/// 
/// This barrel file exports all presentation widgets for easy importing.
/// 
/// Usage:
/// ```dart
/// import 'package:aljal_evaluation/presentation/widgets/widgets.dart';
/// ```
library widgets;

// Atoms
export 'atoms/custom_button.dart';
export 'atoms/custom_date_picker.dart';
export 'atoms/custom_dropdown.dart';
export 'atoms/custom_image_picker.dart';
export 'atoms/custom_text_field.dart';
export 'atoms/empty_state.dart';
export 'atoms/loading_indicator.dart';
export 'atoms/section_header.dart';
export 'atoms/validation_dot.dart';

// Molecules
export 'molecules/collapsible_section.dart';
export 'molecules/confirmation_dialog.dart';
export 'molecules/date_range_picker_widget.dart';
export 'molecules/evaluation_card.dart';
export 'molecules/floor_table_row.dart';
export 'molecules/form_field_group.dart';
export 'molecules/form_navigation_buttons.dart';
export 'molecules/form_step_indicator.dart';
export 'molecules/image_gallery.dart';
export 'molecules/search_bar_widget.dart';
export 'molecules/step_navigation_dropdown.dart';

// Organisms
export 'organisms/app_drawer.dart';
export 'organisms/app_header.dart';
export 'organisms/evaluation_list_toolbar.dart';
export 'organisms/evaluation_list.dart';
export 'organisms/floors_section.dart';
export 'organisms/form_step_app_bar.dart';
export 'organisms/images_section.dart';

// Templates
export 'templates/step_screen_template.dart';

// Shared
export '../shared/responsive/responsive_builder.dart';
