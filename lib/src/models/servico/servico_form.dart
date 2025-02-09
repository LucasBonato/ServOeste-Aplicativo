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
  ValueNotifier<String> garantia = ValueNotifier<String>("");
  ValueNotifier<String> situacao = ValueNotifier<String>("");
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
    this.garantia.value = garantia?? "";
    notifyListeners();
  }

  void setGarantiaBool(bool? garantia) {
    if (garantia != null) {
      this.garantia.value = (garantia) ? Constants.garantias.first : Constants.garantias.last;
      notifyListeners();
    }
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
      this.dataPagamentoComissao.value = Formatters.applyDateMask(dataPagamentoComissao);
      notifyListeners();
    }
  }

  void setDataPagamentoComissao(String? dataPagamentoComissao) {
    this.dataPagamentoComissao.value = dataPagamentoComissao ?? "";
    notifyListeners();
  }

  void setFormaPagamento(String? formaPagamento) {
    this.formaPagamento.value = formaPagamento?? "";
    notifyListeners();
  }

  void setValor(String? valor) {
    if (valor != null) {
      double? valueConverted = double.tryParse(valor);

      if (valueConverted != null && valueConverted > 0) {
        this.valor.value = valueConverted.toString();
        notifyListeners();
      }
    }
  }

  void setValorPecas(String? valorPecas) {
    if (valorPecas != null) {
      double? valueConverted = double.tryParse(valorPecas);

      if (valueConverted != null && valueConverted > 0) {
        this.valorPecas.value = valueConverted.toString();
        notifyListeners();
      }
    }
  }

  void setValorComissao(String? valorComissao) {
    if (valorComissao != null) {
      double? valueConverted = double.tryParse(valorComissao);

      if (valueConverted != null && valueConverted > 0) {
        this.valorComissao.value = valueConverted.toString();
        notifyListeners();
      }
    }
  }
}
