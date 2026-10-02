---
name: create-mapper
description: Create a mapper that converts a data-layer model (DTO) into a domain entity for a NEW feature. Use alongside create-model and create-entity.
---

# create-mapper

Mappers convert `data/models/` DTOs into `domain/entities/` objects. They live in
`features/<f>/data/mappers/` and are used inside the repository implementation.

## Extension style (preferred — `data/mappers/<name>_mapper.dart`)
```dart
import '../../domain/entities/<entity>.dart';
import '../models/<name>_model.dart';

extension <Name>Mapper on <Name>Model {
  <Entity> toEntity() => <Entity>(
        id: id ?? 0,
        name: name ?? '',
        photo: photo,
        price: price ?? 0,
      );
}
```

## List mapping (in the repo impl)
```dart
final entities = (response.dataList ?? [])
    .whereType<<Name>Model>()
    .map((m) => m.toEntity())
    .toList();
```

## Reverse mapping (only if you send entities to the API)
```dart
extension <Name>EntityMapper on <Entity> {
  <Name>RequestBody toRequestBody() => <Name>RequestBody(/* ... */);
}
```

## Guardrails
- Supply null-safe defaults for nullable model fields so entities can be non-nullable.
- Mapping happens in the **repo implementation** — never in the Cubit or UI.
- No networking or business logic in mappers; pure translation only.
- Keep the direction clear: data → domain (`toEntity`), domain → data (`toRequestBody`) only when needed.
