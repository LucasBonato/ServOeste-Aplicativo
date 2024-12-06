import 'package:flutter/material.dart';

class CustomGridCheckersFormField extends StatelessWidget {
  final String? Function([String?])? validator;
  final Map<String, bool> checkersMap;

  const CustomGridCheckersFormField(
      {super.key, required this.validator, required this.checkersMap});

  @override
  Widget build(BuildContext context) {
    return FormField(
      validator: validator,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 12,
              childAspectRatio: 6,
              physics: const NeverScrollableScrollPhysics(),
              children: checkersMap.keys.map((label) {
                return Row(
                  children: [
                    Checkbox(
                      value: checkersMap[label] ?? false,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        checkersMap[label] = value ?? false;
                        field.reset();
                      },
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          if (field.errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                field.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
