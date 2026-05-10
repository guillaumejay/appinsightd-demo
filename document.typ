#import "@preview/touying:0.5.3": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  footer: [Supervision Application-X — Utilisateurs impactés — 04 au 07/05/2026],
)

#set text(lang: "fr", font: "Inter", size: 18pt)
#show heading: set text(weight: "semibold")

// ─────────────────────────────────────────────────────────
// Titre
// ─────────────────────────────────────────────────────────
#title-slide[
  = Utilisateurs impactés
  == Semaine du 4 au 7 mai 2026

  #v(1em)
  #text(size: 18pt)[
    Qui souffre, de quoi, depuis quand — et comment on remédie. \
    Source : Application Insights (`Application-X-AppInsight`)
  ]

  #v(2em)
  #text(size: 14pt, fill: gray)[Généré le 7 mai 2026]
]

// ─────────────────────────────────────────────────────────
// En une diapo
// ─────────────────────────────────────────────────────────
== En une diapo

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2em,
  row-gutter: 1em,
  [
    *✅ Le constat global est bon*
    - 32 utilisateurs actifs sur la période
    - 9 sans aucune erreur
    - 15 avec uniquement du bruit navigateur
    - Aucune panne service générale
  ],
  [
    *⚠ Mais 3 utilisateurs en souffrance réelle*
    - 1 totalement bloquée (CHU-Dijon, réseau)
    - 2 fonction "Lieux ROR" cassée ce matin
    - Panne ROR API SSL démarrée à 09:55 UTC
    - Concerne *tous* les ajouts/recherches de lieux
  ],
)

#v(1em)
#align(center)[
  #box(fill: rgb("#fee2e2"), inset: 12pt, radius: 6pt)[
    *Urgent.* La panne ROR de ce matin n'est pas un cas isolé : tout
    le monde qui clique "Ajouter un lieu" voit un 500. Diagnostic et
    correctif rapide à prioriser.
  ]
]

// ─────────────────────────────────────────────────────────
// Carte d'impact
// ─────────────────────────────────────────────────────────
== Carte d'impact

#let kpi(big, label, color: black) = box(
  fill: rgb("#f1f5f9"),
  inset: 14pt,
  radius: 8pt,
  width: 100%,
  [
    #text(size: 30pt, weight: "bold", fill: color)[#big]
    #v(0.3em)
    #text(size: 14pt, fill: gray)[#label]
  ],
)

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 1em,
  align: center + horizon,
  kpi([*32*], [utilisateurs actifs]),
  kpi([*8*], [≥ 1 échec API], color: red),
  kpi([*15*], [bruit nav. uniquement]),
  kpi([*9*], [aucune erreur], color: green),
)

#v(1em)
*Lecture.* La majorité des utilisateurs n'a rien vu. L'enjeu est
*concentré* sur 3 personnes — ce qui rend l'action rapide possible
si on les contacte directement.

// ─────────────────────────────────────────────────────────
// Tableau utilisateurs impactés
// ─────────────────────────────────────────────────────────
== Utilisateurs impactés — détail

#[
#set text(size: 15pt)
#table(
  columns: (1.6fr, auto, auto, auto, auto, 1.6fr),
  align: (left, right, right, right, center, left),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } else { none },
  table.header[*Utilisateur*][*Pages*][*Échecs*][*Taux*][*Sév.*][*Cause*],
  [`utilisateur01@organisation-a.exemple`], [10], [175], [100 %], [🔴🔴🔴], [Réseau local / extension nav.],
  [`utilisateur02@organisation-b.exemple`], [227], [13], [2 %], [🔴🔴], [Création Lieu — ROR SSL KO],
  [`utilisateur03@organisation-c.exemple`], [41], [8], [7 %], [🔴🔴], [Recherche Lieu — ROR SSL KO],
  [`utilisateur04@organisation-d.exemple`], [115], [3], [1 %], [🟠], [Export PDF rapport PBI],
  [`Utilisateur02@organisation-b.exemple`], [45], [1], [1 %], [🟠], [Reset MdP — Graph 403],
  [`utilisateur05@organisation-c.exemple`], [131], [2], [1 %], [🟡], [Autocomplete Lieu ponctuel],
  [`utilisateur06@organisation-c.exemple`], [43], [1], [1 %], [🟡], [Autocomplete commune],
)
]

// ─────────────────────────────────────────────────────────
// Incident 1 — ROR
// ─────────────────────────────────────────────────────────
== Incident #1 — Panne ROR API (SSL)

*Symptôme.* Depuis 09:55 UTC ce matin, *tous* les `POST /Lieux` et
`GET /Lieux/Ror` répondent en 500. 2 utilisateurs vus, mais la panne
est *globale*.

*Cause technique.*
```
System.Exception: Erreur OAuth2 :
  The SSL connection could not be established
  at ApplicationX.Business.DomaineLieu.RorApi.GetOAuth2TokenAsync:222
```
Endpoint configuré : `bas-auth-api.qualif.ror.esante.gouv.fr` — environnement *QUALIF*.

