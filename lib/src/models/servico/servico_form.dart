import 'package:serv_oeste/src/shared/constants.dart';
import 'package:flutter/cupertino.dart';

class ServicoForm extends ChangeNotifier {
  ValueNotifier<String> equipamento = ValueNotifier("");
  ValueNotifier<String> marca = ValueNotifier("");
  ValueNotifier<String> filial = ValueNotifier(Constants.filiais[0]);
  ValueNotifier<String> dataAtendimentoPrevisto = ValueNotifier("");
  ValueNotifier<String> horarioPrevisto = ValueNotifier(Constants.dataAtendimento[0]);
  ValueNotifier<String> descricao = ValueNotifier("");
  ValueNotifier<String> nomeTecnico = ValueNotifier("");
  ValueNotifier<int?> idTecnico = ValueNotifier(null);
  ValueNotifier<int?> idCliente = ValueNotifier(null);

  void setEquipamento(String? equipamento) {
    if(equipamento != null && equipamento.isNotEmpty) {
      this.equipamento.value = Constants.equipamentos.contains(equipamento) ? equipamento : "Outros";
      notifyListeners();
    } else {
      this.equipamento.value = "";
    }
  }

  void setMarca(String? marca) {
    this.marca.value = marca?? "";
    notifyListeners();
  }

  void setFilial(String? filial) {
    if (filial != null) {
      this.filial.value = filial;
      notifyListeners();
    }
  }

  void setDataAtendimentoPrevisto(String? dataAtendimentoPrevisto) {
    this.dataAtendimentoPrevisto.value = dataAtendimentoPrevisto?? "";
    notifyListeners();
  }

  void setHorarioPrevisto(String? horarioPrevisto) {
    this.horarioPrevisto.value = horarioPrevisto?? "";
    notifyListeners();
  }

  void setDescricao(String? descricao) {
    this.descricao.value = descricao?? "";
    notifyListeners();
  }

  void setNomeTecnico(String? nomeTecnico) {
    this.nomeTecnico.value = nomeTecnico?? "";
    notifyListeners();
  }

  void setIdTecnico(int? idTecnico) {
    this.idTecnico.value = idTecnico;
    notifyListeners();
  }

  void setIdCliente(int? idCliente) {
    this.idCliente.value = idCliente;
    notifyListeners();
  }

  bool isRequiredFieldsFilled() {
    return (
        idTecnico.value != null &&
        equipamento.value.isNotEmpty &&
        descricao.value.isNotEmpty
      );
  }
}