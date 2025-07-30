import 'package:flutter/material.dart';

extension StringConversions on String? {
  String toSituation() {
    return switch (this) {
      "Desativado" => "DESATIVADO",
      "Licença" => "LICENCA",
      _ => "ATIVO",
    };
  }
}
