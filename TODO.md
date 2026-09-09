# TODO — migração Expo (`mobile`) → Flutter (`mobile_v2`)

Referência de comportamento: `../mobile` (Expo Router).  
Não copiar `frontendapp/` (Flutter legado / Supabase).

**Legenda:** `[x]` já no Flutter · `[ ]` falta · `⛔` não existe no Expo (Live / Meet) — copiar o buraco, não inventar.

Marcar `[x]` no arquivo ao terminar cada item (com um comentário curto do que entrou).

---

## 0. Fundação (já iniciado)

- [x] Projeto Flutter iOS / Android / web
- [x] Tema CrowdFans (paleta claro/escuro) + fonte Inter
- [x] `Pages` (`lib/constants/pages.dart`)
- [x] `ApiUrls` (núcleo; **completar** o restante da lista do Expo)
- [x] `HttpService` (envelope `{ success, message, data }` + Bearer Firebase)
- [x] `ApiError`
- [x] Firebase Auth (`crowdfans-prod` via `.env`) + `POST /auth/login` + `POST /auth/verifyTokenId`
- [x] Sessão (Riverpod) + gate de rotas públicas vs autenticadas
- [x] Config de API (`API_MODE` local / DigitalOcean)
- [x] Completar `ApiUrls` com **todos** os endpoints de `mobile/src/api/api-url.ts` — `lib/api/api_urls.dart` + `withParams`
- [x] Deep links / scheme `mobile` (Expo `app.json`) — iOS URL types + Android intent-filter + aliases Expo em `Pages`
- [x] Splash / ícone CrowdFans (`flutter_launcher_icons` + `flutter_native_splash`, fundo `#208AEF`)
- [x] Sentry (`observability/sentry.ts`) — `SentryService`, só inicializa se houver DSN
- [x] Variáveis de ambiente: `.env` (chaves `EXPO_PUBLIC_*` do Expo) via `EnvService`
- [x] `flutterfire configure` no `crowdfans-prod` — iOS/Android `com.crowdfans.crowdfans` + web; `DefaultFirebaseOptions`
- [x] Copiar `assets/` do Expo (`images`, `icons`, `logo`, `special-icons`, `fonts`, `video`, `Stickers`, `data-usage`, ringtone)

---

## 0.1 Assets (usar o que já está em `assets/`)

- [x] Árvore copiada de `../mobile/assets` (mesmos paths: `assets/images/...`, `assets/icons/...`)
- [x] Ligar SVGs com `flutter_svg` (bottom nav; toolbar/feed/settings nas telas de cada domínio)
- [x] Ícone / splash / favicon nativos (`assets/images/icon.png`, `splash-icon.png`, `images/common/favicon.png`)
- [x] Logo `assets/logo/crowdfans-logo.svg` na toolbar
- [x] Fonte Inter local (`assets/fonts/inter/InterVariable.ttf`) no `ThemeData`
- [x] Vídeos de onboarding `assets/video/first.mp4` / `second.mp4` / `third.mp4`
- [ ] Stickers (`assets/Stickers/`) quando fan letters / compose pedirem
- [x] Avatares de demo `assets/data-usage/` — Expo não usa mais; não migrar

---

## 1. Onboarding

- [x] `PresentationScreen` — copy Superfã / Artista
- [x] `StoryBackground` + vídeos (`assets/video/first.mp4`, `second.mp4`, `third.mp4`)
- [x] `StoreBackgroundProgress`
- [x] Botões `Sou um Superfã` / `Sou um Artista` (`onboarding-button-wrapper`)
- [x] `presentation/index.tsx` — não aplicável (go_router aponta direto para a tela)

---

## 2. Login

- [x] `FanLoginScreen`
- [x] `ArtistLoginScreen`
- [x] `CredentialsFormComponent`
- [x] `LoginTextComponent` (label gradiente)
- [x] `RegisterTopBarComponent` (voltar com o mesmo visual do Expo)
- [x] Recuperação de senha de verdade (`ProfileSecurityService.requestPasswordReset` / Firebase `sendPasswordResetEmail`)
- [x] `mapLoginError` completo (rede + URL da API no debug)
- [x] `LoginLayout`
- [ ] Social login (comentado no Expo — **não** implementar até o Expo ligar) — ver `PENDENCIA.md`

