import 'package:serv_oeste/src/models/servico/servico_form.dart';
import 'package:serv_oeste/src/shared/constants.dart';

class Servico {
  late int id;
  late int idCliente;
  late int idTecnico;
  late String nomeCliente;
  late String nomeTecnico;
  late String equipamento;
  late String filial;
  late String horarioPrevisto;
  late String marca;
  late String situacao;
  late String? descricao;
  late bool? garantia;
  late String? formaPagamento;
  late double? valor;
  late double? valorComissao;
  late double? valorPecas;
  late DateTime dataAtendimentoPrevisto;
  late DateTime? dataAtendimentoEfetivo;
  late DateTime? dataAtendimentoAbertura;
  late DateTime? dataFechamento;
  late DateTime? dataInicioGarantia;
  late DateTime? dataFimGarantia;
  late DateTime? dataPagamentoComissao;

  Servico({
    required this.id,
    required this.idCliente,
    required this.idTecnico,
    required this.nomeCliente,
    required this.nomeTecnico,
    required this.equipamento,
    required this.filial,
    required this.horarioPrevisto,
    required this.marca,
    required this.situacao,
    required this.dataAtendimentoPrevisto,
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

  Servico.fromForm(ServicoForm servicoForm) {
    id = servicoForm.getId()!;
    idCliente = servicoForm.getIdCliente()!;
    idTecnico = servicoForm.getIdTecnico()!;
    equipamento = servicoForm.equipamento.value;
    filial = servicoForm.filial.value;
    horarioPrevisto = servicoForm.horario.value;
    marca = servicoForm.marca.value;
    situacao = servicoForm.situacao.value;
    descricao = servicoForm.descricao.value;
    garantia = (servicoForm.getGarantia() == Constants.garantias.first || servicoForm.getGarantia() == Constants.garantias.last) ? servicoForm.getGarantia() == Constants.garantias.first : null;
    formaPagamento = servicoForm.formaPagamento.value.isEmpty ? null : servicoForm.formaPagamento.value;
    valor = double.tryParse(servicoForm.valor.value);
    valorComissao = double.tryParse(servicoForm.valorComissao.value);
    valorPecas = double.tryParse(servicoForm.valorPecas.value);
    dataAtendimentoPrevisto = DateTime.parse(servicoForm.dataAtendimentoPrevisto.value);
    dataAtendimentoEfetivo = (servicoForm.dataAtendimentoEfetivo.value != "") ? null : DateTime.parse(servicoForm.dataAtendimentoEfetivo.value);
    dataAtendimentoAbertura = (servicoForm.dataAtendimentoAbertura.value != "") ? null : DateTime.parse(servicoForm.dataAtendimentoAbertura.value);
    dataFechamento = (servicoForm.dataFechamento.value != "") ? null : DateTime.parse(servicoForm.dataFechamento.value);
    dataPagamentoComissao = (servicoForm.dataPagamentoComissao.value != "") ? null : DateTime.parse(servicoForm.dataPagamentoComissao.value);
  }

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
    dataInicioGarantia: json["dataInicioGarantia"] != null ? DateTime.parse(json["dataInicioGarantia"]) : null,
    dataFimGarantia: json["dataFimGarantia"] != null ? DateTime.parse(json["dataFimGarantia"]) : null,
    dataPagamentoComissao: json["dataPagamentoComissao"] != null ? DateTime.parse(json["dataPagamentoComissao"]) : null,
    dataAtendimentoPrevisto: DateTime.parse(json["dataAtendimentoPrevisto"]),
    dataFechamento: json["dataFechamento"] != null ? DateTime.parse(json["dataFechamento"]) : null,
    dataAtendimentoEfetivo: json["dataAtendimentoEfetiva"] != null ? DateTime.parse(json["dataAtendimentoEfetiva"]) : null,
    dataAtendimentoAbertura: json["dataAtendimentoAbertura"] != null ? DateTime.parse(json["dataAtendimentoAbertura"]) : null,
  );
}
