class TecnicoFilter {
  final int? id;
  final String? nome;
  final String? situacao;

  const TecnicoFilter({
    this.id,
    this.nome,
    this.situacao,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TecnicoFilter) return false;

    return other.id == id &&
        other.nome == nome &&
        other.situacao == situacao;
  }

  @override
  int get hashCode => Object.hash(id, nome, situacao);
}
