# Corevia Mobile — Contexte pour Copilot (MVP)

But : fournir un contexte technique et fonctionnel condensé, factuel et lisible par un LLM pour aider Copilot à faire des changements conformes au projet (MVP). Basé uniquement sur le code source présent.

---

## 1. Vision & objectif de Corevia

- Rôle inféré de l’application :
  - Application mobile Flutter orientée santé/assistance médicale combinant :
    - un écran d'accueil (`home`),
    - un module de chat conversationnel avec des "IA spécialisées",
    - journaux/conversations (historique),
    - calendrier,
    - onglet statistiques,
    - gestion de compte et onboarding/authentification.
  - Fournir un assistant conversationnel (IA) spécialisé par domaine médical et permettre aux utilisateurs d'entamer/consulter des conversations et d'obtenir des suggestions (ex : carte médecin).
- Problème principal résolu :
  - Mise à disposition d’un assistant médical conversationnel simplifié pour l’utilisateur (patients) et surfaces autour de la gestion personnelle (compte, calendrier, statistiques).
- Type d’utilisateurs ciblés (déductible) :
  - Patients/utilisateurs finaux cherchant conseil médical ou triage via un assistant conversationnel.
  - Utilisateurs ayant besoin d’un flux mobile simple (onboarding, login, navigation par onglets).

---

## 2. Portée du MVP

- Ce que le MVP fait actuellement (implémentation observée) :
  - Structure d’app Flutter avec navigation via `go_router`.
  - Onboarding contrôlé par `SharedPreferences` (flag `onboarding_done`).
  - Authentification basique : écran de login (UI + validations de formulaire) et écran d'inscription existant (UI, login simulé localement).
  - Écran Home (données retournées par `HomeRepositoryImpl` sous forme mock).
  - Chat conversationnel local/in-memory :
    - Conversation mock, IA spécialisées déclarées (liste statique `availableAIs`).
    - Simulation de réponse IA (`_generateMockResponse`, `_simulateAIReply`).
    - Contrôleur en mémoire `InMemoryChatController` (flutter_chat_core).
    - Sélection d'IA, historique local, messages système et "doctor card" factice.
  - API client minimal `ApiService` (méthodes `get` et `post`) avec base URL configurable via `.env`.
  - Usage de `provider` / `ChangeNotifier` pour au moins le `HomeProvider`.
  - Thème et composants UI réutilisables (ex : `AppTheme`, boutons, champs).
  - Bottom navigation (shell route) et routes pour `/home`, `/stats`, `/calendar`, `/account`, `/chat/ai/:id`.
- Ce que le MVP ne fait volontairement pas (ou n’implémente pas dans le code présent) :
  - Pas d’intégration serveur réelle pour le chat IA (réponses mockées localement).
  - Pas de persistance des conversations côté serveur ni synchronisation réseau (conversations mock in-memory).
  - Pas d'authentification sécurisée (login simule succès local, pas d'appel API d'auth).
  - Pas de gestion avancée d'erreurs côté UI pour appels API (peu d’usage du `ApiService` dans le code analysé).
  - Pas de logique métier complexe (ex : prise de RDV réelle, paiements, appels vocaux/vidéo).
- Hypothèses / simplifications visibles :
  - Données critiques sont mockées (HomeData, Chat responses, Conversations).
  - Onboarding contrôlé uniquement par un flag boolean dans `SharedPreferences`.
  - Base URL par défaut dans `ApiService` pointe vers `http://10.0.0.2:3000` mais `.env` est pris en charge.
  - Usage mixte de `provider` et `flutter_riverpod` comme dépendances — le code actuel utilise `provider` pour `HomeProvider` (riverpod présent mais non utilisé dans les fichiers inspectés).
  - Priorité sur UX/UI visuelle (animations, gradients, cartes) plutôt que backend.

---

## 3. Architecture technique

- Stack observée :
  - Flutter (Dart SDK >= 3.6.1).
  - Packages principaux : `provider`, `go_router`, `flutter_dotenv`, `flutter_secure_storage`, `shared_preferences`, `flutter_chat_core`/`flutter_chat_ui`, `http`, `intl`, `flutter_riverpod` (présent).
- Organisation des dossiers (extraits pertinents) :
  - `lib/`
    - `main.dart`
    - `core/`
      - `routes/` (`app_router.dart`)
      - `theme/`
    - `features/`
      - `home/` (data, domain, presentation)
      - `chat/` (presentation/...)
      - `account/`, `auth/`, `calendar/`, `onboarding/`, `statistics/`
    - `networking/` (`api_service.dart`)
    - `shared/` (theme)
    - `widgets/` (UI partagés : `navigation_bar`, etc.)
