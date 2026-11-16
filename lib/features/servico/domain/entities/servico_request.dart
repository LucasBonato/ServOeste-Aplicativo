import 'package:serv_oeste/features/servico/domain/entities/servico_form.dart';
import 'package:serv_oeste/features/servico/domain/entities/enums/service_periodo.dart';

class ServicoRequest {
  int? idCliente;
  int? idTecnico;
  String equipamento;
  String marca;
  String filial;
  String? dataAtendimento;
  ServicePeriodo? periodo;
  String descricao;

  ServicoRequest({
    this.idCliente,
    this.idTecnico,
    required this.equipamento,
    required this.marca,
    required this.filial,
    this.dataAtendimento,
    this.periodo,
    required this.descricao,
  });

  factory ServicoRequest.fromServicoForm({required ServicoForm servico}) =>
      ServicoRequest(
        idCliente: servico.idCliente.value,
        idTecnico: servico.idTecnico.value,
        equipamento: servico.equipamento.value,
        marca: servico.marca.value,
        filial: servico.filial.value,
        dataAtendimento: servico.dataAtendimentoPrevisto.value,
        periodo: servico.periodo.value,
        descricao: servico.descricao.value,
      );

  Map<String, dynamic> toJson() {
    return {
      'idCliente': idCliente,
      'idTecnico': idTecnico,
      'equipamento': equipamento,
      'marca': marca,
      'filial': filial,
      'dataAtendimento': dataAtendimento,
      'periodo': periodo?.toJson(),
      'descricao': descricao,
    };
  }
}
