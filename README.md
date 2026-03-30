# OmniService Hub

**OmniService Hub** is a multi-tenant SaaS application designed for service professionals. Built using Flutter for a seamless cross-platform experience (Android, iOS, Web) and powered by Firebase for secure, real-time data management.

## 🚀 Key Features

-   **Advanced Booking Engine**: 
    -   Integrated **2-step selection** (Date & Time) with native Flutter pickers.
    -   **Conflict Prevention**: Real-time availability checks before booking.
    -   **Automatic Buffer**: A mandatory **10-minute break** is added between appointments for business preparation.
-   **Owner Management Dashboard**: 
    -   **Service Lifecycle**: Full CRUD (Create, Read, Update, Delete) for services including custom durations and prices.
    -   **Appointment Workflow**: Dedicated interface for owners to **Approve**, **Cancel**, or view pending bookings.
-   **Global Reach (i18n)**: Standardized localization audit with full support for:
    -   English, Spanish, Japanese, and Simplified Chinese.
    -   **Reactive UI**: Dashboard, currency (0 decimals for JPY, 2 for USD), and date formats update instantly.
-   **Strict Multi-Tenancy**: Data isolation using siloed sub-collections under each `tenantId`.

---

## 🛠 Tech Stack

-   **Frontend**: [Flutter](https://flutter.dev/) (SDK ^3.11.3)
-   **Backend**: [Firebase](https://firebase.google.com/) (Auth, Firestore)
-   **State Management**: [Provider](https://pub.dev/packages/provider)

---

## 🏗 Getting Started

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

3.  **Generate Localizations**:
    ```bash
    flutter gen-l10n
    ```

4.  **Run the app**:
    ```bash
    flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
    ```

---

## 🔐 Security Rules

The data structure follows strict root-level isolation:
-   `/users/{userId}`: Contains `tenantId` mapping.
-   `/tenants/{tenantId}/services/...`: Publicly viewable catalog.
-   `/tenants/{tenantId}/appointments/...`: Managed by owners, created by customers.

Security rules in `firestore.rules` enforce these permissions.

---

## 📦 Project Structure

```text
lib/
 ├── l10n/              # Language translations (.arb)
 ├── models/            # Data models (Service, Appointment)
 ├── providers/         # Global state (TenantProvider, LocaleProvider)
 ├── screens/           # UI Screens (Login, Dashboard, Services, Appointments, Booking)
 ├── services/          # Firebase logic (DatabaseService)
 ├── utils/             # Formatters (RegionalFormatter)
 └── main.dart          # App entry point & routing
```

Developed as part of the **OmniService Hub** ecosystem.
