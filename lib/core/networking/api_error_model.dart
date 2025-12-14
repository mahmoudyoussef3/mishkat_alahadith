import 'package:json_annotation/json_annotation.dart';

part 'api_error_model.g.dart';

@JsonSerializable()
class ApiErrorModel {
  final String? message;
  final bool? success;
  final int? status;
  final String? messageAr;

  ApiErrorModel({
    this.message,
    this.success,
    this.status,
    this.messageAr,
  });

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorModelToJson(this);
}

extension ApiErrorModelX on ApiErrorModel {
  String getAllErrorMessages() {
    if (messageAr != null && messageAr!.isNotEmpty) return messageAr!;

   // if (message != null && message!.isNotEmpty) return message!;

    return "Unknown error occurred";
  }
}
