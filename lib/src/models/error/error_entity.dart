import 'package:serv_oeste/src/models/enums/error_code_key.dart';

class ErrorEntity {
  final String type;
  final String title;
  final int status;
  final String detail;
  final String instance;
  final Map<String, List<String>> errors;

  ErrorEntity({
    required this.type,
    required this.title,
    required this.status,
    required this.detail,
    required this.instance,
    required this.errors,
  });

  factory ErrorEntity.fromJson(Map<String, dynamic> json) {
    final errorMap = (json['error'] as Map<String, dynamic>?)
        ?.map((key, value) => MapEntry(key, List<String>.from(value)))
        ?? {};

    return ErrorEntity(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? 0,
      detail: json['detail'] ?? '',
      instance: json['instance'] ?? '',
      errors: errorMap,
    );
  }

  factory ErrorEntity.global(String message, {int? status}) {
    return ErrorEntity(
      type: "about:blank",
      title: "Unexpected Error",
      status: status ?? 500,
      detail: message,
      instance: "/",
      errors: { ErrorCodeKey.global.name: ["Unexpected Error"] },
    );
  }

  @override
  String toString() => 'ErrorEntity(status: $status, detail: $detail, errors: $errors)';
}
