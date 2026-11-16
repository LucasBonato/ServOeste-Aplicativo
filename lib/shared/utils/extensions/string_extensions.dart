extension StringConversions on String? {
  String toSituation() {
    return switch (this) {
      "Desativado" => "DESATIVADO",
      "Licença" => "LICENCA",
      _ => "ATIVO",
    };
  }

  String convertSituation() {
    return switch (this) {
      "DESATIVADO" => "DESATIVADO",
      "LICENCA" => "LICENÇA",
      _ => "ATIVO",
    };
  }

  String convertToHorarioString() {
    if (this == "MANHA") {
      return "Manhã";
    } else if (this == "TARDE") {
      return "Tarde";
    }
    return "";
  }
}
