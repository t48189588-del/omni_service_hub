# OmniService Hub

**OmniService Hub** is a multi-tenant SaaS application designed for service professionals. Built using Flutter for a seamless cross-platform experience (Android, iOS, Web) and powered by Firebase for secure, real-time data management.

## 🚀 Key Features

-   **Multi-Tenancy Architecture**: Strict data isolation using a "Shared Collection with Silo Sub-collections" model. All tenant data is securely partitioned at the database level.
-   **Strict Security**: Firestore Security Rules ensure users only access the data associated with their specific `tenantId`.
-   **Global Reach (i18n)**: Out-of-the-box support for multiple languages:
    -   English (Default)
    -   Spanish
    -   Japanese
    -   Simplified Chinese (zh-Hans)
-   **State Management**: Centralized `TenantProvider` managing authentication and active business context.

---

## 🛠 Tech Stack

-   **Frontend**: [Flutter](https://flutter.dev/) (SDK ^3.11.3)
-   **Backend**: [Firebase](https://firebase.google.com/) (Auth, Firestore, Hosting)
-   **State Management**: [Provider](https://pub.dev/packages/provider)

---

## 🏗 Getting Started

### Prerequisites

-   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
-   [Firebase CLI](https://firebase.google.com/docs/cli) installed and logged in (`firebase login`).
-   [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup?platform=ios#installing-the-cli) installed and available in your `PATH`.

### Local Setup

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/t48189588-del/omni_service_hub.git
    cd omni_service_hub
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Configure Firebase (Important)**:
    The project currently uses **placeholder** credentials. To connect it to your own Firebase project:
    ```bash
    flutterfire configure
    ```
    *This will regenerate `lib/firebase_options.dart` with your unique project keys.*

4.  **Run the app**:
    ```bash
    flutter run
    ```

---

## 🔐 Security Rules & Multi-Tenancy

The data structure follows this strictly root-level isolation:
-   `/users/{userId}`: Contains `tenantId` mapping.
-   `/tenants/{tenantId}`: Business-specific metadata and configurations.
-   `/tenants/{tenantId}/customers/...`: Siloed customer lists.
-   `/tenants/{tenantId}/services/...`: Siloed service catalogs.

Security rules are located in `firestore.rules`. Ensure you deploy these to your Firebase project:
```bash
firebase deploy --only firestore:rules
```

---

## 🌍 Localization (i18n)

Localization files are stored in `lib/l10n/` as `.arb` (Application Resource Bundle) files.

To update or add translations:
1.  Edit the respective `app_XX.arb` file.
2.  Run `flutter gen-l10n` to regenerate the localization classes.

---

## 📦 Project Structure

```text
lib/
 ├── l10n/              # Language translations (.arb)
 ├── providers/         # Global state management (TenantProvider)
 ├── firebase_options.dart # Firebase configuration (run flutterfire configure to update)
 └── main.dart          # App entry point & initialization
```

Developed as part of the **OmniService Hub** ecosystem.
