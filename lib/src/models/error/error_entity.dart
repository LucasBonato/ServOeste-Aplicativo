class ErrorEntity {
  late int id;
  late String errorMessage;

  ErrorEntity({
    required this.id,
    required this.errorMessage,
  });

  factory ErrorEntity.fromJson(Map<String, dynamic> json) => ErrorEntity(
        id: json["idError"] ?? 0,
        errorMessage: json["message"] ?? "Erro desconhecido",
      );

  @override
  String toString() {
    return 'ErrorEntity(id: $id, message: $errorMessage)';
  }
}
