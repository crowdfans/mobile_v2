# YouTrack backlog — CrowdFans (espelho local)

**Data:** 2026-09-09  
**Fonte:** YouTrack projeto `CF` via API (`crowd-fans.youtrack.cloud`).  
**Objetivo:** espelho local para reduzir visitas ao YouTrack.  
**Cache bruto:** `docs/_youtrack_cache.json` (gitignored).  
**Plano de fechamento:** implementar gaps Flutter → PR/`main` → **só no final** assign Gustavo + Stage Done no YouTrack (Meet/Live/Horus/backend **não** fechar como feito).

### Status de implementação (atualizado nesta sessão)

| Lote | Tickets | Estado |
|---|---|---|
| Superfã resto | CF-67 ✅ PR [#23](https://github.com/crowdfans/mobile_v2/pull/23); CF-103 | CF-67 merged; **CF-103 skip** (sem mocks locais) |
| Superfã polish | CF-106, CF-107 | Feito no Flutter — PRs #30 (cartas) / #32 (perfil, TBD) |
| Artista core | CF-110 ✅ [#24](https://github.com/crowdfans/mobile_v2/pull/24); CF-111 ✅ [#25](https://github.com/crowdfans/mobile_v2/pull/25); CF-113 ✅ [#27](https://github.com/crowdfans/mobile_v2/pull/27) | Merged |
| Artista tools | CF-114/115 ✅ [#26](https://github.com/crowdfans/mobile_v2/pull/26); CF-116 [#28](https://github.com/crowdfans/mobile_v2/pull/28); CF-117 [#29](https://github.com/crowdfans/mobile_v2/pull/29); CF-118 [#30](https://github.com/crowdfans/mobile_v2/pull/30); CF-119 [#31](https://github.com/crowdfans/mobile_v2/pull/31) | Merged (gaps API anotados) |
| Superfã polish | CF-106, CF-107 | Feito no Flutter — #30 cartas; #32 perfil |
| Épicas | CF-66, CF-109 | Filhos UI majormente shipped; fechar YT no lote final |
| QA Patrol/FTL | CF-122–CF-130, CF-125 | Depois das telas; FTL depende de infra |
| Bags | CF-82, CF-83 | Triagem após polish |
| Meet/Live/Backend/Horus | §3–§5 | **Não implementar / não Done falso** |

## Legenda — Status local

| Status local | Significado |
|---|---|
| Pendente | Aberto no YouTrack; ainda não feito no Flutter |
| Em progresso | Stage Develop/Review no YouTrack ou WIP no `mobile_v2` |
| Feito no Flutter | Já entregue nesta migração (ticket Done ou equivalente em `TODO.md`) |
| Fora de escopo | Horus / produto adiado / não somos donos |
| Backend/Meet | Backend-only, Live, Meet/CometChat — fora da paridade Flutter por enquanto |

**Totais (consulta 2026-09-09):** 45 unresolved · 83 resolved (amostra `$top=100`) · 128 issues `project: CF` (`$top=200`).

---

## 1. Flutter Superfã / Mobile (acionável em `mobile_v2`)

Tickets Mobile com impacto direto no app Flutter. Horus e Meet/Live ⛔ ficam nas seções 3–5.

### 1.1 Superfã + Artista (UI / mocks)

| ID | Summary | Stage | Priority | Assignee | Escopo Flutter | Notas / mocks |
|---|---|---|---|---|---|---|
| CF-103 | [Superfã] Onboarding — slides Superfã/Artista iguais ao mock | Backlog | Major | — | Onboarding slides | **Skip (2026-09-09):** sem prints em `Downloads/Screens` nem anexos YouTrack; Drive da issue não está dumpado. Flutter já tem `PresentationScreen` (paridade Expo). Não inventar layout. |
| CF-66 | [Épica] Superfã — alinhar app ao PDF Telas App | Backlog | Major | — | Épica UI Superfã | Épica Superfã. Mocks PDF+PNG anexos. Filhos Done na §2; restam CF-67/103/106/107 (+ bugs 82/83). |
| CF-67 | [Superfã] Home — feed só artistas, tipos de post e exclusivo | Backlog | Major | — | Home feed Superfã | **Feito no Flutter** — PRs #2/#4/#23 em `main` (tipos/exclusivo/FAB/anéis). |
| CF-106 | [Superfã] Cartas — compose e galeria iguais ao mock | Backlog | Normal | — | Cartas / Fan Letters | **Feito no Flutter** — PR #30 (`CF-106` commit em `main`): compose Stories-style + galeria + stickers/fundos. |
| CF-107 | [Superfã] Perfil público do fã — header, Fan Score e artistas iguais ao mock | Backlog | Normal | — | Perfil público fã | **Feito no Flutter** — header/Cartas/artistas/FanScore vs mock Superfã (PR a mergear). |
| CF-109 | [Épica] Artista — alinhar app aos mocks do Drive | Backlog | Major | — | Épica UI Artista | Épica Artista. Fonte `Downloads/Screens/Artista`. Expo tem settings; Flutter base — falta paridade mock. |
| CF-110 | [Artista] Menu + — Live, Meet & Greet, Post Home e Post Fã Clube | Backlog | Major | — | Menu + Artista | Menu + artista (4 itens). Gap: Live/Meet/Post Home/Post Fã Clube vs menu superfã. |
| CF-111 | [Artista] Feed Home — posts do artista, exclusivo e stories | Backlog | Major | — | Feed Home Artista | Feed Home artista + stories. Gap posts do artista/exclusivo/stories vs mock. |
| CF-113 | [Artista] Meu perfil — cover, Editar Perfil, tabs Feed/Sobre/Exclusivo/Fã Clube/Cartas | Backlog | Major | — | Meu perfil Artista | Meu perfil artista (cover, tabs). Gap tabs Feed/Sobre/Exclusivo/Fã Clube/Cartas. |
| CF-114 | [Artista] Configurações — hub com ferramentas Insights, Público e Fã Clube | Backlog | Major | — | Config hub Artista | Hub Configurações artista. Telas `Artist*Settings` existem — gap hub Insights/Público/Fã Clube. |
| CF-115 | [Artista] Insights — períodos, abas de produto e gráficos | Backlog | Major | — | Insights Artista | Insights. `ArtistInsightsSettings` — gap períodos/abas/gráficos vs print. |
| CF-116 | [Artista] Público — demografia, FanScore, cidades e regiões | Backlog | Normal | — | Público Artista | Público. `ArtistAudienceSettings` — gap FanScore/cidades/regiões vs mock. |
| CF-117 | [Artista] Gerenciar Fã Clube — moderadores, pedidos e busca | Backlog | Normal | — | Gerenciar Fã Clube | Gerenciar Fã Clube. Gap moderadores/pedidos/busca vs mock. |
| CF-118 | [Artista] Jam Coins — saldo para usar, resgate e origem dos ganhos | Backlog | Normal | — | Jam Coins Artista | Jam Coins artista. wallet+earnings no Flutter — gap cards do mock artista. |
| CF-119 | [Artista] Telas compartilhadas — comentários, search, notificações, clubes, cartas | Backlog | Normal | — | Pass visual compartilhado | Pass visual contexto artista (comments/search/notifs/clubes/cartas). |

### 1.2 QA — Patrol / Firebase Test Lab

| ID | Summary | Stage | Priority | Assignee | Escopo Flutter | Notas / mocks |
|---|---|---|---|---|---|---|
| CF-122 | [Épica] Mobile — Patrol + Firebase Test Lab | Backlog | Major | — | QA E2E (épica) | Épica Patrol + Test Lab. Hoje só `test/widget_test.dart`. |
| CF-123 | [Mobile] Patrol — setup nativo Android/iOS e smoke local | Backlog | Major | — | QA setup Patrol | Setup Patrol nativo Android/iOS + smoke local. |
| CF-124 | [Mobile] Patrol — suíte smoke Superfã (onboarding e login) | Backlog | Normal | — | QA smoke Superfã | Smoke Superfã onboarding/login (deslogado). |
| CF-126 | [Mobile] Firebase Test Lab — Android (Patrol instrumentation) | Backlog | Major | — | QA FTL Android | Firebase Test Lab Android (Patrol instrumentation). |
| CF-127 | [Mobile] Firebase Test Lab — iOS (Patrol XCTest) | Backlog | Normal | — | QA FTL iOS | Firebase Test Lab iOS (Patrol XCTest; signing pendente). |
| CF-128 | [Mobile] Patrol — fluxo ponta a ponta: artista posta e superfã comenta | Backlog | Major | — | QA E2E post/comentário | E2E artista posta + superfã comenta. |
| CF-129 | [Mobile] Patrol — fluxo Superfã: voto, fã clube e logout | Backlog | Normal | — | QA E2E superfã | E2E superfã voto / fã clube / logout. |
| CF-130 | [Mobile] Patrol — fluxo Artista: editar e apagar o próprio post | Backlog | Normal | — | QA E2E artista post | E2E artista editar/apagar post. |

### 1.3 Bags genéricos (triagem)

| ID | Summary | Stage | Priority | Assignee | Escopo Flutter | Notas / mocks |
|---|---|---|---|---|---|---|
| CF-82 | Correção de Bugs | Backlog | Normal | — | Bugs gerais | Bug bag genérico (preview EAS) — triagem. |
| CF-83 | Correção de Visual | Backlog | Normal | — | Visual gerais | Visual bag genérico — triagem. |

**IDs acionáveis Mobile/Flutter:** CF-103, CF-66, CF-67, CF-106, CF-107, CF-109, CF-110, CF-111, CF-113, CF-114, CF-115, CF-116, CF-117, CF-118, CF-119, CF-122, CF-123, CF-124, CF-126, CF-127, CF-128, CF-129, CF-130, CF-82, CF-83  
**Contagem:** 25

---

## 2. Já feitos nesta migração

Tickets Mobile/Superfã/Artista recentemente **Done** relevantes à migração Expo→Flutter.

| ID | Summary | Stage | Priority | Notas |
|---|---|---|---|---|
| CF-104 | [Superfã] Login — credenciais iguais ao mock | Done | Major | Login Superfã — Feito no Flutter |
| CF-105 | [Superfã] Cadastro — fluxo telefone até sucesso igual ao mock | Done | Major | Cadastro telefone→sucesso — Feito no Flutter |
| CF-68 | [Superfã] Home — notificações, menu lateral, 3 pontinhos e share | Done | Normal | Home notifs/menu/share — Feito no Flutter |
| CF-69 | [Superfã] Comentários — ordenação, composer, GIF e replies aninhadas | Done | Major | Comentários — Feito no Flutter |
| CF-70 | [Superfã] Fã clubes — feed, layout Reddit, modo secreto e busca | Done | Major | Fã clubes feed — Feito no Flutter |
| CF-71 | [Superfã] Fã clube do artista — mods, regras, strike, expulsão, badges | Done | Normal | Fã clube do artista — Feito no Flutter |
| CF-72 | [Superfã] Pesquisar — rankings Top 500/100 e busca de artista | Done | Normal | Pesquisar rankings — Feito no Flutter |
| CF-73 | [Superfã] Meu perfil — contagens, filtros e atalhos | Done | Normal | Meu perfil superfã — Feito no Flutter |
| CF-74 | [Superfã] Perfil do artista — tabs, CTA seguir/membership, sobre e exclusivo | Done | Major | Perfil artista (visão superfã) — Feito no Flutter |
| CF-75 | [Superfã] Novo post — fã clube, secreto, mídia e mínimo para postar | Done | Major | Novo post — Feito no Flutter |
| CF-76 | [Superfã] Jam Coins — home, recarga e pagamento | Done | Normal | Jam Coins — Feito no Flutter |
| CF-77 | [Superfã] Configurações — memberships e FanScore | Done | Normal | Memberships + FanScore — Feito no Flutter |
| CF-81 | [Superfã] Componentes de post, abas e notificações iguais ao PDF | Done | Major | Componentes post/abas/notificações — Feito no Flutter |
| CF-108 | [Superfã] Configurações — conta, aparência, segurança e listas iguais ao mock | Done | Normal | Configurações — Feito no Flutter |
| CF-112 | [Artista] Novo post — Home com toggle Exclusivo e Fã Clube | Done | Major | Artista novo post — Feito no Flutter |
| CF-80 | [Mobile] Apontar tudo para prod (Firebase + API) | Done | Major | Prod Firebase+API — Feito |
| CF-94 | [Mobile/Backend] Upload de imagens no Spaces por pasta do usuário | Done | Major | Upload Spaces — Feito |
| CF-95 | [Mobile] CrowdFans Pro — RevenueCat SDK, paywall e Customer Center | Done | Major | CrowdFans Pro / RevenueCat — Feito |
| CF-54 | [Financial/Mobile] Compra de Jam Coins via RevenueCat (IAP + webhook) | Done | Major | Jam Coins RevenueCat IAP — Feito |
| CF-84 | [Superfã] Superfã Login - Artista/fã | Done | Normal | Done no YouTrack |
| CF-85 | [Superfã] Feed Home - Artistas que não sigo | Done | Normal | Done no YouTrack |
| CF-86 | [Superfã] Feed Home - Bottom Sheet Post Options Background | Done | Normal | Done no YouTrack |
| CF-87 | [Superfã] Feed Home - Perfil Artista | Done | Normal | Done no YouTrack |
| CF-88 | [Superfã] Feed Home - Bottom Sheet Post Share Background | Done | Normal | Done no YouTrack |
| CF-89 | [Superfã] Perfil Artista - Botão Seguir | Done | Normal | Done no YouTrack |
| CF-90 | [Superfã] Novo Post - Bottom Sheet | Done | Normal | Done no YouTrack |
| CF-91 | [Superfã] Fã Clube - Solicitação de entrada não existe | Done | Normal | Done no YouTrack |
| CF-92 | [Superfã] Fã Clube - Posts sumidos | Done | Normal | Done no YouTrack |

API/prod: sempre `https://crowdfans-server-prod-h9qb6.ondigitalocean.app` (nunca `crowdfans-app-dev*` / `crowdfans-app-prod`).

---

## 3. Meet / CometChat / Live (adiados)

Paridade Flutter **não** inclui Live/Meet por enquanto — copiar o buraco do Expo (`⛔`). Status local: **Backend/Meet**.

| ID | Summary | Stage | Priority | Serviço | Notas |
|---|---|---|---|---|---|
| CF-10 | [Mobile] UI checkout Jam Coins + chamada de vídeo 1:1 | Backlog | Major | Mobile | Checkout Jam Coins + Meet UI. Wallet parcial (CF-76 Done); Meet ⛔. |
| CF-120 | [Artista] ⛔ Live — criar acesso e estúdio (chat, destacadas, doações) | Backlog | Minor | Mobile | ⛔ Live — adiado (buraco Expo). |
| CF-121 | [Artista] ⛔ Meet & Greet — criar, fila, atender e encerrar chamada | Backlog | Minor | Mobile | ⛔ Meet & Greet — adiado (buraco Expo). |
| CF-30 | [Mobile/Backend] Meet 1:1 — SDK CometChat + telas fila/chamada | Develop | Major | Mobile | CometChat SDK + fila/chamada — deferred. |
| CF-97 | [Mobile] Meet 1:1 — timer de 1 minuto na UI | Backlog | Major | Mobile | Timer 1 min Meet UI — deferred. |
| CF-99 | [Mobile] Meet 1:1 — consentimento e aviso de gravação judicial | Backlog | Major | Mobile | Consentimento gravação Meet — deferred. |

Relacionados no backend (também §4): CF-9, CF-21, CF-31, CF-96, CF-98.

---

## 4. Backend-only / Infra / Financial / Produto adiado

| ID | Summary | Stage | Priority | Serviço | Status local |
|---|---|---|---|---|---|
| CF-14 | [Épica] Gaps AS-IS e produto restante (TODO implementação) | Backlog | Major | Backend | Backend/Meet |
| CF-21 | [Backend/Mobile] Live Streaming (diretório + studio) | Backlog | Normal | Backend | Backend/Meet |
| CF-31 | [Backend] VideoCall service — tokens, timer, débito, NATS | Develop | Major | Backend | Backend/Meet |
| CF-51 | [Produto] Verificação de artista via Spotify (adiado) | Backlog | Normal | Backend | Fora de escopo |
| CF-52 | [Produto] Consentimento parental (artista menor) — adiado | Backlog | Normal | Backend | Fora de escopo |
| CF-9 | [Backend] Vídeo 1:1 CometChat — sala, timer 60s e dedução Jam Coins | Develop | Major | Backend | Backend/Meet |
| CF-96 | [Backend] Meet 1:1 — limite rígido de 1 minuto | Backlog | Major | Backend | Backend/Meet |
| CF-98 | [Backend] Meet 1:1 — backup da chamada para fins judiciais | Backlog | Major | Backend | Backend/Meet |
| CF-1 | [Arquitetura ALVO] Monetização, mensageria e vídeo 1:1 | Backlog | Major | Infra | Backend/Meet |
| CF-125 | [Infra] Firebase Test Lab — API, billing e service account em crowdfans-prod | Backlog | Major | Infra | Backend/Meet |
| CF-4 | [Financial] Integração Pagar.me PIX (criar cobrança + webhook pago) | Backlog | Major | Financial | Backend/Meet |

---

## 5. Horus (fora de escopo)

Horus / `horus-admin` **não** é responsabilidade atual. Listados só para inventário.

| ID | Summary | Stage | Priority | Assignee | Status local |
|---|---|---|---|---|---|
| CF-100 | Horus - Users - Superfans | Develop | Major | wesley.furlanetto | Fora de escopo |
| CF-101 | Horus - Users - Artist  | Develop | Major | wesley.furlanetto | Fora de escopo |
| CF-102 | Horus - layout e formatação de texto  | Review | Major | wesley.furlanetto | Fora de escopo |

CF-51 menciona fila Horus na descrição, mas é produto Spotify adiado — §4.

---

## 6. Checklist de implementação (prioridade sugerida)

Ordem sugerida para `mobile_v2` (UI Mobile acionável; QA depois das telas críticas).

1. ~~**[Major] CF-67**~~ — Feito no Flutter (PRs #2/#4/#23).
2. ~~**[Major] CF-103**~~ — **Skip:** sem mocks em `Downloads/Screens` / anexos YT; Drive não dumpado.
3. ~~**[Normal] CF-107** — Perfil público do fã vs mock.~~ Feito.
4. ~~**[Normal] CF-106** — Cartas compose/galeria vs mock.~~ Feito (#30).
5. **[Major] CF-109** (épica) → filhos Artista:
   - CF-110 Menu +
   - CF-111 Feed Home artista
   - CF-113 Meu perfil artista
   - CF-114 Config hub
   - CF-115 Insights / CF-116 Público / CF-117 Fã Clube / CF-118 Jam Coins
   - CF-119 Pass visual compartilhado (contexto artista)
6. **Triagem** CF-82 / CF-83.
7. **QA** CF-123 → CF-124 → CF-128/129/130 → CF-126/127 (épica CF-122; infra CF-125).
8. **Não puxar agora:** CF-120/121 Live/Meet ⛔, CF-30/97/99/10 Meet, Horus CF-100–102, backend CF-9/31/96/98/21/4/1/14.

### Expo vs Flutter (resumo rápido)

- Expo (`../mobile`) cobre o fluxo Superfã principal e settings de artista (insights/audience/fan-club/wallet).
- Flutter (`mobile_v2`) já tem a maior parte Superfã Done (§2); gaps abertos = **paridade visual com mocks** (restos CF-66 + CF-109 Artista) e **Patrol/FTL**.
- Live/Meet: buraco nos dois — não inventar UI.

---

*Gerado localmente em 2026-09-09. Token YouTrack não é armazenado neste arquivo.*