- Responsabilités des principales couches :
  - `routes` : configuration de navigation, shell route, redirections onboarding.
  - `presentation/screens` : UI, composants d'écran.
  - `presentation/providers` : state management (ChangeNotifier) pour features.
  - `data/repositories` : implémentations de l'accès aux données (actuellement mock).
  - `domain/entities` & `domain/repositories` : contrats et entités métier.
  - `networking/ApiService` : client HTTP centralisé.
  - `widgets/` : composants UI réutilisables.
- Patterns : séparation feature-driven (domain/data/presentation), repository pattern simple, `go_router` pour navigation.

---

## 4. Modèles et concepts clés

- Entités importantes (exemples) :
  - `HomeData` (title, description)
  - `AIDoctor` (id, name, specialty, primaryColor, secondaryColor) — défini dans `chat_screen_ai.dart`.
  - `Conversation` (id, aiDoctorId, title, lastMessageDate, preview) — défini dans `chat_screen_ai.dart`.
  - `chat_core.Message` (utilisé via `flutter_chat_core`).
- Relations notables :
  - `Conversation.aiDoctorId` référence `AIDoctor`.
  - `HomeProvider` dépend d’un `HomeRepository`.
  - `ApiService` est conçu pour être utilisé par des repositories.
- Terminologie spécifique :
  - "AI Doctor" / `AIDoctor` : agents IA spécialisés.
  - "Doctor Card" : message système contenant informations de praticien (factice).
  - "PRO" : badge UI.

---

## 5. Flux applicatifs majeurs

- Démarrage / Onboarding :
  - `main.dart` charge `.env`, lit `onboarding_done` depuis `SharedPreferences`, crée `onboardingNotifier` (ValueNotifier) et injecte les providers.
  - `GoRouter` redirige vers `/onboarding` tant que le flag est actif.
- Authentification (UI) :
  - `LoginScreen` valide le formulaire, simule le login, puis `context.go('/home')` sur succès.
  - Aucun appel d'API d'auth implémenté.
- Navigation générale : `GoRouter` + `ShellRoute` avec `BottomNavBar` persistant.
- Home : `HomeProvider.loadHomeData()` appelle `HomeRepository.getHomeData()` (mock).
- Chat IA :
  - Initialisation d'une IA (_currentAI) et `InMemoryChatController`.
  - Envoi d'un message → ajout local → simulation de réponse via `_generateMockResponse` → insertion de messages système et de "doctor card" si déclencheur.
  - Sélection d'IA via dialogue et historique local dans le drawer.
- Appels réseau : `ApiService` fournit `get`/`post` (timeout 30s, JSON), mais usage limité dans le code actuel.

---

## 6. Conventions et règles implicites

- Patterns : feature folders (data/domain/presentation), repository -> provider, UI-first.
- Nommage : `snake_case` fichiers, `CamelCase` classes, features par domaine.
- Choix techniques : mocks pour prototypage, `go_router` pour navigation, `flutter_chat_core` pour messages (contrôleur in-memory actuellement), `.env` pour base URL.

---

## 7. Contraintes pour Copilot

- Ne pas introduire de nouvelles architectures sans demande explicite. Respecter la séparation `features/{data,domain,presentation}`.
- Respecter les patterns existants (`provider`/ChangeNotifier) sauf demande de migration.
- Favoriser simplicité (logique MVP). Préserver mocks pour le prototypage si aucune intégration backend n'est demandée.
- Utiliser `ApiService` pour appels réseau réels via les repositories (plutôt que appeler `http` directement depuis les screens).
- Ne pas exposer de secrets ; si ajout de clés, utiliser `flutter_secure_storage` ou `.env` correctement.
- Conserver `onboardingNotifier` et la logique de redirection dans `app_router.dart`.

---

## Mapping exigences -> statut (rapide)

- Navigation onboarding/login/home : Done
- Chat IA local/in-memory : Done
- API client HTTP : Done (usage limité)
- Persistance conversations / backend : Deferred
- Auth réelle / token storage : Deferred

---

## Notes finales & recommandations rapides pour Copilot

- Respecter la structure feature-driven lors de modifications.
- Pour intégrer un backend : implémenter appels `ApiService` dans `data/repositories` et conserver les signatures `domain/repositories`.
- Toute migration (ex : provider → riverpod) doit être explicitement demandée.
- Toujours marquer comme "mock" toute donnée factice ajoutée afin d'éviter confusion lors des revues.

---

*Généré le 2026-01-08 à partir de l'analyse du code présent dans le dépôt.*