---

## 3. Cadastro Superfã

- [x] `RegisterFanScreen` (entrada / telefone)
- [x] `RegisterFanOtpScreen`
- [x] `RegisterFanEmailScreen`
- [x] `RegisterFanPasswordScreen`
- [x] `RegisterFanNameScreen`
- [x] `RegisterFanBirthdateScreen`
- [x] `RegisterFanUsernameScreen`
- [x] `RegisterFanProfileScreen` (bio; avatar via picker fica no `MediaService`)
- [x] `RegisterFanTermsScreen`
- [x] `RegisterFanSuccessScreen`
- [x] Layouts `register/_layout.tsx` e `register/fan/_layout.tsx` — `RegisterFanScaffold` + store
- [x] `OtpService` + verificação no `RegisterFanOtpScreen`
- [x] `firebase-phone-auth.ts` (`FirebasePhoneAuthService`)
- [ ] reCAPTCHA (`FirebaseRecaptchaVerifierModal` + web slot) — ver `PENDENCIA.md`
- [x] `AuthService.registerFan` (`POST /register/fan`)
- [x] Utils: `phone-utils`, `email-utils`, `password-util`, `username-utils`, `birthday-utils`

---

## 4. Cadastro artista

- [x] `RegisterArtistScreen` — telefone + OTP SMS
- [x] `RegisterArtistOtpScreen`
- [x] `RegisterArtistEmailScreen`
- [x] `RegisterArtistDataScreen` (nome, username, senha — o Expo ainda não pede empresa/gênero/avatar)
- [x] Layout `register/artist/_layout.tsx` — `artistRegisterProvider` + rotas
- [x] `ArtistRegisterService` (`POST /register/artist`)
- [x] Models (`artist_register_form_data`, verification status/platform)
- [x] ⛔ Verificação Spotify / contestação de nome — buraco copiado do Expo, sem UI
- [x] ⛔ Consentimento parental — buraco copiado do Expo, sem UI

---

## 5. Shell autenticado (tabs)

- [x] 4 abas: Feed / Clubes / Explorar / Eu
- [x] Botão `+` abre o `CreateMenuSheet`
- [x] `BottomNavComponent` visual (ícones SVG + avatar do perfil)
- [x] `CreateMenuSheetComponent` (artista: post / story / etc.)
- [x] `create-menu-store` (`createMenuProvider`)
- [x] `AppRootLayout` (fontes Inter + tema no `CrowdFansApp`; init Purchases fica no item 16)
- [x] `AppRootAuthGate` (prefixos públicos do Expo + `/demo`; spinner de sessão ainda no go_router)

---

## 6. Feed / Home

- [x] `HomeScreen` (`(main)/feed.tsx` reexporta esta)
- [x] `GET /api/v1/home` (paginação, pull-to-refresh, `hasMore`)
- [x] `FeedComponent` (`FeedItem`)
- [x] `PostCardComponent`
- [x] `ExclusiveFeedCardComponent`
- [x] `ExclusiveFeedCardLockedContentComponent`
- [x] `ExclusivePostMetaRowComponent`
- [x] `VoteControlComponent` (UI; persistência no item `VoteService`)
- [x] `PostOptionsSheetComponent`
- [x] `PostShareSheetComponent`
- [x] `post-share.ts` (share nativo via `share_plus`)
- [x] `StoriesRowComponent`
- [x] `StoryItemComponent`
- [x] `StoryLiveItemComponent` (chip visual; tap sem tela — ⛔ no Expo)
- [x] `StoryMeetAndGreetItemComponent` (chip visual; tap sem tela — ⛔ no Expo)
- [x] Unlock de post exclusivo (`SubscriptionService.list` + `canAccessExclusivePost`; assinar no perfil do artista)
- [x] Model `FeedPost` / `HomeFeedDto` / `StoryItem`

---

## 7. Explorar / busca

- [x] `SearchScreen` (`(main)/explore.tsx`)
- [x] `SearchRankingScreen`
- [x] `SearchArtistOptionsSheetComponent`
- [x] `SearchService` (`GET /api/v1/search/artists`, rankings)

---

## 8. Fan clubs

