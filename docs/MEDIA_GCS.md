# Mídia GCS — clientes mobile (`CF-339`)

Linha **`release/0.2`** / `APP_FLAVOR=gcp`: upload/preview usam shapes **Cloud Storage**, não DO Spaces.

Coordena server [CF-338](https://crowd-fans.youtrack.cloud/issue/CF-338) / ADR [CF-446](https://crowd-fans.youtrack.cloud/issue/CF-446) ·  
auth boundary [CF-358](https://crowd-fans.youtrack.cloud/issue/CF-358) · [API_BACKENDS.md](./API_BACKENDS.md) · [STORAGE_AUTH_CLIENTS.md](./STORAGE_AUTH_CLIENTS.md).

## Contrato (igual ao server CF-446/447)

| Campo | Shape |
|-------|--------|
| `uploadUrl` | `https://storage.googleapis.com/{bucket}/{key}?X-Goog-Algorithm=…&X-Goog-Signature=…` (PUT V4) |
| `method` | `PUT` |
| `headers` | `Content-Type` + `x-goog-content-length-range: 1,{max}` (sem `x-amz-acl` no gcp) |
| `publicUrl` | `https://storage.googleapis.com/{bucket}/{key}` ou `MEDIA_GCS_PUBLIC_BASE_URL/{key}` |
| `objectKey` | `users/{uid}/posts/…` |
| `expiresIn` | segundos (ex. 900) |

Request body: `{ kind, contentType, contentLength? }` — o client **envia** `contentLength` = tamanho dos bytes.

| kind | max bytes |
|------|----------:|
| avatar | 5 242 880 (5 MiB) |
| post / fan-club / fan-letter | 15 728 640 (15 MiB) |

Content-types: `image/jpeg`, `image/png`, `image/webp`, `image/gif` (vídeo fora do contrato).

## Código

| Arquivo | Papel |
|---------|--------|
| `lib/services/media_url_shapes.dart` | Detecta GCS / Spaces / signed; `displayMediaUrl` (object key → HTTPS) |
| `lib/services/object_storage_client.dart` | PUT signed **sem** Bearer; preserva `x-goog-*` (CF-358) |
| `lib/services/media_service.dart` | Presign + `contentLength` + limites + allowlist |
| `lib/components/post/post_media.dart` / `post_avatar.dart` | Preview via `displayMediaUrl` |
| `test/services/media_gcs_shapes_test.dart` | GRE shapes / reject / size |
| `test/services/storage_auth_clients_test.dart` | GRE headers/auth boundary |

```bash
flutter test test/services/media_gcs_shapes_test.dart
flutter test test/services/storage_auth_clients_test.dart
```

## Env / config (flavor gcp)

| Key | Default stub | Uso |
|-----|--------------|-----|
| `MEDIA_GCS_BUCKET` | `crowdfans-media-staging` | docs / build URL |
| `MEDIA_GCS_PUBLIC_BASE_URL` | _(vazio → storage.googleapis.com/{bucket})_ | CDN |

Também em `config/gcp.json` (dart-define).

## Flavor

| `APP_FLAVOR` | Public URL | Upload URL |
|--------------|------------|------------|
| `gcp` / `local` | só GCS (+ CDN) | signed GCS `X-Goog-*` |
| `digitalocean` | Spaces **ou** GCS | http(s) genérico |

## Aceite CF-339

- [x] Sem URL Spaces hardcoded no client
- [x] GRE unit (shapes / reject Spaces / CDN / DO flavor / size / content-type)
- [x] Widgets de feed/avatar resolvem object key → URL GCS
- [ ] Upload/preview green contra bucket live (pós CF-286 + signer ADC)
- [ ] QA visual com print (quando staging existir)

## Sem live bucket

Stubs não fazem HTTP real ao GCS. Quando o server devolver `503` (`gcs_not_configured` / stub), o app mostra erro de API — esperado até ADC/signing.
