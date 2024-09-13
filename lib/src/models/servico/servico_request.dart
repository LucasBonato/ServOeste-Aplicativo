
class ServicoRequest {
  int? idCliente;
  int idTecnico;
  String equipamento;
  String marca;
  String filial;
  String dataAtendimento;
  String horarioPrevisto;
  String descricao;

  ServicoRequest({
    this.idCliente,
    required this.idTecnico,
    required this.equipamento,
    required this.marca,
    required this.filial,
    required this.dataAtendimento,
    required this.horarioPrevisto,
    required this.descricao
  });
}