---
name: create-entity
description: Create a pure domain entity (plain Dart, no JSON annotations) for a feature's domain layer. Use with create-mapper to convert models to entities.
---

# create-entity

Domain entities are plain, immutable Dart objects the app logic and UI depend on. They live in
`features/<f>/domain/entities/` and contain **no** JSON annotations, Dio, Retrofit, or Flutter imports.

## Template (`domain/entities/<entity>.dart`)
```dart
class <Entity> {
  final int id;
  final String name;
  final String? photo;
  final int price;

  const <Entity>({
    required this.id,
    required this.name,
    this.photo,
    required this.price,
  });
}
```

## Guidance
- Prefer non-nullable fields with sensible types; the mapper supplies defaults for nullable model fields.
- Keep entities free of serialization and framework code — that's what the model + mapper are for.
- Add value semantics only if the app needs them (e.g. equality). Do not add freezed here unless the
  feature specifically calls for it.
- Pair every entity with:
  - a `data/models/` DTO (`create-model`),
  - a `data/mappers/` mapper (`create-mapper`),
  - a `domain/repos/` interface returning `ApiResult<<Entity>>`.

## Guardrails
- **Domain layer is pure Dart.** No `package:flutter/...`, `package:dio/...`, `package:retrofit/...`,
  or `package:json_annotation/...` imports in this file.
- Presentation may import entities; Data maps models → entities.
