import 'package:flutter/foundation.dart';
import 'package:serv_oeste/src/models/filtro_servico/filtro_servico.dart';

class FiltroServicoProvider extends ChangeNotifier {
  FiltroServicoModel _filter = FiltroServicoModel();

  FiltroServicoModel get filter => _filter;

  void updateFilter({
    int? codigo,
    String? tecnico,
    String? equipamento,
    String? situacao,
    String? filial,
    String? garantia,
    String? horario,
    DateTime? dataPrevista,
    DateTime? dataEfetiva,
    DateTime? dataAbertura,
  }) {
    _filter = FiltroServicoModel(
      codigo: codigo ?? _filter.codigo,
      tecnico: tecnico ?? _filter.tecnico,
      equipamento: equipamento ?? _filter.equipamento,
      situacao: situacao ?? _filter.situacao,
      filial: filial ?? _filter.filial,
      garantia: garantia ?? _filter.garantia,
      horario: horario ?? _filter.horario,
      dataPrevista: dataPrevista ?? _filter.dataPrevista,
      dataEfetiva: dataEfetiva ?? _filter.dataEfetiva,
      dataAbertura: dataAbertura ?? _filter.dataAbertura,
    );
    notifyListeners();
  }
}
