import 'package:flutter/material.dart';
import 'package:serv_oeste/src/shared/constants.dart';
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
  ValueNotifier<String> horario = ValueNotifier<String>("");
  ValueNotifier<String> descricao = ValueNotifier<String>("");
  ValueNotifier<String> historico = ValueNotifier<String>("");
  ValueNotifier<String> situacao = ValueNotifier<String>("");
  ValueNotifier<String> garantia = ValueNotifier<String>("");
  ValueNotifier<String> dataInicioGarantia = ValueNotifier<String>("");
  ValueNotifier<String> dataFinalGarantia = ValueNotifier<String>("");
  ValueNotifier<String> dataAtendimentoPrevisto = ValueNotifier<String>("");
  ValueNotifier<String> dataAtendimentoEfetivo = ValueNotifier<String>("");
  ValueNotifier<String> dataAtendimentoAbertura = ValueNotifier<String>("");
  ValueNotifier<String> dataFechamento = ValueNotifier<String>("");
  ValueNotifier<String> dataPagamentoComissao = ValueNotifier<String>("");
  ValueNotifier<String> formaPagamento = ValueNotifier<String>("");
  ValueNotifier<String> valor = ValueNotifier("");
  ValueNotifier<String> valorPecas = ValueNotifier("");
  ValueNotifier<String> valorComissao = ValueNotifier("");

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

  void setHorario(String? horario) {
    this.horario.value = horario ?? "";
    notifyListeners();
  }

  void setDescricao(String? descricao) {
    this.descricao.value = descricao ?? "";
    notifyListeners();
  }

  void setHistorico(String? historico) {
    this.historico.value = historico ?? "";
    notifyListeners();
  }

  void setSituacao(String? situacao) {
    if (situacao != null) {
      this.situacao.value =
          Formatters.mapStringStatusToEnumStatus(situacao).getSituacao();
      notifyListeners();
    }
  }

  void setGarantia(String? garantia) {
    this.garantia.value = garantia ?? "";
    notifyListeners();
  }

  void setGarantiaBool(bool? garantia) {
    if (garantia != null) {
      this.garantia.value =
          (garantia) ? Constants.garantias.first : Constants.garantias.last;
      notifyListeners();
    }
  }

  void setDataInicioGarantia(String? dataInicioGarantia) {
    this.dataInicioGarantia.value = dataInicioGarantia ?? "";
    notifyListeners();
  }

  void setDataFinalGarantia(String? dataFinalGarantia) {
    this.dataFinalGarantia.value = dataFinalGarantia ?? "";
    notifyListeners();
  }

  void setDataInicioGarantiaDate(DateTime? dataInicioGarantia) {
    if (dataInicioGarantia != null) {
      this.dataInicioGarantia.value =
          Formatters.applyDateMask(dataInicioGarantia);
      notifyListeners();
    }
  }

  void setDataFinalGarantiaDate(DateTime? dataFinalGarantia) {
    if (dataFinalGarantia != null) {
      this.dataFinalGarantia.value =
          Formatters.applyDateMask(dataFinalGarantia);
      notifyListeners();
    }
  }

  void setDataAtendimentoPrevistoDate(DateTime? dataAtendimentoPrevisto) {
    if (dataAtendimentoPrevisto != null) {
      this.dataAtendimentoPrevisto.value =
          Formatters.applyDateMask(dataAtendimentoPrevisto);
      notifyListeners();
    }
  }

  void setDataAtendimentoPrevisto(String? dataAtendimentoPrevisto) {
    this.dataAtendimentoPrevisto.value = dataAtendimentoPrevisto ?? "";
    notifyListeners();
  }

  void setDataAtendimentoEfetivoDate(DateTime? dataAtendimentoEfetivo) {
    if (dataAtendimentoEfetivo != null) {
      this.dataAtendimentoEfetivo.value =
          Formatters.applyDateMask(dataAtendimentoEfetivo);
      notifyListeners();
    }
  }

  void setDataAtendimentoEfetivo(String? dataAtendimentoEfetivo) {
    this.dataAtendimentoEfetivo.value = dataAtendimentoEfetivo ?? "";
    notifyListeners();
  }

  void setDataAtendimentoAberturaDate(DateTime? dataAtendimentoAbertura) {
    if (dataAtendimentoAbertura != null) {
      this.dataAtendimentoAbertura.value =
          Formatters.applyDateMask(dataAtendimentoAbertura);
      notifyListeners();
    }
  }

  void setDataAtendimentoAbertura(String? dataAtendimentoAbertura) {
    this.dataAtendimentoAbertura.value = dataAtendimentoAbertura ?? "";
    notifyListeners();
  }

  void setDataFechamentoDate(DateTime? dataFechamento) {
    if (dataFechamento != null) {
      this.dataFechamento.value = Formatters.applyDateMask(dataFechamento);
      notifyListeners();
    }
  }

  void setDataFechamento(String? dataFechamento) {
    this.dataFechamento.value = dataFechamento ?? "";
    notifyListeners();
  }

  void setDataPagamentoComissaoDate(DateTime? dataPagamentoComissao) {
    if (dataPagamentoComissao != null) {
      this.dataPagamentoComissao.value =
          Formatters.applyDateMask(dataPagamentoComissao);
      notifyListeners();
    }
  }

  void setDataPagamentoComissao(String? dataPagamentoComissao) {
    this.dataPagamentoComissao.value = dataPagamentoComissao ?? "";
    notifyListeners();
  }

  void setFormaPagamento(String? formaPagamento) {
    this.formaPagamento.value = formaPagamento ?? "";
    notifyListeners();
  }

  void setValor(String? valor) {
    if (valor == "null") {
      valor = null;
    }
    if (valor != null) {
      double valueConverted = double.tryParse(valor) ?? 0;

      if (valueConverted > 0) {
        this.valor.value = valueConverted.toString();
        _calculateCommission();
        notifyListeners();
      }
    }
  }

  void setValorPecas(String? valorPecas) {
    if (valorPecas == "null") {
      valorPecas = null;
    }
    if (valorPecas != null) {
      double valueConverted = double.tryParse(valorPecas) ?? 0;

      if (valueConverted >= 0) {
        this.valorPecas.value = valueConverted.toString();
        _calculateCommission();
        notifyListeners();
      }
    }
  }

  void _calculateCommission() {
    if (valor.value.isNotEmpty && valor.value.isNotEmpty) {
      double pieceValue = double.tryParse(valorPecas.value) ?? 0;
      double value = double.tryParse(valor.value) ?? 0;

      double commission = (value - pieceValue) / 2;
      setValorComissao(commission.toString());
    }
  }

  void setValorComissao(String? valorComissao) {
    if (valorComissao == "null") {
      valorComissao = "";
    }
    if (valorComissao != null) {
      double valueConverted = double.tryParse(valorComissao) ?? 0;

      if (valueConverted >= 0) {
        this.valorComissao.value = valueConverted.toString();
        notifyListeners();
      }
    }
  }

  int? getId() {
    return id.value;
  }

  int? getIdCliente() {
    return idCliente.value;
  }

  int? getIdTecnico() {
    return idTecnico.value;
  }

  String getGarantia() {
    return garantia.value;
  }
}
