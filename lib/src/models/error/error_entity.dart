class ErrorEntity {
  late int id;
  late String errorMessage;

  ErrorEntity({
    required this.id,
    required this.errorMessage
  });

  factory ErrorEntity.fromJson(Map<String, dynamic> json) => ErrorEntity(
      id: json["idError"],
      errorMessage: json["message"]
  );
}