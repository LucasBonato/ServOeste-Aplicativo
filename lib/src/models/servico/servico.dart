import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:serv_oeste/src/shared/constants.dart';

class Servico {
  int id;
  int idCliente;
  int idTecnico;
  String nomeCliente;
  String nomeTecnico;
  String equipamento;
  String filial;
  String marca;
  String situacao;
  String? horarioPrevisto;
  String? descricao;
  String? formaPagamento;
  bool? garantia;
  double? valor;
  double? valorComissao;
  double? valorPecas;
  DateTime? dataAtendimentoPrevisto;
  DateTime? dataAtendimentoEfetivo;
  DateTime? dataAtendimentoAbertura;
  DateTime? dataFechamento;
  DateTime? dataInicioGarantia;
  DateTime? dataFimGarantia;
  DateTime? dataPagamentoComissao;
  String? dataAtendimentoPrevistoString;
  String? dataAtendimentoEfetivoString;
  String? dataAtendimentoAberturaString;
  String? dataFechamentoString;
  String? dataInicioGarantiaString;
  String? dataFimGarantiaString;
  String? dataPagamentoComissaoString;

  Servico({
    required this.id,
    required this.idCliente,
    required this.idTecnico,
    required this.nomeCliente,
    required this.nomeTecnico,
    required this.equipamento,
    required this.filial,
    required this.marca,
    required this.situacao,
    this.horarioPrevisto,
    this.dataAtendimentoPrevisto,
    this.descricao,
    this.dataFechamento,
    this.garantia,
    this.formaPagamento,
    this.valor,
    this.valorPecas,
    this.valorComissao,
    this.dataAtendimentoEfetivo,
    this.dataAtendimentoAbertura,
    this.dataInicioGarantia,
    this.dataFimGarantia,
    this.dataPagamentoComissao,
  });

  Servico.fromForm(ServicoForm servicoForm)
      : id = servicoForm.getId()!,
        idCliente = servicoForm.getIdCliente()!,
        idTecnico = servicoForm.getIdTecnico()!,
        equipamento = servicoForm.equipamento.value,
        filial = servicoForm.filial.value,
        horarioPrevisto =
            servicoForm.horario.value.toLowerCase().replaceAll("ã", "a"),
        marca = servicoForm.marca.value,
        situacao = servicoForm.situacao.value,
        descricao = servicoForm.descricao.value,
        garantia = (servicoForm.getGarantia() == Constants.garantias.first ||
                servicoForm.getGarantia() == Constants.garantias.last)
            ? servicoForm.getGarantia() == Constants.garantias.first
            : null,
        formaPagamento = servicoForm.formaPagamento.value.isEmpty
            ? null
            : servicoForm.formaPagamento.value,
        valor = double.tryParse(servicoForm.valor.value),
        valorComissao = double.tryParse(servicoForm.valorComissao.value),
        valorPecas = double.tryParse(servicoForm.valorPecas.value),
        dataAtendimentoPrevistoString =
            servicoForm.dataAtendimentoPrevisto.value,
        dataAtendimentoEfetivoString =
            (servicoForm.dataAtendimentoEfetivo.value.isEmpty)
                ? null
                : servicoForm.dataAtendimentoEfetivo.value,
        dataAtendimentoAberturaString =
            (servicoForm.dataAtendimentoAbertura.value.isEmpty)
                ? null
                : servicoForm.dataAtendimentoAbertura.value,
        dataFechamentoString = (servicoForm.dataFechamento.value.isEmpty)
            ? null
            : servicoForm.dataFechamento.value,
        dataPagamentoComissaoString =
            (servicoForm.dataPagamentoComissao.value.isEmpty)
                ? null
                : servicoForm.dataPagamentoComissao.value,
        dataInicioGarantiaString =
            (servicoForm.dataInicioGarantia.value.isEmpty)
                ? null
                : servicoForm.dataInicioGarantia.value,
        dataFimGarantiaString = (servicoForm.dataFinalGarantia.value.isEmpty)
            ? null
            : servicoForm.dataFinalGarantia.value,
        nomeCliente = servicoForm.nomeCliente.value,
        nomeTecnico = servicoForm.nomeTecnico.value;

  factory Servico.fromJson(Map<String, dynamic> json) => Servico(
        id: json["id"],
        idCliente: json["idCliente"],
        idTecnico: json["idTecnico"],
        nomeCliente: json["nomeCliente"],
        nomeTecnico: json["nomeTecnico"],
        equipamento: json["equipamento"],
        filial: json["filial"],
        horarioPrevisto: json["horarioPrevisto"],
        marca: json["marca"],
        descricao: json["descricao"],
        situacao: json["situacao"],
        garantia: json["garantia"],
        formaPagamento: json["formaPagamento"],
        valor: json["valor"],
        valorPecas: json["valorPecas"],
        valorComissao: json["valorComissao"],
        dataInicioGarantia: json["dataInicioGarantia"] != null
            ? DateTime.parse(json["dataInicioGarantia"])
            : null,
        dataFimGarantia: json["dataFimGarantia"] != null
            ? DateTime.parse(json["dataFimGarantia"])
            : null,
        dataPagamentoComissao: json["dataPagamentoComissao"] != null
            ? DateTime.parse(json["dataPagamentoComissao"])
            : null,
        dataAtendimentoPrevisto: json["dataAtendimentoPrevisto"] != null
            ? DateTime.parse(json["dataAtendimentoPrevisto"])
            : null,
        dataFechamento: json["dataFechamento"] != null
            ? DateTime.parse(json["dataFechamento"])
            : null,
        dataAtendimentoEfetivo: json["dataAtendimentoEfetiva"] != null
            ? DateTime.parse(json["dataAtendimentoEfetiva"])
            : null,
        dataAtendimentoAbertura: json["dataAtendimentoAbertura"] != null
            ? DateTime.parse(json["dataAtendimentoAbertura"])
            : null,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idCliente': idCliente,
      'idTecnico': idTecnico,
      'nomeCliente': nomeCliente,
      'nomeTecnico': nomeTecnico,
      'equipamento': equipamento,
      'filial': filial,
      'horarioPrevisto': horarioPrevisto,
      'marca': marca,
      'situacao': situacao,
      'descricao': descricao,
      'formaPagamento': formaPagamento,
      'garantia': garantia,
      'valor': valor,
      'valorComissao': valorComissao,
      'valorPecas': valorPecas,
      'dataAtendimentoPrevisto': dataAtendimentoPrevisto?.toIso8601String(),
      'dataAtendimentoEfetivo': dataAtendimentoEfetivo?.toIso8601String(),
      'dataAtendimentoAbertura': dataAtendimentoAbertura?.toIso8601String(),
      'dataFechamento': dataFechamento?.toIso8601String(),
      'dataInicioGarantia': dataInicioGarantia?.toIso8601String(),
      'dataFimGarantia': dataFimGarantia?.toIso8601String(),
      'dataPagamentoComissao': dataPagamentoComissao?.toIso8601String(),
    };
  }
}
