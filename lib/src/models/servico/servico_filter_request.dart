class ServicoFilterRequest {
  final DateTime? dataAtendimentoPrevistoAntes;
  final DateTime? dataAtendimentoPrevistoDepois;
  final int? clienteId;
  final int? tecnicoId;
  final String? filial;
  final String? periodo;

  ServicoFilterRequest({
    this.dataAtendimentoPrevistoAntes,
    this.dataAtendimentoPrevistoDepois,
    this.clienteId,
    this.tecnicoId,
    this.filial,
    this.periodo
  });
}