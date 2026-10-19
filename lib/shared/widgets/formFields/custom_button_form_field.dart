import 'package:flutter/material.dart';

class CustomButtonFormField extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final String? tooltipMessage;
  final bool Function()? enabledCalculator;
  final ValueNotifier<String> valueNotifier;

  const CustomButtonFormField({
    super.key,
    required this.valueNotifier,
    required this.onPressed,
    required this.text,
    this.enabledCalculator,
    this.tooltipMessage
  });

  @override
  State<StatefulWidget> createState() => _CustomButtonFormFieldState();
}

class _CustomButtonFormFieldState extends State<CustomButtonFormField> {

  Widget _buildField(bool enabled, String equipamento) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: enabled ? widget.onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: equipamento.isNotEmpty
                ? Color(0xFF007BFF)
                : Colors.grey.withValues(alpha: 0.5),
            minimumSize: const Size(0, 54),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldWithTooltip(String equipamento) {
    final bool isFieldEnabled = widget.enabledCalculator?.call()?? false;
    final Widget field = _buildField(isFieldEnabled, equipamento);

    return (widget.tooltipMessage?.isNotEmpty ?? false)
        ? Tooltip(
          message: (isFieldEnabled) ? "" : widget.tooltipMessage!,
          textAlign: TextAlign.center,
          child: field,
        )
        : field;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.valueNotifier,
      builder: (context, equipamentoSelecionado, child) {
        return _buildFieldWithTooltip(equipamentoSelecionado);
      },
    );
  }
}
