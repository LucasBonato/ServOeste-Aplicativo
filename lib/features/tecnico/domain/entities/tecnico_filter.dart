class TecnicoFilter {
  final int? id;
  final String? nome;
  final String? situacao;
  final String? equipamento;
  final String? telefone;

  const TecnicoFilter({
    this.id,
    this.nome,
    this.situacao,
    this.equipamento,
    this.telefone
  });

  TecnicoFilter merge(TecnicoFilter? fixed) {
    if (fixed == null) return this;
    return TecnicoFilter(
      nome: _pick(fixed.nome, nome),
      situacao: _pick(fixed.situacao, situacao),
      equipamento: _pick(fixed.equipamento, equipamento),
      telefone: _pick(fixed.telefone, telefone)
    );
  }

  static String? _pick(String? fixed, String? dynamic) => (fixed != null && fixed.isNotEmpty)
      ? fixed
      : dynamic;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TecnicoFilter) return false;

    return other.id == id &&
        other.nome == nome &&
        other.situacao == situacao &&
        other.equipamento == equipamento &&
        other.telefone == telefone;
  }

  @override
  int get hashCode => Object.hash(id, nome, situacao, equipamento, telefone);
}
