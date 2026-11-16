enum ServiceStatus {
  aguardandoAgendamento('AGUARDANDO_AGENDAMENTO', 'Aguardando agendamento'),
  aguardandoAtendimento('AGUARDANDO_ATENDIMENTO', 'Aguardando atendimento'),
  cancelado('CANCELADO', 'Cancelado'),
  semDefeito('SEM_DEFEITO', 'Sem defeito'),
  aguardandoOrcamento('AGUARDANDO_ORCAMENTO', 'Aguardando orçamento'),
  aguardandoAprovacaoCliente(
    'AGUARDANDO_APROVACAO',
    'Aguardando aprovação do cliente',
  ),
  compra('COMPRA', 'Compra'),
  naoAprovadoPeloCliente('NAO_APROVADO', 'Não aprovado pelo cliente'),
  orcamentoAprovado('ORCAMENTO_APROVADO', 'Orçamento aprovado'),
  resolvido('RESOLVIDO', 'Resolvido'),
  garantia('GARANTIA', 'Garantia');

  final String _apiValue;
  final String _label;

  const ServiceStatus(this._apiValue, this._label);

  String get apiValue => _apiValue;
  String get label => _label;
  static List<String> get labels =>
      values.map((status) => status.label).toList();

  static ServiceStatus fromJson(String value) {
    return ServiceStatus.values.firstWhere(
      (status) =>
          status._apiValue == value ||
          status._label.toLowerCase() == value.toLowerCase(),
      orElse: () => throw FormatException('Unknown service status: $value'),
    );
  }

  String toJson() => _apiValue;
}
