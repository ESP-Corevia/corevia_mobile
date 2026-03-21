class UserRoutes {
  static const String base = "/api";

  static String get(String userId) => "$base/get/$userId";
  static String signUp() => "$base/sign-up/email";
  static String update(String userId) => "$base/update/$userId";
  static String delete(String userId) => "$base/delete/$userId";
  static String me() => "$base/me";
}
