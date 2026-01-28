enum ServiceStatus {
  aguardandoAgendamento("Aguardando agendamento"),
  aguardandoAtendimento("Aguardando atendimento"),
  aguardandoAprovacaoCliente("Aguardando aprovação do cliente"),
  aguardandoClienteRetirar("Aguardando cliente retirar"),
  aguardandoOrcamento("Aguardando orçamento"),
  cancelado("Cancelado"),
  compra("Compra"),
  cortesia("Cortesia"),
  garantia("Garantia"),
  naoAprovadoPeloCliente("Não aprovado Pelo cliente"),
  naoRetira3Meses("Não retira há 3 meses"),
  orcamentoAprovado("Orçamento aprovado"),
  resolvido("Resolvido"),
  semDefeito("Sem defeito");

  final String situacao;

  const ServiceStatus(this.situacao);

  String getSituacao() {
    return situacao;
  }
}
