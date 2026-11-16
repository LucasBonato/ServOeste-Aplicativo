enum ServicePeriodo {
  manha('MANHA', 'Manhã'),
  tarde('TARDE', 'Tarde');

  final String _apiValue;
  final String _label;

  const ServicePeriodo(this._apiValue, this._label);

  String get apiValue => _apiValue;
  String get label => _label;

  static ServicePeriodo fromJson(String value) {
    return ServicePeriodo.values.firstWhere(
      (periodo) =>
          periodo._apiValue == value ||
          periodo._label.toLowerCase() == value.toLowerCase(),
      orElse: () => throw FormatException('Unknown service period: $value'),
    );
  }

  String toJson() => _apiValue;
}
