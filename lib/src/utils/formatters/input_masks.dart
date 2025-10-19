import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:serv_oeste/src/utils/formatters/currency_input_formatter.dart';

class InputMasks {
  static final List<MaskTextInputFormatter> cep = [
    MaskTextInputFormatter(
      mask: '#####-###',
      filter: {"#": RegExp(r'[0-9]')},
    ),
  ];
  static final List<MaskTextInputFormatter> telefoneCelular = [
    MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
    ),
  ];
  static final List<MaskTextInputFormatter> telefoneFixo = [
    MaskTextInputFormatter(
      mask: '(##) ####-####',
      filter: {"#": RegExp(r'[0-9]')},
    ),
  ];
  static final List<MaskTextInputFormatter> data = [
    MaskTextInputFormatter(
      mask: '##/##/####',
      filter: {"#": RegExp(r'[0-9]')},
    ),
  ];
  static final List<TextInputFormatter> alphanumericLetters = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))];
  static final List<TextInputFormatter> currency = [CurrencyInputFormatter()];
}
