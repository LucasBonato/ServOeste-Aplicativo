class ClienteFilter {
  final String? nome;
  final String? telefone;
  final String? endereco;

  const ClienteFilter({
    this.nome,
    this.telefone,
    this.endereco
  });

  ClienteFilter copyWith({
    String? nome,
    String? telefone,
    String? endereco,
  }) {
    return ClienteFilter(
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      endereco: endereco ?? this.endereco,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ClienteFilter) return false;

    return other.nome == nome &&
      other.telefone == telefone &&
      other.endereco == endereco;
  }

  @override
  int get hashCode => Object.hash(nome, telefone, endereco);
}