- [x] `FanClubsScreen` (`(main)/clubs.tsx`)
- [x] Comunidade `fan-clubs/community/[artistId].tsx` (hero + feed; compose/about ainda placeholder)
- [ ] `FanClubComposeScreen`
- [ ] `FanClubAboutScreen`
- [ ] `FanClubModeratorsScreen`
- [ ] `FanClubModerationScreen`
- [ ] `FanClubRulesScreen`
- [x] `FanClubService` (`getArtistFanClubFeed`; moderação entra nas telas de settings)
- [ ] `FanClubViewerService`
- [x] `CommunityService` (`GET /api/v1/community/posts`)
- [x] `FollowService` (`FOLLOWS`; follow/unfollow no perfil do artista)

---

## 9. Perfil (aba Eu + públicos)

- [x] `ProfileScreen` (aba Eu: identidade, stats, posts; públicos ainda faltam)
- [ ] Perfil público `profile/[fanHandle].tsx`
- [ ] Fan score público `profile/fan-score/[fanHandle].tsx`
- [ ] `ProfileArtistsScreen` (artistas seguidos)
- [x] Perfil de artista `artists/[artistId].tsx` (follow, membership, posts; fan letters ainda placeholder)
- [x] `ProfileService` completo (`overview`/`social` ainda nas telas públicas; posts por UID + update já entram)
- [x] Store `current-viewer-profile-store` — no Flutter o viewer fica no `authSessionProvider` (`applyProfile`)

---

## 10. Settings (hub + cada tela)

- [x] `ProfileSettingsScreen` (hub; telas filhas ainda placeholder)
- [x] `ProfileAccountScreen` (nome/username/bio/foto; upload via `MediaService`)
- [x] `ProfileAppearanceScreen` + `appearanceSettingsProvider` (persiste em SharedPreferences)
- [x] `ProfileInformationScreen` (ajuda / termos / privacidade)
- [x] `ProfileSecurityScreen` (e-mail, senha; telefone ainda aguarda backend)
- [ ] `ProfileNotificationsScreen` + `notification-preferences-service`
- [ ] `ProfileFanScoreScreen`
- [ ] `ProfileMembershipsScreen` + `SubscriptionService` (check / cancel)
- [ ] `ProfileProScreen` (CrowdFans Pro / RevenueCat)
- [ ] `ProfileWalletScreen` (saldo Jam Coins + packs)
- [ ] Recarga Jam Coins via **RevenueCat IAP** (`jam_starter` / `jam_plus` / `jam_pro`, offering `jam_coins`) — produto atual; Expo local ainda pode mostrar PIX sandbox
- [ ] Checkout sandbox `__DEV__` (`POST /api/v1/me/wallet/checkout`) só para QA
- [ ] WS `GET /api/v1/me/ws` → evento `wallet.credited`
- [ ] `ProfileEarningsScreen` (saque PIX artista)
- [ ] `ProfileReferralScreen` + `ReferralService`
- [x] `BlockedUsersSettingsScreen` + `BlockService`
- [x] `HiddenPostsSettingsScreen` + `HiddenPostService`
- [x] `ProfileMemoriesScreen` + `SavedPostService`
- [ ] `ModerationSettingsScreen`
- [ ] `FanClubModerationListScreen`
- [ ] `FanClubContestationListScreen`
- [ ] `ArtistInsightsSettingsScreen`
- [ ] `ArtistAudienceSettingsScreen`
- [ ] `ArtistFanClubSettingsScreen`
- [x] `ProfileScreenHeaderComponent`
- [x] `ProfileSettingsSectionComponent`
- [x] `ProfileStateComponent`
- [ ] `SidebarMenuComponent` / `SidebarSectionItemComponent` (se ainda usados)

---

## 11. Posts

- [x] `CreatePostScreen` (TEXT, IMAGE, CAROUSEL, VIDEO, MEMBERSHIP; edição via `?postId=`)
- [x] `MyPostsScreen` (listar / editar / deletar)
- [x] `PostService` (CRUD)
- [x] Image picker + upload (`MediaService` via presign Spaces; picker também nas telas de account)

---

## 12. Comentários

