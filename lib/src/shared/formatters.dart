import 'package:intl/intl.dart';
import 'package:serv_oeste/src/models/enums/service_status.dart';

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

  static ServiceStatus mapStringStatusToEnumStatus(String status) {
    return switch (status) {
      "AGUARDANDO_AGENDAMENTO" => ServiceStatus.aguardandoAgendamento,
      "AGUARDANDO_ATENDIMENTO" => ServiceStatus.aguardandoAtendimento,
      "AGUARDANDO_APROVACAO" => ServiceStatus.aguardandoAprovacaoCliente,
      "AGUARDANDO_CLIENTE_RETIRAR" => ServiceStatus.aguardandoClienteRetirar,
      "AGUARDANDO_ORCAMENTO" => ServiceStatus.aguardandoOrcamento,
      "CANCELADO" => ServiceStatus.cancelado,
      "COMPRA" => ServiceStatus.compra,
      "CORTESIA" => ServiceStatus.cortesia,
      "GARANTIA" => ServiceStatus.garantia,
      "NAO_APROVADO" => ServiceStatus.naoAprovadoPeloCliente,
      "NAO_RETIRA_3_MESES" => ServiceStatus.naoRetira3Meses,
      "ORCAMENTO_APROVADO" => ServiceStatus.orcamentoAprovado,
      "RESOLVIDO" => ServiceStatus.resolvido,
      "SEM_DEFEITO" => ServiceStatus.semDefeito,
      _ => ServiceStatus.aguardandoAgendamento
    };
  }
}