#v(0.5em)
*Conséquence métier.* La fonction "ajouter un lieu" est cassée pour
CH Colmar et CHOR (les deux sites qui l'utilisent le plus). CH Beaune
n'utilise pas la fonction → invisible pour eux.

// ─────────────────────────────────────────────────────────
// Remédiation Incident 1
// ─────────────────────────────────────────────────────────
== Remédiation #1 — ROR API

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 1em,
  [
    #box(fill: rgb("#fee2e2"), inset: 10pt, radius: 6pt, width: 100%)[
      *Court terme — minutes*
      - `curl -v` depuis l'App Service vers l'endpoint ROR
      - Vérifier `appsettings.json` (QUALIF vs PROD ?)
      - Vérifier statut esante.gouv.fr (cert renouvelé ?)
      - Bascule PROD si confirmé
    ]
  ],
  [
    #box(fill: rgb("#fef3c7"), inset: 10pt, radius: 6pt, width: 100%)[
      *Moyen terme — aujourd'hui*
      - Catch de l'exception côté API
      - Remontée d'un message UX :
        "Service ROR temporairement indisponible"
      - Plus de 500 affiché à l'utilisateur
    ]
  ],
  [
    #box(fill: rgb("#dcfce7"), inset: 10pt, radius: 6pt, width: 100%)[
      *Long terme — cette semaine*
      - Circuit breaker Polly
        (évite 5 retries × 1 s)
      - Cache local des derniers lieux ROR
      - Alerte AppInsights dédiée si \
         taux échec ROR > 10 %
    ]
  ],
)

#v(0.5em)
#text(size: 14pt)[*Effort cumulé* : 30 min – 2 h diagnostic + 20 min UX + 1 h résilience.]


// ─────────────────────────────────────────────────────────
// Incident 2 — CHU Dijon
// ─────────────────────────────────────────────────────────
== Incident #2 — `utilisateur01@organisation-a.exemple`

*Symptôme.* 175 requêtes échouent en 1 minute le 04/05 à 07:36 UTC,
toutes en code `0` ("Failed to fetch").

*Endpoints touchés.* Tous les appels du démarrage de l'app :
`/Users/MyData`, `/Patients/LastModified`, `/utility/equipesUtilisateur`...
*Aucun n'a atteint le serveur.*

#v(0.5em)
*Diagnostic.* Scénario type *UAP-001* (DEX-monitoring §2.2) — extension
navigateur (uBlock, AV avec inspection TLS) ou proxy CHU-Dijon qui
bloque `applicationx-back-prod.azurewebsites.net`.

#v(0.5em)
*Spécificité.* Aucun autre user du CHU-Dijon dans les logs → problème
*local au poste*. Pas un défaut applicatif.

// ─────────────────────────────────────────────────────────
// Remédiation Incident 2
// ─────────────────────────────────────────────────────────
== Remédiation #2 — Accompagnement utilisatrice

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  [
    #box(fill: rgb("#fef3c7"), inset: 12pt, radius: 6pt, width: 100%)[
      *Procédure de déblocage (5 min + suivi)*
      + Envoyer le runbook DEX-monitoring §2.2
      + Tester en navigation privée \
        (Ctrl+Shift+N Edge)
      + Tester sur partage 4G mobile
      + Si OK en privé → identifier l'extension
      + Si OK en 4G → escalader IT CHU-Dijon \
        (proxy / antivirus avec inspection TLS)
    ]
  ],
  [
    #box(fill: rgb("#dcfce7"), inset: 12pt, radius: 6pt, width: 100%)[
      *Prévention (cette semaine)*
      - Bandeau de diagnostic réseau côté login
        si `Failed to fetch` détecté ≥ 3 fois
      - Lien direct vers le runbook
      - Auto-collecte UA + extensions visibles
        dans la télémétrie
      - Alerte AppInsights "burst > 50 échecs
        en 5 min pour 1 user"
    ]
  ],
)

// ─────────────────────────────────────────────────────────
// Incidents secondaires
// ─────────────────────────────────────────────────────────
== Incidents secondaires

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 1em,
  [
    #box(fill: rgb("#fef3c7"), inset: 10pt, radius: 6pt, width: 100%)[
      #text(size: 14pt)[
      *🟠 Export PDF PBI* \
      `utilisateur04@organisation-d`
      - 3 échecs sur `ExportPDF`
      - Cause : capacité PBI `Resuming` + secret KeyVault `lea-pbi-client-export-id` 404
      - *Fix* : aligner secret (~10 min), pré-réveil CRON (~1 h)
      ]
    ]
  ],
  [
    #box(fill: rgb("#fef3c7"), inset: 10pt, radius: 6pt, width: 100%)[
      #text(size: 14pt)[
      *🟠 Reset mot de passe* \
      `Utilisateur02@organisation-b`
      - `require-password-change` → 400 (Graph 403)
      - Cause : permission Graph `User.ReadWrite.All` manquante
      - *Fix* : ajouter permission app registration (~15 min)
      ]
    ]
  ],
  [
    #box(fill: rgb("#fef9c3"), inset: 10pt, radius: 6pt, width: 100%)[
      #text(size: 14pt)[
      *🟡 Doublons utilisateurs* \
      claim casse variable
      - `utilisateur02` ≠ `Utilisateur02` dans agrégats
      - Pas bloquant, fausse stats
      - *Fix* : `email.ToLowerInvariant()` dans `App.razor` (~10 min)
      ]
    ]
  ],
)

