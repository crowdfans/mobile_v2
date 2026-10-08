# Storage / auth clients — GCS + Firebase (`CF-358`)

Linha **`release/0.2`** / `APP_FLAVOR=gcp`. Empilha em [CF-357](https://crowd-fans.youtrack.cloud/issue/CF-357) (flavors) e [CF-339](https://crowd-fans.youtrack.cloud/issue/CF-339) (shapes GCS).  
PR [#342](https://github.com/crowdfans/mobile_v2/pull/342). Sem bucket live / sem secrets.

## Aceite

| Critério | Como |
|----------|------|
| Upload/download green | Presign API + PUT signed GCS; preview via `Image.network` em `publicUrl` pública |
| Login/API calls green | Firebase ID token → `AuthService` (`requireAuth: false`) → Bearer nas rotas `/api/v1/*` |
| Sem regressão visual | Clientes só; UI continua `Image.network` / pickers existentes |

## Separação de clientes

```
Firebase Auth ──idToken──► HttpService (API CrowdFans) ──presign──► ObjectStorageClient (GCS PUT)
                                                                         ▲
                                                                   sem Bearer
```

| Cliente | Papel | Bearer? |
|---------|--------|---------|
| `FirebaseService` | Init options por flavor; `currentIdToken` | n/a |
| `AuthService` | Login/register com body `{ token }` | não |
| `HttpService` | Envelope JSON da API | sim (`requireAuth`) |
| `ObjectStorageClient` | PUT/POST signed object store | **nunca** |
| `MediaService` | Orquestra presign + PUT + shapes | Bearer só no presign |

`HttpService` **recusa** URLs absolutas GCS/Spaces (`isObjectStoreUrl`) para não vazar Bearer ao bucket.

## Headers signed PUT (gcp)

1. `Content-Type` = mesmo do body do presign.
2. Remove `Authorization`.
3. Remove `x-amz-*` (residual Spaces).
4. Mantém só o que o server assinou (`X-Goog-SignedHeaders`, tipicamente `content-type;host`).

## Firebase stubs

`FirebaseService.usingStubOptions` é `true` enquanto `apiKey` contém `REPLACE_ME`.  
Preencher via `docs/FIREBASE_FLAVORS.md` antes de login real no canal gcp.

## Testes GRE

```bash
flutter test test/services/storage_auth_clients_test.dart
flutter test test/services/media_gcs_shapes_test.dart
```

## Relacionados

- [MEDIA_GCS.md](./MEDIA_GCS.md) — shapes URL
- [FIREBASE_FLAVORS.md](./FIREBASE_FLAVORS.md) — options / plists
- [API_BACKENDS.md](./API_BACKENDS.md) — Cloud Run base URL
