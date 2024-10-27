class ErrorEntity {
  final int id;
  final String error;

  ErrorEntity({
    required this.id,
    required this.error
  });

  factory ErrorEntity.fromJson(Map<String, dynamic> json) => ErrorEntity(
      id: json["id"],
      error: json["error"]
  );
}