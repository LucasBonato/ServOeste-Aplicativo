class ServicoFilter {
  final int? id;
  final int? clienteId;
  final int? tecnicoId;
  final String? clienteNome;
  final String? tecnicoNome;
  final String? equipamento;
  final String? marca;
  final String? situacao;
  final String? garantia;
  final String? filial;
  final String? periodo;
  final DateTime? dataAtendimentoPrevistoAntes;
  final DateTime? dataAtendimentoPrevistoDepois;
  final DateTime? dataAtendimentoEfetivoAntes;
  final DateTime? dataAtendimentoEfetivoDepois;
  final DateTime? dataAberturaAntes;
  final DateTime? dataAberturaDepois;

  const ServicoFilter({
    this.id,
    this.clienteId,
    this.tecnicoId,
    this.clienteNome,
    this.tecnicoNome,
    this.equipamento,
    this.marca,
    this.situacao,
    this.garantia,
    this.filial,
    this.periodo,
    this.dataAtendimentoPrevistoAntes,
    this.dataAtendimentoPrevistoDepois,
    this.dataAtendimentoEfetivoAntes,
    this.dataAtendimentoEfetivoDepois,
    this.dataAberturaAntes,
    this.dataAberturaDepois,
  });

  ServicoFilter copyWith({
    int? id,
    int? clienteId,
    int? tecnicoId,
    String? clienteNome,
    String? tecnicoNome,
    String? equipamento,
    String? marca,
    String? situacao,
    String? garantia,
    String? filial,
    String? periodo,
    DateTime? dataAtendimentoPrevistoAntes,
    DateTime? dataAtendimentoPrevistoDepois,
    DateTime? dataAtendimentoEfetivoAntes,
    DateTime? dataAtendimentoEfetivoDepois,
    DateTime? dataAberturaAntes,
    DateTime? dataAberturaDepois,
  }) {
    return ServicoFilter(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      tecnicoId: tecnicoId ?? this.tecnicoId,
      clienteNome: clienteNome ?? this.clienteNome,
      tecnicoNome: tecnicoNome ?? this.tecnicoNome,
      equipamento: equipamento ?? this.equipamento,
      marca: marca ?? this.marca,
      situacao: situacao ?? this.situacao,
      garantia: garantia ?? this.garantia,
      filial: filial ?? this.filial,
      periodo: periodo ?? this.periodo,
      dataAtendimentoPrevistoAntes: dataAtendimentoPrevistoAntes ?? this.dataAtendimentoPrevistoAntes,
      dataAtendimentoPrevistoDepois: dataAtendimentoPrevistoDepois ?? this.dataAtendimentoPrevistoDepois,
      dataAtendimentoEfetivoAntes: dataAtendimentoEfetivoAntes ?? this.dataAtendimentoEfetivoAntes,
      dataAtendimentoEfetivoDepois: dataAtendimentoEfetivoDepois ?? this.dataAtendimentoEfetivoDepois,
      dataAberturaAntes: dataAberturaAntes ?? this.dataAberturaAntes,
      dataAberturaDepois: dataAberturaDepois ?? this.dataAberturaDepois,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clienteId': clienteId,
      'tecnicoId': tecnicoId,
      'clienteNome': clienteNome,
      'tecnicoNome': tecnicoNome,
      'equipamento': equipamento,
      'marca': marca,
      'situacao': situacao,
      'garantia': garantia,
      'filial': filial,
      'periodo': periodo,
      'dataAtendimentoPrevistoAntes': dataAtendimentoPrevistoAntes?.toIso8601String(),
      'dataAtendimentoPrevistoDepois': dataAtendimentoPrevistoDepois?.toIso8601String(),
      'dataAtendimentoEfetivoAntes': dataAtendimentoEfetivoAntes?.toIso8601String(),
      'dataAtendimentoEfetivoDepois': dataAtendimentoEfetivoDepois?.toIso8601String(),
      'dataAberturaAntes': dataAberturaAntes?.toIso8601String(),
      'dataAberturaDepois': dataAberturaDepois?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ServicoFilter) return false;

    return other.id == id &&
      other.clienteId == clienteId &&
      other.tecnicoId == tecnicoId &&
      other.clienteNome == clienteNome &&
      other.tecnicoNome == tecnicoNome &&
      other.equipamento == equipamento &&
      other.marca == marca &&
      other.situacao == situacao &&
      other.garantia == garantia &&
      other.filial == filial &&
      other.periodo == periodo &&
      other.dataAtendimentoPrevistoAntes == dataAtendimentoPrevistoAntes &&
      other.dataAtendimentoPrevistoDepois == dataAtendimentoPrevistoDepois &&
      other.dataAtendimentoEfetivoAntes == dataAtendimentoEfetivoAntes &&
      other.dataAtendimentoEfetivoDepois == dataAtendimentoEfetivoDepois &&
      other.dataAberturaAntes == dataAberturaAntes &&
      other.dataAberturaDepois == dataAberturaDepois;
  }

  @override
  int get hashCode => Object.hash(
    id,
    clienteId,
    tecnicoId,
    clienteNome,
    tecnicoNome,
    equipamento,
    marca,
    situacao,
    garantia,
    filial,
    periodo,
    dataAtendimentoPrevistoAntes,
    dataAtendimentoPrevistoDepois,
    dataAtendimentoEfetivoAntes,
    dataAtendimentoEfetivoDepois,
    dataAberturaAntes,
    dataAberturaDepois,
  );
}
