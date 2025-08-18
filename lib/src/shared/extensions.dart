extension StringConversions on String? {
  String toSituation() {
    return switch (this) {
      "Desativado" => "DESATIVADO",
      "Licença" => "LICENCA",
      _ => "ATIVO",
    };
  }

  String convertToHorarioString() {
    if (this == "manha") {
      return "Manhã";
    }
    else if (this == "tarde") {
      return "Tarde";
    }
    return "";
  }
}

extension StringEnumConversion on String {
  String convertEnumStatusToString() {
    final specialCases = {
      'NAO_RETIRA_3_MESES': 'Não retira há 3 meses',
      'AGUARDANDO_APROVACAO': 'Aguardando aprovação do cliente',
      'AGUARDANDO_ORCAMENTO': 'Aguardando orçamento',
      'ORCAMENTO_APROVADO': 'Orçamento aprovado',
      'NAO_APROVADO': 'Não aprovado pelo cliente',
    };

    if (specialCases.containsKey(this)) {
      return specialCases[this]!;
    }

    String convertedStatus = "${this[0]}${substring(1).replaceAll("_", " ").toLowerCase()}";
    return convertedStatus;
  }
}
