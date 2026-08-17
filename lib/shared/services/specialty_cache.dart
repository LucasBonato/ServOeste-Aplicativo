import 'package:serv_oeste/features/specialty/domain/specialty_repository.dart';
import 'package:serv_oeste/features/tecnico/domain/entities/tecnico.dart';

class SpecialtyCache {
  static const String outrosLabel = "Outros";

  final SpecialtyRepository _repository;

  List<Especialidade>? _specialties;

  SpecialtyCache(this._repository);

  bool get hasData => _specialties != null;

  List<Especialidade> get specialties => List.unmodifiable(_specialties ?? const []);

  List<Especialidade> get activeSpecialties => List.unmodifiable((_specialties ?? const []).where((s) => s.ativo));

  Map<String, int> get activeIdByConhecimento => {for (final Especialidade especialidade in activeSpecialties) especialidade.conhecimento: especialidade.id};

  int? idByConhecimento(String conhecimento) => activeIdByConhecimento[conhecimento];

  List<String> activeConhecimentosOrdered() {
    final List<Especialidade> active = activeSpecialties;
    final List<String> ordered = [
      for (final Especialidade especialidade in active)
        if (!_isOutros(especialidade.conhecimento)) especialidade.conhecimento,
    ];
    return ordered;
  }

  List<String> activeConhecimentosOrderedWithOutros() {
    final List<String> ordered = activeConhecimentosOrdered();
    ordered.addAll([
      for (final Especialidade especialidade in activeSpecialties)
        if (_isOutros(especialidade.conhecimento)) especialidade.conhecimento,
    ]);
    return ordered;
  }

  bool _isOutros(String conhecimento) => conhecimento.trim().toLowerCase() == outrosLabel.toLowerCase();

  Future<void> warmUp() async {
    if (_specialties != null) return;
    await refresh();
  }

  Future<void> refresh() async {
    final result = await _repository.findAll();
    result.fold((error) => throw error, (specialties) => _specialties = specialties);
  }

  void clear() {
    _specialties = null;
  }
}
