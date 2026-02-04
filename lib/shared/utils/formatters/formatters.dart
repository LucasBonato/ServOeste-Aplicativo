import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:serv_oeste/shared/models/enums/service_status.dart';

class Formatters {
  static String formatPhonePdf(String? phone, {required bool isCell}) {
    if (phone == null || phone.isEmpty) {
      return isCell ? '(   )          -' : '(   )          -';
    }
    return isCell
        ? Formatters.applyCellPhoneMask(phone)
        : Formatters.applyPhoneMask(phone);
  }

  static String applyPhoneMask(String phone) {
    if (phone.length < 10) return phone;
    return "(${phone.substring(0, 2)}) ${phone.substring(2, 6)}-${phone.substring(6)}";
  }

  static String applyCellPhoneMask(String phone) {
    if (phone.length < 11) return phone;
    return "(${phone.substring(0, 2)}) ${phone.substring(2, 7)}-${phone.substring(7)}";
  }

  static String transformPhoneMask(String phone) {
    if (phone.length < 14 || phone.length > 15) return "";
    return phone
        .replaceAll("(", "")
        .replaceAll(")", "")
        .replaceAll(" ", "")
        .replaceAll("-", "");
  }

  static String formatDatePdf(DateTime? date) {
    if (date == null) {
      return '   /   /   ';
    }
    return Formatters.applyDateMask(date);
  }

  static String applyDateMask(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static DateTime transformDateMask(String dateString) {
    return DateFormat('dd/MM/yyyy').parseStrict(dateString);
  }

  static String formatDateForHistory(dynamic date) {
    if (date == null) return "Não informado";

    if (date is DateTime) {
      return applyDateMask(date);
    }

    final dateString = date.toString();
    return convertUsToBrDate(dateString);
  }

  static String convertUsToBrDate(String usDate) {
    if (usDate.isEmpty) return '';

    final parts = usDate.split('/');
    if (parts.length == 3) {
      return '${parts[1]}/${parts[0]}/${parts[2]}';
    }

    return usDate;
  }

  static DateTime parseBrDateForSorting(String brDate) {
    List<String> parts = brDate.split('/');
    if (parts.length == 3) {
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]) + 2000;
      return DateTime(year, month, day);
    }

