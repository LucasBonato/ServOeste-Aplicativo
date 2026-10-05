enum ServiceStatus {
  aguardandoAgendamento("Aguardando agendamento"),
  aguardandoAtendimento("Aguardando atendimento"),
  aguardandoAprovacaoCliente("Aguardando aprovação do cliente"),
  aguardandoClienteRetirar("Aguardando cliente retirar"),
  cancelado("Cancelado"),
  compra("Compra"),
  cortesia("Cortesia"),
  garantia("Garantia"),
  naoAprovadoPeloCliente("Não aprovado Pelo cliente"),
  naoRetira3Meses("Não retira há 3 meses"),
  orcamentoAprovado("Orçamento aprovado"),
  resolvido("Resolvido"),
  semDefeito("Sem defeito");

  final String _situacao;

  const ServiceStatus(this._situacao);

  String getSituacao() {
    return normalize(_situacao);
  }

  String getHumanizedSituacao() {
    return _situacao;
  }

  static ServiceStatus fromString(String status) {
    return switch (status) {
      "AGUARDANDO_AGENDAMENTO" ||
      "Aguardando agendamento" => ServiceStatus.aguardandoAgendamento,
      "AGUARDANDO_ATENDIMENTO" ||
      "Aguardando atendimento" => ServiceStatus.aguardandoAtendimento,
      "AGUARDANDO_APROVACAO" || "Aguardando aprovação do cliente" =>
      ServiceStatus.aguardandoAprovacaoCliente,
      "AGUARDANDO_CLIENTE_RETIRAR" ||
      "Aguardando cliente retirar" => ServiceStatus.aguardandoClienteRetirar,
      "CANCELADO" || "Cancelado" => ServiceStatus.cancelado,
      "COMPRA" || "Compra" => ServiceStatus.compra,
      "CORTESIA" || "Cortesia" => ServiceStatus.cortesia,
      "GARANTIA" || "Garantia" => ServiceStatus.garantia,
      "NAO_APROVADO" ||
      "Não aprovado pelo cliente" => ServiceStatus.naoAprovadoPeloCliente,
      "NAO_RETIRA_3_MESES" ||
      "Não retira há 3 meses" => ServiceStatus.naoRetira3Meses,
      "ORCAMENTO_APROVADO" ||
      "Orçamento aprovado" => ServiceStatus.orcamentoAprovado,
      "RESOLVIDO" || "Resolvido" => ServiceStatus.resolvido,
      "SEM_DEFEITO" || "Sem defeito" => ServiceStatus.semDefeito,
      _ => ServiceStatus.aguardandoAgendamento,
    };
  }

  static String normalize(String situation) {
    return switch (situation) {
      "Aguardando agendamento" => "AGUARDANDO_AGENDAMENTO",
      "Aguardando atendimento" => "AGUARDANDO_ATENDIMENTO",
      "Aguardando aprovação do cliente" => "AGUARDANDO_APROVACAO",
      "Aguardando cliente retirar" => "AGUARDANDO_CLIENTE_RETIRAR",
      "Cancelado" => "CANCELADO",
      "Compra" => "COMPRA",
      "Cortesia" => "CORTESIA",
      "Garantia" => "GARANTIA",
      "Não aprovado pelo cliente" => "NAO_APROVADO",
      "Não retira há 3 meses" => "NAO_RETIRA_3_MESES",
      "Orçamento aprovado" => "ORCAMENTO_APROVADO",
      "Resolvido" => "RESOLVIDO",
      "Sem defeito" => "SEM_DEFEITO",
      _ => "AGUARDANDO_AGENDAMENTO",
    };
  }
}
