import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class InputMasks {
  static final List<MaskTextInputFormatter> maskCep = [
    MaskTextInputFormatter(
      mask: '#####-###',
      filter: {"#": RegExp(r'[0-9]')},
    ),
  ];
  static final List<MaskTextInputFormatter> maskCelular = [
    MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
    ),
  ];
  static final List<MaskTextInputFormatter> maskTelefoneFixo = [
    MaskTextInputFormatter(
      mask: '(##) ####-####',
      filter: {"#": RegExp(r'[0-9]')},
    ),
  ];
  static final List<MaskTextInputFormatter> maskData = [
    MaskTextInputFormatter(
      mask: '##/##/####',
      filter: {"#": RegExp(r'[0-9]')},
    ),
  ];
}
