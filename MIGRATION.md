# Migração Expo → Flutter

Referência: `../mobile` (Expo Router + TypeScript). Este repo é a reescrita.

## Feito

- [x] Projeto Flutter (iOS / Android / web), tema CrowdFans, Inter
- [x] `Pages` + `ApiUrls` + `HttpService` (envelope `{ data, message }`)
- [x] Firebase Auth (`crowdfans-dev`) + `POST /auth/login` + `verifyTokenId`
- [x] Onboarding (copy Superfã / Artista)
- [x] Login fã e login artista (papel conferido no `GET /api/v1/profile`)
- [x] Shell das 4 abas; aba Eu com nome + logout

## Próximo

- [ ] Cadastro fã / artista (OTP, username, termos)
- [ ] Feed + stories
- [ ] Explorar / busca de artistas
- [ ] Fan clubs + compose
- [ ] Perfil completo + settings (wallet, memberships, Pro / RevenueCat)
- [ ] Posts, comentários, fan letters, notificações
- [ ] Vídeo de onboarding (`StoryBackground`)

Não copiar `frontendapp/` (Flutter legado / Supabase). Fonte de verdade de produto é o Expo atual.
