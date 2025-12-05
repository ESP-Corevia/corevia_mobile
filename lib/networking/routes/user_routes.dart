class UserRoutes {
  static const String base = "/api/user";

  static String get(String userId) => "$base/get/$userId";
  static String update(String userId) => "$base/update/$userId";
  static String delete(String userId) => "$base/delete/$userId";
}