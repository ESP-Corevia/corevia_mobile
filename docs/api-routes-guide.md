# API Routes Guide

How to add a new API route and call it from Flutter using `ApiService`.

---

## 1. Create a Routes File

Create a file in `lib/networking/routes/` for your feature.

```dart
// lib/networking/routes/appointment_routes.dart

class AppointmentRoutes {
  static const String base = "/api/appointments";

  static String list()            => base;
  static String byId(String id)   => "$base/$id";
  static String create()          => base;
  static String update(String id) => "$base/$id";
  static String cancel(String id) => "$base/$id/cancel";
}
```

---

## 2. Call the Route

Import `ApiService` and your routes file, then call the appropriate method.

### Public route (no auth required)

```dart
import 'package:corevia_mobile/networking/api_service.dart';
import 'package:corevia_mobile/networking/routes/appointment_routes.dart';

// GET
final data = await ApiService.get(AppointmentRoutes.list());

// POST
final res = await ApiService.post(AppointmentRoutes.create(), {
  'doctorId': '123',
  'date': '2026-03-15',
});
```

### Protected route (requires login)

Use the `auth` variants — the Bearer token is injected automatically.

```dart
// GET  →  Authorization: Bearer <token>
final data = await ApiService.authGet(AppointmentRoutes.list());

// GET with query params
final data = await ApiService.authGet(
  AppointmentRoutes.list(),
  params: {'status': 'pending', 'page': '1'},
);

// POST
final res = await ApiService.authPost(AppointmentRoutes.create(), {
  'doctorId': '123',
  'date': '2026-03-15',
});

// PUT (full update)
await ApiService.authPut(AppointmentRoutes.update('abc'), {
  'date': '2026-03-20',
});

// PATCH (partial update)
await ApiService.authPatch(AppointmentRoutes.update('abc'), {
  'status': 'confirmed',
});

// DELETE
await ApiService.authDelete(AppointmentRoutes.cancel('abc'));
```

---

## 3. Use in a Widget / Screen

```dart
class _AppointmentsState extends State<AppointmentsScreen> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.authGet(AppointmentRoutes.list());
      if (mounted) {
        setState(() {
          _appointments = res['appointments'] as List;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
```

---

## Available Methods

| Method | Auth | Usage |
|--------|------|-------|
| `ApiService.get(path)` | No | Public GET |
| `ApiService.post(path, body)` | No | Public POST |
| `ApiService.put(path, body)` | No | Public PUT |
| `ApiService.patch(path, body)` | No | Public PATCH |
| `ApiService.delete(path)` | No | Public DELETE |
| `ApiService.authGet(path)` | Yes | Protected GET |
| `ApiService.authPost(path, body)` | Yes | Protected POST |
| `ApiService.authPut(path, body)` | Yes | Protected PUT |
| `ApiService.authPatch(path, body)` | Yes | Protected PATCH |
| `ApiService.authDelete(path)` | Yes | Protected DELETE |

---

## Existing Routes

| File | Routes |
|------|--------|
| `routes/auth_routes.dart` | `login()`, `register()`, `logout()`, `getSession()` |
| `routes/user_routes.dart` | `me()` |

---

## Base URL

Configured via `.env`:

```
API_BASE_URL=http://10.0.2.2:3000   # Android emulator → localhost
API_BASE_URL=http://localhost:3000   # iOS simulator / web
```
