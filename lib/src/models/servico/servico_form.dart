import 'package:flutter/material.dart';
import 'package:serv_oeste/src/shared/formatters.dart';

class ServicoForm extends ChangeNotifier {
  ValueNotifier<int?> id = ValueNotifier(null);
  ValueNotifier<int?> idCliente = ValueNotifier(null);
  ValueNotifier<int?> idTecnico = ValueNotifier(null);
  ValueNotifier<String> equipamento = ValueNotifier<String>("");
  ValueNotifier<String> marca = ValueNotifier<String>("");
  ValueNotifier<String> filial = ValueNotifier<String>("");
  ValueNotifier<String> nomeCliente = ValueNotifier<String>("");
  ValueNotifier<String> nomeTecnico = ValueNotifier<String>("");
  ValueNotifier<String> dataPrevista = ValueNotifier<String>("");
  ValueNotifier<String> horario = ValueNotifier<String>("");
  ValueNotifier<String> descricao = ValueNotifier<String>("");
  ValueNotifier<String> garantia = ValueNotifier<String>("");
  ValueNotifier<String> situacao = ValueNotifier<String>("");
  ValueNotifier<String> dataAtendimentoPrevisto = ValueNotifier<String>("");
  ValueNotifier<String> dataAtendimentoEfetivo = ValueNotifier<String>("");
  ValueNotifier<String> dataAtendimentoAbertura = ValueNotifier<String>("");

  void setId(int? id) {
    this.id.value = id;
    notifyListeners();
  }

  void setIdCliente(int? idCliente) {
    this.idCliente.value = idCliente;
    notifyListeners();
  }

  void setIdTecnico(int? idTecnico) {
    this.idTecnico.value = idTecnico;
    notifyListeners();
  }

  void setEquipamento(String? equipamento) {
    this.equipamento.value = equipamento ?? "";
    notifyListeners();
  }

  void setMarca(String? marca) {
    this.marca.value = marca ?? "";
    notifyListeners();
  }

  void setFilial(String? filial) {
    this.filial.value = filial ?? "";
    notifyListeners();
  }

  void setNomeTecnico(String? nomeTecnico) {
    this.nomeTecnico.value = nomeTecnico ?? "";
    notifyListeners();
  }

  void setNomeCliente(String? nomeCliente) {
    this.nomeCliente.value = nomeCliente ?? "";
    notifyListeners();
  }

  void setDataPrevista(String? dataPrevista) {
    this.dataPrevista.value = dataPrevista ?? "";
    notifyListeners();
  }

  void setHorario(String? horario) {
    if (horario != null) {
      this.horario.value = (horario == "manha") ? "Manhã" : "Tarde";
      notifyListeners();
    }
  }

  void setDescricao(String? descricao) {
    this.descricao.value = descricao ?? "";
    notifyListeners();
  }

  void setGarantia(String? garantia) {
    this.garantia.value = garantia ?? "";
    notifyListeners();
  }

  void setSituacao(String? situacao) {
    if (situacao != null) {
      this.situacao.value = Formatters.mapStringStatusToEnumStatus(situacao).getSituacao();
      notifyListeners();
    }
  }

  void setDataAtendimentoPrevistoDate(DateTime? dataAtendimentoPrevisto) {
    if (dataAtendimentoPrevisto != null) {
      this.dataAtendimentoPrevisto.value = Formatters.applyDateMask(dataAtendimentoPrevisto);
      notifyListeners();
    }
  }

  void setDataAtendimentoPrevisto(String? dataAtendimentoPrevisto) {
    this.dataAtendimentoPrevisto.value = dataAtendimentoPrevisto ?? "";
    notifyListeners();
  }

  void setDataAtendimentoEfetivoDate(DateTime? dataAtendimentoEfetivo) {
    if (dataAtendimentoEfetivo != null) {
      this.dataAtendimentoEfetivo.value = Formatters.applyDateMask(dataAtendimentoEfetivo);
      notifyListeners();
    }
  }

  void setDataAtendimentoEfetivo(String? dataAtendimentoEfetivo) {
    this.dataAtendimentoEfetivo.value = dataAtendimentoEfetivo ?? "";
    notifyListeners();
  }

  void setDataAtendimentoAberturaDate(DateTime? dataAtendimentoAbertura) {
    if (dataAtendimentoAbertura != null) {
      this.dataAtendimentoAbertura.value = Formatters.applyDateMask(dataAtendimentoAbertura);
      notifyListeners();
    }
  }

  void setDataAtendimentoAbertura(String? dataAtendimentoAbertura) {
    this.dataAtendimentoAbertura.value = dataAtendimentoAbertura ?? "";
    notifyListeners();
  }
}
