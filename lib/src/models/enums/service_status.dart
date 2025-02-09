enum ServiceStatus {
  aguardandoAgendamento("Aguardando Agendamento"),
  aguardandoAtendimento("Aguardando Atendimento"),
  aguardandoAprovacaoCliente("Aguardando Aprovação do Cliente"),
  aguardandoClienteRetirar("Aguardando Cliente Retirar"),
  aguardandoOrcamento("Aguardando Orçamento"),
  cancelado("Cancelado"),
  compra("Compra"),
  cortesia("Cortesia"),
  garantia("Garantia"),
  naoAprovadoPeloCliente("Não Aprovado Pelo Cliente"),
  naoRetira3Meses("Não Retira há 3 Meses"),
  orcamentoAprovado("Orçamento Aprovado"),
  resolvido("Resolvido"),
  semDefeito("Sem Defeito");

  final String situacao;

  const ServiceStatus(this.situacao);

  String getSituacao() {
    return situacao;
  }
}