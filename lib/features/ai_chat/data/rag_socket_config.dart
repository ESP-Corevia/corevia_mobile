import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RagSocketConfig {
  static const _fallbackUrl =
      'http://corevia-ia-alb-1362532800.eu-west-1.elb.amazonaws.com';

  static String resolveUrl() {
    final defaultUrl = dotenv.env['RAG_SOCKET_URL']?.trim();
    final androidOverride = dotenv.env['RAG_SOCKET_URL_ANDROID']?.trim();

    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        androidOverride != null &&
        androidOverride.isNotEmpty) {
      return androidOverride;
    }

    if (defaultUrl != null && defaultUrl.isNotEmpty) return defaultUrl;
    return _fallbackUrl;
  }
}

