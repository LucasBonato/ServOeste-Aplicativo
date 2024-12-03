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
    this.periodo,
  });

  ServicoFilterRequest copyWith({
    DateTime? dataAtendimentoPrevistoAntes,
    DateTime? dataAtendimentoPrevistoDepois,
    int? clienteId,
    int? tecnicoId,
    String? filial,
    String? periodo,
  }) {
    return ServicoFilterRequest(
      dataAtendimentoPrevistoAntes:
          dataAtendimentoPrevistoAntes ?? this.dataAtendimentoPrevistoAntes,
      dataAtendimentoPrevistoDepois:
          dataAtendimentoPrevistoDepois ?? this.dataAtendimentoPrevistoDepois,
      clienteId: clienteId ?? this.clienteId,
      tecnicoId: tecnicoId ?? this.tecnicoId,
      filial: filial ?? this.filial,
      periodo: periodo ?? this.periodo,
    );
  }
}