- [x] Tela `comments/[postId].tsx` (`CommentsScreen`)
- [x] `CommentService` (listar, criar, editar, deletar, votar)
- [x] `CommentGifService` (Tenor; chave `TENOR_API_KEY` / fallback do Expo)

---

## 13. Fan letters

- [ ] `FanLetterComposeScreen`
- [ ] `FanLetterGalleryScreen`
- [ ] `FanLetterService` (cota, débito Jam Coins, monetização)

---

## 14. Notificações

- [ ] `NotificationsScreen` (abas Posts / Clubes / Meet / Fan Letter / Sistema)
- [ ] `NotificationsService`
- [ ] `PushTokenService` + FCM / APNs
- [ ] Deep link ao tocar na notificação

---

## 15. Denúncia

- [x] `ReportScreen` (motivo → detalhes → sucesso; query `context`/`targetId`/`displayName`)
- [x] `ReportService` (`POST /api/v1/reports`; oculta post denunciado best-effort)

---

## 16. Monetização / IAP

- [ ] `PurchasesService` (logIn Firebase UID, offerings, purchase, restore)
- [ ] `purchases-config` (`crowdfans_pro` + `jam_coins`)
- [ ] `purchases-store`
- [ ] Paywall CrowdFans Pro
- [ ] Customer Center
- [ ] `WalletService` (saldo, packs `productId`, checkout, WS)
- [ ] `EarningsService` (saldo artista + withdrawals)

---

## 17. Votos e conteúdo exclusivo

- [x] `VoteService` (post e comentário; UI de comentário entra na seção 12)
- [x] `SubscriptionService` (assinar com Jam Coins, 402 saldo — UI de compra no perfil do artista)
- [x] Helper `canAccessExclusivePost` (memberships completos no `SubscriptionService`)

---

## 18. Mídia

- [x] `MediaService` (`POST /api/v1/me/media/uploads` + PUT Spaces)
- [ ] Image picker nos fluxos: cadastro, fan club compose, fan letter — account e create post já usam

---

## 19. UI compartilhada (ainda não no Flutter)

- [x] `AppButtonComponent` / `ButtonComponent`
- [x] `AppIconButtonComponent`
- [x] `InputComponent`
- [x] `ToolbarBackButtonComponent` / `ToolbarMenuButtonComponent`
- [x] `StickyToolbarComponent` / `ImageToolbarComponent` / `TextToolbar`
- [x] `BottomSheetShellComponent` + `useBottomSheetShell` (`BottomSheetShell` anima no próprio State)
- [x] `alert.ts` (`showAlert` / `showConfirm`)

---

## 20. Demo

- [ ] Remover `DemoScreen` (`Pages.DEMO`)

---

## 21. Infra que o Expo tem e o Flutter ainda não

- [ ] WebSocket carteira (`WalletService.subscribe`)
- [ ] Expo Notifications → `firebase_messaging`
- [ ] RevenueCat Flutter SDK (`purchases_flutter`)
- [ ] `expo-image` / cache de imagem
- [x] `expo-video` (stories de onboarding; posts/stories autenticados ainda faltam)
- [ ] Clipboard (PIX copy-paste no saque / sandbox)
- [ ] Secure storage da sessão (Firebase plugin já persiste; conferir)

---

## 22. Fora do Expo (não migrar até existir no `mobile`)

- [ ] ⛔ Live: diretório, viewer, estúdio
- [ ] ⛔ Meet & Greet: agenda, lobby, chamada, estúdio, feedback
- [ ] ⛔ Create post de fã (se continuar ⛔ no Expo)

---

## 23. Firebase

- [x] Instalar Firebase CLI local (`firebase-tools` neste repo; usar `node_modules/.bin`)
- [x] Configurar App Distribution (grupo `flutter-testers`; falta e-mails e IPA/APK)

---

## Ordem sugerida

1. Cadastro fã (OTP) — desbloqueia contas novas no Flutter  
2. Feed + card de post + stories row  
3. Perfil Eu completo + settings hub  
4. Fan clubs + comunidade  
5. Create post / my posts  
6. Comentários + votos  
7. Wallet + RevenueCat Jam Coins + Pro  
8. Fan letters, notificações, denúncia, analytics artista  
9. Vídeo de onboarding / stories player  
10. Push + deep links
