enum TechnicalStatus {
  ativo("Ativo"),
  licenca("Licença"),
  desativado("Desativado");

  final String status;

  const TechnicalStatus(this.status);

  String getStatus() {
    return status;
  }
}
