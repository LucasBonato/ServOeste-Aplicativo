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
      "Aguardando Agendamento" =>
        ServiceStatus.aguardandoAgendamento,
      "AGUARDANDO_ATENDIMENTO" ||
      "Aguardando Atendimento" =>
        ServiceStatus.aguardandoAtendimento,
      "AGUARDANDO_APROVACAO" ||
      "Aguardando Aprovação do Cliente" =>
        ServiceStatus.aguardandoAprovacaoCliente,
      "AGUARDANDO_CLIENTE_RETIRAR" ||
      "Aguardando Cliente Retirar" =>
        ServiceStatus.aguardandoClienteRetirar,
      "AGUARDANDO_ORCAMENTO" ||
      "Aguardando Orçamento" =>
        ServiceStatus.aguardandoOrcamento,
      "CANCELADO" || "Cancelado" => ServiceStatus.cancelado,
      "COMPRA" || "Compra" => ServiceStatus.compra,
      "CORTESIA" || "Cortesia" => ServiceStatus.cortesia,
      "GARANTIA" || "Garantia" => ServiceStatus.garantia,
      "NAO_APROVADO" ||
      "Não Aprovado pelo Cliente" =>
        ServiceStatus.naoAprovadoPeloCliente,
      "NAO_RETIRA_3_MESES" ||
      "Não Retira há 3 Meses" =>
        ServiceStatus.naoRetira3Meses,
      "ORCAMENTO_APROVADO" ||
      "Orçamento Aprovado" =>
        ServiceStatus.orcamentoAprovado,
      "RESOLVIDO" || "Resolvido" => ServiceStatus.resolvido,
      "SEM_DEFEITO" || "Sem Defeito" => ServiceStatus.semDefeito,
      _ => ServiceStatus.aguardandoAgendamento
    };
  }

  static String mapSituationToEnumSituation(String situation) {
    return switch (situation) {
      "Aguardando Agendamento" => "AGUARDANDO_AGENDAMENTO",
      "Aguardando Atendimento" => "AGUARDANDO_ATENDIMENTO",
      "Aguardando Aprovação do Cliente" => "AGUARDANDO_APROVACAO",
      "Aguardando Cliente Retirar" => "AGUARDANDO_CLIENTE_RETIRAR",
      "Aguardando Orçamento" => "AGUARDANDO_ORCAMENTO",
      "Cancelado" => "CANCELADO",
      "Compra" => "COMPRA",
      "Cortesia" => "CORTESIA",
      "Garantia" => "GARANTIA",
      "Não Aprovado pelo Cliente" => "NAO_APROVADO",
      "Não Retira há 3 Meses" => "NAO_RETIRA_3_MESES",
      "Orçamento Aprovado" => "ORCAMENTO_APROVADO",
      "Resolvido" => "RESOLVIDO",
      "Sem Defeito" => "SEM_DEFEITO",
      _ => "AGUARDANDO_AGENDAMENTO"
    };
  }
}
