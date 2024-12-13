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
  final String? garantia;
  final String situacao;
  final DateTime dataAtendimentoPrevisto;
  final DateTime? dataAtendimentoEfetivo;
  final DateTime? dataAtendimentoAbertura;

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
    this.garantia,
    required this.dataAtendimentoPrevisto,
    this.dataAtendimentoEfetivo,
    this.dataAtendimentoAbertura,
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
        dataAtendimentoPrevisto:
            DateTime.parse(json["dataAtendimentoPrevisto"]),
        dataAtendimentoEfetivo: json["dataAtendimentoEfetivo"] != null
            ? DateTime.parse(json["dataAtendimentoEfetivo"])
            : null,
        dataAtendimentoAbertura: json["dataAtendimentoAbertura"] != null
            ? DateTime.parse(json["dataAtendimentoAbertura"])
            : null,
      );
}