    return DateTime.now();
  }

  static List<Map<String, String>> parseServiceHistory(String history) {
    List<Map<String, String>> entries = [];

    final dateRegex = RegExp(r'\[(.*?)\]');
    List<String> dates =
        dateRegex.allMatches(history).map((m) => m.group(1)!).toList();

    String textWithoutDates = history.replaceAll(dateRegex, '').trim();

    List<String> blocks = textWithoutDates
        .split(' - ')
        .where((p) => p.trim().isNotEmpty && p.trim() != '-')
        .toList();

    List<Map<String, String>> temporaryEntries = [];

    for (int i = 0; i < blocks.length; i++) {
      String currentBlock = blocks[i].trim();

      if (currentBlock.contains('\n')) {
        List<String> parts = currentBlock.split('\n');
        if (parts.length >= 2) {
          String description = parts[0].trim();
          String situation = parts[1].trim();

          temporaryEntries.add({
            'situacao': situation,
            'descricao': description,
          });
        }
      } else if (currentBlock.contains("ABERTURA:")) {
        String situation = currentBlock;
        String description = '';

        if (i + 1 < blocks.length && !blocks[i + 1].contains("ABERTURA:")) {
          description = blocks[i + 1].trim();
          i++;
        }

        temporaryEntries.add({
          'situacao': situation,
          'descricao': description,
        });
      } else if (currentBlock.toUpperCase().contains("AGUARDANDO") ||
          currentBlock.toUpperCase().contains("CANCELADO") ||
          currentBlock.toUpperCase().contains("RESOLVIDO") ||
          currentBlock.toUpperCase().contains("GARANTIA")) {
        String situation = currentBlock;
        String description = '';

        if (i + 1 < blocks.length &&
            !blocks[i + 1].toUpperCase().contains("AGUARDANDO") &&
            !blocks[i + 1].toUpperCase().contains("CANCELADO") &&
            !blocks[i + 1].toUpperCase().contains("RESOLVIDO")) {
          description = blocks[i + 1].trim();
          i++;
        }

        temporaryEntries.add({
          'situacao': situation,
          'descricao': description,
        });
      } else if (temporaryEntries.isNotEmpty) {
        int lastIndex = temporaryEntries.length - 1;
        if (temporaryEntries[lastIndex]['descricao']!.isEmpty) {
          temporaryEntries[lastIndex]['descricao'] = currentBlock;
        }
      }
    }

    for (int i = 0; i < temporaryEntries.length; i++) {
      String date = '';

      if (i < dates.length) {
        date = Formatters.convertUsToBrDate(dates[i]);
      }

      entries.add({
        'situacao': temporaryEntries[i]['situacao']!,
        'descricao': temporaryEntries[i]['descricao']!,
        'data': date,
      });
    }

    entries.sort((a, b) {
      if (a['data']!.isEmpty && b['data']!.isEmpty) return 0;
      if (a['data']!.isEmpty) return -1;
      if (b['data']!.isEmpty) return 1;

      try {
        DateTime dateA = Formatters.parseBrDateForSorting(a['data']!);
        DateTime dateB = Formatters.parseBrDateForSorting(b['data']!);
        return dateA.compareTo(dateB);
      } catch (e) {
        return a['data']!.compareTo(b['data']!);
      }
    });

    entries = entries.reversed.toList();

    return entries;
  }

  static DateTime? extractDateFromDescription(String? description) {
    if (description == null) return null;

    try {
      final regex = RegExp(r'(\d{1,2}/\d{1,2}/\d{2,4})');
      final matches = regex.allMatches(description);

      if (matches.isEmpty) return null;

      final dates = <DateTime>[];

      for (final match in matches) {
        final dateStr = match.group(0);
        if (dateStr != null) {
          final parts = dateStr.split('/');
          if (parts.length == 3) {
            int day = int.parse(parts[0]);
            int month = int.parse(parts[1]);
            int year = int.parse(parts[2]);

            if (year < 100) {
              year += 2000;
            }

            final date = DateTime(year, month, day);
            dates.add(date);
          }
        }
      }

      if (dates.isEmpty) return null;

      dates.sort();
      return dates.first;
    } catch (e) {
      Logger().e('Erro ao extrair data da descrição: $e');
      return null;
    }
  }

  static String formatScheduleTime(String time) {
    switch (time) {
      case "MANHA":
        return "Manhã";
      case "TARDE":
        return "Tarde";
      default:
        return time[0].toUpperCase() + time.substring(1);
    }
  }

  static String formatValuePdf(double? value) {
    if (value == null || value == 0) return 'Não informado';
    return Formatters.formatToCurrency(value);
  }

  static String formatToCurrency(double value) {
    final NumberFormat formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(value);
  }

  static double parseCurrencyToDouble(String formattedValue) {
    String cleanedValue = formattedValue
        .replaceAll("R\$", "")
        .replaceAll(".", "")
        .replaceAll(",", ".")
        .trim();

    return double.tryParse(cleanedValue) ?? 0.0;
  }

  static double? parseDouble(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    String cleanedValue =
        value.replaceAll(RegExp(r'[^\d,]'), '').replaceAll(',', '.');

    double? parsedValue = double.tryParse(cleanedValue);
    return parsedValue;
  }

  static double parseToDouble(String value) {
    if (value.isEmpty) return 0.0;

    String sanitizedValue = value.replaceAll(RegExp(r'[^\d,]'), '');

    sanitizedValue = sanitizedValue.replaceAll(',', '.');

    return double.tryParse(sanitizedValue) ?? 0.0;
  }

  static String formatDescriptionForPDF(String? history) {
    if (history == null || history.isEmpty) {
      return 'Sem descrição';
    }

    try {
      final entries = parseServiceHistory(history);
      if (entries.isEmpty) return history;

      final invertedEntries = entries.reversed.toList();

      final buffer = StringBuffer();

      for (final entry in invertedEntries) {
        final situation = entry['situacao'] ?? '';
        final description = entry['descricao'] ?? '';
        final date = entry['data'] ?? '';

        if (date.isNotEmpty) {
          buffer.write('$date - $situation');
        } else {
          buffer.write(situation);
        }

        buffer.write('\n');

        if (description.isNotEmpty) {
          buffer.write('  $description');
        }

        buffer.write('\n\n');
      }

      return buffer.toString().trim();
    } catch (e) {
      Logger().e('Erro ao formatar descrição para PDF: $e');
      return history;
    }
  }

  static double getResponsiveFontSize(
    double containerWidth, {
    required double min,
    required double max,
    required double factor,
  }) {
    final double calculatedSize = containerWidth * factor;
    return calculatedSize.clamp(min, max);
  }

  static String getRoleDisplayName(String role) {
    switch (role) {
      case 'ADMIN':
        return 'Administrador';
      case 'EMPLOYEE':
        return 'Balcão';
      case 'TECHNICIAN':
        return 'Técnico';
      default:
        return role;
    }
  }

  static ServiceStatus mapStringStatusToEnumStatus(String status) {
    return switch (status) {
      "AGUARDANDO_AGENDAMENTO" ||
      "Aguardando agendamento" =>
        ServiceStatus.aguardandoAgendamento,
      "AGUARDANDO_ATENDIMENTO" ||
      "Aguardando atendimento" =>
        ServiceStatus.aguardandoAtendimento,
      "AGUARDANDO_APROVACAO" ||
      "Aguardando aprovação do cliente" =>
        ServiceStatus.aguardandoAprovacaoCliente,
      "AGUARDANDO_CLIENTE_RETIRAR" ||
      "Aguardando cliente retirar" =>
        ServiceStatus.aguardandoClienteRetirar,
      "AGUARDANDO_ORCAMENTO" ||
      "Aguardando orçamento" =>
        ServiceStatus.aguardandoOrcamento,
      "CANCELADO" || "Cancelado" => ServiceStatus.cancelado,
      "COMPRA" || "Compra" => ServiceStatus.compra,
      "CORTESIA" || "Cortesia" => ServiceStatus.cortesia,
      "GARANTIA" || "Garantia" => ServiceStatus.garantia,
      "NAO_APROVADO" ||
      "Não aprovado pelo cliente" =>
        ServiceStatus.naoAprovadoPeloCliente,
      "NAO_RETIRA_3_MESES" ||
      "Não retira há 3 meses" =>
        ServiceStatus.naoRetira3Meses,
      "ORCAMENTO_APROVADO" ||
      "Orçamento aprovado" =>
        ServiceStatus.orcamentoAprovado,
      "RESOLVIDO" || "Resolvido" => ServiceStatus.resolvido,
      "SEM_DEFEITO" || "Sem defeito" => ServiceStatus.semDefeito,
      _ => ServiceStatus.aguardandoAgendamento
    };
  }

  static String mapSituationToEnumSituation(String situation) {
    return switch (situation) {
      "Aguardando agendamento" => "AGUARDANDO_AGENDAMENTO",
      "Aguardando atendimento" => "AGUARDANDO_ATENDIMENTO",
      "Aguardando aprovação do cliente" => "AGUARDANDO_APROVACAO",
      "Aguardando cliente retirar" => "AGUARDANDO_CLIENTE_RETIRAR",
      "Aguardando orçamento" => "AGUARDANDO_ORCAMENTO",
      "Cancelado" => "CANCELADO",
      "Compra" => "COMPRA",
      "Cortesia" => "CORTESIA",
      "Garantia" => "GARANTIA",
      "Não aprovado pelo cliente" => "NAO_APROVADO",
      "Não retira há 3 meses" => "NAO_RETIRA_3_MESES",
      "Orçamento aprovado" => "ORCAMENTO_APROVADO",
      "Resolvido" => "RESOLVIDO",
      "Sem defeito" => "SEM_DEFEITO",
      _ => "AGUARDANDO_AGENDAMENTO"
    };
  }
}
