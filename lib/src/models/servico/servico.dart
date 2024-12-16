import 'package:serv_oeste/src/models/servico/servico_form.dart';

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

  factory Servico.fromForm(ServicoForm servicoForm) => Servico(
        id: servicoForm.id!,
        idCliente: servicoForm.idCliente.value!,
        idTecnico: servicoForm.idTecnico.value!,
        nomeCliente: servicoForm.nomeCliente.value,
        nomeTecnico: servicoForm.nomeTecnico.value,
        equipamento: servicoForm.equipamento.value,
        filial: servicoForm.filial.value,
        horarioPrevisto: servicoForm.horario.value,
        marca: servicoForm.marca.value,
        situacao: servicoForm.situacao.value,
        garantia: servicoForm.garantia.value,
        dataAtendimentoPrevisto: servicoForm.dataAtendimentoPrevisto != null
            ? DateTime.parse(servicoForm.dataAtendimentoPrevisto.value)
            : DateTime.now(),
        dataAtendimentoEfetivo: servicoForm.dataAtendimentoEfetivo != null
            ? DateTime.parse(servicoForm.dataAtendimentoEfetivo.value)
            : null,
        dataAtendimentoAbertura: servicoForm.dataAtendimentoAbertura != null
            ? DateTime.parse(servicoForm.dataAtendimentoAbertura.value)
            : null,
      );

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
