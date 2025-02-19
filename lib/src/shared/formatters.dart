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
      "Não Retira há 3 meses" =>
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
