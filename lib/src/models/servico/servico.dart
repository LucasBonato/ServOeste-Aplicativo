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
  final DateTime dataAtendimentoPrevisto;

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
    required this.dataAtendimentoPrevisto
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
    dataAtendimentoPrevisto: DateTime.parse(json["dataAtendimentoPrevisto"])
  );
}