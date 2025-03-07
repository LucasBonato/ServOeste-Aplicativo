import 'package:serv_oeste/src/models/servico/servico_form.dart';

class ServicoRequest {
  int? idCliente;
  int? idTecnico;
  String equipamento;
  String marca;
  String filial;
  String? dataAtendimento;
  String? horarioPrevisto;
  String descricao;

  ServicoRequest(
      {this.idCliente,
      this.idTecnico,
      required this.equipamento,
      required this.marca,
      required this.filial,
      this.dataAtendimento,
      this.horarioPrevisto,
      required this.descricao});

  factory ServicoRequest.fromServicoForm({required ServicoForm servico}) =>
      ServicoRequest(
        idCliente: servico.idCliente.value,
        idTecnico: servico.idTecnico.value,
        equipamento: servico.equipamento.value,
        marca: servico.marca.value,
        filial: servico.filial.value,
        dataAtendimento: servico.dataAtendimentoPrevisto.value,
        horarioPrevisto:
            servico.horario.value.toLowerCase().replaceAll("ã", "a"),
        descricao: servico.descricao.value,
      );
}
