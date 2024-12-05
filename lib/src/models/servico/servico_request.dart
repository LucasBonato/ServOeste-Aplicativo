import 'package:serv_oeste/src/models/servico/servico_form.dart';

class ServicoRequest {
  int? idCliente;
  int idTecnico;
  String equipamento;
  String marca;
  String filial;
  String dataAtendimento;
  String horarioPrevisto;
  String descricao;

  ServicoRequest(
      {this.idCliente,
      required this.idTecnico,
      required this.equipamento,
      required this.marca,
      required this.filial,
      required this.dataAtendimento,
      required this.horarioPrevisto,
      required this.descricao});

  factory ServicoRequest.fromServicoForm({required ServicoForm servico}) =>
    ServicoRequest(
      idTecnico: servico.id!,
      equipamento: servico.equipamento.value,
      marca: servico.marca.value,
      filial: servico.filial.value,
      dataAtendimento: servico.dataPrevista.value,
      horarioPrevisto: servico.horario.value.toLowerCase().replaceAll("ã", "a"),
      descricao: servico.descricao.value,
    );
}
