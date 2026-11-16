import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serv_oeste/shared/widgets/formFields/search_dropdown_form_field.dart';

void main() {
  testWidgets('selection field follows replacement controller', (tester) async {
    final firstController = TextEditingController(text: 'first');
    final replacementController = TextEditingController(text: 'selected');

    Widget buildField(TextEditingController controller) => MaterialApp(
      home: Scaffold(
        body: CustomSearchDropDownFormField(
          key: const ValueKey('field'),
          dropdownValues: const ['first', 'selected'],
          controller: controller,
          label: 'Selection',
          hide: true,
          onChanged: (_) {},
        ),
      ),
    );

    await tester.pumpWidget(buildField(firstController));
    await tester.pumpWidget(buildField(replacementController));

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'selected',
    );

    firstController.dispose();
    replacementController.dispose();
  });
}
