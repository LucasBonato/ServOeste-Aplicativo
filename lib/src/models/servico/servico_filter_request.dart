class ServicoFilterRequest {
  final DateTime? dataAtendimentoPrevistoAntes;
  final DateTime? dataAtendimentoPrevistoDepois;
  final int? clienteId;
  final int? tecnicoId;
  final String? clienteNome;
  final String? tecnicoNome;
  final String? filial;
  final String? periodo;

  ServicoFilterRequest({
    this.dataAtendimentoPrevistoAntes,
    this.dataAtendimentoPrevistoDepois,
    this.clienteId,
    this.tecnicoId,
    this.clienteNome,
    this.tecnicoNome,
    this.filial,
    this.periodo
  });
}