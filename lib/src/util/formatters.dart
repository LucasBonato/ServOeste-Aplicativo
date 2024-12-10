import 'package:intl/intl.dart';

class Formatters {
  static String applyTelefoneMask(String telefone) {
    if (telefone.length < 10) return telefone;
    return "(${telefone.substring(0, 2)}) ${telefone.substring(2, 6)}-${telefone.substring(6)}";
  }

  static String applyCelularMask(String telefone) {
    if (telefone.length < 11) return telefone;
    return "(${telefone.substring(0, 2)}) ${telefone.substring(2, 7)}-${telefone.substring(7)}";
  }

  static String transformTelefoneMask(String telefone) {
    if (telefone.length < 14 || telefone.length > 15) return "";
    return telefone
        .replaceAll("(", "")
        .replaceAll(")", "")
        .replaceAll(" ", "")
        .replaceAll("-", "");
  }

  static String applyDateMask(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static DateTime transformDateMask(String dateString) {
    return DateFormat('dd/MM/yyyy').parseStrict(dateString);
  }
}
