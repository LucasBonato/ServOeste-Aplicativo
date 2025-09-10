import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:serv_oeste/src/models/servico/servico.dart';
import 'package:serv_oeste/src/shared/constants/constants.dart';
import 'package:serv_oeste/src/utils/extensions/string_extensions.dart';
import 'package:serv_oeste/src/utils/formatters/formatters.dart';

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
  double valorNumerico = 0.0;
  double valorPecasNumerico = 0.0;
  double valorComissaoNumerico = 0.0;

  void setForm(Servico servico) {
    id.value = servico.idCliente;
    idCliente.value = servico.idCliente;
    nomeCliente.value = servico.nomeCliente;
    equipamento.value = servico.equipamento;
    marca.value = servico.marca;
    nomeTecnico.value = servico.nomeTecnico ?? "";
    idTecnico.value = servico.idTecnico;
    filial.value = servico.filial;
    situacao.value = servico.situacao.convertEnumStatusToString();
    horario.value = servico.horarioPrevisto.convertToHorarioString();
    if (servico.dataAtendimentoPrevisto != null) {
      dataAtendimentoPrevisto.value =
          Formatters.applyDateMask(servico.dataAtendimentoPrevisto!);
    }
    if (servico.dataAtendimentoEfetivo != null) {
      dataAtendimentoEfetivo.value =
          Formatters.applyDateMask(servico.dataAtendimentoEfetivo!);
    }
    if (servico.dataAtendimentoAbertura != null) {
      dataAtendimentoAbertura.value =
          Formatters.applyDateMask(servico.dataAtendimentoAbertura!);
    }
    valor.value = Formatters.formatToCurrency(servico.valor ?? 0.0);
    valorPecas.value = Formatters.formatToCurrency(servico.valorPecas ?? 0.0);
    valorComissao.value =
        Formatters.formatToCurrency(servico.valorComissao ?? 0.0);
    formaPagamento.value = servico.formaPagamento ?? "";
    if (servico.dataFechamento != null) {
      dataFechamento.value = Formatters.applyDateMask(servico.dataFechamento!);
    }
    if (servico.dataPagamentoComissao != null) {
      dataPagamentoComissao.value =
          Formatters.applyDateMask(servico.dataPagamentoComissao!);
    }
    if (servico.dataInicioGarantia != null) {
      dataInicioGarantia.value =
          Formatters.applyDateMask(servico.dataInicioGarantia!);
    }
    if (servico.dataFimGarantia != null) {
      dataFinalGarantia.value =
          Formatters.applyDateMask(servico.dataFimGarantia!);
    }
    if (servico.garantia != null) {
      garantia.value = (servico.garantia!)
          ? Constants.garantias.first
          : Constants.garantias.last;
    }
    historico.value = servico.descricao ?? "";
    notifyListeners();
  }

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
    Logger().w('Situação: $situacao');
    if (situacao != null && situacao != this.situacao.value) {
      this.situacao.value =
          Formatters.mapStringStatusToEnumStatus(situacao).getSituacao();
      Logger()
          .w(Formatters.mapStringStatusToEnumStatus(situacao).getSituacao());
      Logger().w(this.situacao.value);
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

  void setValorServico(String? valorFormatado) {
    if (valorFormatado == "null") {
      valorFormatado = null;
    }
    if (valorFormatado != null) {
      valor.value = valorFormatado;
      valorNumerico = Formatters.parseCurrencyToDouble(valorFormatado);
      notifyListeners();
      Future.delayed(Duration.zero, _calculateCommission);
    }
  }

  void setValorNumerico(double valor) {
    String valorFormatado = Formatters.formatToCurrency(valor);
    this.valor.value = valorFormatado;
    valorNumerico = valor;

    notifyListeners();
    Future.delayed(Duration.zero, _calculateCommission);
  }

  void setValorPecas(String? valorPecasFormatado) {
    if (valorPecasFormatado == "null") {
      valorPecasFormatado = null;
    }
    if (valorPecasFormatado != null) {
      valorPecas.value = valorPecasFormatado;
      valorPecasNumerico =
          Formatters.parseCurrencyToDouble(valorPecasFormatado);

      notifyListeners();
      Future.delayed(Duration.zero, _calculateCommission);
    }
  }

  void setValorPecasNumerico(double valorPecasNumerico) {
    String valorPecasFormatado =
        Formatters.formatToCurrency(valorPecasNumerico);

    valorPecasNumerico = valorPecasNumerico;
    valorPecas.value = valorPecasFormatado;

    notifyListeners();
    Future.delayed(Duration.zero, _calculateCommission);
  }

  void _calculateCommission() {
    if (valor.value.isNotEmpty && valorPecas.value.isNotEmpty) {
      double pieceValue = Formatters.parseCurrencyToDouble(valorPecas.value);
      double value = Formatters.parseCurrencyToDouble(valor.value);

      double commission = (value - pieceValue) / 2;

      if (commission < 0) {
        commission = 0;
      }

      String formattedCommission = commission.toStringAsFixed(2);
      setValorComissao(formattedCommission);
    }
  }

  void setValorComissao(String? valorComissaoFormatado) {
    if (valorComissaoFormatado == "null") {
      valorComissaoFormatado = null;
    }
    if (valorComissaoFormatado != null) {
      valorComissao.value = valorComissaoFormatado;
      valorComissaoNumerico =
          Formatters.parseCurrencyToDouble(valorComissaoFormatado);
      notifyListeners();
    }
  }

  void setValorComissaoNumerico(double valorComissaoNumerico) {
    String valorComissaoFormatado =
        Formatters.formatToCurrency(valorComissaoNumerico);

    valorComissaoNumerico = valorComissaoNumerico;
    valorComissao.value = valorComissaoFormatado;
    notifyListeners();
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