// ─────────────────────────────────────────────────────────
// Distribution par établissement
// ─────────────────────────────────────────────────────────
== Distribution par établissement

#table(
  columns: (1.5fr, auto, auto, 1.5fr),
  align: (left, right, right, left),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } else { none },
  table.header[*Établissement*][*Actifs*][*Impactés*][*Sévérité dominante*],
  [CH Colmar], [9], [4], [🔴 ROR Lieux],
  [CHOR (Réunion)], [8], [2], [🔴 ROR Lieux + Graph],
  [CH Beaune], [5], [0], [🟢 RAS],
  [Santé Centre Alsace], [5], [1], [🟠 Export PDF],
  [CHU Dijon], [1], [1], [🔴 réseau local],
  [ApyCare (admin)], [1], [1], [🟢 dev],
)

#v(0.5em)
*Lecture.* CH Colmar et CHOR concentrent l'impact ROR : ce sont les
sites qui utilisent le plus la fonction "ajouter un lieu". CH Beaune
n'utilise probablement pas cette fonction — d'où 0 erreur.

// ─────────────────────────────────────────────────────────
// Stratégies transverses
// ─────────────────────────────────────────────────────────
== Stratégies de remédiation transverses

*🛡️ Résilience applicative*
- Circuit breaker Polly sur les dépendances externes (ROR, Graph, PBI)
- Fallback UX : message "service tiers indisponible" plutôt que 500 brut
- Cache local des données ROR récentes pour usage en mode dégradé

#v(0.7em)
*👁️ Qualité de monitoring*
- Filtrer le bruit `ResizeObserver` côté JS (`addTelemetryInitializer`) → -95 % d'exceptions
- Normaliser `user_AuthenticatedId` en lowercase → agrégats fiables
- Alerte burst dédiée : > 50 échecs en 5 min sur un user → page IT

#v(0.7em)
*🤝 Accompagnement utilisateur*
- Bandeau d'auto-diagnostic réseau côté login si fetch échoue
- Lien direct vers les runbooks DEX-monitoring depuis les écrans d'erreur
- Webhook Teams ANC-003 à recréer (alerting muet actuellement)

// ─────────────────────────────────────────────────────────
// Plan d'action
// ─────────────────────────────────────────────────────────
== Plan d'action priorisé

#[
#set text(size: 14pt)
#table(
  columns: (auto, 1.8fr, 1.4fr, auto, auto),
  align: (center, left, left, center, center),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } else { none },
  table.header[*\#*][*Action*][*Utilisateur(s) débloqué(s)*][*Effort*][*Délai*],
  [1], [Diagnostic ROR API SSL + bascule PROD], [`utilisateur02`, `utilisateur03` + sites Colmar/CHOR], [30 min – 2 h], [*immédiat*],
  [2], [Catch exception ROR → message UX propre], [tous les futurs cas], [20 min], [aujourd'hui],
  [3], [Contacter `utilisateur01` (runbook §2.2)], [1 user CHU-Dijon], [5 min + suivi], [aujourd'hui],
  [4], [Normaliser `user_AuthenticatedId` lowercase], [qualité monitoring], [10 min], [cette semaine],
  [5], [Filtre `ResizeObserver` côté JS], [qualité monitoring], [10 min], [cette semaine],
  [6], [Recréer webhook Teams ANC-003], [alerting], [30 min], [cette semaine],
  [7], [Permission Graph `User.ReadWrite.All`], [feature reset MdP], [15 min], [cette semaine],
  [8], [Capacité PBI : pré-réveil CRON], [export PDF stable], [1 h], [semaine prochaine],
)
]

#v(0.5em)
#align(center)[
  #text(size: 14pt)[*≈ 4 h de travail développeur + 1 message support* — couvre l'ensemble.]
]

// ─────────────────────────────────────────────────────────
// À retenir
// ─────────────────────────────────────────────────────────
== À retenir

1. *3 utilisateurs en souffrance réelle, pas plus* — l'impact est
   concentré et adressable rapidement.

2. *Une panne globale en cours* — ROR API SSL depuis 09:55 UTC,
   à diagnostiquer aujourd'hui. Pas une dégradation lente : ça vient
   de tomber.

3. *Trois axes de remédiation* — (a) débloquer les utilisateurs maintenant,
   (b) fiabiliser le code (catch, circuit breaker, fallback UX), (c) nettoyer
   le monitoring pour ne plus rater le prochain incident.

4. *Le code n'est pas seul en cause* — 1 cas réseau local, 1 dépendance
   tierce, 1 config (KeyVault), 1 permission (Graph). La discipline opératoire
   compte autant que la qualité du code.

#v(1em)
#align(center)[
  #text(size: 14pt, fill: gray)[
    *Prochaine revue* : après diagnostic ROR + contact CHU-Dijon.
  ]
]
