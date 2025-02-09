class Servico {
  final int id;
  final int idCliente;
  final int idTecnico;
  final String nomeCliente;
  final String nomeTecnico;
  final String equipamento;
  final String filial;
  final String horarioPrevisto;
  final String marca;
  final String situacao;
  final String? descricao;
  final bool? garantia;
  final String? formaPagamento;
  final double? valor;
  final double? valorComissao;
  final double? valorPecas;
  final DateTime dataAtendimentoPrevisto;
  final DateTime? dataAtendimentoEfetivo;
  final DateTime? dataAtendimentoAbertura;
  final DateTime? dataFechamento;
  final DateTime? dataInicioGarantia;
  final DateTime? dataFimGarantia;
  final DateTime? dataPagamentoComissao;

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
