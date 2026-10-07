# Mídia GCS — clientes mobile (`CF-339`)

Linha **`release/0.2`** / `APP_FLAVOR=gcp`: upload/preview usam shapes **Cloud Storage**, não DO Spaces.

Coordena server [CF-338](https://crowd-fans.youtrack.cloud/issue/CF-338) (`ObjectStore` / signed PUT) ·  
PR mobile [#342](https://github.com/crowdfans/mobile_v2/pull/342) · [API_BACKENDS.md](./API_BACKENDS.md).

## Contrato (igual ao server)

| Campo | Shape |
|-------|--------|
| `uploadUrl` | `https://storage.googleapis.com/{bucket}/{key}?X-Goog-Algorithm=…&X-Goog-Signature=…` (PUT V4) |
| `method` | `PUT` |
| `headers` | `Content-Type` (sem `x-amz-acl` no gcp) |
| `publicUrl` | `https://storage.googleapis.com/{bucket}/{key}` ou `MEDIA_GCS_PUBLIC_BASE_URL/{key}` |
| `objectKey` | `users/{uid}/posts/…` (opcional no client) |
| `expiresIn` | segundos (ex. 900) |

## Código

| Arquivo | Papel |
|---------|--------|
| `lib/services/media_url_shapes.dart` | Detecta GCS / Spaces / signed; `isAllowed*` por flavor |
| `lib/services/media_service.dart` | Presign + PUT; rejeita Spaces no flavor gcp |
| `test/services/media_gcs_shapes_test.dart` | GRE |

```bash
flutter test test/services/media_gcs_shapes_test.dart
```

## Env / config (flavor gcp)

| Key | Default stub | Uso |
|-----|--------------|-----|
| `MEDIA_GCS_BUCKET` | `crowdfans-media-gcp` | docs / build URL |
| `MEDIA_GCS_PUBLIC_BASE_URL` | _(vazio → storage.googleapis.com/{bucket})_ | CDN |

Também em `config/gcp.json` (dart-define).

## Flavor

| `APP_FLAVOR` | Public URL | Upload URL |
|--------------|------------|------------|
| `gcp` / `local` | só GCS (+ CDN) | signed GCS `X-Goog-*` |
| `digitalocean` | Spaces **ou** GCS | http(s) genérico |

## Aceite CF-339

- [x] Sem URL Spaces hardcoded no client
- [x] GRE unit (shapes / reject Spaces / CDN / DO flavor)
- [ ] Upload/preview green contra bucket live (pós CF-286 + signer ADC)
- [ ] QA visual com print (quando staging existir)

## Sem live bucket

Stubs não fazem HTTP real ao GCS. Quando o server devolver `503` (`ErrStubNotWired`), o app mostra erro de API — esperado até ADC/signing.
