const String lastRouteStorageKey = 'last_route';
const String defaultAuthenticatedRoute = '/home';

bool isRestorableRoute(String location) {
  if (location.isEmpty) return false;

  final uri = Uri.tryParse(location);
  if (uri == null) return false;

  final path = uri.path;
  if (path.isEmpty) return false;

  // Never persist transient/auth bootstrap pages.
  if (path == '/' || path == '/login' || path == '/onboarding') return false;

  // Booking confirmation relies on runtime extras, so reopening directly can fail.
  if (path == '/calendar/booking' || path == '/calendar/booking/confirmation') {
    return false;
  }

  // App pages safe to restore.
  return true;
}

String sanitizeRestorableRoute(String? rawLocation) {
  if (rawLocation == null || rawLocation.trim().isEmpty) {
    return defaultAuthenticatedRoute;
  }
  final location = rawLocation.trim();
  return isRestorableRoute(location) ? location : defaultAuthenticatedRoute;
}
