import 'package:flutter/material.dart';

class BuildFieldLabels extends StatelessWidget {
  final bool isClientAndService;

  const BuildFieldLabels({
    super.key,
    this.isClientAndService = true,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        children: [
          Text(
            "* - Campos obrigatórios",
            style: TextStyle(
              fontSize:
                  (MediaQuery.of(context).size.width * 0.01).clamp(12.0, 14.0),
              color: Colors.black,
            ),
          ),
          if (isClientAndService) ...[
            const SizedBox(width: 12),
            Text(
              "** - Preencha ao menos um destes campos",
              style: TextStyle(
                fontSize: (MediaQuery.of(context).size.width * 0.01)
                    .clamp(12.0, 14.0),
                color: Colors.black,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
