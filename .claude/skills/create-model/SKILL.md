---
name: create-model
description: Create a @JsonSerializable request body or response model with @JsonKey mapping and run build_runner. Use when adding/updating a network DTO.
---

# create-model

Creates a JSON model following `CLAUDE.md` §7.

## Request body (`<name>_request_body.dart`)
Fields + constructor + `toJson()` only.
```dart
import 'package:json_annotation/json_annotation.dart';
part '<name>_request_body.g.dart';

@JsonSerializable()
class <Name>RequestBody {
  final String email;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;

  <Name>RequestBody({
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => _$<Name>RequestBodyToJson(this);
}
```

## Response model (`<name>_response.dart` / `<name>_response_model.dart`)
Nullable fields + `factory fromJson`. Multiple related classes may live in one file.
```dart
import 'package:json_annotation/json_annotation.dart';
part '<name>_response.g.dart';

@JsonSerializable()
class <Name>Response {
  String? message;
  @JsonKey(name: 'data')
  <Name>Data? data;
  bool? status;
  int? code;

  <Name>Response({this.message, this.data, this.status, this.code});

  factory <Name>Response.fromJson(Map<String, dynamic> json) => _$<Name>ResponseFromJson(json);
}

@JsonSerializable()
class <Name>Data {
  int? id;
  @JsonKey(name: 'username')
  String? userName;

  <Name>Data({this.id, this.userName});

  factory <Name>Data.fromJson(Map<String, dynamic> json) => _$<Name>DataFromJson(json);
}
```

## Generate
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Guardrails
- `part '<file>.g.dart';` required. Response fields nullable; use `@JsonKey(name:)` for server key mismatches.
- Request bodies: `toJson` only. Responses: `fromJson` (add `toJson` only if the model is also sent).
- No Flutter imports, no business logic. Commit source + `.g.dart` together. Never hand-edit `.g.dart`.
- In a Clean Architecture feature, pair the model with a `domain/entities/` entity + a mapper
  (see `create-entity`, `create-mapper`).
