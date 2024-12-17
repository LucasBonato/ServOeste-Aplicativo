class FiltroServicoModel {
  int? codigo;
  String? tecnico;
  String? equipamento;
  String? situacao;
  String? filial;
  String? garantia;
  String? horario;
  DateTime? dataPrevista;
  DateTime? dataEfetiva;
  DateTime? dataAbertura;

  FiltroServicoModel({
    this.codigo,
    this.tecnico,
    this.equipamento,
    this.situacao,
    this.filial,
    this.garantia,
    this.horario,
    this.dataPrevista,
    this.dataEfetiva,
    this.dataAbertura,
  });
}
