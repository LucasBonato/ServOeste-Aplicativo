import 'package:flutter/foundation.dart';
import 'package:serv_oeste/src/models/filterService/filterService.dart';

class FilterServiceProvider extends ChangeNotifier {
  FilterServiceModel _filter = FilterServiceModel();

  FilterServiceModel get filter => _filter;

  void updateFilter({
    String? endereco,
    String? equipamento,
    String? situacao,
    String? filial,
    String? garantia,
    String? horario,
    String? dataPrevista,
    String? dataEfetiva,
    String? dataAbertura,
  }) {
    _filter = FilterServiceModel(
      endereco: endereco ?? _filter.endereco,
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
