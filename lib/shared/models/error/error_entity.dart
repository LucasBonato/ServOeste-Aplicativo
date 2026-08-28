import 'package:serv_oeste/shared/models/enums/error_code_key.dart';

class ErrorEntity {
  final String type;
  final String title;
  final int status;
  final String detail;
  final String instance;
  final String? traceId;
  final Map<String, List<String>> errors;

  ErrorEntity({
    required this.type,
    required this.title,
    required this.status,
    required this.detail,
    required this.instance,
    this.traceId,
    required this.errors,
  });

  /// [detail] with the backend trace id appended, so errors can be
  /// correlated with the backend trace when reported to support.
  String get fullDetail {
    final String? id = traceId;
    return (id == null || id.isEmpty) ? detail : '$detail\nTrace ID: $id';
  }

  factory ErrorEntity.fromJson(Map<String, dynamic> json) {
    final errorMap = (json['error'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, List<String>.from(value))) ?? {};

    return ErrorEntity(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? 0,
      detail: json['detail'] ?? '',
      instance: json['instance'] ?? '',
      traceId: json['traceId']?.toString(),
      errors: errorMap,
    );
  }

  factory ErrorEntity.global(String message, {int? status, String? traceId}) {
    return ErrorEntity(
      type: "about:blank",
      title: "Unexpected Error",
      status: status ?? 500,
      detail: message,
      instance: "/",
      traceId: traceId,
      errors: {
        ErrorCodeKey.global.name: ["Unexpected Error"]
      },
    );
  }

  ErrorEntity withTraceId(String? id) {
    if (id == null || id.isEmpty) return this;
    return ErrorEntity(
      type: type,
      title: title,
      status: status,
      detail: detail,
      instance: instance,
      traceId: id,
      errors: errors,
    );
  }

  @override
  String toString() => 'ErrorEntity(status: $status, detail: $detail, errors: $errors)';
}
