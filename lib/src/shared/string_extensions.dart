extension Situation on String? {
  String toSituation() {
    return switch (this) {
      "Desativado" => "DESATIVADO",
      "Licença" => "LICENCA",
      _ => "ATIVO",
    };
  }
}