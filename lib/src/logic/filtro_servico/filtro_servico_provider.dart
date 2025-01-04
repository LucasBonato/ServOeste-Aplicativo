import 'package:flutter/foundation.dart';
import 'package:serv_oeste/src/models/servico/servico_filter_request.dart';

class FiltroServicoProvider extends ChangeNotifier {
  ServicoFilterRequest _filter = ServicoFilterRequest();

  ServicoFilterRequest get filter => _filter;

  void clearFields() {
    _filter = ServicoFilterRequest();
    notifyListeners();
  }

  void resetFilter({bool resetAll = true}) {
    if (resetAll) {
      _filter = ServicoFilterRequest();
    } else {
      _filter = ServicoFilterRequest(
        id: null,
        clienteId: null,
        tecnicoId: null,
        clienteNome: null,
        tecnicoNome: null,
        equipamento: null,
        situacao: null,
        filial: null,
        garantia: null,
        periodo: null,
        dataAtendimentoPrevistoAntes: null,
        dataAtendimentoPrevistoDepois: null,
        dataAtendimentoEfetivoAntes: null,
        dataAtendimentoEfetivoDepois: null,
        dataAberturaAntes: null,
        dataAberturaDepois: null,
      );
    }
    notifyListeners();
  }

  void updateFilter({
    int? codigo,
    String? tecnico,
    String? equipamento,
    String? situacao,
    String? filial,
    String? garantia,
    String? periodo,
    DateTime? dataPrevista,
    DateTime? dataEfetiva,
    DateTime? dataAbertura,
  }) {
    _filter = ServicoFilterRequest(
      id: codigo ?? _filter.id,
      tecnicoNome: tecnico ?? _filter.tecnicoNome,
      equipamento: equipamento ?? _filter.equipamento,
      situacao: situacao ?? _filter.situacao,
      filial: filial ?? _filter.filial,
      garantia: garantia ?? _filter.garantia,
      periodo: periodo ?? _filter.periodo,
      dataAtendimentoPrevistoAntes: dataPrevista ?? _filter.dataAtendimentoPrevistoAntes,
      dataAtendimentoEfetivoAntes: dataEfetiva ?? _filter.dataAtendimentoEfetivoAntes,
      dataAberturaAntes: dataAbertura ?? _filter.dataAberturaAntes,
    );
    notifyListeners();
  }
}
