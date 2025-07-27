// class ErrorEntity {
//   late String type;
//   late String title;
//   late int status;
//   late String detail;
//   late String instance;
//   late InternalError error;
//
//   ErrorEntity({
//     required this.type,
//     required this.title,
//     required this.status,
//     required this.detail,
//     required this.instance,
//     required this.error,
//   });
//
//   factory ErrorEntity.fromJson(Map<String, dynamic> json)
//     => ErrorEntity(
//         type: json["type"],
//         title: json["title"],
//         status: json["status"],
//         detail: json["detail"],
//         instance: json["instance"],
//         error: InternalError.fromJson(json["error"])
//     );
// }

class ErrorEntity {
  late int id;
  late String errorMessage;

  ErrorEntity({
    required this.id,
    required this.errorMessage,
  });

  factory ErrorEntity.fromJson(Map<String, dynamic> json) =>
      ErrorEntity(
        id: json["error.idError"],
        errorMessage: json["error.message"],
      );

  @override
  String toString() {
    return 'ErrorEntity(id: $id, message: $errorMessage)';
  }
}
