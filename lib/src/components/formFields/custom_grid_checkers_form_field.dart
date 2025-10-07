import 'package:flutter/material.dart';

class CustomGridCheckersFormField extends StatelessWidget {
  final String? Function([String?])? validator;
  final Map<String, bool> checkersMap;
  final Function(bool)? onOutrosSelected;
  final String? title;

  const CustomGridCheckersFormField(
      {super.key,
      required this.validator,
      required this.checkersMap,
      this.onOutrosSelected,
      this.title});

  @override
  Widget build(BuildContext context) {
    return FormField(
      validator: validator,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 0),
            child: Text(
              title ?? "",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
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
                return InkWell(
                  onTap: () {
                    final newValue = !(checkersMap[label] ?? false);
                    checkersMap[label] = newValue;
                    if (label == "Outros" && onOutrosSelected != null) {
                      onOutrosSelected!(newValue);
                    }
                    field.reset();
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        value: checkersMap[label] ?? false,
                        activeColor: Color(0xFF007BFF),
                        onChanged: (value) {
                          checkersMap[label] = value ?? false;
                          if (label == "Outros" && onOutrosSelected != null) {
                            onOutrosSelected!(value ?? false);
                          }
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
                  ),
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
