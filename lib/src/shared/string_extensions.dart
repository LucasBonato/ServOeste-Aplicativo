extension Situation on String {
  String toSituation() {
    return switch (this) {
      "Ativo" => "ATIVO",
      "Licença" => "LICENCA",
      "Desativado" => "DESATIVADO",
    // TODO: Handle this case.
      _ => throw UnimplementedError(),
    };
  }
}