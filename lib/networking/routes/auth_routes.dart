class AuthRoutes {
  static const String base = "/api/auth";

  static String login() => "$base/sign-in/email";
  static String register() => "$base/sign-up/email";
  static String logout() => "$base/sign-out";
}
